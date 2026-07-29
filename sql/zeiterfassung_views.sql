-- ============================================================================
-- Zeiterfassung — Sichten und Funktionen fuer das Delphi-Modul.
--
-- Bewusst hier und nicht als Inline-SQL im DataModule: die Rechenregeln
-- (Soll, Saldo, Ferienverbrauch) sollen EINE Wahrheit haben. AnwesenheitDm
-- ruft nur noch `SELECT * FROM fn_...` auf.
--
-- Setzt sql/betriebskalender.sql und sql/zeiterfassung.sql voraus.
-- ============================================================================

-- ── Tagesliste: eine Zeile je Person mit Regime an diesem Tag ──────────────
-- Das ist die linke Liste im Modul. Soll kommt live aus dem Kalender, solange
-- der Tag noch nicht verdichtet wurde — so sieht man das Soll auch vorher.
CREATE OR REPLACE FUNCTION fn_tagesliste(p_mandant_id integer, p_datum date)
RETURNS TABLE (
    person_id       integer,
    name            varchar(300),
    erfassungsart   varchar(20),
    pensum_prozent  numeric(5,2),
    soll_minuten    integer,
    ist_minuten     integer,
    saldo_minuten   integer,
    status          varchar(20),
    abwesenheit     varchar(100),
    offene_checks   bigint
)
LANGUAGE sql STABLE AS $$
    SELECT p.person_id,
           CAST(p.nachname_firmenname ||
                CASE WHEN COALESCE(p.vorname, '') <> ''
                     THEN ', ' || p.vorname ELSE '' END AS varchar(300)),
           az.erfassungsart,
           az.pensum_prozent,
           COALESCE(t.soll_minuten, fn_soll_minuten(p.person_id, p_datum)),
           COALESCE(t.ist_minuten, 0),
           COALESCE(t.ist_minuten, 0)
             - COALESCE(t.soll_minuten, fn_soll_minuten(p.person_id, p_datum)),
           COALESCE(t.status, 'offen')::varchar(20),
           (SELECT CAST(art.bezeichnung AS varchar(100))
              FROM abwesenheit a
              JOIN abwesenheitsart art
                ON art.mandant_id = a.mandant_id AND art.art_id = a.art_id
             WHERE a.person_id = p.person_id AND a.zeitraum @> p_datum
             LIMIT 1),
           -- noch nicht abgehakte Abschnitte — zeigt dem Betreuer die Arbeit an
           (SELECT count(*) FROM anwesenheit_check c
             WHERE c.person_id = p.person_id AND c.datum = p_datum
               AND NOT c.anwesend AND NOT c.entschuldigt)
      FROM person_arbeitszeit az
      JOIN person p ON p.person_id = az.person_id
      LEFT JOIN anwesenheit_tag t
             ON t.person_id = p.person_id AND t.datum = p_datum
     WHERE az.mandant_id = p_mandant_id
       AND az.erfassungsart <> 'keine'
       AND az.gueltig_ab <= p_datum
       AND (az.gueltig_bis IS NULL OR az.gueltig_bis >= p_datum)
     ORDER BY p.nachname_firmenname, p.vorname;
$$;

-- ── Checkliste einer Person an einem Tag (Reiter "Check") ──────────────────
CREATE OR REPLACE FUNCTION fn_checkliste(p_person_id integer, p_datum date)
RETURNS TABLE (
    check_id        integer,
    abschnitt_id    integer,
    -- nicht "position": das ist in einer RETURNS TABLE-Liste ein Schluesselwort
    abschnitt_pos   smallint,
    abschnitt       varchar(100),
    von_zeit        time,
    bis_zeit        time,
    minuten         integer,
    anwesend        boolean,
    entschuldigt    boolean,
    art_id          integer,
    grund           varchar(100),
    fehlminuten     integer,
    bemerkung       text
)
LANGUAGE sql STABLE AS $$
    SELECT c.check_id, a.abschnitt_id, a.position, a.bezeichnung,
           a.von_zeit, a.bis_zeit,
           fn_abschnitt_minuten(a.abschnitt_id, c.mandant_id, az.adresse_id, c.datum),
           c.anwesend, c.entschuldigt, c.art_id,
           CAST(art.bezeichnung AS varchar(100)), c.fehlminuten, c.bemerkung
      FROM anwesenheit_check c
      JOIN raster_abschnitt a ON a.abschnitt_id = c.abschnitt_id
      LEFT JOIN person_arbeitszeit az
             ON az.person_id = c.person_id AND az.mandant_id = c.mandant_id
            AND az.gueltig_ab <= c.datum
            AND (az.gueltig_bis IS NULL OR az.gueltig_bis >= c.datum)
      LEFT JOIN abwesenheitsart art
             ON art.mandant_id = c.mandant_id AND art.art_id = c.art_id
     WHERE c.person_id = p_person_id AND c.datum = p_datum
     ORDER BY a.position;
