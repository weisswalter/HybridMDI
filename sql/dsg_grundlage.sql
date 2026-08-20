-- ============================================================================
-- DSG-Fundament: Zweckbindung, Informationspflicht, Einwilligung
-- Stand 03.08.2026 (DS-01, DS-02, DS-03)
--
-- WICHTIGE GRENZE VORWEG: Alles hier ist TECHNISCHES FUNDAMENT — Tabellen und
-- Funktionen, die eine korrekte DSG-Umsetzung BRAUCHT. Ob die eingetragenen
-- Zwecke, Rechtsgrundlagen und Texte tatsächlich zutreffen, ist eine
-- rechtliche Frage, keine technische. Rechtstexte bleiben hier PLATZHALTER.
--
-- `vorgang` wird bisher von KEINEM Delphi-Modul beschrieben (geprüft:
-- kein Treffer für 'vorgang' in allen .pas-Dateien) — die neue Spalte ist
-- deshalb ohne jedes Risiko für bestehenden, kompilierten Code.
-- ============================================================================

-- ── DS-01: Zweckbindung ─────────────────────────────────────────────────────
-- Jeder Vorgang (= die "Akte" im Sinn der Story) bekommt einen Verweis auf
-- eine dokumentierte Verarbeitungstätigkeit aus dem VBT (sql/dsg_verzeichnis.sql).
-- Damit ist der Zweck nicht Freitext, sondern zeigt auf das, was im VBT
-- ohnehin schon zu Rechtsgrundlage und Aufbewahrung dokumentiert ist — ein
-- Vorgang OHNE dort hinterlegten Zweck kann nicht auf einen erfundenen
-- verweisen.
ALTER TABLE vorgang ADD COLUMN IF NOT EXISTS verwendungszweck_id integer
    REFERENCES verarbeitungstaetigkeit(taetigkeit_id);

COMMENT ON COLUMN vorgang.verwendungszweck_id IS
    'Verweist auf verarbeitungstaetigkeit (VBT) - der dokumentierte Zweck, '
    'fuer den dieser Vorgang angelegt wurde.';

-- BEWUSST KEIN NOT NULL / Pflichtfeld-Constraint: das würde bestehende und
-- künftige Erfassungswege blockieren, ohne dass irgendein Delphi-Formular
-- schon eine Auswahl dafür anbietet — die Story verlangt "muss ausgewählt
-- werden", aber das durchzusetzen ist eine GUI-Entscheidung (welches Feld,
-- wo im Formular), keine, die nachts am Schema getroffen werden sollte.
-- Stattdessen die ehrliche Zwischenlösung: eine Arbeitsliste, wie bei der
-- Belegpflicht (v_beleg_fehlt).
CREATE OR REPLACE VIEW v_vorgang_ohne_zweck AS
SELECT vorgang_id, mandant_id, vorgang_nr, bezeichnung, person_id, eroeffnet_am
  FROM vorgang
 WHERE verwendungszweck_id IS NULL AND status <> 'abgebrochen';

-- ── DS-02: Informationspflicht ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS datenschutzinformation (
    info_id      serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    sprache      varchar(5) NOT NULL DEFAULT 'de',
    version      integer NOT NULL DEFAULT 1,
    text_inhalt  text NOT NULL,
    gueltig_ab   date NOT NULL DEFAULT CURRENT_DATE,
    aktiv        boolean NOT NULL DEFAULT true,
    UNIQUE (mandant_id, sprache, version)
);

COMMENT ON TABLE datenschutzinformation IS
    'Der tatsaechliche Informationstext ist hier NICHT vorausgefuellt - er '
    'muss von Walter/einer Rechtsberatung formuliert werden, nicht von mir '
    'nachts erfunden. Struktur steht, Inhalt fehlt bewusst.';

-- Protokoll: WER hat WELCHE Version WANN zur Kenntnis genommen. Ein zweiter
-- Eintrag für dieselbe Version überschreibt den ersten nicht (append-only im
-- Sinn der Sache) — kommt jemand später mit derselben Person/Version wieder
-- vorbei, ist das eine neue, eigene Kenntnisnahme.
CREATE TABLE IF NOT EXISTS datenschutz_kenntnisnahme (
    kenntnisnahme_id serial PRIMARY KEY,
    person_id    integer NOT NULL REFERENCES person(person_id),
    info_id      integer NOT NULL REFERENCES datenschutzinformation(info_id),
    zeitpunkt    timestamp NOT NULL DEFAULT clock_timestamp(),
    quelle       varchar(50) NOT NULL DEFAULT 'ersterfassung'
                   CHECK (quelle IN ('ersterfassung', 'login', 'manuell'))
);

