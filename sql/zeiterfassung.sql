-- ============================================================================
-- Zeiterfassung / Anwesenheit — Stand 28.07.2026
--
-- ZWEI ERFASSUNGSARTEN, EINE VERDICHTUNG:
--   'stempel' (Lehrer/Mitarbeiter) — kommen/gehen/Pause, minutengenau
--   'check'   (Klienten)           — Kontrolle je Abschnitt, Vormittag/Nachmittag
--                                    (Anzahl der Abschnitte frei konfigurierbar)
-- Beide muenden in `anwesenheit_tag` (Soll/Ist je Person und Tag). Welche Art
-- fuer wen gilt, steht in `person_arbeitszeit` — dieselbe Person kann das
-- Regime im Lauf der Zeit wechseln (Klient wird Mitarbeiter).
--
-- SOLL kommt IMMER aus dem Betriebskalender x Pensum, nie aus der Erfassung
-- (siehe sql/betriebskalender.sql). Feiertage sind deshalb KEIN
-- Abwesenheitsgrund — sie setzen das Soll auf 0.
--
-- Abgrenzung zu `kurs_anwesenheit`: das bleibt die feine, didaktische Ebene
-- (wer hat WELCHE Lektion verpasst). Hier geht es um den Tag als Ganzes
-- (Stundennachweis, Fehlzeiten). Die beiden koexistieren bewusst.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Hilfsfunktion: time -> Minuten seit Mitternacht. IMMUTABLE, damit sie in
-- EXCLUDE-Constraints und Indexausdruecken verwendet werden darf.
CREATE OR REPLACE FUNCTION fn_time_minuten(p_zeit time)
RETURNS integer LANGUAGE sql IMMUTABLE AS $$
    SELECT (EXTRACT(hour FROM p_zeit) * 60 + EXTRACT(minute FROM p_zeit))::integer;
$$;

-- ── 1. Erfassungsraster (die "Haeufigkeit") ────────────────────────────────
-- Ein Raster ist eine benannte Zerlegung des Tages in Kontrollabschnitte.
-- 1 Abschnitt  = einmal taeglich
-- 2 Abschnitte = Vormittag / Nachmittag  (Walters Regelfall)
-- n Abschnitte = beliebig feiner, ohne Codeaenderung
CREATE TABLE IF NOT EXISTS erfassungsraster (
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    raster_id       serial,
    bezeichnung     varchar(100) NOT NULL,
    beschreibung    text,
    aktiv           boolean NOT NULL DEFAULT true,
    PRIMARY KEY (mandant_id, raster_id),
    UNIQUE (mandant_id, bezeichnung)
);

-- KEIN Wochentag: der Abschnitt ist die grobe Tagesstruktur, die feine
-- Wahrheit liefert die Betriebszeit. Endet der Freitag um 15:00, wird der
-- Nachmittagsabschnitt 13:00-17:00 von fn_abschnitt_minuten automatisch auf
-- zwei Stunden beschnitten — das Raster muss das nicht wissen.
CREATE TABLE IF NOT EXISTS raster_abschnitt (
    abschnitt_id    serial PRIMARY KEY,
    mandant_id      integer NOT NULL,
    raster_id       integer NOT NULL,
    position        smallint NOT NULL,
    bezeichnung     varchar(100) NOT NULL,
    von_zeit        time NOT NULL,
    bis_zeit        time NOT NULL,
    FOREIGN KEY (mandant_id, raster_id)
        REFERENCES erfassungsraster(mandant_id, raster_id) ON DELETE CASCADE,
    UNIQUE (mandant_id, raster_id, position),
    CHECK (bis_zeit > von_zeit),
    -- Abschnitte desselben Rasters duerfen sich nicht ueberlappen, sonst
    -- wuerde dieselbe Minute doppelt als Ist gezaehlt.
    EXCLUDE USING gist (
        mandant_id WITH =, raster_id WITH =,
        int4range(fn_time_minuten(von_zeit), fn_time_minuten(bis_zeit)) WITH &&)
);

