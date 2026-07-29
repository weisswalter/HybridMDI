-- ============================================================================
-- E-Mail-Konto: vollstaendige Konfigurierbarkeit — Stand 28.07.2026
--
-- GRUNDSATZ (Walters Vorgabe): "bei den vielen Moeglichkeiten trifft man
-- 99%tig die falsche Wahl". Also wird NICHTS im Code entschieden, was der
-- Anwender wissen koennte. Jeder Schalter, den MailKit bzw. Graph anbietet,
-- ist hier eine Spalte. Vorbelegung ist ueberall 'auto' — dann verhaelt sich
-- das Programm wie bisher, aber man kann jede Entscheidung uebersteuern,
-- ohne dass jemand neu compiliert.
--
-- Die alten Spalten imap_ssl und smtp_starttls bleiben vorerst stehen
-- (Rueckfallebene), werden aber von den neuen ueberstimmt.
-- ============================================================================

-- ── Welches Protokoll ──────────────────────────────────────────────────────
-- 'auto'  = anhand der Domain entscheiden (Microsoft-Tenant -> graph)
-- 'graph' = Microsoft Graph, reines Delphi, ohne Bruecke
-- 'imap'  = MailKit ueber die Bruecke
-- 'pop3'  = MailKit, Notnagel: keine Ordner, keine Serverflags
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS protokoll varchar(10)
    NOT NULL DEFAULT 'auto';
ALTER TABLE email_konto DROP CONSTRAINT IF EXISTS email_konto_protokoll_check;
ALTER TABLE email_konto ADD CONSTRAINT email_konto_protokoll_check
    CHECK (protokoll IN ('auto', 'graph', 'imap', 'pop3'));

-- ── Transportsicherheit, je Dienst getrennt ────────────────────────────────
-- Bildet SecureSocketOptions von MailKit 1:1 ab. Der bisherige boolean
-- smtp_starttls konnte implizites SSL (Port 465) und STARTTLS (587) nicht
-- unterscheiden — genau die Verwechslung, die bei Vodafone auffiel.
--   'auto'      = MailKit entscheidet anhand des Ports
--   'keine'     = unverschluesselt (nur fuer Testserver im LAN)
--   'ssl'       = ab Verbindungsaufbau verschluesselt (SslOnConnect, Port 465/993)
--   'starttls'  = im Klartext verbinden, dann hochstufen — Pflicht
--   'starttls_wenn_moeglich' = hochstufen falls angeboten, sonst weiter
DO $$ BEGIN
    PERFORM 1;
END $$;

ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS imap_sicherheit varchar(25);
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS smtp_sicherheit varchar(25);
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS pop3_sicherheit varchar(25);

-- ── Anmeldeverfahren erzwingen ─────────────────────────────────────────────
-- NULL/'auto' = MailKit waehlt aus dem, was der Server anbietet. Manche
-- Server bewerben Verfahren, die dann doch scheitern; dann setzt man hier
-- z.B. 'PLAIN' oder 'LOGIN' hart. 'XOAUTH2' fuer Microsoft/Google.
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS imap_auth varchar(30);
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS smtp_auth varchar(30);

-- ── POP3 hat eigenen Host und Port ─────────────────────────────────────────
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS pop3_host varchar(200);
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS pop3_port integer DEFAULT 995;
-- POP3 loescht traditionell nach dem Abholen. Standard: liegen lassen.
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS pop3_loeschen boolean
    NOT NULL DEFAULT false;

-- ── Verbindungsverhalten ───────────────────────────────────────────────────
-- Selbstsignierte Zertifikate kommen bei Exchange on-premises staendig vor.
-- Abschalten ist eine bewusste Entscheidung des Betreibers, keine Voreinstellung.
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS zertifikat_pruefen boolean
    NOT NULL DEFAULT true;
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS timeout_sekunden integer
    NOT NULL DEFAULT 60;

-- ── Abrufumfang ────────────────────────────────────────────────────────────
-- max_abruf existiert bereits. Ergaenzend ein Datumsschnitt: oft will man
-- "alles ab Jahresbeginn" statt "die letzten N".
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS abruf_ab_datum date;
-- Nur Kopfdaten holen, Textkoerper erst beim Anklicken nachladen. Bei grossen
-- Postfaechern der Unterschied zwischen Minuten und Stunden.
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS nur_kopfdaten boolean
    NOT NULL DEFAULT false;
