-- ============================================================================
-- Kursdaten von TRT (Mandant 1) nach BMW (Mandant 3) uebernehmen.
--
-- HINTERGRUND (Walter, 29.07.2026): Das Agogikprogramm hat mit TRT
-- fachlich nichts zu tun - TRT waere hoechstens Auftragnehmer. Die
-- Kursdaten wurden bisher nur unter TRT gepflegt, weil dort entwickelt
-- wurde. Sie gehoeren aber zum Agogik-Mandanten.
--
-- Das Programm ist modular: was fuer TRT nicht gilt, wird spaeter
-- ausgeblendet, nicht geloescht. Deshalb wird hier KOPIERT und nichts
-- entfernt - TRT behaelt seine Saetze.
--
-- Idempotent: mehrfaches Ausfuehren legt nichts doppelt an (Abgleich ueber
-- die Bezeichnung bzw. kurs_nr je Mandant).
-- ============================================================================

BEGIN;

-- ── 1. Kompetenztypen ──────────────────────────────────────────────────────
INSERT INTO kompetenz_typ (mandant_id, bezeichnung, beschreibung,
                           gueltigkeit_monate, quelle, aktiv)
SELECT 3, k.bezeichnung, k.beschreibung, k.gueltigkeit_monate, k.quelle, k.aktiv
  FROM kompetenz_typ k
 WHERE k.mandant_id = 1
   AND NOT EXISTS (SELECT 1 FROM kompetenz_typ z
                    WHERE z.mandant_id = 3 AND z.bezeichnung = k.bezeichnung);

-- ── 2. Kurse ───────────────────────────────────────────────────────────────
-- artikel/leistung-Verweise werden bewusst NICHT mitkopiert: die haengen an
-- den Stammdaten des jeweiligen Mandanten und muessen dort neu zugeordnet
-- werden. Alles andere kommt mit.
INSERT INTO kurs (mandant_id, kurs_nr, bezeichnung, beschreibung, lernziele,
                  unterrichtsstunden, min_teilnehmer, max_teilnehmer,
                  preis_pro_teilnehmer, prioritaet, aktiv)
SELECT 3, k.kurs_nr, k.bezeichnung, k.beschreibung, k.lernziele,
       k.unterrichtsstunden, k.min_teilnehmer, k.max_teilnehmer,
       k.preis_pro_teilnehmer, k.prioritaet, k.aktiv
  FROM kurs k
 WHERE k.mandant_id = 1
   AND NOT EXISTS (SELECT 1 FROM kurs z
                    WHERE z.mandant_id = 3 AND z.bezeichnung = k.bezeichnung);

-- ── 3. Baukasten (Unterkurse) ueber die Bezeichnung nachziehen ─────────────
-- Die IDs sind neu, deshalb wird ueber den Namen zugeordnet.
INSERT INTO kurs_kurs (kurs_id, unter_kurs_id, mandant_id, position, pflicht)
SELECT neu_ober.kurs_id, neu_unter.kurs_id, 3, kk.position, kk.pflicht
  FROM kurs_kurs kk
  JOIN kurs alt_ober  ON alt_ober.kurs_id  = kk.kurs_id       AND alt_ober.mandant_id  = 1
  JOIN kurs alt_unter ON alt_unter.kurs_id = kk.unter_kurs_id AND alt_unter.mandant_id = 1
  JOIN kurs neu_ober  ON neu_ober.mandant_id  = 3 AND neu_ober.bezeichnung  = alt_ober.bezeichnung
  JOIN kurs neu_unter ON neu_unter.mandant_id = 3 AND neu_unter.bezeichnung = alt_unter.bezeichnung
 WHERE kk.mandant_id = 1
ON CONFLICT DO NOTHING;

-- ── 4. Kompetenzzuordnung der Kurse ────────────────────────────────────────
INSERT INTO kurs_kompetenz (kurs_id, kompetenz_id, mandant_id, rolle)
SELECT neu_k.kurs_id, neu_c.kompetenz_id, 3, kc.rolle
  FROM kurs_kompetenz kc
  JOIN kurs alt_k ON alt_k.kurs_id = kc.kurs_id AND alt_k.mandant_id = 1
  JOIN kompetenz_typ alt_c ON alt_c.mandant_id = 1 AND alt_c.kompetenz_id = kc.kompetenz_id
  JOIN kurs neu_k ON neu_k.mandant_id = 3 AND neu_k.bezeichnung = alt_k.bezeichnung
  JOIN kompetenz_typ neu_c ON neu_c.mandant_id = 3 AND neu_c.bezeichnung = alt_c.bezeichnung
 WHERE kc.mandant_id = 1
ON CONFLICT DO NOTHING;

-- ── 5. Semester: BMW hat noch keines, ohne das laesst sich keine
--      Durchfuehrung anlegen ───────────────────────────────────────────────
INSERT INTO semester (mandant_id, bezeichnung, von_datum, bis_datum)
SELECT 3, 'Herbst 2026', DATE '2026-08-01', DATE '2027-01-31'
 WHERE NOT EXISTS (SELECT 1 FROM semester
                    WHERE mandant_id = 3 AND bezeichnung = 'Herbst 2026');

COMMIT;

-- ── Kontrolle ──────────────────────────────────────────────────────────────
SELECT m.mandant_id, m.mandanten_name,
       (SELECT count(*) FROM kurs k            WHERE k.mandant_id  = m.mandant_id) AS kurse,
       (SELECT count(*) FROM kompetenz_typ kt  WHERE kt.mandant_id = m.mandant_id) AS kompetenzen,
       (SELECT count(*) FROM kurs_kurs kk      WHERE kk.mandant_id = m.mandant_id) AS unterkurse,
       (SELECT count(*) FROM kurs_kompetenz kc WHERE kc.mandant_id = m.mandant_id) AS kurs_kompetenz,
       (SELECT count(*) FROM semester s        WHERE s.mandant_id  = m.mandant_id) AS semester
  FROM mandant m ORDER BY m.mandant_id;
