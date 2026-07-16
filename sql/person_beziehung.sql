-- ============================================================================
-- Heisenberg: person_beziehung (m:n Person<->Person mit Rolle, pro Mandant)
-- PostgreSQL DDL
--
-- Voraussetzung: rolle_typ existiert bereits, aber noch mit einfachem PK
-- (rolle_id) und nullable mandant_id -- das passt nicht zum Muster "Typ-
-- Tabellen sind pro Mandant, mandant_id gehoert in den PK" (siehe emailtyp,
-- telefonnummertyp). Wird hier nachgezogen, da aktuell keine NULL-Werte und
-- keine Duplikate in mandant_id/rolle_id vorliegen (geprueft).
-- ============================================================================

ALTER TABLE rolle_typ
    ALTER COLUMN mandant_id SET NOT NULL;

ALTER TABLE rolle_typ
    DROP CONSTRAINT rolle_typ_pkey;

ALTER TABLE rolle_typ
    ADD PRIMARY KEY (mandant_id, rolle_id);

ALTER TABLE rolle_typ
    ADD CONSTRAINT rolle_typ_mandant_bezeichnung_key UNIQUE (mandant_id, rollen_bezeichnung);

-- ── person_beziehung ────────────────────────────────────────────────────────
--
-- Fehler in der urspruenglichen Fassung:
--  1. person(mandant_id, person_id) -- person hat gar keine mandant_id-Spalte;
--     Person<->Mandant ist m:n ueber person_mandant. Richtig: gegen
--     person_mandant(mandant_id, person_id) referenzieren (genau dessen PK).
--  2. persontyp(mandant_id, persontyp_id) -- Tabelle heisst weder "persontyp"
--     noch hat sie diese Spalten. Gemeint war rolle_typ (Spalte rolle_id),
--     jetzt mit (mandant_id, rolle_id) als PK referenzierbar.

CREATE TABLE person_beziehung (
    beziehungs_id     SERIAL NOT NULL,
    mandant_id        INTEGER NOT NULL,
    quell_person_id   INTEGER NOT NULL,
    ziel_person_id    INTEGER NOT NULL,
    rolle_id          INTEGER NOT NULL,

    PRIMARY KEY (mandant_id, beziehungs_id),

    FOREIGN KEY (mandant_id)
        REFERENCES mandant(mandant_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    FOREIGN KEY (mandant_id, quell_person_id)
        REFERENCES person_mandant(mandant_id, person_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (mandant_id, ziel_person_id)
        REFERENCES person_mandant(mandant_id, person_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    FOREIGN KEY (mandant_id, rolle_id)
        REFERENCES rolle_typ(mandant_id, rolle_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
