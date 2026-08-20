-- ============================================================================
--  web_farbe — einstellbare Farben je Mandant, Stand 03.08.2026
--
--  VORGABE (Walter): Die Farben muessen einstellbar sein. Fuer einen anderen
--  Kunden wird die Website sonst nur inhaltlich neu, sieht aber weiter nach
--  TRT aus.
--
--  ALS CSS-VARIABLEN: Die Anwendung schreibt daraus einen :root-Block. Damit
--  wirkt eine Aenderung ueberall, wo die Variable benutzt wird — man muss
--  nicht wissen, an welchen Stellen eine Farbe vorkommt.
-- ============================================================================

CREATE TABLE IF NOT EXISTS web_farbe (
    mandant_id  integer      NOT NULL REFERENCES mandant(mandant_id),
    schluessel  varchar(60)  NOT NULL,   -- wird zu --<schluessel>
    wert        varchar(40)  NOT NULL,   -- #rrggbb, rgb(), linear-gradient(...)
    bemerkung   varchar(200),
    reihenfolge integer      NOT NULL DEFAULT 100,
    PRIMARY KEY (mandant_id, schluessel)
);

COMMENT ON TABLE web_farbe IS
    'Farben je Mandant. Werden als CSS-Variablen (:root) in die Seite '
    'geschrieben, damit eine Aenderung ueberall wirkt.';

INSERT INTO web_farbe (mandant_id, schluessel, wert, bemerkung, reihenfolge)
SELECT 1, v.k, v.w, v.b, v.r FROM (VALUES
  ('farbe-akzent',      '#4FE3E7', 'Tuerkis: Ueberschriften, Links, Marke',        10),
  ('farbe-akzent-2',    '#00E676', 'Gruen: Hervorhebungen, aktive Zeitpunkte',     20),
  ('farbe-akzent-3',    '#FFD600', 'Gelb: Warnungen, Auszeichnungen',              30),
  ('farbe-kopf-von',    '#2b3a67', 'Titelleiste, Farbverlauf links',               40),
  ('farbe-kopf-bis',    '#6b5b8a', 'Titelleiste, Farbverlauf rechts',              50),
  ('farbe-grund',       '#7b7f9e', 'Seitenhintergrund',                            60),
  ('farbe-flaeche',     '#ffffff', 'Karten und Inhaltsflaechen',                   70),
  ('farbe-schrift',     '#1f2430', 'Grundschrift',                                 80),
  ('farbe-schrift-hell','#eef1f7', 'Schrift auf dunklem Grund',                    90),
  ('farbe-gedaempft',   '#8b93a7', 'Nebentexte, Hinweise',                        100),
  ('farbe-linie',       '#d7dbe6', 'Trennlinien und Raender',                     110)
) AS v(k, w, b, r)
 WHERE NOT EXISTS (SELECT 1 FROM web_farbe f
                    WHERE f.mandant_id = 1 AND f.schluessel = v.k);

SELECT schluessel, wert, bemerkung FROM web_farbe
 WHERE mandant_id = 1 ORDER BY reihenfolge;
