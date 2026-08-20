-- ============================================================================
-- Besitz aller eigenen Objekte in public auf wwe123 umhaengen
-- Stand 09.08.2026 -- MUSS als postgres laufen.
--
-- Warum: wwe123 ist kein Superuser. ALTER TABLE, CREATE TRIGGER und
-- CREATE OR REPLACE FUNCTION darf nur der Eigentuemer. Von 138 Tabellen
-- gehoeren 131 postgres, von 152 eigenen Funktionen 68 -- damit ist aus der
-- Anwendung heraus keine Schemapflege moeglich.
--
-- Bewusst NICHT "REASSIGN OWNED BY postgres TO wwe123": das greift auf die
-- ganze Datenbank durch, samt Objekten der Erweiterungen (pgcrypto,
-- btree_gist) und der Datenbank selbst. Hier nur Schema public, und
-- Erweiterungsobjekte bleiben aussen vor (pg_depend.deptype = 'e').
-- ============================================================================

DO $$
DECLARE
    r record;
    n integer := 0;
BEGIN
    -- Tabellen, Sichten, materialisierte Sichten.
    -- Sequenzen bewusst NICHT: alle 103 haengen ueber serial oder IDENTITY an
    -- einer Tabellenspalte, und so eine Sequenz kann keinen eigenen
    -- Eigentuemer haben ("Sequenz ist mit Tabelle verknuepft"). Sie folgt
    -- dem Eigentuemer ihrer Tabelle von selbst.
    FOR r IN
        SELECT c.oid::regclass AS obj,
               CASE c.relkind
                   WHEN 'r' THEN 'TABLE'
                   WHEN 'p' THEN 'TABLE'
                   WHEN 'v' THEN 'VIEW'
                   WHEN 'm' THEN 'MATERIALIZED VIEW'
               END AS art
        FROM pg_class c
        JOIN pg_namespace ns ON ns.oid = c.relnamespace AND ns.nspname = 'public'
        WHERE c.relkind IN ('r','p','v','m')
          AND pg_get_userbyid(c.relowner) <> 'wwe123'
          AND NOT EXISTS (SELECT 1 FROM pg_depend d
                          WHERE d.objid = c.oid AND d.deptype = 'e')
    LOOP
        EXECUTE format('ALTER %s %s OWNER TO wwe123', r.art, r.obj);
        n := n + 1;
    END LOOP;
    RAISE NOTICE 'Relationen umgehaengt: %', n;

    n := 0;
    -- Funktionen und Prozeduren
    FOR r IN
        SELECT p.oid::regprocedure AS obj,
               CASE p.prokind WHEN 'p' THEN 'PROCEDURE' ELSE 'FUNCTION' END AS art
        FROM pg_proc p
        JOIN pg_namespace ns ON ns.oid = p.pronamespace AND ns.nspname = 'public'
        WHERE pg_get_userbyid(p.proowner) <> 'wwe123'
          AND NOT EXISTS (SELECT 1 FROM pg_depend d
                          WHERE d.objid = p.oid AND d.deptype = 'e')
    LOOP
        EXECUTE format('ALTER %s %s OWNER TO wwe123', r.art, r.obj);
        n := n + 1;
    END LOOP;
    RAISE NOTICE 'Funktionen umgehaengt: %', n;
END
$$;

-- Kontrolle: muss jeweils 0 ergeben
SELECT count(*) AS relationen_noch_fremd
FROM pg_class c JOIN pg_namespace ns ON ns.oid = c.relnamespace
WHERE ns.nspname='public' AND c.relkind IN ('r','p','v','m')
  AND pg_get_userbyid(c.relowner) <> 'wwe123'
  AND NOT EXISTS (SELECT 1 FROM pg_depend d WHERE d.objid=c.oid AND d.deptype='e');

SELECT count(*) AS funktionen_noch_fremd
FROM pg_proc p JOIN pg_namespace ns ON ns.oid = p.pronamespace
WHERE ns.nspname='public'
  AND pg_get_userbyid(p.proowner) <> 'wwe123'
  AND NOT EXISTS (SELECT 1 FROM pg_depend d WHERE d.objid=p.oid AND d.deptype='e');
