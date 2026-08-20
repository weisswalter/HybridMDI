-- Der Shop zeigt Artikel aus dem Artikelstamm, nicht aus einer eigenen
-- Liste. Dafuer fehlt genau eine Angabe: ob ein Artikel im Netz stehen soll.
--
-- beleg_position laesst keine reinen Textzeilen zu
--   CHECK ((artikel_id IS NOT NULL AND leistung_id IS NULL)
--       OR (artikel_id IS NULL AND leistung_id IS NOT NULL))
-- Eine Weblbestellung kann also nur Artikel enthalten, die es wirklich gibt.
-- Damit ist die Umstellung keine Kuer: ohne sie landet keine Bestellung im
-- Bestellwesen.

BEGIN;

-- Einzeln aufschaltbar. Standard ist false: nach dem Einspielen steht kein
-- Artikel im Netz, bis ihn jemand bewusst freigibt.
ALTER TABLE artikel ADD COLUMN IF NOT EXISTS im_shop boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN artikel.im_shop IS
  'true = Artikel wird im Webshop angezeigt und ist bestellbar.';

CREATE INDEX IF NOT EXISTS ix_artikel_im_shop
    ON artikel(mandant_id) WHERE im_shop;

COMMIT;

-- ---------------------------------------------------------------------------
-- Was der Shop liest. Eine Sicht, weil die Website nur lesen soll und die
-- Zusammenstellung (Preis aus artikel_preis, Kategorie ueber die Bruecke,
-- Bestand aus artikel_fach) sonst dreimal im C#-Code stuende.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_shop_artikel AS
SELECT a.artikel_id,
       a.mandant_id,
       a.artikel_nr,
       a.artikelname,
       a.beschreibung,
       -- Gueltiger Preis von heute; ohne Eintrag 0, dann sieht man es sofort.
       COALESCE((SELECT p.preis
                   FROM artikel_preis p
                  WHERE p.artikel_id = a.artikel_id
                    AND p.gueltig_von <= CURRENT_DATE
                    AND (p.gueltig_bis IS NULL OR p.gueltig_bis >= CURRENT_DATE)
                  ORDER BY p.gueltig_von DESC
                  LIMIT 1), 0)::numeric(12,2) AS preis,
       -- Mehrere Kategorien sind moeglich; fuer die Anzeige reicht die erste.
       COALESCE((SELECT k.bezeichnung
                   FROM artikel_kategorie ak
                   JOIN kategorie k ON k.kategorie_id = ak.kategorie_id
                  WHERE ak.artikel_id = a.artikel_id AND k.aktiv
                  ORDER BY k.sortierung, k.bezeichnung
                  LIMIT 1), '') AS kategorie,
       COALESCE((SELECT sum(af.bestand)
                   FROM artikel_fach af
                  WHERE af.artikel_id = a.artikel_id), 0)::numeric(12,3) AS bestand
  FROM artikel a
 WHERE a.im_shop;

-- Bild-Nummern je Artikel, in der gewuenschten Reihenfolge. Die Bilder selbst
-- holt die Website einzeln ueber /artikelbild/{foto_id}.
CREATE OR REPLACE VIEW v_shop_artikel_bild AS
SELECT af.foto_id, af.artikel_id, af.mandant_id,
       COALESCE(af.reihenfolge, 0) AS reihenfolge
  FROM artikel_foto af
  JOIN artikel a ON a.artikel_id = af.artikel_id AND a.im_shop
 WHERE af.foto IS NOT NULL;
