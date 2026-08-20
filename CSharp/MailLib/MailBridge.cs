using MailKit;
using MailKit.Net.Imap;
using MailKit.Net.Smtp;
using MailKit.Search;
using MailKit.Security;
using MimeKit;
using Npgsql;
using NpgsqlTypes;

namespace Heisenberg.Mail;

/// <summary>
/// C#-Seite des Heisenberg-Mailmoduls.
///
/// Aufgerufen von Python (mail_caller.py) ueber die BridgePOC-Bruecke:
///     Delphi -> Python4Delphi -> pythonnet -> hier
///
/// Entwurfsprinzip: Ueber die Bruecke gehen nur Standardtypen (hier: eine
/// konto_id, Rueckgabe ein Statustext). Alle Daten laufen ueber die
/// Datenbank — Delphi liest sie dort mit TFDTable wieder aus. Deshalb
/// haelt diese Klasse ihre EIGENE Npgsql-Verbindung und ist damit autark.
///
/// Die komplette MIME-Verarbeitung passiert hier: MailKit dekodiert Base64,
/// Quoted-Printable, Charsets und zerlegt den Multipart-Baum. Was in der
/// Datenbank landet, ist fertig — die Delphi-Seite dekodiert nichts mehr.
/// </summary>
public static class MailBridge
{
    // Wird beim ersten Aufruf gesetzt. Bewusst hier und nicht in einer
    // Konfigurationsdatei: die Verbindungsdaten stehen im selben Postgres,
    // aus dem auch Heisenberg liest.
    private static string _connString =
        "Host=localhost;Port=5455;Database=TRTHeisenberg;Username=wwe123;Password=a4cX7pAp29WRK7XHkGHBzs4DIhjAM14Z";

    /// <summary>Erlaubt Delphi, die Verbindungszeichenfolge zu setzen
    /// (z.B. wenn die Datenbank spaeter auf dem VPS liegt).</summary>
    public static string SetConnection(string connString)
    {
        _connString = connString;
        return "OK";
    }

    // ------------------------------------------------------------------
    // Oeffentliche Einstiegspunkte (von mail_caller.py aufgerufen)
    // ------------------------------------------------------------------

    /// <summary>Gleicht die IMAP-Ordnerliste mit email_ordner ab.</summary>
    public static string FetchFolders(int kontoId)
    {
        try
        {
            var konto = LadeKonto(kontoId);
            using var client = VerbindeImap(konto);

            int neu = 0, aktualisiert = 0;
            foreach (var folder in client.GetFolders(client.PersonalNamespaces[0]))
            {
                if (SpeichereOrdner(kontoId, folder)) neu++; else aktualisiert++;
            }
            client.Disconnect(true);
            return $"OK: {neu} neue Ordner, {aktualisiert} aktualisiert";
        }
        catch (Exception ex)
        {
            return "FEHLER: " + ex.Message;
        }
    }

    /// <summary>Holt neue Nachrichten aller Ordner des Kontos.</summary>
    public static string FetchInbox(int kontoId)
    {
        try
        {
            var konto = LadeKonto(kontoId);
            using var client = VerbindeImap(konto);

            int gesamt = 0;
            int uebersprungen = 0;
            foreach (var folder in client.GetFolders(client.PersonalNamespaces[0]))
            {
                if (folder.Attributes.HasFlag(FolderAttributes.NonExistent) ||
                    folder.Attributes.HasFlag(FolderAttributes.NoSelect))
                    continue;

                var (neu, uesp) = HoleOrdner(kontoId, konto.MandantId, folder,
                                             konto.MaxAbruf);
                gesamt += neu;
                uebersprungen += uesp;
            }
            client.Disconnect(true);

            if (uebersprungen > 0)
                return $"OK: {gesamt} neue Nachricht(en). {uebersprungen} aeltere " +
                       $"wurden uebersprungen (Grenze {konto.MaxAbruf} je Ordner) " +
                       "und werden auch spaeter nicht nachgeholt.";
            return $"OK: {gesamt} neue Nachricht(en)";
        }
        catch (Exception ex)
        {
            return "FEHLER: " + ex.Message;
        }
    }

