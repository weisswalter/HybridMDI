-- ============================================================================
-- Mailmodul + Vorgangsverwaltung
-- Stand 28.07.2026
--
-- ARCHITEKTUR (siehe project_heisenberg_mailmodul):
--   Die C#-Seite (MailKit ueber die BridgePOC-Bruecke) holt Mails per IMAP,
--   dekodiert MIME vollstaendig und schreibt das Ergebnis hier hinein.
--   Delphi liest nur noch fertige Daten mit TFDTable — keine MIME-Verarbeitung
--   auf der Delphi-Seite. Ueber die Bruecke gehen nur Kommandos mit
--   Standardtypen (FetchInbox(mandantId), SendMail(nachrichtId)).
--
--   ANHAENGE werden KEINE eigenen Blobs, sondern normale `dokument`-Saetze
--   (quelle='email'). Damit liegen Mailanhaenge automatisch im
--   Dokumentenmanagement, haengen ueber person_dokument an Personen und
--   koennen spaeter per OCR durchsuchbar gemacht werden (ocr_text existiert).
-- ============================================================================

-- ── 1. E-Mail-Konto je Mandant ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS email_konto (
    konto_id        serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    bezeichnung     varchar(100) NOT NULL,     -- 'Info-Postfach', 'Buchhaltung'
    email_adresse   varchar(320) NOT NULL,
    anzeige_name    varchar(200),

    imap_host       varchar(200),
    imap_port       integer DEFAULT 993,
    imap_ssl        boolean NOT NULL DEFAULT true,
    smtp_host       varchar(200),
    smtp_port       integer DEFAULT 587,
    smtp_starttls   boolean NOT NULL DEFAULT true,

    benutzername    varchar(200),
    -- NIEMALS Klartext. Die Verschluesselung (AES-256) passiert in der
    -- Anwendung, die DB sieht nur den Chiffretext — analog smtp_config
    -- aus der CMS-Roadmap.
    passwort_crypt  bytea,

    -- Fuer OAuth2 (Gmail/M365), sobald Basic Auth dort wegfaellt.
    -- Ebenfalls verschluesselt abzulegen.
    oauth_refresh_crypt bytea,
    oauth_access_crypt  bytea,
    oauth_gueltig_bis   timestamp,

    ist_standard    boolean NOT NULL DEFAULT false,
    aktiv           boolean NOT NULL DEFAULT true,
    created_at      timestamp NOT NULL DEFAULT now(),
    UNIQUE (mandant_id, bezeichnung)
);
-- hoechstens ein Standardkonto je Mandant
CREATE UNIQUE INDEX IF NOT EXISTS ux_email_konto_standard
    ON email_konto (mandant_id) WHERE ist_standard;

-- ── 2. Ordnerbaum je Konto, mit IMAP-Synchronisationszustand ───────────────
-- WICHTIG: uidvalidity/letzte_uid gehoeren an den ORDNER, nicht ans Konto —
-- jeder IMAP-Ordner hat seine eigene UID-Sequenz. Aendert der Server die
-- uidvalidity, ist die gespeicherte letzte_uid wertlos und der Ordner muss
-- neu abgeglichen werden.
CREATE TABLE IF NOT EXISTS email_ordner (
    ordner_id       serial PRIMARY KEY,
    konto_id        integer NOT NULL REFERENCES email_konto(konto_id) ON DELETE CASCADE,
    parent_id       integer REFERENCES email_ordner(ordner_id),
    name            varchar(200) NOT NULL,     -- 'Gesendet'
    voller_pfad     varchar(500) NOT NULL,     -- 'INBOX/Projekte/TRT'
    uidvalidity     bigint,
    letzte_uid      bigint,
    anzahl_gesamt   integer,
    anzahl_ungelesen integer,
    letzter_abruf   timestamp,
    UNIQUE (konto_id, voller_pfad)
);

-- ── 3. Nachrichten ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS email_nachricht (
    nachricht_id    serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    konto_id        integer NOT NULL REFERENCES email_konto(konto_id) ON DELETE CASCADE,
    ordner_id       integer REFERENCES email_ordner(ordner_id),
    uid             bigint,                    -- IMAP-UID im Ordner
    message_id      varchar(500),              -- RFC-Message-ID
    in_reply_to     varchar(500),              -- fuer Konversations-Zuordnung

    richtung        varchar(10) NOT NULL DEFAULT 'eingehend'
                      CHECK (richtung IN ('eingehend', 'ausgehend')),
    von_adresse     varchar(320),
    von_name        varchar(200),
    an_adressen     text,                      -- mehrere, kommagetrennt
    cc_adressen     text,
    bcc_adressen    text,
    betreff         varchar(998),              -- RFC 5322 Zeilenlaenge
    gesendet_am     timestamp,
    empfangen_am    timestamp,

    body_text       text,
    body_html       text,

    gelesen         boolean NOT NULL DEFAULT false,
    beantwortet     boolean NOT NULL DEFAULT false,
    hat_anhang      boolean NOT NULL DEFAULT false,

    -- Zuordnung zum Geschaeftskontext
    person_id       integer REFERENCES person(person_id),
    beleg_id        integer REFERENCES beleg(beleg_id),

    -- Versandsteuerung fuer ausgehende Mails
    versand_status  varchar(20) DEFAULT 'neu'
                      CHECK (versand_status IN ('neu','wartend','gesendet','fehler')),
    versand_fehler  text,
    versendet_am    timestamp,

    created_at      timestamp NOT NULL DEFAULT now()
);
-- Duplikatschutz beim Abruf: dieselbe UID darf im Ordner nur einmal liegen
CREATE UNIQUE INDEX IF NOT EXISTS ux_email_nachricht_uid
    ON email_nachricht (ordner_id, uid) WHERE uid IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_email_nachricht_person ON email_nachricht (person_id);
