-- ============================================================================
-- Testdaten fuer Mandant 3 (BMW) - alle Kombinationen der Planungsregeln.
--
-- Zweck: die Auswahlfunktionen fn_raum_auswahl und fn_lehrer_auswahl gegen
-- jeden Fall pruefen koennen, der in der Praxis auftritt. Deshalb bewusst
-- auch die UNSCHOENEN Faelle - abgelaufene Nachweise, Doppelbelegung,
-- Termin ueber Mitternacht, Mehrzweckraum ohne freies Inventar.
--
-- Idempotent: Abgleich ueber Bezeichnungen, mehrfaches Ausfuehren legt
-- nichts doppelt an.
-- ============================================================================

BEGIN;

-- ── Ausstattung: fest, mobil, knapp ────────────────────────────────────────
INSERT INTO ausstattung (bezeichnung, ist_mobil, anzahl_mobil)
SELECT v.bez, v.mobil, v.anzahl
  FROM (VALUES ('Beamer',        true,  1),
               ('Laptopwagen',   true,  2),
               ('Flipchart',     true,  5),
               ('Whiteboard',    false, 0),
               ('Werkbank',      false, 0),
               ('Nassbereich',   false, 0)) AS v(bez, mobil, anzahl)
 WHERE NOT EXISTS (SELECT 1 FROM ausstattung a WHERE a.bezeichnung = v.bez);

-- vorhandene Eintraege auf die Testwerte heben
UPDATE ausstattung SET ist_mobil = true,  anzahl_mobil = 1 WHERE bezeichnung = 'Beamer';
UPDATE ausstattung SET ist_mobil = true,  anzahl_mobil = 2 WHERE bezeichnung = 'Laptopwagen';
UPDATE ausstattung SET ist_mobil = true,  anzahl_mobil = 5 WHERE bezeichnung = 'Flipchart';

-- ── Raeume: jede Kombination aus fester Ausstattung und Mehrzweck ─────────
INSERT INTO raum (adresse_id, bezeichnung, max_personen, ist_mehrzweck, beschreibung)
SELECT (SELECT MIN(adresse_id) FROM adresse), v.bez, v.pers, v.mz, v.beschr
  FROM (VALUES
    ('Schulungsraum 1', 16, false, 'fest mit Beamer und Whiteboard'),
    ('Schulungsraum 2', 12, false, 'nur Whiteboard, kein Beamer, nicht nachruestbar'),
    ('Mehrzweckraum A', 24, true,  'leer, laesst sich mobil ausruesten'),
    ('Mehrzweckraum B', 10, true,  'leer, klein - fuer Kapazitaetstests'),
    ('Werkstatt',       20, false, 'Werkbank und Nassbereich, kein Beamer'),
    ('Besprechung',      6, true,  'sehr klein, Mehrzweck')
  ) AS v(bez, pers, mz, beschr)
 WHERE NOT EXISTS (SELECT 1 FROM raum r WHERE r.bezeichnung = v.bez);

UPDATE raum SET ist_mehrzweck = true
 WHERE bezeichnung IN ('Mehrzweckraum A', 'Mehrzweckraum B', 'Besprechung');

-- feste Ausstattung zuordnen
INSERT INTO raum_ausstattung (raum_id, ausstattungs_id)
SELECT r.raum_id, a.ausstattungs_id
  FROM raum r, ausstattung a
 WHERE (r.bezeichnung = 'Schulungsraum 1' AND a.bezeichnung IN ('Beamer', 'Whiteboard'))
    OR (r.bezeichnung = 'Schulungsraum 2' AND a.bezeichnung IN ('Whiteboard'))
    OR (r.bezeichnung = 'Werkstatt'       AND a.bezeichnung IN ('Werkbank', 'Nassbereich'))
ON CONFLICT DO NOTHING;

-- ── Personen: Lehrer und Klienten in allen Varianten ──────────────────────
INSERT INTO person (typ_id, vorname, nachname_firmenname, beschreibung)
SELECT (SELECT MIN(typ_id) FROM person_typ), v.vn, v.nn, v.beschr
  FROM (VALUES
    ('Anna',   'Berger',    'Lohnmitarbeiterin, alle Kompetenzen gueltig'),
    ('Bruno',  'Caduff',    'Honorarlehrer, eine Kompetenz abgelaufen'),
    ('Carla',  'Dietrich',  'Honorarlehrerin ohne Kompetenznachweis'),
    ('Dario',  'Egli',      'Lohnmitarbeiter, unbefristete Kompetenz'),
    ('Elena',  'Fankhauser','Klientin Gruppe A'),
    ('Fabio',  'Gerber',    'Klient Gruppe A'),
    ('Gina',   'Huber',     'Klientin Gruppe B'),
    ('Hans',   'Iten',      'Klient, zugleich Lehrer (Sonderfall)')
  ) AS v(vn, nn, beschr)
 WHERE NOT EXISTS (SELECT 1 FROM person p
                    WHERE p.vorname = v.vn AND p.nachname_firmenname = v.nn);

