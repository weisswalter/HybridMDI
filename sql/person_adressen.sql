-- ============================================================================
-- Heisenberg: fehlende Tabellen fuer Person <-> Telefonnummer (m:n) + emailtyp
-- PostgreSQL DDL
--
-- Bereits vorhanden in TRTHeisenberg (per psql geprueft, NICHT erneut anlegen):
--   person, mandant, person_mandant, adresse, adressentyp,
--   emailadresse, person_adresse, person_email
-- Hinweis: adressentyp existiert bereits (ohne mandant_id), wird aber von
-- person_adresse.funktion (freier Text) noch nicht referenziert. person_email.typ
-- ist ebenfalls freier Text. Beides hier unangetastet gelassen (bestehende Module).
--
-- Typ-Tabellen sind pro Mandant anpassbar -> mandant_id ist Teil des PK.
-- ============================================================================

-- ── Typ-Tabelle fuer Email (existiert noch nicht) ──────────────────────────

CREATE TABLE IF NOT EXISTS emailtyp (
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    emailtyp_id  serial  NOT NULL,
    bezeichnung  varchar(50) NOT NULL,
    PRIMARY KEY (mandant_id, emailtyp_id),
    UNIQUE (mandant_id, bezeichnung)
);

-- ── Telefonnummer: Stammdaten, Typ-Tabelle (pro Mandant), m:n-Verknuepfung ──

CREATE TABLE IF NOT EXISTS telefonnummertyp (
    mandant_id           integer NOT NULL REFERENCES mandant(mandant_id),
    telefonnummertyp_id  serial  NOT NULL,
    bezeichnung          varchar(50) NOT NULL,
    PRIMARY KEY (mandant_id, telefonnummertyp_id),
    UNIQUE (mandant_id, bezeichnung)
);

CREATE TABLE IF NOT EXISTS telefonnummer (
    telefonnummer_id serial PRIMARY KEY,
    nummer           varchar(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS person_telefonnummer (
    person_id            integer NOT NULL REFERENCES person(person_id),
    telefonnummer_id     integer NOT NULL REFERENCES telefonnummer(telefonnummer_id),
    mandant_id           integer NOT NULL REFERENCES mandant(mandant_id),
    telefonnummertyp_id  integer,
    PRIMARY KEY (person_id, telefonnummer_id, mandant_id),
    FOREIGN KEY (mandant_id, telefonnummertyp_id)
        REFERENCES telefonnummertyp(mandant_id, telefonnummertyp_id)
);