CREATE INDEX IF NOT EXISTS ix_email_nachricht_beleg  ON email_nachricht (beleg_id);
CREATE INDEX IF NOT EXISTS ix_email_nachricht_datum  ON email_nachricht (gesendet_am DESC);

-- ── 4. Anhaenge: nur die Verknuepfung, der Inhalt liegt in `dokument` ──────
CREATE TABLE IF NOT EXISTS email_anhang (
    nachricht_id    integer NOT NULL REFERENCES email_nachricht(nachricht_id) ON DELETE CASCADE,
    dokument_id     integer NOT NULL REFERENCES dokument(dokument_id),
    dateiname       varchar(300),              -- Originalname aus der Mail
    inline          boolean NOT NULL DEFAULT false,  -- eingebettetes Bild statt Anhang
    content_id      varchar(200),              -- fuer inline-Referenzen im HTML
    PRIMARY KEY (nachricht_id, dokument_id)
);

-- ============================================================================
-- VORGANG — die Klammer ueber Belege, Mails und Dokumente
-- ============================================================================

CREATE TABLE IF NOT EXISTS vorgang (
    vorgang_id      serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    vorgang_nr      varchar(50),
    bezeichnung     varchar(200) NOT NULL,
    beschreibung    text,
    -- Hauptbeteiligter (Kunde, Klient, Lieferant ...)
    person_id       integer REFERENCES person(person_id),
    status          varchar(20) NOT NULL DEFAULT 'offen'
                      CHECK (status IN ('offen','wartend','abgeschlossen','abgebrochen')),
    eroeffnet_am    date NOT NULL DEFAULT CURRENT_DATE,
    geschlossen_am  date,
    created_at      timestamp NOT NULL DEFAULT now(),
    UNIQUE (mandant_id, vorgang_nr)
);
CREATE INDEX IF NOT EXISTS ix_vorgang_person ON vorgang (person_id);

CREATE TABLE IF NOT EXISTS vorgang_email (
    vorgang_id      integer NOT NULL REFERENCES vorgang(vorgang_id) ON DELETE CASCADE,
    nachricht_id    integer NOT NULL REFERENCES email_nachricht(nachricht_id) ON DELETE CASCADE,
    PRIMARY KEY (vorgang_id, nachricht_id)
);

CREATE TABLE IF NOT EXISTS vorgang_dokument (
    vorgang_id      integer NOT NULL REFERENCES vorgang(vorgang_id) ON DELETE CASCADE,
    dokument_id     integer NOT NULL REFERENCES dokument(dokument_id),
    beschreibung    varchar(300),
    PRIMARY KEY (vorgang_id, dokument_id)
);

-- Belege gehoeren fachlich genauso in den Vorgang wie Mails und Dokumente
CREATE TABLE IF NOT EXISTS vorgang_beleg (
    vorgang_id      integer NOT NULL REFERENCES vorgang(vorgang_id) ON DELETE CASCADE,
    beleg_id        integer NOT NULL REFERENCES beleg(beleg_id),
    PRIMARY KEY (vorgang_id, beleg_id)
);

-- ============================================================================
-- DOKUMENT: Erweiterung fuer Freitext, Sprach- und Videoaufnahmen
-- ============================================================================

-- Vom ANWENDER erfasster Freitext (Notiz, Gespraechsnotiz) — bewusst getrennt
-- von ocr_text, das maschinell Extrahiertes enthaelt (OCR-Ergebnis, spaeter
-- auch Transkripte von Sprachaufnahmen).
ALTER TABLE dokument ADD COLUMN IF NOT EXISTS inhalt_text text;

-- Laufzeit von Audio-/Videoaufnahmen
ALTER TABLE dokument ADD COLUMN IF NOT EXISTS dauer_sekunden integer;

-- Wer hat es erfasst
ALTER TABLE dokument ADD COLUMN IF NOT EXISTS erfasst_von_person_id integer
    REFERENCES person(person_id);

-- Neue Dokumenttypen (global, mandant_id NULL wie die bestehenden sechs)
INSERT INTO dokument_typ (mandant_id, bezeichnung, kategorie)
SELECT NULL, v.bez, v.kat
FROM (VALUES
    ('Notiz',          'Freitext'),
    ('Sprachaufnahme', 'Medien'),
    ('Videoaufnahme',  'Medien'),
    ('E-Mail-Anhang',  'E-Mail'),
    ('E-Mail',         'E-Mail')
) AS v(bez, kat)
WHERE NOT EXISTS (
    SELECT 1 FROM dokument_typ d
    WHERE d.bezeichnung = v.bez AND d.mandant_id IS NULL
);

-- Hinweis zur Speicherung grosser Medien:
--   Sprach-/Videoaufnahmen NICHT in pdf_blob (bytea) ablegen, sondern die
--   Datei im Dateisystem lassen und nur datei_pfad + mime_type + groesse
--   speichern. Postgres kaeme mit bytea zwar zurecht (TOAST), aber Dumps und
--   Backups werden unbrauchbar gross. Fuer Anhaenge normaler Groesse ist
--   pdf_blob dagegen genau richtig.
