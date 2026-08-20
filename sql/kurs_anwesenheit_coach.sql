-- ============================================================================
-- Kurs-Anwesenheit: wer hat erfasst — Stand 03.08.2026
--
-- Walters Vorgabe: "die Kursteilnehmer werden von den Coaches erfasst als
-- anwesend". Damit ist der Coach (= Kursleiter des Termins) der Erfassende.
-- Wer eine Anwesenheit gesetzt hat, muss nachvollziehbar sein — bei einer
-- Anwesenheitsliste, die in eine Kursbestaetigung oder eine Abrechnung
-- gegenueber einer Foerderstelle einfliesst, ist das keine Kuer.
--
-- WARUM NICHT ueber das Audit-Log: `kurs_anwesenheit` steht dort (bewusst)
-- nicht drin, und selbst wenn — `current_user` waere immer 'postgres', weil
-- Heisenberg kein eigenes Login hat (siehe Nachtbericht, SEC-01). Der Coach
-- wird deshalb in der Maske ausgewaehlt und hier festgehalten. Das ist
-- ehrlicher als ein Audit-Feld, das fuer alle dasselbe sagt.
-- ============================================================================

ALTER TABLE kurs_anwesenheit ADD COLUMN IF NOT EXISTS erfasst_von_person_id
    integer REFERENCES person(person_id);
ALTER TABLE kurs_anwesenheit ADD COLUMN IF NOT EXISTS erfasst_am timestamp;

COMMENT ON COLUMN kurs_anwesenheit.erfasst_von_person_id IS
    'Der Coach/Kursleiter, der die Anwesenheit erfasst hat. Wird in der '
    'Maske ueber die Leiter-Auswahl gesetzt, nicht aus einem Login '
    'abgeleitet (Heisenberg hat keines).';

-- Setzt Erfasser und Zeitpunkt automatisch, sobald die Anwesenheit
-- tatsaechlich gesetzt oder geaendert wird. Ein BEFORE-Trigger, damit die
-- Delphi-Seite nichts mitschreiben muss und es auch dann greift, wenn
-- jemand direkt im Grid arbeitet.
--
-- Nur bei ECHTER Aenderung von anwesend/entschuldigt/fehlminuten — sonst
-- wuerde eine reine Bemerkungskorrektur den Erfasser ueberschreiben und so
-- aussehen, als haette der die Anwesenheit gesetzt.
CREATE OR REPLACE FUNCTION fn_kurs_anwesenheit_erfasser()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'UPDATE'
       AND NEW.anwesend IS NOT DISTINCT FROM OLD.anwesend
       AND NEW.entschuldigt IS NOT DISTINCT FROM OLD.entschuldigt
       AND NEW.fehlminuten IS NOT DISTINCT FROM OLD.fehlminuten THEN
        RETURN NEW;
    END IF;

    -- Hat die Anwendung den Erfasser bereits gesetzt, bleibt er stehen.
    IF NEW.erfasst_von_person_id IS NULL THEN
        SELECT t.leiter_person_id INTO NEW.erfasst_von_person_id
          FROM kurs_termin t WHERE t.termin_id = NEW.termin_id;
    END IF;
    NEW.erfasst_am := clock_timestamp();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_kurs_anwesenheit_erfasser ON kurs_anwesenheit;
CREATE TRIGGER tr_kurs_anwesenheit_erfasser
    BEFORE INSERT OR UPDATE ON kurs_anwesenheit
    FOR EACH ROW EXECUTE FUNCTION fn_kurs_anwesenheit_erfasser();

-- ── Offene Anwesenheitslisten je Coach ─────────────────────────────────────
-- Die Arbeitsliste des Coaches: welche meiner Termine sind noch nicht (oder
-- nur teilweise) erfasst. Ausgefallene Termine bleiben aussen vor — dort ist
-- nichts zu erfassen.
CREATE OR REPLACE VIEW v_kurs_anwesenheit_offen AS
SELECT t.termin_id, t.mandant_id,
       t.leiter_person_id AS coach_person_id,
       p.nachname_firmenname || COALESCE(', ' || p.vorname, '') AS coach,
       lower(t.zeitraum)::date AS datum,
       to_char(lower(t.zeitraum), 'DD.MM.YYYY HH24:MI') AS beginn,
       k.bezeichnung AS kurs,
       d.bezeichnung AS durchfuehrung,
       t.status,
       (SELECT count(*) FROM kurs_teilnehmer kt
         WHERE kt.durchfuehrung_id = d.durchfuehrung_id
           AND kt.status IN ('angemeldet','bestaetigt')) AS erwartet,
       (SELECT count(*) FROM kurs_anwesenheit ka
         WHERE ka.termin_id = t.termin_id) AS erfasst
  FROM kurs_termin t
  JOIN kurs_durchfuehrung d ON d.durchfuehrung_id = t.durchfuehrung_id
  JOIN kurs k ON k.kurs_id = d.kurs_id
  LEFT JOIN person p ON p.person_id = t.leiter_person_id
 WHERE t.status <> 'ausgefallen'
   AND (SELECT count(*) FROM kurs_anwesenheit ka WHERE ka.termin_id = t.termin_id)
       < (SELECT count(*) FROM kurs_teilnehmer kt
           WHERE kt.durchfuehrung_id = d.durchfuehrung_id
             AND kt.status IN ('angemeldet','bestaetigt'));
