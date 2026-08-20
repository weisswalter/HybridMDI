-- ============================================================================
-- Funktionsregister — Stand 09.08.2026
--
-- Drei Tabellen:
--   funktion          eine Zeile je Funktion
--   funktion_tabelle  welche Tabellen eine Funktion anfasst (1:n)
--   funktion_aufruf   Protokoll: was wurde wann mit welchen Werten gerufen
--
-- WARUM VON HAND UND NICHT AUS DEM KATALOG: Postgres fuehrt das nicht mit.
-- Geprueft am 09.08.2026 — pg_depend liefert fuer Funktion -> Tabelle exakt
-- 0 Zeilen, weil der Rumpf einer plpgsql-Funktion fuer den Server nur ein
-- Textblob ist. Von unseren Funktionen sind 93 plpgsql und 56 sql, keine
-- einzige mit Standard-Rumpf (BEGIN ATOMIC) — nur damit wuerde Postgres die
-- Abhaengigkeiten selbst aufloesen und sogar ein DROP TABLE verweigern.
--
-- WOZU: nach einem Schreibvorgang weiss SpAufrufen aus funktion_tabelle,
-- welche Tabellen im zentralen Datenmodul nachzuziehen sind. Heute rufen nur
-- 8 von 21 Modulen ueberhaupt TabelleAuffrischen. Nebenbei zeigt das Register
-- ueber v_tabelle_ohne_schreibfunktion, welche Tabelle gar keinen
-- Schreibweg ueber eine Funktion hat.
-- ============================================================================

-- ── Master ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS funktion (
    funktion_id    serial PRIMARY KEY,
    name           varchar(100) NOT NULL UNIQUE,
    -- Abbild von pg_get_function_arguments, AUSSCHLIESSLICH vom Abgleich
    -- unten geschrieben, nie von Hand. Weicht sie vom Katalog ab, wurde die
    -- Funktion umgebaut — dann wird geprueft_am zurueckgesetzt, weil die
    -- Tabellenzuordnung womoeglich nicht mehr stimmt.
    parameterliste varchar(4000),
    -- NULL = Entwurf. Erst ein Datum heisst: jemand hat die Zuordnung in
    -- funktion_tabelle wirklich geprueft.
    geprueft_am    date
);

COMMENT ON TABLE funktion IS
    'Register aller eigenen Funktionen. geprueft_am NULL = die Zuordnung in '
    'funktion_tabelle ist ein ungeprueter Entwurf.';