$$;

-- ── Stempel einer Person an einem Tag (Reiter "Stempel") ───────────────────
CREATE OR REPLACE VIEW v_zeit_stempel_tag AS
SELECT s.stempel_id, s.mandant_id, s.person_id,
       (s.zeitpunkt AT TIME ZONE 'Europe/Zurich')::date AS datum,
       s.zeitpunkt, s.art, s.quelle, s.bemerkung
  FROM zeit_stempel s;

-- ── Monatsuebersicht einer Person (Reiter "Monat") ─────────────────────────
-- Enthaelt AUCH Tage ohne Erfassung, damit Luecken sichtbar werden.
CREATE OR REPLACE FUNCTION fn_monatsliste(
    p_person_id integer, p_jahr integer, p_monat integer)
RETURNS TABLE (
    datum           date,
    wochentag       varchar(10),
    soll_minuten    integer,
    ist_minuten     integer,
    saldo_minuten   integer,
    status          varchar(20),
    abwesenheit     varchar(100)
)
LANGUAGE sql STABLE AS $$
    WITH tage AS (
        SELECT d::date AS datum
          FROM generate_series(
                 make_date(p_jahr, p_monat, 1),
                 (make_date(p_jahr, p_monat, 1) + interval '1 month - 1 day')::date,
                 interval '1 day') d
    )
    SELECT t.datum,
           CAST(to_char(t.datum, 'Dy') AS varchar(10)),
           COALESCE(a.soll_minuten, fn_soll_minuten(p_person_id, t.datum)),
           COALESCE(a.ist_minuten, 0),
           COALESCE(a.ist_minuten, 0)
             - COALESCE(a.soll_minuten, fn_soll_minuten(p_person_id, t.datum)),
           COALESCE(a.status, 'offen')::varchar(20),
           (SELECT CAST(art.bezeichnung AS varchar(100))
              FROM abwesenheit ab
              JOIN abwesenheitsart art
                ON art.mandant_id = ab.mandant_id AND art.art_id = ab.art_id
             WHERE ab.person_id = p_person_id AND ab.zeitraum @> t.datum
             LIMIT 1)
      FROM tage t
      LEFT JOIN anwesenheit_tag a
             ON a.person_id = p_person_id AND a.datum = t.datum
     ORDER BY t.datum;
$$;

-- ── Ferienverbrauch ────────────────────────────────────────────────────────
-- Zaehlt nur BETRIEBSTAGE: Wochenenden und Feiertage innerhalb der Ferien
-- verbrauchen kein Guthaben. Halbtags zaehlt 0.5.
CREATE OR REPLACE FUNCTION fn_abwesenheit_tage(p_abwesenheit_id integer)
RETURNS numeric
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(CASE WHEN a.halbtags THEN 0.5 ELSE 1 END), 0)::numeric
      FROM abwesenheit a
      JOIN person_arbeitszeit az
        ON az.person_id = a.person_id AND az.mandant_id = a.mandant_id
      CROSS JOIN LATERAL generate_series(
             lower(a.zeitraum), upper(a.zeitraum) - 1, interval '1 day') d
     WHERE a.abwesenheit_id = p_abwesenheit_id
       AND az.gueltig_ab <= d::date
       AND (az.gueltig_bis IS NULL OR az.gueltig_bis >= d::date)
       AND fn_betriebszeit_minuten(a.mandant_id, az.adresse_id, d::date) > 0;
$$;

CREATE OR REPLACE VIEW v_ferien_saldo AS
SELECT f.mandant_id, f.person_id, f.jahr,
       f.tage_anspruch, f.tage_uebertrag,
       COALESCE((SELECT SUM(fn_abwesenheit_tage(a.abwesenheit_id))
                   FROM abwesenheit a
                   JOIN abwesenheitsart art
                     ON art.mandant_id = a.mandant_id AND art.art_id = a.art_id
                  WHERE a.person_id = f.person_id
                    AND art.mindert_ferien
                    AND EXTRACT(year FROM lower(a.zeitraum)) = f.jahr), 0) AS tage_bezogen,
       f.tage_anspruch + f.tage_uebertrag
         - COALESCE((SELECT SUM(fn_abwesenheit_tage(a.abwesenheit_id))
                       FROM abwesenheit a
                       JOIN abwesenheitsart art
                         ON art.mandant_id = a.mandant_id AND art.art_id = a.art_id
                      WHERE a.person_id = f.person_id
                        AND art.mindert_ferien
                        AND EXTRACT(year FROM lower(a.zeitraum)) = f.jahr), 0) AS tage_rest
  FROM ferien_anspruch f;