CREATE INDEX IF NOT EXISTS ix_kenntnisnahme_person
    ON datenschutz_kenntnisnahme (person_id, zeitpunkt DESC);

-- Hat eine Person die AKTUELLE Version zur Kenntnis genommen? Praktisch für
-- eine künftige Login-/Ersterfassungsmaske: nur fragen, wenn nötig.
CREATE OR REPLACE FUNCTION fn_kenntnisnahme_aktuell(
    p_person_id integer, p_mandant_id integer, p_sprache varchar DEFAULT 'de')
RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1 FROM datenschutz_kenntnisnahme k
        JOIN datenschutzinformation i ON i.info_id = k.info_id
       WHERE k.person_id = p_person_id
         AND i.mandant_id = p_mandant_id AND i.sprache = p_sprache
         AND i.info_id = (SELECT info_id FROM datenschutzinformation
                            WHERE mandant_id = p_mandant_id
                              AND sprache = p_sprache AND aktiv
                            ORDER BY version DESC LIMIT 1));
$$;

-- ── DS-03: Einwilligungen (Consent) ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS einwilligung (
    einwilligung_id serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    zweck           varchar(200) NOT NULL,   -- z.B. "Weitergabe an Drittstellen"
    status          varchar(20) NOT NULL DEFAULT 'erteilt'
                      CHECK (status IN ('erteilt', 'widerrufen')),
    erteilt_am      timestamp NOT NULL DEFAULT clock_timestamp(),
    widerrufen_am   timestamp,
    eingeholt_von_person_id integer REFERENCES person(person_id),
    dokument_id     integer REFERENCES dokument(dokument_id),  -- Nachweis
    bemerkung       text,
    UNIQUE (person_id, zweck)
);

COMMENT ON TABLE einwilligung IS
    'Pro Person und Zweck genau EIN aktueller Satz - die Historie (wann '
    'erteilt, wann widerrufen, wer hat was geaendert) steht im audit_log, '
    'wenn diese Tabelle dort angemeldet wird (siehe unten).';

CREATE INDEX IF NOT EXISTS ix_einwilligung_person ON einwilligung (person_id);

CREATE OR REPLACE FUNCTION fn_einwilligung_widerrufen(p_einwilligung_id integer)
RETURNS void
LANGUAGE sql AS $$
    UPDATE einwilligung SET status = 'widerrufen', widerrufen_am = clock_timestamp()
     WHERE einwilligung_id = p_einwilligung_id;
$$;

-- Die eigentliche Prüffunktion — DAS ist die Stelle, die eine künftige
-- "Weitergabe"-Funktion vor der eigentlichen Aktion aufrufen sollte
-- ("Ein Widerruf stellt die Verarbeitung sofort ein"). Fehlt die Einwilligung
-- komplett, gilt sie als NICHT erteilt (sicherer Default) statt als Fehler.
CREATE OR REPLACE FUNCTION fn_hat_einwilligung(p_person_id integer, p_zweck varchar)
RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(
        (SELECT status = 'erteilt' FROM einwilligung
          WHERE person_id = p_person_id AND zweck = p_zweck), false);
$$;

COMMENT ON FUNCTION fn_hat_einwilligung IS
    'Pruefprimitive, NICHT verdrahtet: heute Nacht bewusst an keine '
    'bestehende Funktion (z.B. Zuwendungsabruf, Mailversand) angehaengt.'
    ' Welche konkreten Vorgaenge eine Einwilligung brauchen, ist eine '
    'fachliche Entscheidung je Feature - siehe Morgenbericht.';

-- Verlauf mit ins Audit-Log aufnehmen — passt genau ins gestern gebaute
-- Muster (sql/audit_log.sql) und macht Erteilung/Widerruf nachvollziehbar.
DROP TRIGGER IF EXISTS tr_audit_einwilligung ON einwilligung;
CREATE TRIGGER tr_audit_einwilligung
    AFTER INSERT OR UPDATE OR DELETE ON einwilligung
    FOR EACH ROW EXECUTE FUNCTION fn_audit_erfassen('einwilligung_id');
