-- ============================================================================
-- Rauchtest: der Weg des Coaches — Stand 02.08.2026
--
-- Prüft in EINER zurückgerollten Transaktion den ganzen Pfad, auf den es beim
-- Werks Bahnhof ankommt: Anmelden, Anwesenheitsblatt holen, Klasse erfassen,
-- Spur kontrollieren.
--
-- Läuft gegen jede Heisenberg-Datenbank, lokal wie online:
--   psql -h localhost -p 5432 -U postgres -d TRTHeisenberg -f sql/test_coachweg.sql
--   psql -h localhost -p 5455 -U postgres -d TRTHeisenberg -f sql/test_coachweg.sql
--
-- Ändert nichts: am Ende steht ein ROLLBACK. Erwartet wird durchgehend
-- "OK"; jedes "FEHLT" ist eine Baustelle.
-- ============================================================================

\set ON_ERROR_STOP off
\timing on

BEGIN;

\echo ''
\echo '=== 1. Sind die Funktionen überhaupt da? ==='
SELECT p.proname,
       CASE WHEN p.proname IS NULL THEN 'FEHLT' ELSE 'OK' END AS stand
  FROM (VALUES ('fn_benutzer_anmelden'), ('fn_app_benutzer_setzen'),
               ('fn_kurs_anwesenheit_blatt'), ('fn_kurs_anwesenheit_liste'),
               ('fn_person_anlegen')) AS soll(name)
  LEFT JOIN pg_proc p ON p.proname = soll.name
                     AND p.pronamespace = 'public'::regnamespace
 ORDER BY 1 NULLS FIRST;

\echo ''
\echo '=== 2. Testkurs mit drei Teilnehmern aufbauen ==='
SELECT t.termin_id AS tid, t.durchfuehrung_id AS did
  FROM kurs_termin t ORDER BY t.termin_id LIMIT 1
\gset

INSERT INTO kurs_teilnehmer (durchfuehrung_id, person_id, mandant_id)
SELECT :did, p.person_id, 1
  FROM person p
 WHERE EXISTS (SELECT 1 FROM person_mandant pm
                WHERE pm.person_id = p.person_id AND pm.mandant_id = 1)
 ORDER BY p.person_id LIMIT 3
    ON CONFLICT DO NOTHING;

SELECT count(*) AS teilnehmer_im_kurs
  FROM kurs_teilnehmer WHERE durchfuehrung_id = :did;

\echo ''
\echo '=== 3. Der Coach meldet sich an ==='
SELECT fn_app_benutzer_setzen('coach_test');
SELECT COALESCE(fn_app_benutzer(), '(nicht gesetzt)') AS angemeldet_als;

\echo ''
\echo '=== 4. Anwesenheitsblatt vor dem Abhaken ==='
SELECT person_id, nachname, anwesend, schon_erfasst
  FROM fn_kurs_anwesenheit_blatt(:tid);

\echo ''
\echo '=== 5. Ganze Klasse in EINEM Aufruf erfassen ==='
-- Der Zweite gilt als entschuldigt, die anderen als anwesend.
-- Die Nummerierung muss in eine Unterabfrage: eine Fensterfunktion darf
-- nicht innerhalb eines Aggregats stehen.
SELECT fn_kurs_anwesenheit_liste(
    :tid,
    (SELECT jsonb_agg(jsonb_build_object(
              'person_id',    x.person_id,
              'anwesend',     x.nr <> 2,
              'entschuldigt', x.nr =  2,
              'bemerkung',    CASE WHEN x.nr = 2 THEN 'krank' END))
       FROM (SELECT kt.person_id,
                    row_number() OVER (ORDER BY kt.person_id) AS nr
               FROM kurs_teilnehmer kt
              WHERE kt.durchfuehrung_id = :did) x),
    NULL) AS erfasste_eintraege;

\echo ''
\echo '=== 6. Blatt danach ==='
SELECT person_id, nachname, anwesend, entschuldigt, bemerkung, schon_erfasst
  FROM fn_kurs_anwesenheit_blatt(:tid);

\echo ''
\echo '=== 7. Erneutes Speichern darf die Spur nicht verfälschen ==='
SELECT erfasst_am AS t0 FROM kurs_anwesenheit
 WHERE termin_id = :tid ORDER BY person_id LIMIT 1
\gset
SELECT pg_sleep(0.05);
SELECT fn_kurs_anwesenheit_liste(:tid,
    (SELECT jsonb_agg(jsonb_build_object('person_id', ka.person_id,
                                         'anwesend', ka.anwesend,
                                         'entschuldigt', ka.entschuldigt,
                                         'bemerkung', ka.bemerkung))
       FROM kurs_anwesenheit ka WHERE ka.termin_id = :tid), NULL);
SELECT CASE WHEN erfasst_am = :'t0' THEN 'OK - unveraendert'
            ELSE 'FEHLT - Zeitstempel wandert ohne Aenderung' END AS ergebnis
  FROM kurs_anwesenheit WHERE termin_id = :tid ORDER BY person_id LIMIT 1;

\echo ''
\echo '=== 8. Ablehnung: Person gehoert nicht zum Kurs ==='
SAVEPOINT s_fremd;
SELECT fn_kurs_anwesenheit_setzen(:tid, 999999, true);
ROLLBACK TO s_fremd;

\echo ''
\echo '=== 9. Ablehnung: anwesend UND entschuldigt ==='
SAVEPOINT s_wider;
SELECT fn_kurs_anwesenheit_setzen(:tid,
    (SELECT person_id FROM kurs_teilnehmer WHERE durchfuehrung_id = :did
      ORDER BY person_id LIMIT 1), true, true);
ROLLBACK TO s_wider;

\echo ''
\echo '=== 10. Steht der Coach in der Aenderungsspur? ==='
SELECT geaendert_von, tabelle, aktion, count(*) AS zeilen
  FROM audit_log
 WHERE geaendert_von = 'coach_test'
 GROUP BY 1,2,3 ORDER BY 2,3;

\echo ''
\echo '=== 11. Waisen: Personen ohne Mandantenzuordnung ==='
SELECT count(*) AS waisen,
       CASE WHEN count(*) = 0 THEN 'OK' ELSE 'zu pruefen' END AS stand
  FROM person p
 WHERE NOT EXISTS (SELECT 1 FROM person_mandant pm
                    WHERE pm.person_id = p.person_id);

ROLLBACK;

\echo ''
\echo '=== Ende. ROLLBACK ausgefuehrt, die Datenbank ist unveraendert. ==='
