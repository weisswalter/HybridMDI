-- ============================================================================
-- Kursmodul — Stand 28.07.2026
--
-- ZENTRALE ENTSCHEIDUNG: Trennung von Curriculum und Durchfuehrung.
--   `kurs`              = WAS gelehrt wird (Lernziele, Stunden, Material,
--                         Aufbau aus Unterkursen) — bleibt ueber Jahre gleich
--   `kurs_durchfuehrung` = die konkrete Runde (Semester, Lehrer, Raum,
--                         Teilnehmer, Termine)
-- Ohne diese Trennung muesste beim jaehrlichen Wiederholen alles neu erfasst
-- werden (Walter: "koennte sich im naechsten Jahr wiederholen").
--
-- Wiederverwendet: person/person_beziehung (Lehrer via ist_lehrer), raum +
-- raum_ausstattung, artikel/artikel_fach (Material), semester, klient,
-- dokument (Kompetenznachweise), leistung (Fakturierung).
-- ============================================================================

-- Fuer die EXCLUDE-Constraints gegen Doppelbelegung (Raum/Lehrer)
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- ── 1. Kompetenzen ─────────────────────────────────────────────────────────
-- Gelten in DREI Rollen (siehe kurs_kompetenz): der Lehrer muss sie haben,
-- der Kurs vermittelt sie, oder er setzt sie beim Teilnehmer voraus.
CREATE TABLE IF NOT EXISTS kompetenz_typ (
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    kompetenz_id    serial,
    bezeichnung     varchar(150) NOT NULL,
    beschreibung    text,
    -- Viele Nachweise laufen ab (Erste Hilfe, Staplerschein). NULL = unbefristet.
    gueltigkeit_monate integer,
    -- Woher stammt die Anforderung: Hersteller, Gesetzgeber, intern ...
    quelle          varchar(100),
    aktiv           boolean NOT NULL DEFAULT true,
    PRIMARY KEY (mandant_id, kompetenz_id),
    UNIQUE (mandant_id, bezeichnung)
);

-- Nachweis einer Kompetenz bei einer Person (Lehrer ODER Teilnehmer)
CREATE TABLE IF NOT EXISTS person_kompetenz (
    person_kompetenz_id serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    kompetenz_id    integer NOT NULL,
    erworben_am     date,
    gueltig_bis     date,            -- aus gueltigkeit_monate errechenbar
    -- Der Nachweis selbst (Zertifikat, Zeugnis) als Dokument
    dokument_id     integer REFERENCES dokument(dokument_id),
    bemerkung       text,
    FOREIGN KEY (mandant_id, kompetenz_id)
        REFERENCES kompetenz_typ(mandant_id, kompetenz_id),
    UNIQUE (person_id, kompetenz_id, erworben_am)
);
CREATE INDEX IF NOT EXISTS ix_person_kompetenz_person ON person_kompetenz (person_id);

-- ── 2. Kurs = Curriculum ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS kurs (
    kurs_id         serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    kurs_nr         varchar(50),
    bezeichnung     varchar(200) NOT NULL,
    beschreibung    text,
    lernziele       text,
    unterrichtsstunden numeric(6,2),
    min_teilnehmer  integer,          -- darunter faellt die Durchfuehrung aus
    max_teilnehmer  integer,
    -- Fakturierung: der Kurs als abrechenbare Leistung
    leistung_id     integer REFERENCES leistung(leistung_id),
    preis_pro_teilnehmer numeric(12,2),
    aktiv           boolean NOT NULL DEFAULT true,
    created_at      timestamp NOT NULL DEFAULT now(),
    UNIQUE (mandant_id, kurs_nr)
);

-- ── 3. Baukasten: Kurs aus Unterkursen ─────────────────────────────────────
-- m:n statt parent_id, damit derselbe Unterkurs in mehreren Oberkursen
-- vorkommen kann (Modul-Baukasten) — dasselbe Muster wie artikel_artikel.
CREATE TABLE IF NOT EXISTS kurs_kurs (
    kurs_id         integer NOT NULL REFERENCES kurs(kurs_id) ON DELETE CASCADE,
    unter_kurs_id   integer NOT NULL REFERENCES kurs(kurs_id),
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    position        integer,
    pflicht         boolean NOT NULL DEFAULT true,
    PRIMARY KEY (kurs_id, unter_kurs_id),
    -- Faengt nur die direkte Selbstreferenz ab. Mehrstufige Zyklen
    -- (A->B->C->A) muss die Anwendung pruefen — analog artikel_artikel,
    -- wo dafuer ein rekursiver Trigger existiert.
    CHECK (kurs_id <> unter_kurs_id)
);

