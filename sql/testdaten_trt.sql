-- ============================================================================
-- Testartikel fuer Mandant 1 (TRT Engineering GmbH) — 09.08.2026
--
-- Gegenstueck zu testdaten_bmw.sql: dort Werkstattmoebel fuer die Agogik,
-- hier Emissionsmesstechnik, also das Geschaeft von TRT. Damit hat jeder
-- Mandant eigene Artikel und die Mandantentrennung im ArtikelStamm laesst
-- sich ueberhaupt erst pruefen.
--
-- Wiederholbar: ON CONFLICT auf (mandant_id, artikel_nr).
-- ============================================================================

INSERT INTO artikel (mandant_id, artikel_nr, artikelname, beschreibung) VALUES
  (1, 'TRT-100', 'Emissionsmessplatz komplett', 'Oberbaugruppe, anschlussfertig'),
  (1, 'TRT-110', 'Messschrank',                 '19-Zoll, fahrbar'),
  (1, 'TRT-111', 'Gehaeuse 19 Zoll',            '12 HE, lackiert'),
  (1, 'TRT-112', 'Lueftereinheit',              'mit Filtermatte'),
  (1, 'TRT-120', 'Analysator NOx',              'Chemilumineszenz'),
  (1, 'TRT-121', 'Analysator CO/CO2',           'nichtdispersiv infrarot'),
  (1, 'TRT-122', 'Analysator O2',               'paramagnetisch'),
  (1, 'TRT-130', 'Probenahmesonde',             'beheizt, 1 m'),
  (1, 'TRT-131', 'Beheizte Leitung 4 m',        '180 Grad, PTFE'),
  (1, 'TRT-140', 'Gasaufbereitung',             'Kuehler mit Kondensatabscheider'),
  (1, 'TRT-150', 'Steuerrechner',               'Industrie-PC, luefterlos'),
  (1, 'TRT-151', 'Messsoftware Lizenz',         'ein Arbeitsplatz'),
  (1, 'TRT-200', 'Kalibriergas-Set',            'drei Flaschen, Pruefgas'),
  (1, 'TRT-210', 'Filtersatz',                  'Verbrauchsmaterial'),
  (1, 'TRT-220', 'Schlauchset',                 'Verbrauchsmaterial')
ON CONFLICT (mandant_id, artikel_nr) DO NOTHING;