-- ── 2. Erfassungsregime je Person ──────────────────────────────────────────
-- Beantwortet drei Fragen auf einmal: WIE wird erfasst, mit welchem PENSUM,
-- an welchem STANDORT (der Standort bestimmt Betriebszeit und Feiertage).
CREATE TABLE IF NOT EXISTS person_arbeitszeit (
    arbeitszeit_id  serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    gueltig_ab      date NOT NULL,
    gueltig_bis     date,
    erfassungsart   varchar(20) NOT NULL
                    CHECK (erfassungsart IN ('stempel', 'check', 'keine')),
    raster_id       integer,
    -- Lehrer 80% Anstellung, Klient 60% Programm — dieselbe Groesse
    pensum_prozent  numeric(5,2) NOT NULL DEFAULT 100
                    CHECK (pensum_prozent > 0 AND pensum_prozent <= 100),
    adresse_id      integer REFERENCES adresse(adresse_id),
    bemerkung       text,
    FOREIGN KEY (mandant_id, raster_id)
        REFERENCES erfassungsraster(mandant_id, raster_id),
    CHECK (erfassungsart <> 'check' OR raster_id IS NOT NULL),
    CHECK (gueltig_bis IS NULL OR gueltig_bis >= gueltig_ab),
    -- Eine Person kann pro Mandant nicht zwei Regime gleichzeitig haben
    EXCLUDE USING gist (
        person_id WITH =, mandant_id WITH =,
        daterange(gueltig_ab, gueltig_bis, '[]') WITH &&)
);

-- ── 3. Erfassung: Stempel (Lehrer) ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS zeit_stempel (
    stempel_id      serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    zeitpunkt       timestamptz NOT NULL,
    art             varchar(20) NOT NULL
                    CHECK (art IN ('kommen', 'gehen', 'pause_start', 'pause_ende')),
    quelle          varchar(30) NOT NULL DEFAULT 'manuell',
    erfasst_von     integer REFERENCES person(person_id),
    erfasst_am      timestamptz NOT NULL DEFAULT now(),
    bemerkung       text,
    UNIQUE (person_id, zeitpunkt, art)
);

-- `zeitpunkt::date` waere STABLE (haengt an der Session-Zeitzone) und damit im
-- Index nicht erlaubt. Feste Zone — CH und Muenchen liegen ohnehin in derselben.
CREATE INDEX IF NOT EXISTS ix_zeit_stempel_person_tag
    ON zeit_stempel (person_id, ((zeitpunkt AT TIME ZONE 'Europe/Zurich')::date));

-- ── 4. Erfassung: Check (Klienten) ─────────────────────────────────────────
-- Eine Zeile je Person, Tag und Abschnitt. Bei zwei Abschnitten also zwei
-- Zeilen pro Klient und Tag — Vormittag anwesend, Nachmittag entschuldigt.
CREATE TABLE IF NOT EXISTS anwesenheit_check (
    check_id        serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    datum           date NOT NULL,
    abschnitt_id    integer NOT NULL REFERENCES raster_abschnitt(abschnitt_id),
    anwesend        boolean NOT NULL DEFAULT false,
    entschuldigt    boolean NOT NULL DEFAULT false,
    art_id          integer,
    -- Teilanwesenheit: kam 40 Minuten zu spaet
    fehlminuten     integer CHECK (fehlminuten IS NULL OR fehlminuten >= 0),
    erfasst_von     integer REFERENCES person(person_id),
    erfasst_am      timestamptz NOT NULL DEFAULT now(),
    bemerkung       text,
    UNIQUE (person_id, datum, abschnitt_id)
);

CREATE INDEX IF NOT EXISTS ix_anwesenheit_check_tag
    ON anwesenheit_check (mandant_id, datum);

