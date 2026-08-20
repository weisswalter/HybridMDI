-- ============================================================================
-- Revisionssicheres Audit-Log — Stand 03.08.2026 (SEC-02)
--
-- GENERISCHE Trigger-Funktion statt einer eigenen pro Tabelle: eine
-- Implementierung, an beliebige Tabellen anhängbar, bekommt den Namen der
-- PK-Spalte als Trigger-Argument mit. `to_jsonb(OLD)`/`to_jsonb(NEW)` erfasst
-- die GESAMTE Zeile — unabhängig vom Schema der jeweiligen Tabelle, und ohne
-- dass diese Datei bei jeder künftigen Spaltenänderung angepasst werden muss.
--
-- ANGEWANDT AUF VIER SENSIBLE TABELLEN heute Nacht (person, lohn_periode,
-- kostengutsprache, abwesenheit) — NICHT auf alle 115. Das ist eine bewusste
-- Grenze: jede protokollierte Tabelle kostet Schreiblast, und welche Tabellen
-- wirklich prüfungsrelevant sind, ist eine Entscheidung, die Walter treffen
-- sollte, nicht ich stillschweigend für alle 115. Erweitern ist danach nur
-- eine Zeile (siehe Abschnitt 3 unten).
--
-- EHRLICHE GRENZE bei "Wer": Heisenberg hat noch kein eigenes Login-System —
-- die Anwendung verbindet durchgehend als `postgres`-Superuser. `current_user`
-- liefert deshalb heute für JEDEN Anwender denselben Wert. Das Feld ist bereits
-- da, damit es nutzbar wird, sobald es ein echtes DB-Login je Anwender gibt
-- (hängt an SEC-01, siehe Morgenbericht).
--
-- WARUM APPEND-ONLY HIER WIRKLICH GREIFT: Ein simples REVOKE UPDATE/DELETE
-- würde nichts nützen — die App verbindet als Superuser, der Grants ignoriert.
-- Ein BEFORE-Trigger dagegen feuert auch für den Superuser (nur Row-Level-
-- Security wird von Superusern übersprungen, Trigger nicht) — deshalb blockt
-- ein Trigger hier tatsächlich, ein GRANT/REVOKE hätte nur so ausgesehen.
-- ============================================================================

CREATE TABLE IF NOT EXISTS audit_log (
    log_id        bigserial PRIMARY KEY,
    tabelle       varchar(100) NOT NULL,
    zeile_id      varchar(100),
    aktion        varchar(10) NOT NULL CHECK (aktion IN ('INSERT','UPDATE','DELETE')),
    alter_wert    jsonb,
    neuer_wert    jsonb,
    geaendert_von varchar(100) NOT NULL DEFAULT current_user,
    -- clock_timestamp(), NICHT now(): now() liefert den TRANSAKTIONSSTART und
    -- ist damit fuer alle Aenderungen einer Transaktion identisch — bei einem
    -- Test mit INSERT+UPDATE+DELETE in derselben Transaktion zeigte sich das
    -- sofort (alle drei Zeilen exakt derselbe Zeitstempel). clock_timestamp()
    -- liefert die tatsaechliche Ausfuehrungszeit der einzelnen Anweisung.
    geaendert_am  timestamp NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS ix_audit_log_tabelle_zeile
    ON audit_log (tabelle, zeile_id, geaendert_am DESC);
CREATE INDEX IF NOT EXISTS ix_audit_log_zeit ON audit_log (geaendert_am DESC);

COMMENT ON TABLE audit_log IS
    'Revisionssicheres Log: Wer/Wann/Aktion/Alter Wert/Neuer Wert. Append-only '
    'per Trigger erzwungen (siehe fn_audit_log_schutz), nicht nur per GRANT.';

-- ── 1. Die generische Erfassung ────────────────────────────────────────────
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

    INSERT INTO audit_log (tabelle, zeile_id, aktion, alter_wert, neuer_wert)
    VALUES (TG_TABLE_NAME, v_id, TG_OP,
            CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) END,
            CASE WHEN TG_OP IN ('INSERT','UPDATE') THEN to_jsonb(NEW) END);

    RETURN COALESCE(NEW, OLD);
