-- ============================================================================
-- Klient- und Kunde-Module: erweitern die BESTEHENDE person/person_beziehung-
-- Infrastruktur (siehe project_heisenberg_db_schema) um die von Walter
-- vorgelegten CRM-Felder (Kontakt Klient / Kontakt Kunde), statt eine
-- parallele Personen-Verwaltung aufzubauen.
--
-- Wiederverwendet (KEINE neuen Spalten/Tabellen noetig):
--   - Name/Vorname            -> person.vorname / person.nachname_firmenname
--   - E-Mail (+ zweite)       -> person_email (m:n, mehrere Adressen moeglich)
--   - Telefon Geschaeft/Mobil/Fax -> person_telefonnummer + telefonnummertyp
--     (Fax/Firmenpool/Festnetz/Mobil existieren schon)
--   - Postadresse komplett    -> adresse/person_adresse (inkl. Kanton = bezirk)
--   - Beschreibung            -> person.beschreibung
--   - "Kunde" als Rolle       -> person_beziehung.ist_kunde (existiert schon
--     seit den Bestellungs-Modulen, sql/rechnungstyp_beleg.sql)
--
-- Neu ergaenzt:
--   - person.titel, person.geburtsdatum (generisch nuetzlich, nicht nur Klient)
--   - telefonnummertyp: 'Privat', 'Alternativ' (Walters Feldliste braucht
--     mehr Typen als bisher vorhanden)
--   - person_beziehung.ist_klient (analog ist_lieferant/ist_lehrer-Muster)
--   - leadquelle_typ (Lookup, mandantenbezogen wie adressentyp)
--   - semester (Zeitabschnitt, mandantenbezogen) + klient_semester (m:n,
--     ein Klient kann ueber mehrere Semester hinweg erfasst sein)
--   - klient (Erweiterungstabelle zu person: Kundenname-Verknuepfung,
--     Abteilung, Lead-Quelle, Besitzer)
--   - kunde (Erweiterungstabelle zu person: nur Besitzer -- Name/Kontakte/
--     Adresse/Email/Telefon kommen komplett aus person/person_*)
-- ============================================================================

ALTER TABLE person ADD COLUMN IF NOT EXISTS titel varchar(50);
ALTER TABLE person ADD COLUMN IF NOT EXISTS geburtsdatum date;

INSERT INTO telefonnummertyp (mandant_id, bezeichnung)
SELECT m.mandant_id, v.bezeichnung
FROM mandant m
CROSS JOIN (VALUES ('Privat'), ('Alternativ')) AS v(bezeichnung)
ON CONFLICT (mandant_id, bezeichnung) DO NOTHING;

ALTER TABLE person_beziehung ADD COLUMN IF NOT EXISTS ist_klient boolean NOT NULL DEFAULT false;

-- ── Lead-Quelle (Lookup, je Mandant anpassbar) ──────────────────────────────
CREATE TABLE IF NOT EXISTS leadquelle_typ (
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    leadquelle_id serial,
    bezeichnung  varchar(100) NOT NULL,
    PRIMARY KEY (mandant_id, leadquelle_id),
    UNIQUE (mandant_id, bezeichnung)
);

INSERT INTO leadquelle_typ (mandant_id, bezeichnung)
SELECT m.mandant_id, v.bezeichnung
FROM mandant m
CROSS JOIN (VALUES
    ('Website'), ('Empfehlung'), ('Telefonakquise'), ('Messe'), ('Sonstige')
) AS v(bezeichnung)
ON CONFLICT (mandant_id, bezeichnung) DO NOTHING;

-- ── Semester (Zeitabschnitt) -- Klienten werden semesterweise gefuehrt ──────
CREATE TABLE IF NOT EXISTS semester (
    semester_id serial PRIMARY KEY,
    mandant_id  integer NOT NULL REFERENCES mandant(mandant_id),
    bezeichnung varchar(100) NOT NULL,   -- z.B. 'Herbstsemester 2026'
    von_datum   date,
    bis_datum   date,
    UNIQUE (mandant_id, bezeichnung)
);

-- ── Klient: Erweiterung von person um die CRM-spezifischen Felder ──────────
CREATE TABLE IF NOT EXISTS klient (
    klient_id         serial PRIMARY KEY,
    person_id         integer NOT NULL UNIQUE REFERENCES person(person_id),
    mandant_id        integer NOT NULL REFERENCES mandant(mandant_id),
    -- "Kundenname" -> Verknuepfung mit Kunde (ebenfalls ein person-Datensatz)
    kunde_person_id   integer REFERENCES person(person_id),
    abteilung         varchar(100),
    leadquelle_id     integer,
    -- "Klienten-Besitzer" -> Mitarbeiter (Person mit ist_mitarbeiter=true)
    besitzer_person_id integer REFERENCES person(person_id),
    FOREIGN KEY (mandant_id, leadquelle_id) REFERENCES leadquelle_typ(mandant_id, leadquelle_id)
);

-- ── Klient <-> Semester (m:n, mehrfache Einschreibung ueber die Zeit) ──────
CREATE TABLE IF NOT EXISTS klient_semester (
    klient_id   integer NOT NULL REFERENCES klient(klient_id),
    semester_id integer NOT NULL REFERENCES semester(semester_id),
    mandant_id  integer NOT NULL REFERENCES mandant(mandant_id),
    PRIMARY KEY (klient_id, semester_id)
);

-- ── Kunde: Erweiterung von person -- Name/Kontakte/Adresse/E-Mail/Telefon
--    kommen bereits vollstaendig aus person/person_email/person_telefonnummer/
--    person_adresse; "Kunde" als Rolle ist person_beziehung.ist_kunde
--    (schon vorhanden). Hier nur das zusaetzliche Feld "Kunden-Besitzer".
CREATE TABLE IF NOT EXISTS kunde (
    kunde_id           serial PRIMARY KEY,
    person_id          integer NOT NULL UNIQUE REFERENCES person(person_id),
    mandant_id         integer NOT NULL REFERENCES mandant(mandant_id),
    besitzer_person_id integer REFERENCES person(person_id)
);
