-- ============================================================================
-- Artikelpreise mit Gueltigkeitszeitraum — Grundlage fuer das Kalkulationsmodul
-- Stand 28.07.2026
-- ============================================================================

CREATE TABLE IF NOT EXISTS artikel_preis (
    preis_id    serial PRIMARY KEY,
    mandant_id  integer NOT NULL REFERENCES mandant(mandant_id),
    artikel_id  integer NOT NULL REFERENCES artikel(artikel_id),
    gueltig_von date NOT NULL,
    gueltig_bis date,                    -- NULL = bis auf Weiteres
    preis       numeric(12,4) NOT NULL,  -- 4 Nachkommastellen: Stueckpreise
                                         -- gehen oft unter einen Rappen
    waehrung    varchar(3) NOT NULL DEFAULT 'CHF',   -- ISO 4217: CHF, EUR
    mwst_satz   numeric(5,2),            -- Prozent, z.B. 8.10 (CH) / 19.00 (DE)
    -- Einkauf und Verkauf getrennt fuehrbar. Die Kalkulation braucht beides:
    -- EK als Kostenbasis, VK als Ergebnis. Ohne diese Spalte muesste man die
    -- Tabelle spaeter umbauen.
    preis_art   varchar(2) NOT NULL DEFAULT 'VK' CHECK (preis_art IN ('EK','VK')),
    bemerkung   text,
    created_at  timestamp NOT NULL DEFAULT now(),
    CHECK (gueltig_bis IS NULL OR gueltig_bis >= gueltig_von)
);

CREATE INDEX IF NOT EXISTS ix_artikel_preis_artikel ON artikel_preis (artikel_id);

-- Ein Artikel darf je Preisart und Waehrung nicht zwei gleichzeitig gueltige
-- Preise haben — sonst weiss keine Kalkulation, welcher gilt. Dieselbe
-- Technik wie bei kurs_termin (btree_gist ist dort schon aktiviert).
ALTER TABLE artikel_preis DROP CONSTRAINT IF EXISTS ex_artikel_preis_zeitraum;
ALTER TABLE artikel_preis ADD CONSTRAINT ex_artikel_preis_zeitraum
    EXCLUDE USING gist (
        artikel_id WITH =,
        preis_art  WITH =,
        waehrung   WITH =,
        daterange(gueltig_von, gueltig_bis, '[]') WITH &&
    );

-- Bequemer Zugriff auf den heute gueltigen Preis
CREATE OR REPLACE VIEW v_artikel_preis_aktuell AS
SELECT p.*
FROM artikel_preis p
WHERE CURRENT_DATE >= p.gueltig_von
  AND (p.gueltig_bis IS NULL OR CURRENT_DATE <= p.gueltig_bis);
