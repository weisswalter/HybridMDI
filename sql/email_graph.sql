-- ============================================================================
-- Microsoft Graph als zweiter Abrufweg — Stand 01.08.2026
--
-- WARUM UEBERHAUPT: Die Zielgruppe verwendet ueberwiegend Exchange. Graph ist
-- REST, also braucht dieser Weg KEINE Bruecke und KEINE Fremdsprache — er
-- laeuft komplett in Delphi (MailGraph.pas). MailKit ueber die C#-Bruecke
-- bleibt fuer IMAP/POP3 und Exchange on-premises zustaendig.
--
-- WAS HIER FEHLTE: Die Tabellen waren fuer IMAP entworfen. IMAP identifiziert
-- eine Nachricht ueber eine ZAHL (uid, bigint) je Ordner. Graph identifiziert
-- sie ueber eine lange Zeichenkette und kennt keine uid. Ohne eigene Spalte
-- haette man beim Graph-Abruf keinen Duplikatschutz.
-- ============================================================================

-- ── 1. Ordner: die Graph-Kennung ───────────────────────────────────────────
-- Graph adressiert Unterordner und Nachrichten ueber diese ID, nicht ueber den
-- Pfad. voller_pfad bleibt trotzdem gefuellt (aus dem Ordnerbaum
-- zusammengesetzt), damit die Anzeige und der bestehende UNIQUE-Schluessel
-- (konto_id, voller_pfad) unveraendert weiterfunktionieren.
ALTER TABLE email_ordner ADD COLUMN IF NOT EXISTS graph_id varchar(300);
CREATE UNIQUE INDEX IF NOT EXISTS ux_email_ordner_graph
    ON email_ordner (konto_id, graph_id) WHERE graph_id IS NOT NULL;

-- uidvalidity und letzte_uid bleiben auf dem Graph-Weg LEER. Sie sind
-- IMAP-Begriffe; Graph hat kein Gegenstueck dazu. Der Graph-Abruf holt
-- stattdessen die neuesten max_abruf Nachrichten und verlaesst sich auf den
-- Duplikatschutz unten. (Ausbaustufe waere Graphs Delta-Query — bewusst noch
-- nicht gebaut, dafuer braeuchte es eine eigene Spalte fuer den Delta-Link.)

-- ── 2. Nachricht: die Graph-Kennung ────────────────────────────────────────
ALTER TABLE email_nachricht ADD COLUMN IF NOT EXISTS graph_id varchar(300);

-- Duplikatschutz auf dem Graph-Weg. Bewusst je KONTO, nicht je Ordner: die
-- Graph-ID ist innerhalb des Postfachs eindeutig.
--
-- GRENZE, die man kennen muss: Verschiebt der Anwender eine Mail im Postfach
-- in einen anderen Ordner, vergibt Graph eine NEUE ID. Beim naechsten Abruf
-- erscheint sie deshalb ein zweites Mal — im neuen Ordner. Ueber
-- internet_message_id zu deduplizieren waere falsch, das wuerde legitime
-- Kopien (Gesendet + Archiv) unterdruecken.
CREATE UNIQUE INDEX IF NOT EXISTS ux_email_nachricht_graph
    ON email_nachricht (konto_id, graph_id) WHERE graph_id IS NOT NULL;

-- Graph liefert kein In-Reply-To im Datensatz (das steckt nur in den
-- Rohkopfzeilen, die man einzeln nachladen muesste), dafuer aber eine
-- Konversations-ID. Sie ist das bessere Mittel, um Antwortketten zu bilden.
ALTER TABLE email_nachricht ADD COLUMN IF NOT EXISTS conversation_id varchar(300);
CREATE INDEX IF NOT EXISTS ix_email_nachricht_conversation
    ON email_nachricht (conversation_id) WHERE conversation_id IS NOT NULL;

-- ── 3. Ablage der OAuth2-Token ─────────────────────────────────────────────
-- Die Spalten oauth_refresh_crypt / oauth_access_crypt / oauth_gueltig_bis
-- existieren seit dem ersten Entwurf, waren aber ungenutzt. Jetzt bekommen
-- sie dieselbe Behandlung wie das Passwort (sql/email_konto_crypt.sql):
-- verschluesselt wird in der DATENBANK per pgcrypto, der Schluessel wird
-- nirgends gespeichert.
--
-- WARUM DAS WICHTIGER IST ALS BEIM PASSWORT: Ein Refresh-Token ist ein
-- vollwertiger Postfachzugang, der ohne Kennwort und ohne zweiten Faktor
-- funktioniert, bis er widerrufen wird. Wer ihn hat, liest und versendet Mail.
--
-- Wie beim Passwort ist Klartext moeglich (leerer Schluessel), damit man den
-- Weg ausprobieren kann, bevor man sich auf eine Schluesselverwaltung
-- festlegt. Die Lesefunktionen erkennen selbst, welche Form vorliegt.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Beide Token in einem Rutsch setzen — sie kommen auch gemeinsam vom
-- Anmeldeserver. Leerer Schluessel legt Klartext ab.
CREATE OR REPLACE FUNCTION fn_konto_oauth_setzen(
    p_konto_id integer, p_refresh text, p_access text,
    p_gueltig_bis timestamp, p_schluessel text)
