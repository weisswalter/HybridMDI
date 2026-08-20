-- ============================================================================
-- Formatprüfungen für Kontaktdaten — Stand 03.08.2026 (DQ-01)
--
-- ADDITIV UND GEPRÜFT: Vor dem Hinzufügen wurde die vorhandene Datenmenge
-- gegen jede Regel geprüft (3 E-Mail-Adressen, 0 Telefonnummern, alle
-- vorhandenen PLZ) — 0 Verstösse. Deshalb NICHT NOT VALID belassen, sondern
-- sofort vollständig validiert; das ist strenger und ehrlicher als eine
-- Prüfung, die nur für künftige Zeilen gilt.
--
-- BEWUSST PERMISSIV: Diese Muster sollen offensichtlichen Unsinn abfangen
-- (kein @, Buchstaben in der PLZ), nicht jede erdenkliche gültige Schreibweise
-- durchsetzen. Eine zu strenge Regel lehnt echte Adressen ab — das wäre in
-- einem Klientenverwaltungssystem der teurere Fehler.
--
-- GRENZE: Die PLZ-Regel (4 oder 5 Ziffern) passt für CH/DE/AT, nicht für
-- jedes Land. `adresse.land_id` existiert bereits — eine landesabhängige
-- Prüfung wäre der nächste Schritt, aber eine Entscheidung, die eine echte
-- Formularänderung braucht (welches Land zuerst wählen?), keine reine
-- Schema-Ergänzung.
-- ============================================================================

ALTER TABLE emailadresse DROP CONSTRAINT IF EXISTS emailadresse_format_check;
ALTER TABLE emailadresse ADD CONSTRAINT emailadresse_format_check
    CHECK (email_adresse ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$');

ALTER TABLE telefonnummer DROP CONSTRAINT IF EXISTS telefonnummer_format_check;
ALTER TABLE telefonnummer ADD CONSTRAINT telefonnummer_format_check
    CHECK (nummer ~ '^[+0-9()[:space:]/-]{6,30}$');

ALTER TABLE adresse DROP CONSTRAINT IF EXISTS adresse_plz_format_check;
ALTER TABLE adresse ADD CONSTRAINT adresse_plz_format_check
    CHECK (plz IS NULL OR plz ~ '^[0-9]{4,5}$');