-- ── 5. Abwesenheiten (Ferien, Krankheit, ...) ──────────────────────────────
CREATE TABLE IF NOT EXISTS abwesenheitsart (
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    art_id          serial,
    bezeichnung     varchar(100) NOT NULL,
    bezahlt         boolean NOT NULL DEFAULT false,
    -- true = die Soll-Zeit gilt als erfuellt (Ferien, Krankheit)
    -- false = Fehlzeit, die im Saldo stehen bleibt (unentschuldigt)
    zaehlt_als_soll boolean NOT NULL DEFAULT true,
    braucht_beleg   boolean NOT NULL DEFAULT false,
    -- true = zieht Tage vom Ferienanspruch ab
    mindert_ferien  boolean NOT NULL DEFAULT false,
    -- false = nur fuer Mitarbeiter bzw. nur fuer Klienten sichtbar
    fuer_klient     boolean NOT NULL DEFAULT true,
    fuer_mitarbeiter boolean NOT NULL DEFAULT true,
    aktiv           boolean NOT NULL DEFAULT true,
    PRIMARY KEY (mandant_id, art_id),
    UNIQUE (mandant_id, bezeichnung)
);

ALTER TABLE anwesenheit_check
    DROP CONSTRAINT IF EXISTS anwesenheit_check_art_fkey;
ALTER TABLE anwesenheit_check
    ADD CONSTRAINT anwesenheit_check_art_fkey
    FOREIGN KEY (mandant_id, art_id) REFERENCES abwesenheitsart(mandant_id, art_id);

CREATE TABLE IF NOT EXISTS abwesenheit (
    abwesenheit_id  serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    art_id          integer NOT NULL,
    zeitraum        daterange NOT NULL,
    halbtags        boolean NOT NULL DEFAULT false,
    genehmigt_von   integer REFERENCES person(person_id),
    genehmigt_am    timestamptz,
    bemerkung       text,
    FOREIGN KEY (mandant_id, art_id)
        REFERENCES abwesenheitsart(mandant_id, art_id),
    -- Niemand ist gleichzeitig in den Ferien und krank gemeldet
    EXCLUDE USING gist (person_id WITH =, zeitraum WITH &&)
);

CREATE TABLE IF NOT EXISTS ferien_anspruch (
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    jahr            smallint NOT NULL,
    tage_anspruch   numeric(5,2) NOT NULL,
    tage_uebertrag  numeric(5,2) NOT NULL DEFAULT 0,
    bemerkung       text,
    PRIMARY KEY (person_id, jahr)
);

-- ── 6. Verdichtung je Tag ──────────────────────────────────────────────────
-- Bewusst eine eigene Tabelle und keine View: der Tag wird irgendwann
-- freigegeben und darf sich danach nicht mehr aendern, auch wenn jemand
-- rueckwirkend an den Betriebszeiten dreht.
CREATE TABLE IF NOT EXISTS anwesenheit_tag (
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    datum           date NOT NULL,
    soll_minuten    integer NOT NULL DEFAULT 0,
    ist_minuten     integer NOT NULL DEFAULT 0,
    pause_minuten   integer NOT NULL DEFAULT 0,
    status          varchar(20) NOT NULL DEFAULT 'offen'
                    CHECK (status IN ('offen', 'erfasst', 'freigegeben')),
    freigegeben_von integer REFERENCES person(person_id),
    freigegeben_am  timestamptz,
    bemerkung       text,
    PRIMARY KEY (person_id, datum)
);

CREATE INDEX IF NOT EXISTS ix_anwesenheit_tag_mandant
    ON anwesenheit_tag (mandant_id, datum);

-- ── 7. Funktionen ──────────────────────────────────────────────────────────

-- Wie viele Minuten des Abschnitts fallen tatsaechlich in die Betriebszeit?
-- Beschneidet z.B. den Nachmittag 13:00-17:00 am kurzen Freitag auf 13:00-15:00.
CREATE OR REPLACE FUNCTION fn_abschnitt_minuten(
    p_abschnitt_id integer, p_mandant_id integer,
    p_adresse_id integer, p_datum date)
