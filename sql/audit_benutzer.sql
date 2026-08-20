-- ============================================================================
-- Wer war das? — angemeldeter Benutzer im Audit-Log — Stand 02.08.2026
--
-- PROBLEM: `audit_log.geaendert_von` steht auf CURRENT_USER, und die
-- Anwendung meldet sich als `postgres` an. In jedem Eintrag stuende also
-- "postgres" — der alte Wert waere rekonstruierbar, aber nicht, wer ihn
-- ueberschrieben hat. Bei "wer hat den Auftrag geaendert" ist das die
-- halbe Frage.
--
-- LOESUNG: Die Anwendung hinterlegt nach dem Anmelden ihren Benutzernamen
-- in einer Sitzungsvariablen. Der Trigger liest sie aus und faellt auf
-- CURRENT_USER zurueck, wenn nichts gesetzt ist (Wartung ueber psql,
-- PGManager, Skripte).
--
-- EHRLICHE GRENZE: Das ist eine *Behauptung* der Anwendung, keine vom
-- Server gepruefte Identitaet. Solange sich alle als `postgres` anmelden,
-- koennte jemand mit Datenbankzugang etwas anderes hineinschreiben. Es ist
-- trotzdem strikt besser als "postgres" bei jedem Eintrag, und wenn die
-- Anwendung spaeter eine eigene Rolle bekommt, laesst sich beides
-- gegeneinander pruefen.
-- ============================================================================

-- Setzt den angemeldeten Benutzer fuer die laufende Sitzung.
-- Leerer Text loescht die Angabe wieder (z.B. beim Abmelden).
CREATE OR REPLACE FUNCTION fn_app_benutzer_setzen(p_benutzer text)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
    -- false = Sitzungsebene, nicht nur bis zum Transaktionsende. Die
    -- Anwendung haelt ihre Verbindung ueber die gesamte Sitzung.
    PERFORM set_config('app.benutzer', COALESCE(p_benutzer, ''), false);
END;
$$;

-- Wer gilt gerade als Verursacher?
CREATE OR REPLACE FUNCTION fn_app_benutzer()
RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT NULLIF(COALESCE(current_setting('app.benutzer', true), ''), '');
$$;

COMMENT ON FUNCTION fn_app_benutzer IS
    'Angemeldeter Anwendungsbenutzer der Sitzung, NULL wenn nicht gesetzt.';

-- ── Trigger nachziehen ─────────────────────────────────────────────────────
-- Unveraendert bis auf geaendert_von: dort steht jetzt der angemeldete
-- Benutzer, und nur ersatzweise die Datenbankrolle.
CREATE OR REPLACE FUNCTION fn_audit_erfassen()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_id text;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_id := to_jsonb(OLD) ->> TG_ARGV[0];
    ELSE
        v_id := to_jsonb(NEW) ->> TG_ARGV[0];
    END IF;

    INSERT INTO audit_log (tabelle, zeile_id, aktion, alter_wert, neuer_wert,
                           geaendert_von)
    VALUES (TG_TABLE_NAME, v_id, TG_OP,
            CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) END,
            CASE WHEN TG_OP IN ('INSERT','UPDATE') THEN to_jsonb(NEW) END,
            -- Angemeldeter Benutzer, sonst die Datenbankrolle. Das Muster
            -- "postgres" im Log heisst ab jetzt: kam nicht aus der Anwendung.
            COALESCE(fn_app_benutzer(), CURRENT_USER));

    RETURN COALESCE(NEW, OLD);
END;
$$;

-- Bequemer Blick auf die letzten Aenderungen samt Verursacher.
CREATE OR REPLACE VIEW v_audit_letzte AS
SELECT l.log_id,
       l.geaendert_am,
       l.geaendert_von,
       l.tabelle,
       l.zeile_id,
       l.aktion,
       l.alter_wert,
       l.neuer_wert
  FROM audit_log l
 ORDER BY l.geaendert_am DESC, l.log_id DESC;

COMMENT ON VIEW v_audit_letzte IS
    'Audit-Log neueste zuerst. log_id bricht Gleichstaende, weil now() '
    'innerhalb einer Transaktion fuer alle Zeilen identisch ist.';