-- Kommaliste der Ordner, die abgeglichen werden. Leer = alle. Damit laesst
-- sich ein Archiv mit 40.000 Mails gezielt aussparen.
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS ordner_filter text;
-- Anhaenge ueber dieser Groesse werden nicht gespeichert (0 = keine Grenze).
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS max_anhang_kb integer
    NOT NULL DEFAULT 0;

-- ── OAuth2 / Graph ─────────────────────────────────────────────────────────
-- authority und graph_basis_url sind noetig, weil es neben der weltweiten
-- Cloud auch nationale gibt (US Government, China). Wer das fest verdrahtet,
-- schliesst Kunden aus.
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS oauth_tenant varchar(200);
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS oauth_client_id varchar(200);
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS oauth_authority varchar(300)
    DEFAULT 'https://login.microsoftonline.com';
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS graph_basis_url varchar(300)
    DEFAULT 'https://graph.microsoft.com/v1.0';
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS oauth_scopes text
    DEFAULT 'offline_access https://graph.microsoft.com/Mail.ReadWrite https://graph.microsoft.com/Mail.Send';
-- 'device' = Code auf microsoft.com/devicelogin eintippen (kein Listener noetig)
-- 'authcode' = klassischer Weg mit Weiterleitung
ALTER TABLE email_konto ADD COLUMN IF NOT EXISTS oauth_flow varchar(20)
    NOT NULL DEFAULT 'device';

-- ── Bestandsdaten auf die neuen Spalten heben ──────────────────────────────
UPDATE email_konto
   SET imap_sicherheit = COALESCE(imap_sicherheit,
         CASE WHEN imap_ssl THEN 'ssl' ELSE 'starttls' END),
       smtp_sicherheit = COALESCE(smtp_sicherheit,
         CASE WHEN smtp_starttls THEN 'starttls'
              WHEN smtp_port = 465 THEN 'ssl'
              ELSE 'auto' END),
       pop3_sicherheit = COALESCE(pop3_sicherheit, 'ssl');

-- ── Nachschlagelisten fuer die Oberflaeche ─────────────────────────────────
-- Eigene Tabelle statt fester Items im Formular: neue Werte lassen sich ohne
-- Neuuebersetzung ergaenzen, und die Oberflaeche zeigt Klartext statt Kuerzel.
CREATE TABLE IF NOT EXISTS email_option (
    feld        varchar(30) NOT NULL,
    wert        varchar(30) NOT NULL,
    anzeige     varchar(120) NOT NULL,
    reihenfolge smallint NOT NULL DEFAULT 0,
    PRIMARY KEY (feld, wert)
);

INSERT INTO email_option (feld, wert, anzeige, reihenfolge) VALUES
    ('protokoll', 'auto',  'Automatisch erkennen', 1),
    ('protokoll', 'graph', 'Microsoft Graph (Exchange Online, outlook.com)', 2),
    ('protokoll', 'imap',  'IMAP', 3),
    ('protokoll', 'pop3',  'POP3 (Notnagel, keine Ordner)', 4),

    ('sicherheit', 'auto',      'Automatisch (nach Port)', 1),
    ('sicherheit', 'ssl',       'SSL/TLS ab Verbindungsaufbau (465/993/995)', 2),
    ('sicherheit', 'starttls',  'STARTTLS erzwingen (587/143)', 3),
    ('sicherheit', 'starttls_wenn_moeglich', 'STARTTLS wenn angeboten', 4),
    ('sicherheit', 'keine',     'Unverschluesselt (nur Testserver)', 5),

    ('auth', 'auto',        'Automatisch (was der Server anbietet)', 1),
    ('auth', 'PLAIN',       'PLAIN', 2),
    ('auth', 'LOGIN',       'LOGIN', 3),
    ('auth', 'CRAM-MD5',    'CRAM-MD5', 4),
    ('auth', 'DIGEST-MD5',  'DIGEST-MD5', 5),
    ('auth', 'NTLM',        'NTLM (Exchange on-premises)', 6),
    ('auth', 'XOAUTH2',     'XOAUTH2 (Microsoft, Google)', 7),

    ('oauth_flow', 'device',   'Geraetecode (empfohlen fuer Desktop)', 1),
    ('oauth_flow', 'authcode', 'Autorisierungscode mit Weiterleitung', 2)
ON CONFLICT (feld, wert) DO UPDATE SET anzeige = EXCLUDED.anzeige,
                                       reihenfolge = EXCLUDED.reihenfolge;