RETURNS integer
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_von time; v_bis time; v_hat_eigene boolean; v_minuten integer;
BEGIN
    SELECT von_zeit, bis_zeit INTO v_von, v_bis
      FROM raster_abschnitt WHERE abschnitt_id = p_abschnitt_id;
    IF NOT FOUND THEN RETURN 0; END IF;

    -- Geschlossen/Feiertag: der Betriebskalender hat das letzte Wort
    IF fn_betriebszeit_minuten(p_mandant_id, p_adresse_id, p_datum) = 0 THEN
        RETURN 0;
    END IF;

    SELECT EXISTS (SELECT 1 FROM betriebszeit z
                    WHERE z.mandant_id = p_mandant_id
                      AND z.adresse_id = p_adresse_id
                      AND z.wochentag = EXTRACT(isodow FROM p_datum)::smallint
                      AND z.gueltig_ab <= p_datum
                      AND (z.gueltig_bis IS NULL OR z.gueltig_bis >= p_datum))
      INTO v_hat_eigene;

    SELECT COALESCE(SUM(
             GREATEST(0, fn_time_minuten(LEAST(z.bis_zeit, v_bis))
                       - fn_time_minuten(GREATEST(z.von_zeit, v_von)))), 0)
      INTO v_minuten
      FROM betriebszeit z
     WHERE z.mandant_id = p_mandant_id
       AND z.wochentag = EXTRACT(isodow FROM p_datum)::smallint
       AND z.gueltig_ab <= p_datum
       AND (z.gueltig_bis IS NULL OR z.gueltig_bis >= p_datum)
       AND (CASE WHEN v_hat_eigene THEN z.adresse_id = p_adresse_id
                 ELSE z.adresse_id IS NULL END);

    RETURN v_minuten;
END;
$$;

-- Soll-Minuten einer Person an einem Tag = Betriebszeit x Pensum.
-- Kommt AUSSCHLIESSLICH aus dem Kalender, nie aus der Erfassung.
CREATE OR REPLACE FUNCTION fn_soll_minuten(p_person_id integer, p_datum date)
RETURNS integer
LANGUAGE plpgsql STABLE AS $$
DECLARE r record;
BEGIN
    SELECT mandant_id, adresse_id, pensum_prozent INTO r
      FROM person_arbeitszeit
     WHERE person_id = p_person_id
       AND erfassungsart <> 'keine'
       AND gueltig_ab <= p_datum
       AND (gueltig_bis IS NULL OR gueltig_bis >= p_datum)
     LIMIT 1;
    IF NOT FOUND THEN RETURN 0; END IF;

    RETURN ROUND(fn_betriebszeit_minuten(r.mandant_id, r.adresse_id, p_datum)
                 * r.pensum_prozent / 100.0);
END;
$$;

-- Ist-Minuten aus beiden Erfassungswegen, vereinheitlicht.
CREATE OR REPLACE VIEW v_anwesenheit_ist AS
-- Weg A: Stempel. kommen/gehen und pause_start/pause_ende werden getrennt
-- gepaart, damit eine Pause zwischen kommen und gehen die Paarung nicht zerreisst.
WITH kg AS (
    SELECT person_id, mandant_id, (zeitpunkt AT TIME ZONE 'Europe/Zurich')::date AS datum,
           art, zeitpunkt,
           lead(zeitpunkt) OVER w AS n_zeit,
           lead(art)       OVER w AS n_art
      FROM zeit_stempel WHERE art IN ('kommen', 'gehen')
    WINDOW w AS (PARTITION BY person_id, (zeitpunkt AT TIME ZONE 'Europe/Zurich')::date
                 ORDER BY zeitpunkt)
), pz AS (
    SELECT person_id, (zeitpunkt AT TIME ZONE 'Europe/Zurich')::date AS datum,
           art, zeitpunkt,
           lead(zeitpunkt) OVER w AS n_zeit,
           lead(art)       OVER w AS n_art
      FROM zeit_stempel WHERE art IN ('pause_start', 'pause_ende')
    WINDOW w AS (PARTITION BY person_id, (zeitpunkt AT TIME ZONE 'Europe/Zurich')::date
                 ORDER BY zeitpunkt)
), stempel AS (
    SELECT kg.person_id, kg.mandant_id, kg.datum,
           SUM(EXTRACT(epoch FROM (kg.n_zeit - kg.zeitpunkt))::integer / 60)
               FILTER (WHERE kg.art = 'kommen' AND kg.n_art = 'gehen') AS brutto,
           COALESCE((SELECT SUM(EXTRACT(epoch FROM (p.n_zeit - p.zeitpunkt))::integer / 60)
                       FROM pz p
                      WHERE p.person_id = kg.person_id AND p.datum = kg.datum
                        AND p.art = 'pause_start' AND p.n_art = 'pause_ende'), 0) AS pause
      FROM kg
     GROUP BY kg.person_id, kg.mandant_id, kg.datum
)
SELECT person_id, mandant_id, datum, 'stempel'::varchar(10) AS quelle,
       GREATEST(0, COALESCE(brutto, 0) - pause) AS ist_minuten,
       pause AS pause_minuten
  FROM stempel
