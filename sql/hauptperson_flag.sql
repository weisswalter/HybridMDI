-- Hauptperson pro Mandant (die "Besitzer"-Person, meist juristisch).
-- Gehoert wegen der m:n-Struktur in person_mandant, nicht in person.
-- Partieller Unique-Index: pro Mandant hoechstens EINE Hauptperson.
BEGIN;
ALTER TABLE person_mandant ADD COLUMN IF NOT EXISTS ist_hauptperson boolean NOT NULL DEFAULT false;
CREATE UNIQUE INDEX IF NOT EXISTS ux_person_mandant_hauptperson
    ON person_mandant (mandant_id) WHERE ist_hauptperson;
COMMIT;