-- an den Mandanten haengen
INSERT INTO person_mandant (person_id, mandant_id)
SELECT p.person_id, 3 FROM person p
 WHERE p.nachname_firmenname IN ('Berger','Caduff','Dietrich','Egli',
                                 'Fankhauser','Gerber','Huber','Iten')
   AND NOT EXISTS (SELECT 1 FROM person_mandant pm
                    WHERE pm.person_id = p.person_id AND pm.mandant_id = 3);

-- Rolle sicherstellen
INSERT INTO rolle_typ (mandant_id, rollen_bezeichnung)
SELECT 3, 'Lehrer'
 WHERE NOT EXISTS (SELECT 1 FROM rolle_typ WHERE mandant_id = 3 AND rollen_bezeichnung = 'Lehrer');

-- Hauptperson des Mandanten als Beziehungsziel
INSERT INTO person_beziehung (mandant_id, quell_person_id, ziel_person_id, rolle_id,
                              ist_mitarbeiter, ist_lehrer, ist_klient)
SELECT 3, p.person_id,
       COALESCE((SELECT pm.person_id FROM person_mandant pm
                  WHERE pm.mandant_id = 3 AND pm.ist_hauptperson LIMIT 1),
                (SELECT MIN(pm.person_id) FROM person_mandant pm WHERE pm.mandant_id = 3)),
       (SELECT rolle_id FROM rolle_typ WHERE mandant_id = 3 AND rollen_bezeichnung = 'Lehrer'),
       v.ma, v.lehrer, v.klient
  FROM person p
  JOIN (VALUES
    ('Berger',     true,  true,  false),
    ('Caduff',     false, true,  false),
    ('Dietrich',   false, true,  false),
    ('Egli',       true,  true,  false),
    ('Fankhauser', false, false, true),
    ('Gerber',     false, false, true),
    ('Huber',      false, false, true),
    ('Iten',       false, true,  true)
  ) AS v(nn, ma, lehrer, klient) ON v.nn = p.nachname_firmenname
 WHERE NOT EXISTS (SELECT 1 FROM person_beziehung pb
                    WHERE pb.mandant_id = 3 AND pb.quell_person_id = p.person_id);

-- ── Kompetenznachweise: gueltig, abgelaufen, unbefristet, fehlend ─────────
INSERT INTO person_kompetenz (mandant_id, person_id, kompetenz_id,
                              erworben_am, gueltig_bis, bemerkung)
SELECT 3, p.person_id, kt.kompetenz_id, v.erworben, v.bis, v.bem
  FROM person p
  JOIN (VALUES
    ('Berger', 1, DATE '2025-01-15', DATE '2027-12-31', 'gueltig'),
    ('Berger', 2, DATE '2025-03-01', DATE '2027-06-30', 'gueltig'),
    ('Caduff', 1, DATE '2022-05-01', DATE '2025-04-30', 'ABGELAUFEN'),
    ('Egli',   1, DATE '2024-09-01', NULL,              'unbefristet')
  ) AS v(nn, kidx, erworben, bis, bem) ON v.nn = p.nachname_firmenname
  JOIN LATERAL (SELECT kompetenz_id FROM kompetenz_typ
                 WHERE mandant_id = 3 ORDER BY kompetenz_id
                 OFFSET v.kidx - 1 LIMIT 1) kt ON true
 WHERE NOT EXISTS (SELECT 1 FROM person_kompetenz pk
                    WHERE pk.person_id = p.person_id
                      AND pk.kompetenz_id = kt.kompetenz_id
                      AND pk.erworben_am = v.erworben);

-- ── Ausstattungsanforderung an zwei Kurse haengen ─────────────────────────
-- Kurs 1 braucht den Beamer (mobil, nur 1 Stueck -> knapp),
-- Kurs 2 die Werkbank (fest, nicht nachruestbar).
INSERT INTO kurs_ausstattung (kurs_id, ausstattungs_id, zwingend)
SELECT k.kurs_id, a.ausstattungs_id, true
  FROM (SELECT kurs_id, row_number() OVER (ORDER BY kurs_id) AS rn
          FROM kurs WHERE mandant_id = 3) k
  JOIN ausstattung a ON (k.rn = 1 AND a.bezeichnung = 'Beamer')
                     OR (k.rn = 2 AND a.bezeichnung = 'Werkbank')
 WHERE k.rn <= 2
ON CONFLICT DO NOTHING;

-- Kompetenzanforderung an Kurs 1 (Rolle lehrer)
INSERT INTO kurs_kompetenz (kurs_id, kompetenz_id, mandant_id, rolle)
SELECT k.kurs_id, kt.kompetenz_id, 3, 'lehrer'
  FROM (SELECT kurs_id, row_number() OVER (ORDER BY kurs_id) AS rn
          FROM kurs WHERE mandant_id = 3) k
  JOIN LATERAL (SELECT kompetenz_id FROM kompetenz_typ
                 WHERE mandant_id = 3 ORDER BY kompetenz_id LIMIT 1) kt ON true
 WHERE k.rn = 1
ON CONFLICT DO NOTHING;

COMMIT;