-- ── 4. Kompetenzen am Kurs, in drei Rollen ─────────────────────────────────
CREATE TABLE IF NOT EXISTS kurs_kompetenz (
    kurs_id         integer NOT NULL REFERENCES kurs(kurs_id) ON DELETE CASCADE,
    kompetenz_id    integer NOT NULL,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    rolle           varchar(20) NOT NULL
        CHECK (rolle IN ('lehrer', 'vermittelt', 'voraussetzung')),
    -- lehrer        = der Kursleiter muss diese Kompetenz nachweisen
    -- vermittelt    = der Teilnehmer erwirbt sie mit dem Kursabschluss
    -- voraussetzung = der Teilnehmer muss sie zur Anmeldung schon haben
    PRIMARY KEY (kurs_id, kompetenz_id, rolle),
    FOREIGN KEY (mandant_id, kompetenz_id)
        REFERENCES kompetenz_typ(mandant_id, kompetenz_id)
);

-- ── 5. Material am Curriculum ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS kurs_material (
    kurs_id         integer NOT NULL REFERENCES kurs(kurs_id) ON DELETE CASCADE,
    artikel_id      integer NOT NULL REFERENCES artikel(artikel_id),
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    -- Der Bedarf ergibt sich aus:
    --   menge_pauschal + menge_pro_teilnehmer * Anzahl bestaetigter Teilnehmer
    menge_pauschal       numeric(12,3) DEFAULT 0,
    menge_pro_teilnehmer numeric(12,3) DEFAULT 0,
    einheit_id      integer,
    -- Werkzeug kommt zurueck, Verbrauchsmaterial nicht
    rueckgabe_erwartet boolean NOT NULL DEFAULT false,
    PRIMARY KEY (kurs_id, artikel_id),
    FOREIGN KEY (mandant_id, einheit_id) REFERENCES einheit(mandant_id, einheit_id)
);