-- ── Detail: die betroffenen Tabellen ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS funktion_tabelle (
    funktion_id integer      NOT NULL
                REFERENCES funktion (funktion_id) ON DELETE CASCADE,
    -- Bewusst Text: auf pg_class laesst sich kein Fremdschluessel legen.
    -- Stattdessen prueft tr_funktion_tabelle_pruefen beim Eintragen.
    tabelle     varchar(100) NOT NULL,
    -- Dieselben Woerter wie audit_log.aktion und
    -- information_schema.table_privileges.privilege_type.
    wirkung     varchar(10)  NOT NULL
                CHECK (wirkung IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT')),
    -- Betroffen ist mehr als das, was im Rumpf steht:
    --   direkt  — die Funktion fasst die Tabelle selbst an
    --   trigger — ein Trigger auf der geschriebenen Tabelle fasst sie an
    --             (person schreiben laesst tr_audit_person in audit_log
    --             schreiben)
    --   kaskade — ON DELETE CASCADE raeumt sie mit ab
    -- Ohne diese Zeilen liesse das automatische Auffrischen genau die
    -- Tabellen aus, die niemand im Rumpf sieht.
    ueber       varchar(10)  NOT NULL DEFAULT 'direkt'
                CHECK (ueber IN ('direkt', 'trigger', 'kaskade')),
    PRIMARY KEY (funktion_id, tabelle, wirkung)
);

COMMENT ON TABLE funktion_tabelle IS
    'Welche Tabelle eine Funktion anfasst und auf welchem Weg.';

-- Rueckrichtung: welche Funktionen fassen Tabelle X an? Der
-- Primaerschluessel beginnt mit funktion_id und hilft dafuer nicht.
CREATE INDEX IF NOT EXISTS ix_funktion_tabelle_tabelle
    ON funktion_tabelle (tabelle, wirkung);

-- Tippfehlerschutz. Denselben Fehler — Name eingetragen, Objekt gibt es
-- nicht — habe ich mit den Views schon zweimal gemacht; dort fiel er erst
-- zur Laufzeit auf, verpackt in einen EInvokeSubscriberError.
CREATE OR REPLACE FUNCTION fn_funktion_tabelle_pruefen()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    -- to_regclass liefert NULL statt eines Fehlers. Sichten sind erlaubt:
    -- ein Modul fuellt seine MemTable auch aus einer Sicht, und die muss
    -- genauso nachgezogen werden.
    IF to_regclass('public.' || NEW.tabelle) IS NULL THEN
        RAISE EXCEPTION
            'Tabelle oder Sicht "%" gibt es in public nicht.', NEW.tabelle;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_funktion_tabelle_pruefen ON funktion_tabelle;
CREATE TRIGGER tr_funktion_tabelle_pruefen
    BEFORE INSERT OR UPDATE ON funktion_tabelle
    FOR EACH ROW EXECUTE FUNCTION fn_funktion_tabelle_pruefen();

-- ── Protokoll ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS funktion_aufruf (
    aufruf_id   bigserial PRIMARY KEY,
    funktion_id integer      NOT NULL REFERENCES funktion (funktion_id),
    -- Nur die Werte, in Aufrufreihenfolge. Die Parameternamen stehen im
    -- Katalog und werden beim Lesen dazugeholt (siehe unten) — sie muessen
    -- nicht in jeder Protokollzeile stehen.
    parameter   jsonb        NOT NULL DEFAULT '[]'::jsonb,
    ergebnis    text,
    fehler      text,
    dauer_ms    integer,
    benutzer    varchar(100) NOT NULL DEFAULT current_user,
    mandant_id  integer,
    -- clock_timestamp(), NICHT now(): now() liefert den Transaktionsstart
    -- und waere fuer alle Aufrufe einer Transaktion identisch. Derselbe
    -- Fehler steckte anfangs in audit_log.
    zeitpunkt   timestamp    NOT NULL DEFAULT clock_timestamp()
);

COMMENT ON TABLE funktion_aufruf IS
    'Protokoll jedes Funktionsaufrufs ueber SpAufrufen: Werte, Ergebnis, '
    'Zeitpunkt. Parameternamen kommen aus dem Katalog dazu.';

CREATE INDEX IF NOT EXISTS ix_funktion_aufruf_zeit
    ON funktion_aufruf (zeitpunkt DESC);
CREATE INDEX IF NOT EXISTS ix_funktion_aufruf_funktion
    ON funktion_aufruf (funktion_id, zeitpunkt DESC);

-- ── Abgleich mit dem Katalog ────────────────────────────────────────────────
-- Idempotent: laeuft beliebig oft. Neue Funktionen kommen dazu, geaenderte
-- Signaturen werden nachgezogen UND setzen geprueft_am zurueck.
-- Erfasst werden die eigenen Funktionen (plpgsql/sql in public) — die
-- C-Funktionen gehoeren den Erweiterungen und haben hier nichts zu suchen.
INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
FROM pg_proc p
JOIN pg_language l  ON l.oid = p.prolang  AND l.lanname IN ('plpgsql', 'sql')
JOIN pg_namespace n ON n.oid = p.pronamespace AND n.nspname = 'public'
WHERE p.proname NOT IN ('fn_funktion_tabelle_pruefen')
ON CONFLICT (name) DO UPDATE
    SET parameterliste = EXCLUDED.parameterliste,
        geprueft_am    = CASE
                             WHEN funktion.parameterliste
                                  IS DISTINCT FROM EXCLUDED.parameterliste
                             THEN NULL
                             ELSE funktion.geprueft_am
                         END;