-- ── Abwesenheiten einer Person (Reiter "Abwesenheit") ──────────────────────
CREATE OR REPLACE FUNCTION fn_abwesenheitsliste(p_person_id integer)
RETURNS TABLE (
    abwesenheit_id  integer,
    von_datum       date,
    bis_datum       date,
    grund           varchar(100),
    halbtags        boolean,
    tage            numeric,
    genehmigt       boolean,
    bemerkung       text
)
LANGUAGE sql STABLE AS $$
    SELECT a.abwesenheit_id, lower(a.zeitraum), upper(a.zeitraum) - 1,
           CAST(art.bezeichnung AS varchar(100)), a.halbtags,
           fn_abwesenheit_tage(a.abwesenheit_id),
           a.genehmigt_am IS NOT NULL, a.bemerkung
      FROM abwesenheit a
      JOIN abwesenheitsart art
        ON art.mandant_id = a.mandant_id AND art.art_id = a.art_id
     WHERE a.person_id = p_person_id
     ORDER BY lower(a.zeitraum) DESC;
$$;

-- ── Erfassungsregime einer Person (Reiter "Regime") ────────────────────────
CREATE OR REPLACE FUNCTION fn_regimeliste(p_person_id integer)
RETURNS TABLE (
    arbeitszeit_id  integer,
    gueltig_ab      date,
    gueltig_bis     date,
    erfassungsart   varchar(20),
    raster          varchar(100),
    pensum_prozent  numeric(5,2),
    standort        varchar(200)
)
LANGUAGE sql STABLE AS $$
    SELECT az.arbeitszeit_id, az.gueltig_ab, az.gueltig_bis, az.erfassungsart,
           CAST(r.bezeichnung AS varchar(100)), az.pensum_prozent,
           CAST(COALESCE(ad.strasse, '') || ' ' || COALESCE(ad.ort, '') AS varchar(200))
      FROM person_arbeitszeit az
      LEFT JOIN erfassungsraster r
             ON r.mandant_id = az.mandant_id AND r.raster_id = az.raster_id
      LEFT JOIN adresse ad ON ad.adresse_id = az.adresse_id
     WHERE az.person_id = p_person_id
     ORDER BY az.gueltig_ab DESC;
$$;

-- ── Massenoperationen ──────────────────────────────────────────────────────

-- Legt fuer alle Check-Personen die Abschnittszeilen des Tages an.
-- Ueberspringt Feiertage, Wochenenden und Betriebsferien von selbst, weil
-- fn_betriebszeit_minuten dort 0 liefert. Rueckgabe: Anzahl neuer Zeilen.
CREATE OR REPLACE FUNCTION fn_tagesliste_erzeugen(
    p_mandant_id integer, p_datum date)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_anzahl integer;
BEGIN
    INSERT INTO anwesenheit_check (mandant_id, person_id, datum, abschnitt_id, anwesend)
    SELECT az.mandant_id, az.person_id, p_datum, a.abschnitt_id, false
      FROM person_arbeitszeit az
      JOIN raster_abschnitt a
        ON a.mandant_id = az.mandant_id AND a.raster_id = az.raster_id
     WHERE az.mandant_id = p_mandant_id
       AND az.erfassungsart = 'check'
       AND az.gueltig_ab <= p_datum
       AND (az.gueltig_bis IS NULL OR az.gueltig_bis >= p_datum)
       AND fn_betriebszeit_minuten(az.mandant_id, az.adresse_id, p_datum) > 0
    ON CONFLICT (person_id, datum, abschnitt_id) DO NOTHING;

    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- Verdichtet alle Personen eines Tages. Freigegebene Tage bleiben unberuehrt
-- (das entscheidet fn_tag_verdichten selbst).
CREATE OR REPLACE FUNCTION fn_tag_verdichten_alle(
    p_mandant_id integer, p_datum date)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_anzahl integer := 0; r record;
BEGIN
    FOR r IN SELECT az.person_id FROM person_arbeitszeit az
              WHERE az.mandant_id = p_mandant_id
                AND az.erfassungsart <> 'keine'
                AND az.gueltig_ab <= p_datum
                AND (az.gueltig_bis IS NULL OR az.gueltig_bis >= p_datum)
    LOOP
        PERFORM fn_tag_verdichten(r.person_id, p_datum);
        v_anzahl := v_anzahl + 1;
    END LOOP;
    RETURN v_anzahl;
END;
$$;
