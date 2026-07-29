-- ============================================================================
-- E-Mail-Konto: Passwortablage — Stand 28.07.2026
--
-- ENTSCHEIDUNG: verschluesselt wird in der DATENBANK (pgcrypto, pgp_sym_*),
-- nicht auf dem Client. Begruendung: sonst muesste der Schluessel auf jedem
-- Arbeitsplatz liegen, und die C#-Seite (MailKit) braeuchte eine zweite,
-- kompatible Implementierung. So gibt es genau eine.
--
-- Der SCHLUESSEL wird NICHT gespeichert — weder in der DB noch auf Platte.
-- Er wird bei jedem Aufruf mitgegeben und in der Anwendung nur fuer die Dauer
-- der Sitzung im Speicher gehalten. Ein Datenbank-Dump allein enthaelt damit
-- keine brauchbaren Zugangsdaten.
--
-- GRENZE, die man kennen muss: das Passwort und der Schluessel laufen als
-- Parameter durch die Verbindung. Bei eingeschaltetem Statement-Logging
-- (log_statement = 'all') landen sie im Serverlog. Fuer den Produktivbetrieb
-- gehoert die Verbindung auf SSL und log_statement auf 'none' oder 'ddl'.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Passwort setzen. Leerer String loescht es.
CREATE OR REPLACE FUNCTION fn_konto_passwort_setzen(
    p_konto_id integer, p_passwort text, p_schluessel text)
RETURNS void
LANGUAGE sql AS $$
    UPDATE email_konto
       SET passwort_crypt = CASE
             WHEN COALESCE(p_passwort, '') = '' THEN NULL
             ELSE pgp_sym_encrypt(p_passwort, p_schluessel)
           END
     WHERE konto_id = p_konto_id;
$$;

-- Passwort lesen. Falscher Schluessel liefert NULL statt einer Exception,
-- damit die Anwendung "Schluessel stimmt nicht" sauber melden kann.
CREATE OR REPLACE FUNCTION fn_konto_passwort_lesen(
    p_konto_id integer, p_schluessel text)
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE v_klartext text;
BEGIN
    SELECT pgp_sym_decrypt(passwort_crypt, p_schluessel)
      INTO v_klartext
      FROM email_konto
     WHERE konto_id = p_konto_id AND passwort_crypt IS NOT NULL;
    RETURN v_klartext;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$;

-- Ist ueberhaupt ein Passwort hinterlegt? Beantwortet die Frage, ohne den
-- Schluessel zu brauchen — fuer die Statusanzeige in der Maske.
CREATE OR REPLACE FUNCTION fn_konto_hat_passwort(p_konto_id integer)
RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(passwort_crypt IS NOT NULL, false)
      FROM email_konto WHERE konto_id = p_konto_id;
$$;

-- ── Uebergangsloesung Klartext ─────────────────────────────────────────────
-- MailLib liest passwort_crypt derzeit noch mit Encoding.UTF8.GetString
-- (TODO in MailBridge.cs). Solange das so ist, muss man zum AUSPROBIEREN
-- Klartext ablegen koennen. Bewusst eine eigene Funktion und kein Schalter
-- an fn_konto_passwort_setzen, damit im Code sichtbar bleibt, welcher Weg
-- gewaehlt wurde.
CREATE OR REPLACE FUNCTION fn_konto_passwort_klartext(
    p_konto_id integer, p_passwort text)
RETURNS void
LANGUAGE sql AS $$
    UPDATE email_konto
       SET passwort_crypt = CASE
             WHEN COALESCE(p_passwort, '') = '' THEN NULL
             ELSE convert_to(p_passwort, 'UTF8')
           END
     WHERE konto_id = p_konto_id;
$$;

-- ── Eigene SMTP-Zugangsdaten ───────────────────────────────────────────────
-- Viele Anbieter (auch Vodafone) verlangen fuer den Postausgang dieselben
-- Daten wie fuer den Abruf. Das ist aber kein Naturgesetz: Relay-Server und
-- Firmenkonten haben oft eigene. Beide Felder NULL = die Daten des Kontos
-- werden verwendet, es muss also nichts eingetragen werden, wenn es gleich ist.
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS smtp_benutzername varchar(200);
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS smtp_passwort_crypt bytea;

CREATE OR REPLACE FUNCTION fn_konto_smtp_passwort_setzen(
    p_konto_id integer, p_passwort text, p_schluessel text)
RETURNS void
LANGUAGE sql AS $$
    UPDATE email_konto
       SET smtp_passwort_crypt = CASE
             WHEN COALESCE(p_passwort, '') = '' THEN NULL
             ELSE pgp_sym_encrypt(p_passwort, p_schluessel)
           END
     WHERE konto_id = p_konto_id;
$$;

CREATE OR REPLACE FUNCTION fn_konto_smtp_passwort_klartext(
    p_konto_id integer, p_passwort text)
RETURNS void
LANGUAGE sql AS $$
    UPDATE email_konto
       SET smtp_passwort_crypt = CASE
             WHEN COALESCE(p_passwort, '') = '' THEN NULL
             ELSE convert_to(p_passwort, 'UTF8')
           END
     WHERE konto_id = p_konto_id;
$$;

CREATE OR REPLACE FUNCTION fn_konto_smtp_passwort_status(p_konto_id integer)
RETURNS varchar(20)
LANGUAGE sql STABLE AS $$
    SELECT CASE
             WHEN smtp_passwort_crypt IS NULL THEN 'keins'
             WHEN get_byte(smtp_passwort_crypt, 0) = 195 THEN 'verschluesselt'
             ELSE 'klartext'
           END::varchar(20)
      FROM email_konto WHERE konto_id = p_konto_id;
$$;

-- Welche Form liegt vor? 'keins' / 'klartext' / 'verschluesselt'.
-- Erkennung ueber das erste Byte: pgp_sym_encrypt beginnt immer mit 0xC3
-- (195), dem Symmetric-Key-ESK-Paket. Geprueft mit mehreren Passwoertern
-- und Schluesseln.
-- GRENZE: ein Klartextpasswort, das mit einem Umlaut beginnt, faengt in UTF-8
-- ebenfalls mit 0xC3 an und wuerde faelschlich als verschluesselt gemeldet.
-- Das betrifft nur die Anzeige, nicht die Funktion.
CREATE OR REPLACE FUNCTION fn_konto_passwort_status(p_konto_id integer)
RETURNS varchar(20)
LANGUAGE sql STABLE AS $$
    SELECT CASE
             WHEN passwort_crypt IS NULL THEN 'keins'
             WHEN get_byte(passwort_crypt, 0) = 195 THEN 'verschluesselt'
             ELSE 'klartext'
           END::varchar(20)
      FROM email_konto WHERE konto_id = p_konto_id;
$$;