-- ── 6. Durchfuehrung = die konkrete Runde ──────────────────────────────────
CREATE TABLE IF NOT EXISTS kurs_durchfuehrung (
    durchfuehrung_id serial PRIMARY KEY,
    kurs_id         integer NOT NULL REFERENCES kurs(kurs_id),
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    semester_id     integer REFERENCES semester(semester_id),
    bezeichnung     varchar(200),     -- z.B. 'Gruppe A, Vormittag'
    -- Standardwerte; je Termin ueberschreibbar
    leiter_person_id integer REFERENCES person(person_id),
    raum_id         integer REFERENCES raum(raum_id),
    von_datum       date,
    bis_datum       date,
    status          varchar(20) NOT NULL DEFAULT 'geplant'
        CHECK (status IN ('geplant','laeuft','abgeschlossen','abgesagt')),
    bemerkung       text,
    created_at      timestamp NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_kurs_durchfuehrung_kurs ON kurs_durchfuehrung (kurs_id);
CREATE INDEX IF NOT EXISTS ix_kurs_durchfuehrung_sem  ON kurs_durchfuehrung (semester_id);

-- ── 7. Termine (Stundenplan) ───────────────────────────────────────────────
-- Einzeltermine, erzeugt von einem Serien-Assistenten — KEINE
-- Wiederholungsregel in der DB, damit jeder Termin einzeln verschieb- und
-- absagbar bleibt.
CREATE TABLE IF NOT EXISTS kurs_termin (
    termin_id       serial PRIMARY KEY,
    durchfuehrung_id integer NOT NULL REFERENCES kurs_durchfuehrung(durchfuehrung_id) ON DELETE CASCADE,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    zeitraum        tstzrange NOT NULL,
    -- Beim Anlegen aus der Durchfuehrung MATERIALISIEREN (kopieren), nicht
    -- per NULL erben — sonst greifen die EXCLUDE-Constraints unten nicht.
    raum_id         integer REFERENCES raum(raum_id),
    leiter_person_id integer REFERENCES person(person_id),
    thema           varchar(300),
    status          varchar(20) NOT NULL DEFAULT 'geplant'
        CHECK (status IN ('geplant','stattgefunden','ausgefallen','verschoben')),
    bemerkung       text
);
CREATE INDEX IF NOT EXISTS ix_kurs_termin_df ON kurs_termin (durchfuehrung_id);

-- Doppelbelegung verhindert die DATENBANK, nicht die Anwendungslogik:
-- derselbe Raum bzw. derselbe Lehrer kann nicht zweimal gleichzeitig verplant
-- werden — auch nicht durch einen Fehler im Delphi-Code oder direktes SQL.
ALTER TABLE kurs_termin DROP CONSTRAINT IF EXISTS ex_kurs_termin_raum;
ALTER TABLE kurs_termin ADD CONSTRAINT ex_kurs_termin_raum
    EXCLUDE USING gist (raum_id WITH =, zeitraum WITH &&)
    WHERE (raum_id IS NOT NULL AND status <> 'ausgefallen');

ALTER TABLE kurs_termin DROP CONSTRAINT IF EXISTS ex_kurs_termin_leiter;
ALTER TABLE kurs_termin ADD CONSTRAINT ex_kurs_termin_leiter
    EXCLUDE USING gist (leiter_person_id WITH =, zeitraum WITH &&)
    WHERE (leiter_person_id IS NOT NULL AND status <> 'ausgefallen');

-- ── 8. Teilnehmer ──────────────────────────────────────────────────────────
-- Bewusst gegen `person`, nicht gegen `klient`: so koennen auch Mitarbeiter
-- in Weiterbildung oder externe Gaeste teilnehmen. Wer Klient ist, steht
-- ohnehin in der klient-Tabelle.
CREATE TABLE IF NOT EXISTS kurs_teilnehmer (
    durchfuehrung_id integer NOT NULL REFERENCES kurs_durchfuehrung(durchfuehrung_id) ON DELETE CASCADE,
    person_id       integer NOT NULL REFERENCES person(person_id),
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    angemeldet_am   date NOT NULL DEFAULT CURRENT_DATE,
    status          varchar(20) NOT NULL DEFAULT 'angemeldet'
        CHECK (status IN ('angemeldet','bestaetigt','abgemeldet','abgeschlossen','abgebrochen')),
    -- Abschluss: erworbene Kompetenzen werden bei 'abgeschlossen' aus
    -- kurs_kompetenz (rolle='vermittelt') nach person_kompetenz uebernommen
    abgeschlossen_am date,
    note            varchar(20),
    bemerkung       text,
    PRIMARY KEY (durchfuehrung_id, person_id)
);
CREATE INDEX IF NOT EXISTS ix_kurs_teilnehmer_person ON kurs_teilnehmer (person_id);

-- ── 9. Anwesenheit je Termin ───────────────────────────────────────────────
-- Im Arbeitsagogik-Umfeld i.d.R. Nachweispflicht gegenueber dem Kostentraeger.
CREATE TABLE IF NOT EXISTS kurs_anwesenheit (
    termin_id       integer NOT NULL REFERENCES kurs_termin(termin_id) ON DELETE CASCADE,
    person_id       integer NOT NULL REFERENCES person(person_id),
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    anwesend        boolean NOT NULL DEFAULT false,
    entschuldigt    boolean NOT NULL DEFAULT false,
    fehlminuten     integer,
    bemerkung       text,
    PRIMARY KEY (termin_id, person_id)
);

-- ── 10. Verbindung zum Vorgang (Ticket/Akte) ───────────────────────────────
ALTER TABLE vorgang ADD COLUMN IF NOT EXISTS durchfuehrung_id integer
    REFERENCES kurs_durchfuehrung(durchfuehrung_id);

-- Beleg kennt seinen Ausloeser: die Materialentnahme fuer eine Durchfuehrung
ALTER TABLE beleg ADD COLUMN IF NOT EXISTS durchfuehrung_id integer
    REFERENCES kurs_durchfuehrung(durchfuehrung_id);

-- ── 11. Sicht: Materialbedarf je Durchfuehrung ─────────────────────────────
-- Rechnet den Bedarf aus Curriculum-Material und bestaetigten Teilnehmern.
-- Grundlage fuer den Knopf "Entnahme erzeugen" im Kursmodul.
CREATE OR REPLACE VIEW v_kurs_materialbedarf AS
SELECT d.durchfuehrung_id,
       d.mandant_id,
       m.artikel_id,
       a.artikel_nr,
       a.artikelname,
       m.einheit_id,
       m.rueckgabe_erwartet,
       COALESCE(m.menge_pauschal, 0)
         + COALESCE(m.menge_pro_teilnehmer, 0) * COALESCE(t.anzahl, 0) AS bedarf,
       COALESCE(t.anzahl, 0) AS teilnehmer,
       COALESCE(b.bestand, 0) AS bestand_gesamt
FROM kurs_durchfuehrung d
JOIN kurs_material m ON m.kurs_id = d.kurs_id
JOIN artikel a       ON a.artikel_id = m.artikel_id
LEFT JOIN (
    SELECT durchfuehrung_id, count(*) AS anzahl
    FROM kurs_teilnehmer
    WHERE status IN ('bestaetigt','abgeschlossen')
    GROUP BY durchfuehrung_id
) t ON t.durchfuehrung_id = d.durchfuehrung_id
LEFT JOIN (
    SELECT artikel_id, sum(bestand) AS bestand
    FROM artikel_fach GROUP BY artikel_id
) b ON b.artikel_id = m.artikel_id;
