-- ============================================================================
-- fn_variante_baum -- Variantenbaum fuer den VirtualStringTree
--
-- Nach dem Muster von fn_artikel_stueckliste (sql/baum_rekursiv.sql): liefert
-- eine flache Liste mit Ebene und Sortpfad, den Aufbau im VST macht dann
-- BaumKnotenData ueber einen Stapel. Die Tiefe ist damit beliebig -- Walters
-- Beispiel hat drei Ebenen (Groesse > Deutsch > 50), spaeter koennen es mehr
-- werden.
--
-- Die Aequivalenzen kommen als fertiger Text mit, damit die Anzeige im Baum
-- nichts nachladen muss: "50   = XXL, 25".
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_variante_baum(p_mandant_id integer)
RETURNS TABLE (
    ebene           integer,
    sortpfad        text,
    variante_id     integer,
    eltern_id       integer,
    name            varchar(100),
    kurzzeichen     varchar(20),
    pfad            text,
    hat_kinder      boolean,
    aequivalenzen   text,
    aktiv           boolean,
    sortierung      integer
)
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE baum AS (
        -- Wurzeln: Knoten ohne Elternteil = die Merkmale selbst
        SELECT 0 AS ebene,
               lpad(v.sortierung::text, 6, '0') || lpad(v.variante_id::text, 6, '0')
                   AS sortpfad,
               v.variante_id,
               NULL::integer AS eltern_id,
               v.name,
               v.kurzzeichen,
               v.name::text AS pfad,
               v.aktiv,
               v.sortierung
          FROM variante v
         WHERE v.mandant_id = p_mandant_id
           AND NOT EXISTS (SELECT 1 FROM variante_variante vv
                            WHERE vv.von_id = v.variante_id
                              AND vv.bezug  = 'child')

        UNION ALL

        SELECT b.ebene + 1,
               b.sortpfad || '.' || lpad(v.sortierung::text, 6, '0')
                          || lpad(v.variante_id::text, 6, '0'),
               v.variante_id,
               b.variante_id,
               v.name,
               v.kurzzeichen,
               b.pfad || ' > ' || v.name,
               v.aktiv,
               v.sortierung
          FROM variante v
          JOIN variante_variante vv
            ON vv.von_id = v.variante_id AND vv.bezug = 'child'
          JOIN baum b ON b.variante_id = vv.nach_id
         WHERE v.mandant_id = p_mandant_id
    )
    SELECT b.ebene,
           b.sortpfad,
           b.variante_id,
           b.eltern_id,
           b.name,
           b.kurzzeichen,
           b.pfad,
           EXISTS (SELECT 1 FROM variante_variante k
                    WHERE k.nach_id = b.variante_id AND k.bezug = 'child')
               AS hat_kinder,
           -- Gleichwertige Knoten als Text. COALESCE, damit die Spalte nie
           -- NULL ist -- der VST zeigt sonst 'nil' statt einer leeren Zelle.
           COALESCE((SELECT string_agg(g.name, ', ' ORDER BY g.name)
                       FROM fn_variante_gleichwertig(b.variante_id) g), '')
               AS aequivalenzen,
           b.aktiv,
           b.sortierung
      FROM baum b
     ORDER BY b.sortpfad;
$$;


-- ── Knoten anlegen und gleich einhaengen ────────────────────────────────────
-- Damit die Oberflaeche fuer "Kind einfuegen" nur EINEN Aufruf braucht und
-- nicht zwei Schritte, zwischen denen etwas schiefgehen kann.
-- p_eltern_id NULL legt ein neues Merkmal auf oberster Ebene an.
CREATE OR REPLACE FUNCTION fn_variante_anlegen(
    p_mandant_id  integer,
    p_name        varchar(100),
    p_eltern_id   integer DEFAULT NULL,
    p_kurzzeichen varchar(20) DEFAULT NULL
) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_id   integer;
    v_sort integer;
