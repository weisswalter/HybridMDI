-- ============================================================================
-- Heisenberg: Land/Bezirk-Tabellen, Adress-Erweiterung, Person-Zusatzfelder,
-- Beziehungs-Flags. PostgreSQL DDL, transaktional + datenerhaltend.
-- ============================================================================

BEGIN;

-- ── Land ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS land (
    land_id   serial PRIMARY KEY,
    land_name varchar(100) NOT NULL UNIQUE,
    iso_code  varchar(3)
);

INSERT INTO land (land_name, iso_code) VALUES
    ('Schweiz', 'CH'),
    ('Deutschland', 'DE'),
    ('Österreich', 'AT'),
    ('Liechtenstein', 'LI')
ON CONFLICT (land_name) DO NOTHING;

-- ── Bezirk (gehoert zu einem Land) ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bezirk (
    bezirk_id   serial PRIMARY KEY,
    land_id     integer NOT NULL REFERENCES land(land_id),
    bezirk_name varchar(100) NOT NULL,
    UNIQUE (land_id, bezirk_name)
);

-- Schweiz (Kantone als Bezirke)
INSERT INTO bezirk (land_id, bezirk_name)
SELECT l.land_id, v.name FROM land l
CROSS JOIN (VALUES ('St. Gallen'),('Zürich'),('Graubünden'),('Bern'),('Aargau'),('Thurgau')) v(name)
WHERE l.land_name = 'Schweiz'
ON CONFLICT (land_id, bezirk_name) DO NOTHING;

-- Deutschland (Bundeslaender)
INSERT INTO bezirk (land_id, bezirk_name)
SELECT l.land_id, v.name FROM land l
CROSS JOIN (VALUES ('Bayern'),('Baden-Württemberg'),('Nordrhein-Westfalen'),('Hessen'),('Berlin')) v(name)
WHERE l.land_name = 'Deutschland'
ON CONFLICT (land_id, bezirk_name) DO NOTHING;

-- Österreich (Bundeslaender)
INSERT INTO bezirk (land_id, bezirk_name)
SELECT l.land_id, v.name FROM land l
CROSS JOIN (VALUES ('Wien'),('Tirol'),('Vorarlberg'),('Salzburg'),('Steiermark')) v(name)
WHERE l.land_name = 'Österreich'
ON CONFLICT (land_id, bezirk_name) DO NOTHING;

-- ── adresse: Land + Bezirk ──────────────────────────────────────────────────
ALTER TABLE adresse ADD COLUMN IF NOT EXISTS land_id   integer REFERENCES land(land_id);
ALTER TABLE adresse ADD COLUMN IF NOT EXISTS bezirk_id integer REFERENCES bezirk(bezirk_id);

-- ── person: Beschreibung + Photo ────────────────────────────────────────────
ALTER TABLE person ADD COLUMN IF NOT EXISTS beschreibung text;
ALTER TABLE person ADD COLUMN IF NOT EXISTS photo        bytea;

-- ── person_beziehung: drei Flags (bezogen auf die Besitzer-/Hauptperson) ────
ALTER TABLE person_beziehung ADD COLUMN IF NOT EXISTS ist_mitarbeiter boolean NOT NULL DEFAULT false;
ALTER TABLE person_beziehung ADD COLUMN IF NOT EXISTS ist_kunde       boolean NOT NULL DEFAULT false;
ALTER TABLE person_beziehung ADD COLUMN IF NOT EXISTS ist_kontakt     boolean NOT NULL DEFAULT false;

COMMIT;
