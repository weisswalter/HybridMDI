-- ============================================================================
--  web_seite: Hierarchie ueber parent_id — Stand 03.08.2026
--
--  VORGABE (Walter): "id und parentid gehoeren rein, parentid 0 == NavBar."
--
--  Damit sagt die Struktur selbst, wo eine Seite hingehoert:
--     parent_id = 0        -> steht in der Navigationsleiste
--     parent_id = <id>     -> Unterseite dieser Seite
--
--  `im_menue` wird damit ueberfluessig — die Zugehoerigkeit stand vorher an
--  zwei Stellen (Flag und Namensmuster im slug), was frueher oder spaeter
--  auseinanderlaeuft. Die Spalte bleibt vorerst stehen, wird aber nicht mehr
--  ausgewertet.
-- ============================================================================

ALTER TABLE web_seite ADD COLUMN IF NOT EXISTS parent_id integer NOT NULL DEFAULT 0;

COMMENT ON COLUMN web_seite.parent_id IS
    '0 = Eintrag in der Navigationsleiste. Sonst seite_id der Elternseite.';

CREATE INDEX IF NOT EXISTS ix_web_seite_parent
    ON web_seite (mandant_id, parent_id, reihenfolge);

-- Eine Seite darf nicht ihr eigenes Elternteil sein.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conname = 'web_seite_parent_check') THEN
        ALTER TABLE web_seite ADD CONSTRAINT web_seite_parent_check
            CHECK (parent_id <> seite_id);
    END IF;
END;
$$;

-- Bestand einordnen: was einen Schraegstrich im slug hat, ist Unterseite
-- des Teils davor. Alles andere steht in der Leiste.
UPDATE web_seite k
   SET parent_id = e.seite_id
  FROM web_seite e
 WHERE k.mandant_id = e.mandant_id
   AND position('/' in k.slug) > 0
   AND e.slug = split_part(k.slug, '/', 1)
   AND k.parent_id = 0;

-- Sicht mit Ebene und Elternname, damit man die Struktur sieht.
-- DROP zuerst: CREATE OR REPLACE kann Spalten weder einfuegen noch
-- umbenennen, und die Sicht bekommt hier zwei neue Spalten vorne.
DROP VIEW IF EXISTS v_web_seite;
CREATE VIEW v_web_seite AS
WITH RECURSIVE baum AS (
    SELECT s.*, 0 AS ebene, s.reihenfolge::text AS pfad
      FROM web_seite s WHERE s.parent_id = 0
    UNION ALL
    SELECT k.*, b.ebene + 1, b.pfad || '.' || lpad(k.reihenfolge::text, 4, '0')
      FROM web_seite k JOIN baum b ON b.seite_id = k.parent_id
)
SELECT b.seite_id, b.parent_id, b.ebene, b.mandant_id, b.slug, b.sprache,
       b.titel, b.untertitel, b.darstellung, b.aktiv, b.reihenfolge,
       (b.parent_id = 0) AS in_navbar,
       e.titel AS eltern_titel,
       COALESCE(b.text_inhalt, '') <> '' AS hat_text,
       COALESCE(b.html_inhalt, '') <> '' AS hat_html,
       b.pdf_inhalt IS NOT NULL          AS hat_pdf,
       length(COALESCE(b.text_inhalt, '')) AS zeichen_text,
       length(COALESCE(b.html_inhalt, '')) AS zeichen_html,
       COALESCE(length(b.pdf_inhalt), 0)   AS bytes_pdf,
       CASE
         WHEN b.darstellung = 'text' AND COALESCE(b.text_inhalt, '') = '' THEN 'Text gewaehlt, aber leer'
         WHEN b.darstellung = 'html' AND COALESCE(b.html_inhalt, '') = '' THEN 'HTML gewaehlt, aber leer'
         WHEN b.darstellung = 'pdf'  AND b.pdf_inhalt IS NULL             THEN 'PDF gewaehlt, aber keins hinterlegt'
       END AS hinweis,
       b.pfad, b.geaendert_am
  FROM baum b
  LEFT JOIN web_seite e ON e.seite_id = b.parent_id;

SELECT seite_id, parent_id, ebene, slug, titel, in_navbar, aktiv,
       COALESCE(eltern_titel, '-') AS eltern
  FROM v_web_seite WHERE mandant_id = 1 ORDER BY pfad;