RETURNS void
LANGUAGE sql AS $$
    UPDATE email_konto
       SET oauth_refresh_crypt = CASE
             WHEN COALESCE(p_refresh, '') = '' THEN NULL
             WHEN COALESCE(p_schluessel, '') = '' THEN convert_to(p_refresh, 'UTF8')
             ELSE pgp_sym_encrypt(p_refresh, p_schluessel)
           END,
           oauth_access_crypt = CASE
             WHEN COALESCE(p_access, '') = '' THEN NULL
             WHEN COALESCE(p_schluessel, '') = '' THEN convert_to(p_access, 'UTF8')
             ELSE pgp_sym_encrypt(p_access, p_schluessel)
           END,
           oauth_gueltig_bis = p_gueltig_bis
     WHERE konto_id = p_konto_id;
$$;

-- Erkennt selbst, ob verschluesselt oder Klartext abgelegt wurde.
-- Das erste Byte eines pgp_sym_encrypt-Ergebnisses ist immer 0xC3 (195).
-- Bei Passwoertern ist das eine unsaubere Heuristik (ein Umlaut am Anfang
-- faengt in UTF-8 genauso an); bei OAuth-Token nicht: die sind Base64url
-- bzw. JWT und bestehen ausschliesslich aus ASCII.
CREATE OR REPLACE FUNCTION fn_konto_oauth_refresh_lesen(
    p_konto_id integer, p_schluessel text)
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE v_roh bytea;
BEGIN
    SELECT oauth_refresh_crypt INTO v_roh
      FROM email_konto WHERE konto_id = p_konto_id;
    IF v_roh IS NULL THEN
        RETURN NULL;
    END IF;
    IF get_byte(v_roh, 0) = 195 THEN
        RETURN pgp_sym_decrypt(v_roh, COALESCE(p_schluessel, ''));
    END IF;
    RETURN convert_from(v_roh, 'UTF8');
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;   -- falscher Schluessel: sauber melden statt abbrechen
END;
$$;

CREATE OR REPLACE FUNCTION fn_konto_oauth_access_lesen(
    p_konto_id integer, p_schluessel text)
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE v_roh bytea;
BEGIN
    SELECT oauth_access_crypt INTO v_roh
      FROM email_konto WHERE konto_id = p_konto_id;
    IF v_roh IS NULL THEN
        RETURN NULL;
    END IF;
    IF get_byte(v_roh, 0) = 195 THEN
        RETURN pgp_sym_decrypt(v_roh, COALESCE(p_schluessel, ''));
    END IF;
    RETURN convert_from(v_roh, 'UTF8');
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$;

-- Fuer die Statusanzeige, ohne Schluessel: 'keins' / 'klartext' /
-- 'verschluesselt'. Zusaetzlich interessiert, ob das Zugriffstoken noch gilt —
-- das steht als Klartext-Zeitstempel daneben und braucht keine Entschluesselung.
CREATE OR REPLACE FUNCTION fn_konto_oauth_status(p_konto_id integer)
RETURNS varchar(20)
LANGUAGE sql STABLE AS $$
    SELECT CASE
             WHEN oauth_refresh_crypt IS NULL THEN 'keins'
             WHEN get_byte(oauth_refresh_crypt, 0) = 195 THEN 'verschluesselt'
             ELSE 'klartext'
           END::varchar(20)
      FROM email_konto WHERE konto_id = p_konto_id;
$$;

-- Abmelden: Token verwerfen. Der Zugang beim Anbieter bleibt bestehen — wer
-- ihn wirklich entziehen will, muss das im Microsoft-Konto tun. Das gehoert
-- als Hinweis in die Oberflaeche, nicht in diese Funktion.
CREATE OR REPLACE FUNCTION fn_konto_oauth_loeschen(p_konto_id integer)
RETURNS void
LANGUAGE sql AS $$
    UPDATE email_konto
       SET oauth_refresh_crypt = NULL,
           oauth_access_crypt  = NULL,
           oauth_gueltig_bis   = NULL
     WHERE konto_id = p_konto_id;
$$;

-- ── 4. Nachschlagewerte fuer die Oberflaeche ergaenzen ─────────────────────
-- oauth_flow stand in email_option noch nicht drin, obwohl die Combo im
-- Reiter "Erweitert" darauf zeigt.
INSERT INTO email_option (feld, wert, anzeige, reihenfolge) VALUES
    ('oauth_flow', 'device',   'Geraetecode (Code auf microsoft.com/devicelogin eintippen)', 1),
    ('oauth_flow', 'authcode', 'Weiterleitung im Browser (noch nicht gebaut)', 2)
ON CONFLICT (feld, wert) DO UPDATE SET anzeige = EXCLUDED.anzeige,
                                       reihenfolge = EXCLUDED.reihenfolge;
