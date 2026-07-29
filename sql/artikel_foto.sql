-- ============================================================================
-- Artikel-Fotos: mehrere Bilder je Artikel — eigene Detailseite ("Fotos")
-- im Artikelstammfenster, navigierbar wie "Bestand" (artikel_fach).
-- Mandantenbezogen wie alle uebrigen Artikel-Tabellen (Stand 22.07.2026).
-- ============================================================================

CREATE TABLE IF NOT EXISTS artikel_foto (
    foto_id      serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    artikel_id   integer NOT NULL REFERENCES artikel(artikel_id),
    foto         bytea,
    beschreibung text,
    reihenfolge  integer
);
CREATE INDEX IF NOT EXISTS ix_artikel_foto_artikel ON artikel_foto (artikel_id);