BEGIN
    IF p_name IS NULL OR btrim(p_name) = '' THEN
        RAISE EXCEPTION 'Bezeichnung fehlt';
    END IF;

    -- Neuer Knoten kommt ans Ende seiner Geschwisterreihe
    IF p_eltern_id IS NULL THEN
        SELECT COALESCE(max(v.sortierung), 0) + 10 INTO v_sort
          FROM variante v
         WHERE v.mandant_id = p_mandant_id
           AND NOT EXISTS (SELECT 1 FROM variante_variante vv
                            WHERE vv.von_id = v.variante_id AND vv.bezug = 'child');
    ELSE
        SELECT COALESCE(max(v.sortierung), 0) + 10 INTO v_sort
          FROM variante_variante vv
          JOIN variante v ON v.variante_id = vv.von_id
         WHERE vv.nach_id = p_eltern_id AND vv.bezug = 'child';
    END IF;

    INSERT INTO variante (mandant_id, name, kurzzeichen, sortierung)
    VALUES (p_mandant_id, btrim(p_name), p_kurzzeichen, v_sort)
    RETURNING variante.variante_id INTO v_id;

    IF p_eltern_id IS NOT NULL THEN
        -- Die Trigger auf variante_variante pruefen Zyklus und doppelte
        -- Geschwisternamen. Schlaegt das fehl, rollt die ganze Funktion
        -- zurueck und der Knoten oben bleibt nicht als Waise stehen.
        INSERT INTO variante_variante (mandant_id, von_id, nach_id, bezug)
        VALUES (p_mandant_id, v_id, p_eltern_id, 'child');
    END IF;

    RETURN v_id;
END;
$$;


-- ── Aequivalenz setzen ──────────────────────────────────────────────────────
-- Reihenfolge der beiden Knoten ist egal: der Unique-Index ueber
-- LEAST/GREATEST verhindert die Dublette in beide Richtungen. Die Funktion
-- meldet verstaendlich, statt den Constraint-Fehler durchzureichen.
CREATE OR REPLACE FUNCTION fn_variante_gleichsetzen(
    p_mandant_id integer,
    p_a_id       integer,
    p_b_id       integer
) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
    IF p_a_id IS NULL OR p_b_id IS NULL THEN
        RAISE EXCEPTION 'Bitte zwei Auspraegungen waehlen';
    END IF;
    IF p_a_id = p_b_id THEN
        RAISE EXCEPTION 'Eine Auspraegung kann nicht sich selbst entsprechen';
    END IF;

    IF EXISTS (SELECT 1 FROM fn_variante_gleichwertig(p_a_id) g
                WHERE g.variante_id = p_b_id) THEN
        RAISE EXCEPTION '"%" und "%" gelten bereits als gleichwertig',
            (SELECT name FROM variante WHERE variante_id = p_a_id),
            (SELECT name FROM variante WHERE variante_id = p_b_id);
    END IF;

    INSERT INTO variante_variante (mandant_id, von_id, nach_id, bezug)
    VALUES (p_mandant_id, p_a_id, p_b_id, 'aequivalenz');
END;
$$;


-- ── Auswahlliste fuer die ComboBoxen ────────────────────────────────────────
-- Nur Blaetter: Gleichheit zwischen Gruppen ("Deutsch = Englisch") waere
-- sinnlos, gleichgesetzt werden immer konkrete Auspraegungen.
CREATE OR REPLACE VIEW v_variante_auspraegung AS
SELECT b.variante_id,
       b.mandant_id,
       b.name,
       b.pfad,
       b.pfad || CASE WHEN b.aequivalenzen <> ''
                      THEN '   [= ' || b.aequivalenzen || ']'
                      ELSE '' END AS anzeige
  FROM (SELECT f.*, v.mandant_id
          FROM variante v
          JOIN LATERAL fn_variante_baum(v.mandant_id) f
            ON f.variante_id = v.variante_id
         GROUP BY f.ebene, f.sortpfad, f.variante_id, f.eltern_id, f.name,
                  f.kurzzeichen, f.pfad, f.hat_kinder, f.aequivalenzen,
                  f.aktiv, f.sortierung, v.mandant_id) b
 WHERE NOT b.hat_kinder
   AND b.aktiv;
