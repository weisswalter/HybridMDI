-- ============================================================================
-- Entwurf der Zuordnung Funktion -> Tabelle  (Stand 09.08.2026)
--
-- ABGELEITET, NICHT GEPRUEFT. Alles, was hier landet, gehoert zu Funktionen
-- mit geprueft_am = NULL. Erst wenn jemand draufgeschaut und das Datum
-- gesetzt hat, darf sich etwas darauf verlassen.
--
-- Drei Quellen:
--   direkt  — Regex ueber pg_proc.prosrc (INSERT INTO / UPDATE .. SET /
--             DELETE FROM / FROM|JOIN). Der Rumpf ist fuer Postgres nur
--             Text, es gibt keinen besseren Weg. Gegen to_regclass gefiltert,
--             damit CTE-Namen, Aliase und Mengenfunktionen rausfallen.
--   trigger — pg_trigger: was die Trigger der geschriebenen Tabelle ihrerseits
--             schreiben (person schreiben -> tr_audit_person -> audit_log).
--             EINE Ebene tief. Reicht heute: die einzige Tabelle, die per
--             Trigger beschrieben wird und selbst einen Trigger hat, ist
--             audit_log, und dessen fn_audit_log_schutz schreibt nichts.
--   kaskade — pg_constraint mit ON DELETE CASCADE, rekursiv ueber alle Ebenen.
--
-- Beim Sammeln kann dieselbe (Funktion, Tabelle, Wirkung) aus mehreren
-- Quellen kommen. Der Primaerschluessel laesst nur eine zu; min(ueber)
-- gewinnt und das ist alphabetisch 'direkt' vor 'kaskade' vor 'trigger' —
-- also gewinnt der direkte Zugriff, was richtig ist.
-- ============================================================================

WITH RECURSIVE quelle AS (
    SELECT p.proname, p.prosrc
    FROM pg_proc p
    JOIN pg_language l  ON l.oid = p.prolang AND l.lanname IN ('plpgsql','sql')
    JOIN pg_namespace n ON n.oid = p.pronamespace AND n.nspname = 'public'
    WHERE p.proname <> 'fn_funktion_tabelle_pruefen'
),
treffer AS (
    SELECT proname, 'INSERT' AS wirkung, m[1] AS tabelle FROM quelle,
      LATERAL regexp_matches(prosrc,
        'insert\s+into\s+(?:public\.)?([a-z_][a-z0-9_]*)', 'gi') m
    UNION ALL
    -- \y ist in Postgres die Wortgrenze, NICHT \b — \b ist dort das
    -- Backspace-Zeichen und trifft nie. Mit \b lieferte dieser Zweig
    -- stillschweigend null Treffer, und keine einzige UPDATE-Zuordnung
    -- waere im Register gelandet.
    SELECT proname, 'UPDATE', m[1] FROM quelle,
      LATERAL regexp_matches(prosrc,
        'update\s+(?:public\.)?([a-z_][a-z0-9_]*)\s+set\y', 'gi') m
    UNION ALL
    SELECT proname, 'DELETE', m[1] FROM quelle,
      LATERAL regexp_matches(prosrc,
        'delete\s+from\s+(?:public\.)?([a-z_][a-z0-9_]*)', 'gi') m
    UNION ALL
    SELECT proname, 'SELECT', m[1] FROM quelle,
      LATERAL regexp_matches(prosrc,
        '(?:from|join)\s+(?:public\.)?([a-z_][a-z0-9_]*)', 'gi') m
),
gueltig AS (
    SELECT DISTINCT proname, wirkung, tabelle FROM treffer
    WHERE to_regclass('public.' || tabelle) IS NOT NULL
),
schreibt AS (
    SELECT * FROM gueltig WHERE wirkung <> 'SELECT'
),
per_trigger AS (
    SELECT DISTINCT s.proname, tw.wirkung, tw.tabelle
    FROM schreibt s
    JOIN pg_class c     ON c.relname = s.tabelle
    JOIN pg_namespace n ON n.oid = c.relnamespace AND n.nspname = 'public'
    JOIN pg_trigger t   ON t.tgrelid = c.oid AND NOT t.tgisinternal
    JOIN pg_proc tp     ON tp.oid = t.tgfoid
    JOIN schreibt tw    ON tw.proname = tp.proname
    WHERE tp.proname <> s.proname
),
kaskade(proname, tabelle) AS (
    SELECT s.proname, quell.relname
    FROM schreibt s
    JOIN pg_class ref      ON ref.relname = s.tabelle
    JOIN pg_namespace n    ON n.oid = ref.relnamespace AND n.nspname = 'public'
    JOIN pg_constraint con ON con.confrelid = ref.oid
                          AND con.contype = 'f' AND con.confdeltype = 'c'
    JOIN pg_class quell    ON quell.oid = con.conrelid
    WHERE s.wirkung = 'DELETE'
  UNION
    SELECT k.proname, quell.relname
    FROM kaskade k
    JOIN pg_class ref      ON ref.relname = k.tabelle
    JOIN pg_namespace n    ON n.oid = ref.relnamespace AND n.nspname = 'public'
    JOIN pg_constraint con ON con.confrelid = ref.oid
                          AND con.contype = 'f' AND con.confdeltype = 'c'
    JOIN pg_class quell    ON quell.oid = con.conrelid
),
alle AS (
    SELECT proname, tabelle, wirkung, 'direkt'  AS ueber FROM gueltig
    UNION
    SELECT proname, tabelle, wirkung, 'trigger'        FROM per_trigger
    UNION
    SELECT proname, tabelle, 'DELETE', 'kaskade'       FROM kaskade
)
INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, a.tabelle, a.wirkung, min(a.ueber)
FROM alle a
JOIN funktion f ON f.name = a.proname
GROUP BY f.funktion_id, a.tabelle, a.wirkung
ON CONFLICT DO NOTHING;
