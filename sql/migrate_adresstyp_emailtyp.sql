-- ============================================================================
-- Heisenberg: person_adresse.funktion / person_email.typ normalisieren
-- Freitext-Spalten -> echte Fremdschluessel auf adressentyp / emailtyp
--
-- Vorher: person_adresse.funktion (varchar), person_email.typ (varchar) hielten
--   den Adress-/Email-Typ als Freitext, obwohl die Lookup-Tabellen adressentyp
--   und emailtyp bereits existieren (waren aber leer).
-- Nachher: person_adresse.adressentyp_id / person_email.emailtyp_id als
--   zusammengesetzte FK (mandant_id, *_id) auf die jeweilige Typ-Tabelle.
--
-- Datenerhaltend: die bestehenden Freitext-Werte werden pro Mandant in die
--   Typ-Tabellen uebernommen und die Datensaetze darauf gemappt.
-- Transaktional: bei einem Fehler wird alles zurueckgerollt.
-- ============================================================================

BEGIN;

-- ── Adressen ────────────────────────────────────────────────────────────────

-- 1. vorhandene funktion-Werte pro Mandant als adressentyp anlegen
INSERT INTO adressentyp (mandant_id, bezeichnung)
SELECT DISTINCT mandant_id, funktion
FROM person_adresse
WHERE funktion IS NOT NULL AND funktion <> ''
ON CONFLICT (mandant_id, bezeichnung) DO NOTHING;

-- 2. FK-Spalte anlegen und aus dem Freitext mappen
ALTER TABLE person_adresse ADD COLUMN IF NOT EXISTS adressentyp_id integer;

UPDATE person_adresse pa
SET adressentyp_id = at.adressentyp_id
FROM adressentyp at
WHERE at.mandant_id = pa.mandant_id
  AND at.bezeichnung = pa.funktion;

-- 3. FK-Constraint (zusammengesetzt, passend zum adressentyp-PK)
ALTER TABLE person_adresse
    ADD CONSTRAINT person_adresse_adressentyp_fkey
    FOREIGN KEY (mandant_id, adressentyp_id)
    REFERENCES adressentyp (mandant_id, adressentyp_id);

-- 4. Freitext-Spalte entfernen
ALTER TABLE person_adresse DROP COLUMN funktion;

-- ── Emails ──────────────────────────────────────────────────────────────────

INSERT INTO emailtyp (mandant_id, bezeichnung)
SELECT DISTINCT mandant_id, typ
FROM person_email
WHERE typ IS NOT NULL AND typ <> ''
ON CONFLICT (mandant_id, bezeichnung) DO NOTHING;

ALTER TABLE person_email ADD COLUMN IF NOT EXISTS emailtyp_id integer;

UPDATE person_email pe
SET emailtyp_id = et.emailtyp_id
FROM emailtyp et
WHERE et.mandant_id = pe.mandant_id
  AND et.bezeichnung = pe.typ;

ALTER TABLE person_email
    ADD CONSTRAINT person_email_emailtyp_fkey
    FOREIGN KEY (mandant_id, emailtyp_id)
    REFERENCES emailtyp (mandant_id, emailtyp_id);

ALTER TABLE person_email DROP COLUMN typ;

COMMIT;
