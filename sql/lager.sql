-- ============================================================================
-- Heisenberg: Lagertabelle (Lagerplätze/Lagerorte)
-- PostgreSQL DDL
--
-- Annahmen (bitte gegenprüfen):
--  * mandant_id ergänzt — Lager sind mandantspezifisch (Multi-Tenant wie der
--    Rest von Heisenberg).
--  * adresse_id als echter FK auf adresse (poolfähig, kann geteilt werden).
--  * raum_id / regal_id als integer OHNE FK — es gibt (noch) keine raum-/
--    regal-Tabellen. Falls Räume/Regale eigene Stammtabellen werden sollen
--    (wie adresse), lege ich raum + regal mit FKs nachträglich an; dann werden
--    diese Spalten zu echten Fremdschlüsseln.
--  * barcode = Textwert des Barcodes; qrcode = QR-Code als Bild (bytea);
--    photo = optionales Foto des Lagerorts (bytea).
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS lager (
    lager_id     serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    adresse_id   integer REFERENCES adresse(adresse_id),
    raum_id      integer,
    regal_id     integer,
    barcode      varchar(100),
    qrcode       bytea,           -- QR-Code als Bild
    beschreibung text,
    photo        bytea            -- optionales Foto des Lagerorts
);

-- Barcode pro Mandant eindeutig (nur wenn gesetzt) — verhindert Doppelvergabe,
-- lässt aber leere Barcodes zu.
CREATE UNIQUE INDEX IF NOT EXISTS ux_lager_barcode
    ON lager (mandant_id, barcode) WHERE barcode IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_lager_adresse ON lager (adresse_id);

COMMIT;