UNION ALL
-- Weg B: Checks. Anwesender Abschnitt zaehlt seine Betriebszeit-Minuten,
-- abzueglich gemeldeter Verspaetung.
SELECT c.person_id, c.mandant_id, c.datum, 'check'::varchar(10),
       COALESCE(SUM(GREATEST(0,
           fn_abschnitt_minuten(c.abschnitt_id, c.mandant_id, az.adresse_id, c.datum)
           - COALESCE(c.fehlminuten, 0))) FILTER (WHERE c.anwesend), 0)::integer,
       0
  FROM anwesenheit_check c
  LEFT JOIN person_arbeitszeit az
         ON az.person_id = c.person_id AND az.mandant_id = c.mandant_id
        AND az.gueltig_ab <= c.datum
        AND (az.gueltig_bis IS NULL OR az.gueltig_bis >= c.datum)
 GROUP BY c.person_id, c.mandant_id, c.datum;

-- Schreibt Soll und Ist eines Tages fest. Freigegebene Tage bleiben unberuehrt.
CREATE OR REPLACE FUNCTION fn_tag_verdichten(p_person_id integer, p_datum date)
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    v_mandant integer; v_soll integer;
    v_ist integer := 0; v_pause integer := 0;
BEGIN
    SELECT mandant_id INTO v_mandant FROM person_arbeitszeit
     WHERE person_id = p_person_id AND gueltig_ab <= p_datum
       AND (gueltig_bis IS NULL OR gueltig_bis >= p_datum) LIMIT 1;
    IF v_mandant IS NULL THEN RETURN; END IF;

    IF EXISTS (SELECT 1 FROM anwesenheit_tag
                WHERE person_id = p_person_id AND datum = p_datum
                  AND status = 'freigegeben') THEN
        RETURN;
    END IF;

    v_soll := fn_soll_minuten(p_person_id, p_datum);

    SELECT COALESCE(SUM(ist_minuten), 0), COALESCE(SUM(pause_minuten), 0)
      INTO v_ist, v_pause
      FROM v_anwesenheit_ist
     WHERE person_id = p_person_id AND datum = p_datum;

    -- Genehmigte Abwesenheit mit zaehlt_als_soll gutschreiben (Ferien, Krankheit)
    IF EXISTS (SELECT 1 FROM abwesenheit a
                 JOIN abwesenheitsart t
                   ON t.mandant_id = a.mandant_id AND t.art_id = a.art_id
                WHERE a.person_id = p_person_id AND a.zeitraum @> p_datum
                  AND t.zaehlt_als_soll) THEN
        v_ist := GREATEST(v_ist, CASE WHEN (SELECT halbtags FROM abwesenheit
                                             WHERE person_id = p_person_id
                                               AND zeitraum @> p_datum LIMIT 1)
                                      THEN v_soll / 2 ELSE v_soll END);
    END IF;

    INSERT INTO anwesenheit_tag (mandant_id, person_id, datum, soll_minuten,
                                 ist_minuten, pause_minuten, status)
    VALUES (v_mandant, p_person_id, p_datum, v_soll, v_ist, v_pause, 'erfasst')
    ON CONFLICT (person_id, datum) DO UPDATE
       SET soll_minuten = EXCLUDED.soll_minuten,
           ist_minuten  = EXCLUDED.ist_minuten,
           pause_minuten = EXCLUDED.pause_minuten,
           status = 'erfasst';