    /// <summary>Verschickt eine in email_nachricht vorbereitete Mail.</summary>
    public static string SendMail(int nachrichtId)
    {
        try
        {
            using var conn = Oeffne();
            using var cmd = new NpgsqlCommand(@"
                SELECT n.konto_id, n.von_adresse, n.an_adressen, n.cc_adressen,
                       n.betreff, n.body_text, n.body_html
                FROM email_nachricht n WHERE n.nachricht_id = @id", conn);
            cmd.Parameters.AddWithValue("id", nachrichtId);

            int kontoId;
            var msg = new MimeMessage();
            var builder = new BodyBuilder();

            using (var r = cmd.ExecuteReader())
            {
                if (!r.Read()) return "FEHLER: Nachricht nicht gefunden";
                kontoId = r.GetInt32(0);

                if (!r.IsDBNull(1)) msg.From.Add(MailboxAddress.Parse(r.GetString(1)));
                if (!r.IsDBNull(2)) FuegeEmpfaengerHinzu(msg.To, r.GetString(2));
                if (!r.IsDBNull(3)) FuegeEmpfaengerHinzu(msg.Cc, r.GetString(3));
                msg.Subject = r.IsDBNull(4) ? "" : r.GetString(4);
                if (!r.IsDBNull(5)) builder.TextBody = r.GetString(5);
                if (!r.IsDBNull(6)) builder.HtmlBody = r.GetString(6);
            }

            // Anhaenge: liegen als dokument-Saetze, verknuepft ueber email_anhang
            foreach (var (name, bytes, mime) in LadeAnhaenge(nachrichtId))
            {
                var ct = ContentType.Parse(string.IsNullOrWhiteSpace(mime)
                    ? "application/octet-stream" : mime);
                builder.Attachments.Add(name, bytes, ct);
            }

            msg.Body = builder.ToMessageBody();

            var konto = LadeKonto(kontoId);
            if (msg.From.Count == 0)
                msg.From.Add(new MailboxAddress(konto.AnzeigeName ?? konto.EmailAdresse,
                                                konto.EmailAdresse));

            using (var smtp = VerbindeSmtp(konto))
            {
                smtp.Send(msg);
                smtp.Disconnect(true);
            }

            SetzeVersandStatus(nachrichtId, "gesendet", null);
            return "OK: gesendet";
        }
        catch (Exception ex)
        {
            SetzeVersandStatus(nachrichtId, "fehler", ex.Message);
            return "FEHLER: " + ex.Message;
        }
    }

    /// <summary>Prueft IMAP und SMTP, ohne etwas zu veraendern.</summary>
    public static string TestConnection(int kontoId)
    {
        try
        {
            var konto = LadeKonto(kontoId);
            using (var imap = VerbindeImap(konto))
            {
                imap.Disconnect(true);
            }
            using (var smtp = VerbindeSmtp(konto))
            {
                smtp.Disconnect(true);
            }
            return "OK: IMAP und SMTP erreichbar";
        }
        catch (Exception ex)
        {
            return "FEHLER: " + ex.Message;
        }
    }

    // ------------------------------------------------------------------
    // Abruf eines einzelnen Ordners
    // ------------------------------------------------------------------

    private static (int Neu, int Uebersprungen) HoleOrdner(
        int kontoId, int mandantId, IMailFolder folder, int maxAbruf)
    {
        folder.Open(FolderAccess.ReadOnly);

        var (ordnerId, gespeicherteValidity, letzteUid) = LadeOrdnerZustand(kontoId, folder);

        // UIDVALIDITY-Wechsel bedeutet: der Server hat die UIDs neu vergeben.
        // Alles bisher Gemerkte ist damit wertlos, es muss neu abgeglichen werden.
        if (gespeicherteValidity.HasValue && gespeicherteValidity.Value != folder.UidValidity)
            letzteUid = 0;

        var query = letzteUid > 0
            ? SearchQuery.Uids(new UniqueIdRange(new UniqueId((uint)letzteUid + 1), UniqueId.MaxValue))
            : SearchQuery.All;

        var uids = folder.Search(query);

        // OBERGRENZE. Ohne sie zieht der Erstabruf eines gewachsenen Postfachs
        // ALLE Nachrichten samt Anhaengen — bei einem jahrzehntealten Konto
        // sind das Stunden und Gigabytes. Search liefert die UIDs aufsteigend,
        // die NEUESTEN stehen also am Ende. maxAbruf = 0 hebt die Grenze auf.
        //
        // WICHTIG, was das bedeutet: der Ordnerzustand kennt nur EINE
        // Wassermarke ("bis hierhin geholt"). Wird gekuerzt, entsteht eine
        // Luecke davor, die diese Marke nicht ausdruecken kann. Die
        // uebersprungenen aelteren Nachrichten werden deshalb NICHT
        // nachtraeglich geholt — spaetere Abrufe bringen nur neu
        // eingetroffene Post. Wer die Historie doch will, setzt max_abruf
        // hoch und den Ordnerzustand zurueck (letzte_uid = 0).
        int uebersprungen = 0;
        if (maxAbruf > 0 && uids.Count > maxAbruf)
        {
            uebersprungen = uids.Count - maxAbruf;
            uids = uids.Skip(uebersprungen).ToList();
        }

        int neu = 0;
        long maxUid = letzteUid;

        foreach (var uid in uids)
        {
            if (uid.Id <= letzteUid) continue;

            var msg = folder.GetMessage(uid);
            if (SpeichereNachricht(kontoId, mandantId, ordnerId, uid.Id, msg))
                neu++;
            if (uid.Id > maxUid) maxUid = uid.Id;
        }

        SpeichereOrdnerZustand(ordnerId, folder.UidValidity, maxUid,
                               folder.Count, folder.Unread);
        folder.Close();
        return (neu, uebersprungen);
    }

    // ------------------------------------------------------------------
    // Speichern: Nachricht + Anhaenge in EINER Transaktion
    // ------------------------------------------------------------------

    private static bool SpeichereNachricht(int kontoId, int mandantId, int ordnerId,
                                           uint uid, MimeMessage msg)
    {
        using var conn = Oeffne();
        using var tx = conn.BeginTransaction();

        int nachrichtId;
        using (var cmd = new NpgsqlCommand(@"
            INSERT INTO email_nachricht
                (mandant_id, konto_id, ordner_id, uid, message_id, in_reply_to,
                 richtung, von_adresse, von_name, an_adressen, cc_adressen,
                 betreff, gesendet_am, empfangen_am, body_text, body_html,
                 hat_anhang)
            VALUES (@m, @k, @o, @uid, @mid, @irt, 'eingehend', @vona, @vonn,
                    @an, @cc, @betreff, @gesendet, now(), @text, @html, @anh)
            ON CONFLICT (ordner_id, uid) DO NOTHING
            RETURNING nachricht_id", conn, tx))
        {
            var von = msg.From.Mailboxes.FirstOrDefault();
            cmd.Parameters.AddWithValue("m", mandantId);
            cmd.Parameters.AddWithValue("k", kontoId);
            cmd.Parameters.AddWithValue("o", ordnerId);
            cmd.Parameters.AddWithValue("uid", (long)uid);
            cmd.Parameters.AddWithValue("mid", (object?)msg.MessageId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("irt", (object?)msg.InReplyTo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("vona", (object?)von?.Address ?? DBNull.Value);
            cmd.Parameters.AddWithValue("vonn", (object?)von?.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("an", Adressen(msg.To));
            cmd.Parameters.AddWithValue("cc", Adressen(msg.Cc));
            cmd.Parameters.AddWithValue("betreff", (object?)Kuerze(msg.Subject, 998) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("gesendet", msg.Date.UtcDateTime);
            cmd.Parameters.AddWithValue("text", (object?)msg.TextBody ?? DBNull.Value);
            cmd.Parameters.AddWithValue("html", (object?)msg.HtmlBody ?? DBNull.Value);
            cmd.Parameters.AddWithValue("anh", msg.Attachments.Any());

            var res = cmd.ExecuteScalar();
            if (res == null)   // ON CONFLICT: gab es schon
            {
                tx.Rollback();
                return false;
            }
            nachrichtId = Convert.ToInt32(res);
        }

        foreach (var att in msg.Attachments)
            SpeichereAnhang(conn, tx, nachrichtId, att);

        tx.Commit();
        return true;
    }

    /// <summary>
    /// Ein Anhang wird ein normaler dokument-Satz (quelle='email') und ueber
    /// email_anhang verknuepft — dadurch liegt er automatisch im
    /// Dokumentenmanagement und ist spaeter per OCR durchsuchbar.
    /// </summary>
    private static void SpeichereAnhang(NpgsqlConnection conn, NpgsqlTransaction tx,
                                        int nachrichtId, MimeEntity att)
    {
        var name = att.ContentDisposition?.FileName
                ?? att.ContentType?.Name
                ?? "unbenannt";

        using var ms = new MemoryStream();
        if (att is MessagePart rfc822)
        {
            // Weitergeleitete Mail als Anhang: hat keinen Content, nur eine
            // eingebettete Nachricht.
            rfc822.Message.WriteTo(ms);
        }
        else if (att is MimePart part)
        {
            // DecodeTo, NICHT WriteTo: WriteTo schriebe die MIME-Kodierung
            // (Base64) mit, die Datei waere unbrauchbar.
            part.Content.DecodeTo(ms);
        }
        else
        {
            return;
        }

        var bytes = ms.ToArray();
        var mime = att.ContentType?.MimeType ?? "application/octet-stream";

        int dokumentId;
        using (var cmd = new NpgsqlCommand(@"
            INSERT INTO dokument (typ_id, titel, pdf_blob, mime_type,
                                  dateigroesse_kb, quelle, scan_datum)
            VALUES ((SELECT typ_id FROM dokument_typ
                     WHERE bezeichnung = 'E-Mail-Anhang' AND mandant_id IS NULL LIMIT 1),
                    @titel, @blob, @mime, @kb, 'email', now())
            RETURNING dokument_id", conn, tx))
        {
            cmd.Parameters.AddWithValue("titel", Kuerze(name, 300) ?? "unbenannt");
            cmd.Parameters.Add("blob", NpgsqlDbType.Bytea).Value = bytes;
            cmd.Parameters.AddWithValue("mime", Kuerze(mime, 100) ?? "");
            cmd.Parameters.AddWithValue("kb", bytes.Length / 1024);
            dokumentId = Convert.ToInt32(cmd.ExecuteScalar());
        }

        using (var cmd = new NpgsqlCommand(@"
            INSERT INTO email_anhang (nachricht_id, dokument_id, dateiname,
                                      inline, content_id)
            VALUES (@n, @d, @f, @inl, @cid)
            ON CONFLICT DO NOTHING", conn, tx))
        {
            cmd.Parameters.AddWithValue("n", nachrichtId);
            cmd.Parameters.AddWithValue("d", dokumentId);
            cmd.Parameters.AddWithValue("f", Kuerze(name, 300) ?? "");
            cmd.Parameters.AddWithValue("inl",
                att.ContentDisposition?.Disposition == ContentDisposition.Inline);
            cmd.Parameters.AddWithValue("cid",
                (object?)Kuerze(att.ContentId, 200) ?? DBNull.Value);
            cmd.ExecuteNonQuery();
        }
    }

    // ------------------------------------------------------------------
    // Datenbank-Hilfsfunktionen
    // ------------------------------------------------------------------

    private sealed record KontoDaten(int KontoId, int MandantId, string EmailAdresse,
        string? AnzeigeName, string? ImapHost, int ImapPort, bool ImapSsl,
        string? SmtpHost, int SmtpPort, bool SmtpStartTls,
        string? Benutzername, string? Passwort, int MaxAbruf,
        // NULL = die Zugangsdaten des Kontos verwenden. Viele Anbieter nutzen
        // fuer den Postausgang dieselben, Relay- und Firmenserver oft eigene.
        string? SmtpBenutzername, string? SmtpPasswort,
        // Ab hier: alles einstellbar statt im Code entschieden
        string Protokoll,
        string? ImapSicherheit, string? SmtpSicherheit, string? Pop3Sicherheit,
        string? ImapAuth, string? SmtpAuth,
        string? Pop3Host, int Pop3Port, bool Pop3Loeschen,
        bool ZertifikatPruefen, int TimeoutSekunden,
        int MaxAnhangKb, bool NurKopfdaten, string? OrdnerFilter)
    {
        public string? EffektiverSmtpBenutzer =>
            string.IsNullOrWhiteSpace(SmtpBenutzername) ? Benutzername : SmtpBenutzername;
        public string? EffektivesSmtpPasswort =>
            string.IsNullOrEmpty(SmtpPasswort) ? Passwort : SmtpPasswort;
    }

    private static NpgsqlConnection Oeffne()
    {
        var c = new NpgsqlConnection(_connString);
        c.Open();
        return c;
    }

    private static KontoDaten LadeKonto(int kontoId)
    {
        using var conn = Oeffne();
        using var cmd = new NpgsqlCommand(
            "SELECT * FROM email_konto WHERE konto_id = @id AND aktiv", conn);
        cmd.Parameters.AddWithValue("id", kontoId);
        using var r = cmd.ExecuteReader();
        if (!r.Read())
            throw new InvalidOperationException(
                $"E-Mail-Konto {kontoId} nicht gefunden oder inaktiv.");

        // Zugriff ueber SPALTENNAMEN, nicht ueber Indizes. Die Tabelle ist heute
        // schon dreimal gewachsen; mit Indizes verschiebt sich bei jeder neuen
        // Spalte still alles, und man sucht den Fehler woanders.
        string? Txt(string n) { int i = r.GetOrdinal(n);
                                return r.IsDBNull(i) ? null : r.GetString(i); }
        int Zahl(string n, int fb) { int i = r.GetOrdinal(n);
                                     return r.IsDBNull(i) ? fb : r.GetInt32(i); }
        bool Ja(string n, bool fb) { int i = r.GetOrdinal(n);
                                     return r.IsDBNull(i) ? fb : r.GetBoolean(i); }
        byte[]? Bytes(string n) { int i = r.GetOrdinal(n);
                                  return r.IsDBNull(i) ? null : (byte[])r[i]; }

        byte[]? passBytes = Bytes("passwort_crypt");
        byte[]? smtpPassBytes = Bytes("smtp_passwort_crypt");

        // pgp_sym_encrypt beginnt immer mit 0xC3 (Symmetric-Key-ESK-Paket).
        // Ohne diese Pruefung wuerde der Chiffretext als UTF8 dekodiert und als
        // Passwort verschickt - der Server bricht dann kommentarlos ab, und
        // niemand kaeme auf die eigentliche Ursache.
        // Unschaerfe: ein Klartextpasswort mit fuehrendem Umlaut hat in UTF-8
        // ebenfalls 0xC3 vorn. Solange Klartext nur der Uebergang ist, tragbar.
        if ((passBytes is { Length: > 0 } && passBytes[0] == 0xC3) ||
            (smtpPassBytes is { Length: > 0 } && smtpPassBytes[0] == 0xC3))
            throw new InvalidOperationException(
                "Das Passwort dieses Kontos liegt verschluesselt in der Datenbank " +
                "(pgcrypto). Diese Seite kann es noch nicht entschluesseln. " +
                "Bitte im Reiter \"Konto\" das Haekchen \"Klartext ablegen\" setzen " +
                "und das Passwort erneut setzen.");

        return new KontoDaten(
            kontoId,
            Zahl("mandant_id", 0),
            Txt("email_adresse") ?? "",
            Txt("anzeige_name"),
            Txt("imap_host"),
            Zahl("imap_port", 993),
            Ja("imap_ssl", true),
            Txt("smtp_host"),
            Zahl("smtp_port", 587),
            Ja("smtp_starttls", true),
            Txt("benutzername"),
            passBytes is null ? null : System.Text.Encoding.UTF8.GetString(passBytes),
            Zahl("max_abruf", 200),
            Txt("smtp_benutzername"),
            smtpPassBytes is null ? null
                : System.Text.Encoding.UTF8.GetString(smtpPassBytes),
            Txt("protokoll") ?? "auto",
            Txt("imap_sicherheit"),
            Txt("smtp_sicherheit"),
            Txt("pop3_sicherheit"),
            Txt("imap_auth"),
            Txt("smtp_auth"),
            Txt("pop3_host"),
            Zahl("pop3_port", 995),
            Ja("pop3_loeschen", false),
            Ja("zertifikat_pruefen", true),
            Zahl("timeout_sekunden", 60),
            Zahl("max_anhang_kb", 0),
            Ja("nur_kopfdaten", false),
            Txt("ordner_filter"));
    }

    // Uebersetzt die Spalte *_sicherheit in MailKits SecureSocketOptions.
    // NULL/'auto' laesst MailKit anhand des Ports entscheiden.
    private static SecureSocketOptions Sicherheit(string? wert)
        => (wert ?? "auto").ToLowerInvariant() switch
        {
            "keine"                  => SecureSocketOptions.None,
            "ssl"                    => SecureSocketOptions.SslOnConnect,
            "starttls"               => SecureSocketOptions.StartTls,
            "starttls_wenn_moeglich" => SecureSocketOptions.StartTlsWhenAvailable,
            _                        => SecureSocketOptions.Auto,
        };

    // Erzwingt ein Anmeldeverfahren, falls konfiguriert. Manche Server bewerben
    // Verfahren, die dann doch scheitern - dann setzt man hier eines hart.
    private static void AuthVerfahrenSetzen(MailKit.MailService dienst, string? wunsch)
    {
        if (string.IsNullOrWhiteSpace(wunsch) || wunsch.Equals("auto",
                StringComparison.OrdinalIgnoreCase))
            return;
        dienst.AuthenticationMechanisms.RemoveWhere(
            m => !m.Equals(wunsch, StringComparison.OrdinalIgnoreCase));
        if (dienst.AuthenticationMechanisms.Count == 0)
            throw new InvalidOperationException(
                $"Der Server bietet das eingestellte Anmeldeverfahren \"{wunsch}\" " +
                "nicht an. Bitte im Reiter \"Erweitert\" auf \"Automatisch\" " +
                "stellen oder ein anderes waehlen.");
    }

    // Baut einen SmtpClient nach den Einstellungen des Kontos auf.
    private static SmtpClient VerbindeSmtp(KontoDaten k)
    {
        var smtp = new SmtpClient { Timeout = k.TimeoutSekunden * 1000 };
        if (!k.ZertifikatPruefen)
            smtp.ServerCertificateValidationCallback = (s, c, ch, e) => true;
        smtp.Connect(k.SmtpHost, k.SmtpPort, Sicherheit(k.SmtpSicherheit));
        AuthVerfahrenSetzen(smtp, k.SmtpAuth);
        if (!string.IsNullOrEmpty(k.EffektiverSmtpBenutzer))
            smtp.Authenticate(k.EffektiverSmtpBenutzer, k.EffektivesSmtpPasswort);
        return smtp;
    }

    private static ImapClient VerbindeImap(KontoDaten k)
    {
        var client = new ImapClient { Timeout = k.TimeoutSekunden * 1000 };
        if (!k.ZertifikatPruefen)
            client.ServerCertificateValidationCallback = (s, c, ch, e) => true;
        client.Connect(k.ImapHost, k.ImapPort, Sicherheit(k.ImapSicherheit));
        AuthVerfahrenSetzen(client, k.ImapAuth);
        if (!string.IsNullOrEmpty(k.Benutzername))
            client.Authenticate(k.Benutzername, k.Passwort);
        return client;
    }

    private static bool SpeichereOrdner(int kontoId, IMailFolder folder)
    {
        using var conn = Oeffne();
        using var cmd = new NpgsqlCommand(@"
            INSERT INTO email_ordner (konto_id, name, voller_pfad)
            VALUES (@k, @n, @p)
            ON CONFLICT (konto_id, voller_pfad) DO NOTHING
            RETURNING ordner_id", conn);
        cmd.Parameters.AddWithValue("k", kontoId);
        cmd.Parameters.AddWithValue("n", Kuerze(folder.Name, 200) ?? "");
        cmd.Parameters.AddWithValue("p", Kuerze(folder.FullName, 500) ?? "");
        return cmd.ExecuteScalar() != null;
    }

    private static (int ordnerId, uint? validity, long letzteUid)
        LadeOrdnerZustand(int kontoId, IMailFolder folder)
    {
        SpeichereOrdner(kontoId, folder);   // legt an, falls noch nicht vorhanden

        using var conn = Oeffne();
        using var cmd = new NpgsqlCommand(@"
            SELECT ordner_id, uidvalidity, letzte_uid
            FROM email_ordner WHERE konto_id = @k AND voller_pfad = @p", conn);
        cmd.Parameters.AddWithValue("k", kontoId);
        cmd.Parameters.AddWithValue("p", Kuerze(folder.FullName, 500) ?? "");
        using var r = cmd.ExecuteReader();
        if (!r.Read())
            throw new InvalidOperationException("Ordner konnte nicht angelegt werden: " + folder.FullName);

        return (r.GetInt32(0),
                r.IsDBNull(1) ? null : (uint)r.GetInt64(1),
                r.IsDBNull(2) ? 0 : r.GetInt64(2));
    }

    private static void SpeichereOrdnerZustand(int ordnerId, uint validity,
        long letzteUid, int gesamt, int ungelesen)
    {
        using var conn = Oeffne();
        using var cmd = new NpgsqlCommand(@"
            UPDATE email_ordner
               SET uidvalidity = @v, letzte_uid = @u, anzahl_gesamt = @g,
                   anzahl_ungelesen = @ung, letzter_abruf = now()
             WHERE ordner_id = @id", conn);
        cmd.Parameters.AddWithValue("v", (long)validity);
        cmd.Parameters.AddWithValue("u", letzteUid);
        cmd.Parameters.AddWithValue("g", gesamt);
        cmd.Parameters.AddWithValue("ung", ungelesen);
        cmd.Parameters.AddWithValue("id", ordnerId);
        cmd.ExecuteNonQuery();
    }

    private static List<(string name, byte[] bytes, string mime)> LadeAnhaenge(int nachrichtId)
    {
        var list = new List<(string, byte[], string)>();
        using var conn = Oeffne();
        using var cmd = new NpgsqlCommand(@"
            SELECT COALESCE(a.dateiname, d.titel), d.pdf_blob, d.mime_type
            FROM email_anhang a JOIN dokument d ON d.dokument_id = a.dokument_id
            WHERE a.nachricht_id = @n AND d.pdf_blob IS NOT NULL", conn);
        cmd.Parameters.AddWithValue("n", nachrichtId);
        using var r = cmd.ExecuteReader();
        while (r.Read())
            list.Add((r.GetString(0), (byte[])r[1], r.IsDBNull(2) ? "" : r.GetString(2)));
        return list;
    }

    private static void SetzeVersandStatus(int nachrichtId, string status, string? fehler)
    {
        try
        {
            using var conn = Oeffne();
            using var cmd = new NpgsqlCommand(@"
                UPDATE email_nachricht
                   SET versand_status = @s, versand_fehler = @f,
                       versendet_am = CASE WHEN @s = 'gesendet' THEN now() ELSE versendet_am END
                 WHERE nachricht_id = @id", conn);
            cmd.Parameters.AddWithValue("s", status);
            cmd.Parameters.AddWithValue("f", (object?)fehler ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id", nachrichtId);
            cmd.ExecuteNonQuery();
        }
        catch
        {
            // Ein fehlgeschlagenes Status-Update darf den urspruenglichen
            // Fehler nicht ueberdecken.
        }
    }

    // ------------------------------------------------------------------
    private static string Adressen(InternetAddressList list) =>
        string.Join(", ", list.Mailboxes.Select(m => m.Address));

    private static void FuegeEmpfaengerHinzu(InternetAddressList ziel, string adressen)
    {
        foreach (var a in adressen.Split(',', StringSplitOptions.RemoveEmptyEntries))
        {
            var t = a.Trim();
            if (t.Length > 0 && MailboxAddress.TryParse(t, out var mb))
                ziel.Add(mb);
        }
    }

    private static string? Kuerze(string? s, int max) =>
        s == null ? null : (s.Length <= max ? s : s.Substring(0, max));
}
