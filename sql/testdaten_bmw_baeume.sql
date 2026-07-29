-- ============================================================================
-- Testdaten fuer die beiden Baeume (Mandant 3 / BMW).
--
-- Ziel: genug Tiefe und Breite, damit sich der VirtualStringTree beweisen
-- muss - vierstufig, mit echten Blaettern, Pflicht und Kuer gemischt.
--
-- Idempotent ueber Bezeichnung bzw. Artikelnummer.
-- ============================================================================

BEGIN;

-- ── Zusaetzliche Kurse als BLAETTER ────────────────────────────────────────
INSERT INTO kurs (mandant_id, kurs_nr, bezeichnung, unterrichtsstunden, aktiv)
SELECT 3, v.nr, v.bez, v.std, true
  FROM (VALUES
    ('K-201', 'Arbeitssicherheit Grundlagen',      4.0),
    ('K-202', 'Persoenliche Schutzausruestung',    2.0),
    ('K-203', 'Erste Hilfe am Arbeitsplatz',       8.0),
    ('K-211', 'Messschieber und Mikrometer',       6.0),
    ('K-212', 'Technische Zeichnung lesen',       12.0),
    ('K-213', 'Werkstoffkunde Stahl',              8.0),
    ('K-221', 'Feilen und Saegen',                10.0),
    ('K-222', 'Bohren und Senken',                 8.0),
    ('K-223', 'Gewinde schneiden',                 6.0),
    ('K-231', 'Tastatur und Maus',                 4.0),
    ('K-232', 'Dateien und Ordner',                4.0),
    ('K-233', 'E-Mail im Alltag',                  6.0)
  ) AS v(nr, bez, std)
 WHERE NOT EXISTS (SELECT 1 FROM kurs k
                    WHERE k.mandant_id = 3 AND k.kurs_nr = v.nr);

-- ── Zwischenebene: Sammelkurse ─────────────────────────────────────────────
INSERT INTO kurs (mandant_id, kurs_nr, bezeichnung, unterrichtsstunden, aktiv)
SELECT 3, v.nr, v.bez, NULL, true
  FROM (VALUES
    ('K-200', 'Sicherheit und Gesundheit'),
    ('K-210', 'Messen und Pruefen'),
    ('K-220', 'Manuelle Fertigung'),
    ('K-230', 'EDV Grundlagen')
  ) AS v(nr, bez)
 WHERE NOT EXISTS (SELECT 1 FROM kurs k
                    WHERE k.mandant_id = 3 AND k.kurs_nr = v.nr);

-- ── Baukasten verdrahten: Sammelkurs -> Blaetter ──────────────────────────
INSERT INTO kurs_kurs (kurs_id, unter_kurs_id, mandant_id, position, pflicht)
SELECT o.kurs_id, u.kurs_id, 3, v.pos, v.pflicht
  FROM kurs o
  JOIN kurs u ON u.mandant_id = 3
  JOIN (VALUES
    ('K-200','K-201',1,true), ('K-200','K-202',2,true), ('K-200','K-203',3,false),
    ('K-210','K-211',1,true), ('K-210','K-212',2,true), ('K-210','K-213',3,false),
    ('K-220','K-221',1,true), ('K-220','K-222',2,true), ('K-220','K-223',3,true),
    ('K-230','K-231',1,true), ('K-230','K-232',2,true), ('K-230','K-233',3,false)
  ) AS v(onr, unr, pos, pflicht)
    ON v.onr = o.kurs_nr AND v.unr = u.kurs_nr
 WHERE o.mandant_id = 3
ON CONFLICT DO NOTHING;

-- ── Die Sammelkurse unter den ersten BMW-Kurs haengen ─────────────────────
-- Damit wird der Baum vierstufig: Hauptkurs -> Sammelkurs -> Blatt.
INSERT INTO kurs_kurs (kurs_id, unter_kurs_id, mandant_id, position, pflicht)
SELECT h.kurs_id, s.kurs_id, 3, v.pos, v.pflicht
  FROM (SELECT kurs_id FROM kurs WHERE mandant_id = 3 ORDER BY kurs_id LIMIT 1) h
  JOIN kurs s ON s.mandant_id = 3
  JOIN (VALUES ('K-200',10,true), ('K-210',11,true),
               ('K-220',12,true), ('K-230',13,false)) AS v(nr, pos, pflicht)
    ON v.nr = s.kurs_nr
ON CONFLICT DO NOTHING;

-- ── Mehr Artikel, mehrstufige Stueckliste ─────────────────────────────────
INSERT INTO artikel (mandant_id, artikel_nr, artikelname, beschreibung)
SELECT 3, v.nr, v.name, v.beschr
  FROM (VALUES
    ('BMW-200','Werkstattwagen komplett','Oberbaugruppe'),
    ('BMW-210','Korpus',                 'Blechgehaeuse'),
    ('BMW-211','Seitenwand',             'Blech 1.5 mm'),
    ('BMW-212','Rueckwand',              'Blech 1.5 mm'),
    ('BMW-213','Bodenblech',             'Blech 2.0 mm'),
    ('BMW-220','Schubladensatz',         'fuenf Schubladen'),
    ('BMW-221','Schublade flach',        'Hoehe 60 mm'),
    ('BMW-222','Schublade tief',         'Hoehe 150 mm'),
    ('BMW-223','Teleskopschiene',        'Paar, 400 mm'),
    ('BMW-230','Rollensatz',             'vier Rollen'),
    ('BMW-231','Lenkrolle',              'mit Bremse'),
    ('BMW-232','Bockrolle',              'ohne Bremse'),
    ('BMW-240','Griffleiste',            'Aluminium'),
    ('BMW-250','Schraubenset',           'Verbrauchsmaterial')
  ) AS v(nr, name, beschr)
 WHERE NOT EXISTS (SELECT 1 FROM artikel a
                    WHERE a.mandant_id = 3 AND a.artikel_nr = v.nr);

INSERT INTO artikel_artikel (mandant_id, artikel_id, unter_artikel_id,
                             menge, einheit_id, position)
SELECT 3, o.artikel_id, u.artikel_id, v.menge,
       (SELECT einheit_id FROM einheit WHERE mandant_id = 3 ORDER BY einheit_id LIMIT 1),
       v.pos
  FROM artikel o
  JOIN artikel u ON u.mandant_id = 3
  JOIN (VALUES
    ('BMW-200','BMW-210', 1, 1), ('BMW-200','BMW-220', 1, 2),
    ('BMW-200','BMW-230', 1, 3), ('BMW-200','BMW-240', 2, 4),
    ('BMW-200','BMW-250', 1, 5),
    ('BMW-210','BMW-211', 2, 1), ('BMW-210','BMW-212', 1, 2),
    ('BMW-210','BMW-213', 1, 3),
    ('BMW-220','BMW-221', 3, 1), ('BMW-220','BMW-222', 2, 2),
    ('BMW-220','BMW-223', 5, 3),
    ('BMW-230','BMW-231', 2, 1), ('BMW-230','BMW-232', 2, 2)
  ) AS v(onr, unr, menge, pos)
    ON v.onr = o.artikel_nr AND v.unr = u.artikel_nr
 WHERE o.mandant_id = 3
ON CONFLICT DO NOTHING;

COMMIT;
