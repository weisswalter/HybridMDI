-- ============================================================================
-- Diagnosehilfen zum Notfallzugang — Stand 03.08.2026
--
-- WICHTIG ZUR ABGRENZUNG: Der Notfallzugang selbst (TAN-Liste, Anmeldung,
-- Wiederherstellung) liegt BEWUSST NICHT in der Datenbank, sondern im
-- Programm (NotfallFrm.pas). Walters Begründung, wörtlich: der Zugang soll
-- gerade dann noch funktionieren, wenn die Datenbank das Problem IST — und
-- er soll sie auf einen Sicherungsstand zurücksetzen können. Läge der
-- Mechanismus in derselben Datenbank, würde er beim Zurücksetzen
-- mitgelöscht und wäre im entscheidenden Moment nicht da.
--
-- Was hier bleibt, sind reine LESE-Hilfen für die Ursachensuche. Sie sind
-- Teil des Audit-Logs, nicht des Notfallzugangs, und funktionieren auch im
-- Normalbetrieb.
-- ============================================================================

-- Genau Walters Fall "ein Mandant wurde verschoben": zeigt alle Änderungen,
-- bei denen sich eine mandant_id tatsächlich geändert hat. Damit lässt sich
-- vor einem Zurücksetzen erst einmal nachsehen, WAS überhaupt passiert ist —
-- oft reicht das, und die grosse Wiederherstellung bleibt aus.
CREATE OR REPLACE VIEW v_mandant_verschiebungen AS
SELECT log_id, geaendert_am, tabelle, zeile_id, geaendert_von,
       alter_wert->>'mandant_id' AS mandant_vorher,
       neuer_wert->>'mandant_id' AS mandant_nachher
  FROM audit_log
 WHERE aktion = 'UPDATE'
   AND (alter_wert ? 'mandant_id')
   AND (alter_wert->>'mandant_id') IS DISTINCT FROM (neuer_wert->>'mandant_id')
 ORDER BY geaendert_am DESC;

COMMENT ON VIEW v_mandant_verschiebungen IS
    'Diagnose: welche Datensaetze wurden einem anderen Mandanten zugeordnet. '
    'Nur Anzeige - das Zuruecksetzen passiert ueber den Notfallzugang im '
    'Programm (Wiederherstellung aus dem letzten Dump).';

-- Was wurde in einem Zeitraum überhaupt geändert — die Übersicht, mit der
-- die Ursachensuche anfängt.
CREATE OR REPLACE FUNCTION fn_aenderungen_zeitraum(
    p_von timestamp, p_bis timestamp, p_tabelle varchar DEFAULT NULL)
RETURNS TABLE (log_id bigint, zeitpunkt timestamp, tabelle varchar,
               zeile_id varchar, aktion varchar, wer varchar, kurzfassung text)
LANGUAGE sql STABLE AS $$
    SELECT l.log_id, l.geaendert_am, l.tabelle, l.zeile_id, l.aktion,
           l.geaendert_von,
           CASE l.aktion
             WHEN 'DELETE' THEN 'geloescht: ' || left(l.alter_wert::text, 200)
             WHEN 'INSERT' THEN 'angelegt: ' || left(l.neuer_wert::text, 200)
             ELSE (SELECT string_agg(k || ': ' || COALESCE(l.alter_wert->>k, '<leer>')
                                     || ' -> ' || COALESCE(l.neuer_wert->>k, '<leer>'), ', ')
                     FROM jsonb_object_keys(COALESCE(l.alter_wert,'{}'::jsonb)
                                          || COALESCE(l.neuer_wert,'{}'::jsonb)) AS k
                    WHERE (l.alter_wert->>k) IS DISTINCT FROM (l.neuer_wert->>k))
           END
      FROM audit_log l
     WHERE l.geaendert_am BETWEEN p_von AND p_bis
       AND (p_tabelle IS NULL OR l.tabelle = p_tabelle)
     ORDER BY l.geaendert_am DESC, l.log_id DESC;
$$;