END;
$$;

-- ── 8. Seeds ───────────────────────────────────────────────────────────────

-- Standardraster "Halbtags" je Mandant: Vormittag / Nachmittag.
INSERT INTO erfassungsraster (mandant_id, bezeichnung, beschreibung)
SELECT m.mandant_id, 'Halbtags', 'Kontrolle am Vormittag und am Nachmittag'
  FROM mandant m
 WHERE NOT EXISTS (SELECT 1 FROM erfassungsraster r
                    WHERE r.mandant_id = m.mandant_id AND r.bezeichnung = 'Halbtags');

INSERT INTO raster_abschnitt (mandant_id, raster_id, position, bezeichnung, von_zeit, bis_zeit)
SELECT r.mandant_id, r.raster_id, a.pos, a.bez, a.von, a.bis
  FROM erfassungsraster r,
       (VALUES (1::smallint, 'Vormittag',  TIME '08:00', TIME '12:00'),
               (2::smallint, 'Nachmittag', TIME '13:00', TIME '17:00')) AS a(pos, bez, von, bis)
 WHERE r.bezeichnung = 'Halbtags'
   AND NOT EXISTS (SELECT 1 FROM raster_abschnitt x
                    WHERE x.mandant_id = r.mandant_id AND x.raster_id = r.raster_id);

-- Taegliche Einmalkontrolle als Alternative
INSERT INTO erfassungsraster (mandant_id, bezeichnung, beschreibung)
SELECT m.mandant_id, 'Taeglich', 'Eine Kontrolle pro Tag'
  FROM mandant m
 WHERE NOT EXISTS (SELECT 1 FROM erfassungsraster r
                    WHERE r.mandant_id = m.mandant_id AND r.bezeichnung = 'Taeglich');

INSERT INTO raster_abschnitt (mandant_id, raster_id, position, bezeichnung, von_zeit, bis_zeit)
SELECT r.mandant_id, r.raster_id, 1, 'Ganztags', TIME '08:00', TIME '17:00'
  FROM erfassungsraster r
 WHERE r.bezeichnung = 'Taeglich'
   AND NOT EXISTS (SELECT 1 FROM raster_abschnitt x
                    WHERE x.mandant_id = r.mandant_id AND x.raster_id = r.raster_id);

-- Abwesenheitsarten
INSERT INTO abwesenheitsart (mandant_id, bezeichnung, bezahlt, zaehlt_als_soll,
                             braucht_beleg, mindert_ferien, fuer_klient, fuer_mitarbeiter)
SELECT m.mandant_id, a.bez, a.bez_lohn, a.soll, a.beleg, a.ferien, a.klient, a.ma
  FROM mandant m, (VALUES
    ('Ferien',              true,  true,  false, true,  true,  true),
    ('Krankheit',           true,  true,  false, false, true,  true),
    ('Krankheit mit Zeugnis', true, true, true,  false, true,  true),
    ('Unfall',              true,  true,  true,  false, true,  true),
    ('Arzttermin',          true,  true,  false, false, true,  true),
    ('Militaer / Zivilschutz', true, true, true, false, false, true),
    ('Behoerdentermin',     true,  true,  false, false, true,  true),
    ('Unbezahlter Urlaub',  false, false, false, false, true,  true),
    ('Unentschuldigt',      false, false, false, false, true,  true)
  ) AS a(bez, bez_lohn, soll, beleg, ferien, klient, ma)
 WHERE NOT EXISTS (SELECT 1 FROM abwesenheitsart x
                    WHERE x.mandant_id = m.mandant_id AND x.bezeichnung = a.bez);
