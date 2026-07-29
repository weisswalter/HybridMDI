-- ============================================================================
-- Rekursive Sichten fuer die beiden Baukasten-Baeume - Stand 29.07.2026
--
-- Beide Strukturen sind mehrstufig und selbstbezueglich:
--   artikel_artikel  Stueckliste  (Artikel enthaelt Artikel)
--   kurs_kurs        Baukasten    (Kurs besteht aus Unterkursen)
--
-- Geliefert wird ein FLACHES, bereits richtig sortiertes Ergebnis mit
-- Ebenenangabe - genau das Format, das ArtikelBestandBaumData per
-- Control-Break in einen VirtualStringTree umsetzt. Ein Baum aus N
-- Einzelabfragen waere bei jeder Ebene ein Rundlauf zur Datenbank.
--
-- ZYKLUSSCHUTZ: der Pfad wird als Array mitgefuehrt und ein Knoten, der
-- darin schon vorkommt, nicht weiterverfolgt. Ohne das laeuft die Abfrage
-- bei einem Datenfehler (A enthaelt B enthaelt A) endlos. Bei
-- artikel_artikel gibt es zwar einen Trigger dagegen, bei kurs_kurs aber
-- NICHT - und eine Ansicht darf sich nie darauf verlassen, dass die Daten
-- sauber sind.
-- ============================================================================

-- ── Stueckliste eines Artikels ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_artikel_stueckliste(p_artikel_id integer)
RETURNS TABLE (
    ebene           integer,
    sortpfad        text,
    artikel_id      integer,
    eltern_id       integer,
    artikel_nr      varchar(50),
    artikelname     varchar(200),
    menge           numeric(12,3),
    einheit         varchar(50),
    -- nicht "position": in einer RETURNS TABLE-Liste ein Schluesselwort
    pos_nr          integer,
    ist_zyklus      boolean
)
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE baum AS (
        -- Wurzel: der Artikel selbst, Ebene 0
        SELECT 0 AS ebene,
               lpad('0', 6, '0') AS sortpfad,
               a.artikel_id,
               NULL::integer AS eltern_id,
               a.artikel_nr,
               a.artikelname,
               NULL::numeric(12,3) AS menge,
               NULL::varchar(50) AS einheit,
               NULL::integer AS position,
               false AS ist_zyklus,
               ARRAY[a.artikel_id] AS pfad
          FROM artikel a
         WHERE a.artikel_id = p_artikel_id

        UNION ALL

        SELECT b.ebene + 1,
               b.sortpfad || '.' || lpad(COALESCE(aa.position, 0)::text, 6, '0')
                          || lpad(u.artikel_id::text, 6, '0'),
               u.artikel_id,
               b.artikel_id,
               u.artikel_nr,
               u.artikelname,
               aa.menge,
               e.name,
               aa.position,
               u.artikel_id = ANY(b.pfad) AS ist_zyklus,
               b.pfad || u.artikel_id
          FROM baum b
          JOIN artikel_artikel aa ON aa.artikel_id = b.artikel_id
          JOIN artikel u ON u.artikel_id = aa.unter_artikel_id
          LEFT JOIN einheit e ON e.mandant_id = u.mandant_id
                             AND e.einheit_id = aa.einheit_id
         -- Zyklus: den Knoten noch ZEIGEN (damit der Fehler sichtbar wird),
         -- aber nicht weiter absteigen.
         WHERE NOT b.ist_zyklus
    )
    SELECT ebene, sortpfad, artikel_id, eltern_id, artikel_nr, artikelname,
           menge, einheit, position AS pos_nr, ist_zyklus
      FROM baum
     ORDER BY sortpfad;
$$;

-- ── Baukasten eines Kurses ─────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_kurs_baukasten(p_kurs_id integer)
RETURNS TABLE (
    ebene               integer,
    sortpfad            text,
    kurs_id             integer,
    eltern_id           integer,
    kurs_nr             varchar(50),
    bezeichnung         varchar(200),
    unterrichtsstunden  numeric(6,2),
    pflicht             boolean,
    pos_nr              integer,
    stunden_summe       numeric(6,2),
    ist_zyklus          boolean
)
LANGUAGE sql STABLE AS $$
    WITH RECURSIVE baum AS (
        SELECT 0 AS ebene,
               lpad('0', 6, '0') AS sortpfad,
               k.kurs_id,
               NULL::integer AS eltern_id,
               k.kurs_nr,
               k.bezeichnung,
               k.unterrichtsstunden,
               NULL::boolean AS pflicht,
               NULL::integer AS position,
               false AS ist_zyklus,
               ARRAY[k.kurs_id] AS pfad
          FROM kurs k
         WHERE k.kurs_id = p_kurs_id

        UNION ALL

        SELECT b.ebene + 1,
               b.sortpfad || '.' || lpad(COALESCE(kk.position, 0)::text, 6, '0')
                          || lpad(u.kurs_id::text, 6, '0'),
               u.kurs_id,
               b.kurs_id,
               u.kurs_nr,
               u.bezeichnung,
               u.unterrichtsstunden,
               kk.pflicht,
               kk.position,
               u.kurs_id = ANY(b.pfad) AS ist_zyklus,
               b.pfad || u.kurs_id
          FROM baum b
          JOIN kurs_kurs kk ON kk.kurs_id = b.kurs_id
          JOIN kurs u ON u.kurs_id = kk.unter_kurs_id
         WHERE NOT b.ist_zyklus
    )
    SELECT b.ebene, b.sortpfad, b.kurs_id, b.eltern_id, b.kurs_nr, b.bezeichnung,
           b.unterrichtsstunden, b.pflicht, b.position AS pos_nr,
           -- Summe der Unterrichtsstunden dieses Knotens samt aller Nachfahren.
           -- Beantwortet die Frage, die man bei einem Baukasten wirklich hat:
           -- wieviel Unterricht steckt insgesamt drin.
           (SELECT COALESCE(SUM(x.unterrichtsstunden), 0)
              FROM baum x
             WHERE x.sortpfad LIKE b.sortpfad || '%')::numeric(6,2) AS stunden_summe,
           b.ist_zyklus
      FROM baum b
     ORDER BY b.sortpfad;
$$;