END;
$$;

-- ── 2. Der Schutz: auch der Superuser darf hier nichts ändern/löschen ──────
CREATE OR REPLACE FUNCTION fn_audit_log_schutz()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'audit_log ist append-only - Aenderungen und Loeschungen '
        'sind nicht vorgesehen, auch nicht fuer Administratoren.';
END;
$$;

DROP TRIGGER IF EXISTS tr_audit_log_schutz ON audit_log;
CREATE TRIGGER tr_audit_log_schutz
    BEFORE UPDATE OR DELETE ON audit_log
    FOR EACH ROW EXECUTE FUNCTION fn_audit_log_schutz();

-- ── 3. Anwendung auf vier sensible Tabellen ────────────────────────────────
-- Muster für JEDE weitere Tabelle: dieselbe Zeile mit anderem Tabellen- und
-- PK-Spaltennamen. Bewusst nicht automatisiert über alle Tabellen der DB
-- generiert (DO-Block über information_schema wäre technisch möglich) —
-- genau das wäre die Art von stillschweigend grosser Entscheidung, die nicht
-- unbeaufsichtigt getroffen werden soll.
DROP TRIGGER IF EXISTS tr_audit_person ON person;
CREATE TRIGGER tr_audit_person
    AFTER INSERT OR UPDATE OR DELETE ON person
    FOR EACH ROW EXECUTE FUNCTION fn_audit_erfassen('person_id');

DROP TRIGGER IF EXISTS tr_audit_lohn_periode ON lohn_periode;
CREATE TRIGGER tr_audit_lohn_periode
    AFTER INSERT OR UPDATE OR DELETE ON lohn_periode
    FOR EACH ROW EXECUTE FUNCTION fn_audit_erfassen('periode_id');

DROP TRIGGER IF EXISTS tr_audit_kostengutsprache ON kostengutsprache;
CREATE TRIGGER tr_audit_kostengutsprache
    AFTER INSERT OR UPDATE OR DELETE ON kostengutsprache
    FOR EACH ROW EXECUTE FUNCTION fn_audit_erfassen('gutsprache_id');

DROP TRIGGER IF EXISTS tr_audit_abwesenheit ON abwesenheit;
CREATE TRIGGER tr_audit_abwesenheit
    AFTER INSERT OR UPDATE OR DELETE ON abwesenheit
    FOR EACH ROW EXECUTE FUNCTION fn_audit_erfassen('abwesenheit_id');

-- ── 4. Abfragehilfen ────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_audit_verlauf(p_tabelle varchar, p_zeile_id varchar)
RETURNS TABLE (geaendert_am timestamp, aktion varchar, geaendert_von varchar,
               alter_wert jsonb, neuer_wert jsonb)
LANGUAGE sql STABLE AS $$
    -- log_id als zweites Sortierkriterium: falls clock_timestamp() zweimal
    -- dieselbe Millisekunde trifft, bleibt trotzdem die echte Reihenfolge
    -- (Einfuegereihenfolge = log_id) erhalten.
    SELECT geaendert_am, aktion, geaendert_von, alter_wert, neuer_wert
      FROM audit_log
     WHERE tabelle = p_tabelle AND zeile_id = p_zeile_id
     ORDER BY geaendert_am, log_id;
$$;

-- Nur die geänderten Felder eines einzelnen Log-Eintrags — bei grossen
-- Zeilen (z. B. person mit Foto) ist die Voll-Diff sonst unübersichtlich.
CREATE OR REPLACE FUNCTION fn_audit_diff(p_log_id bigint)
RETURNS TABLE (feld text, vorher text, nachher text)
LANGUAGE sql STABLE AS $$
    SELECT k,
           l.alter_wert ->> k,
           l.neuer_wert ->> k
      FROM audit_log l,
           jsonb_object_keys(COALESCE(l.alter_wert, '{}'::jsonb)
                            || COALESCE(l.neuer_wert, '{}'::jsonb)) AS k
     WHERE l.log_id = p_log_id
       AND (l.alter_wert ->> k) IS DISTINCT FROM (l.neuer_wert ->> k);
$$;
