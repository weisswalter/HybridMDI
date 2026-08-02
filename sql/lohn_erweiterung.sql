-- ============================================================================
-- Lohnmodell Stufe 2 — Stand 01.08.2026
-- 13. Monatslohn · Zulagen · Sozialabzüge (AHV/ALV/BVG) · bezahlte Abwesenheit
--
-- WIEDER GILT: nichts neu bauen, was schon da ist.
--   abwesenheit + abwesenheitsart sind bereits vollständig gepflegt und
--   tragen genau die zwei Merkmale, auf die es beim Lohn ankommt:
--     `bezahlt`         → wird die Zeit vergütet?
--     `zaehlt_als_soll` → zählt sie wie geleistete Arbeitszeit?
--   fn_soll_minuten() kennt Betriebszeiten, Pensum und Feiertage.
--   person.geburtsdatum ist vorhanden → BVG-Altersstaffel ist rechenbar.
--
-- WAS FEHLTE, war die Brücke zum Lohn: Ein Ferientag darf keine Minusstunden
-- erzeugen, und beim Stundenlohn muss bezahlte Abwesenheit auch bezahlt
-- werden — sonst verliert eine Stundenlohnkraft ihren Ferien- und Kranklohn.
-- ============================================================================

-- ── 1. Vereinbarung erweitern ──────────────────────────────────────────────

-- 13. Monatslohn: Anteil in Prozent eines Monatslohns (100 = voller 13.).
-- Zwei Auszahlungsmonate, weil die Hälfte im Juni und die Hälfte im Dezember
-- verbreitet ist. NULL im zweiten Feld = alles in einer Rate.
ALTER TABLE person_lohn ADD COLUMN IF NOT EXISTS dreizehnter_prozent
    numeric(5,2) NOT NULL DEFAULT 0 CHECK (dreizehnter_prozent >= 0);
ALTER TABLE person_lohn ADD COLUMN IF NOT EXISTS dreizehnter_monat
    smallint CHECK (dreizehnter_monat BETWEEN 1 AND 12);
ALTER TABLE person_lohn ADD COLUMN IF NOT EXISTS dreizehnter_monat2
    smallint CHECK (dreizehnter_monat2 BETWEEN 1 AND 12);

-- Ferienentschädigung als Zuschlag statt bezahlter Ferien — der übliche Weg
-- bei Stundenlohn, weil dort ein freier Tag sonst schlicht unbezahlt bliebe.
-- 8.33 % entspricht 4 Wochen, 10.64 % entspricht 5 Wochen.
-- 0 = kein Zuschlag, dann werden bezahlte Abwesenheiten direkt vergütet.
-- BEIDES zugleich wäre doppelt gezahlt — fn_lohn_berechnen schliesst das aus.
ALTER TABLE person_lohn ADD COLUMN IF NOT EXISTS ferien_prozent
    numeric(5,2) NOT NULL DEFAULT 0 CHECK (ferien_prozent >= 0);

COMMENT ON COLUMN person_lohn.ferien_prozent IS
    'Ferienzuschlag in % auf den Grundlohn (Stundenlohn). >0 schaltet die '
    'direkte Verguetung bezahlter Abwesenheit ab - sonst doppelt bezahlt.';

-- ── 2. Zulagen und feste Abzüge je Person ──────────────────────────────────
-- Alles, was regelmässig dazukommt oder abgeht, ohne Sozialversicherung zu
-- sein: Kinderzulage, Verpflegung, Spesenpauschale, Wohnabzug, Vorschuss.
-- Vorzeichen über `art`, damit eine Tabelle für beides reicht.
CREATE TABLE IF NOT EXISTS lohn_zulage (
    zulage_id       serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    bezeichnung     varchar(100) NOT NULL,
    art             varchar(10) NOT NULL DEFAULT 'zulage'
                      CHECK (art IN ('zulage', 'abzug')),
    betrag          numeric(12,2) NOT NULL CHECK (betrag >= 0),
    bezug           varchar(20) NOT NULL DEFAULT 'monat'
                      CHECK (bezug IN ('monat', 'stunde', 'einmalig')),
    -- Zählt sie zum AHV-pflichtigen Lohn? Spesen tun das NICHT, eine
    -- Kinderzulage auch nicht — eine Leistungsprämie schon. Falsch gesetzt
    -- verrechnet sich jeder Sozialabzug.
    sozialpflichtig boolean NOT NULL DEFAULT true,
    gueltig_ab      date NOT NULL,
    gueltig_bis     date,
    -- Nur für 'einmalig': in welchem Monat
    jahr            smallint,
    monat           smallint CHECK (monat BETWEEN 1 AND 12),
    bemerkung       text,
    CONSTRAINT lohn_zulage_zeitraum_check
        CHECK (gueltig_bis IS NULL OR gueltig_bis >= gueltig_ab),
    CONSTRAINT lohn_zulage_einmalig_check
        CHECK (bezug <> 'einmalig' OR (jahr IS NOT NULL AND monat IS NOT NULL))
);

CREATE INDEX IF NOT EXISTS ix_lohn_zulage_person
    ON lohn_zulage (mandant_id, person_id, gueltig_ab);

-- ── 3. Sozialversicherung: Sätze je Mandant und Zeitraum ───────────────────
-- Beitragssätze und Grenzbeträge ändern sich jährlich. Deshalb zeitraum-
-- bezogen und als DATEN, nicht als Konstanten im Programm — sonst muss zu
-- jedem Jahreswechsel jemand neu übersetzen.
--
-- Alle Grenzbeträge sind MONATSwerte (der Lohnlauf rechnet monatlich).
CREATE TABLE IF NOT EXISTS lohn_abzugsart (
    abzugsart_id    serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    code            varchar(20) NOT NULL,       -- 'AHV', 'ALV', 'BVG', 'NBU'
    bezeichnung     varchar(100) NOT NULL,
    gueltig_ab      date NOT NULL,
    gueltig_bis     date,

    prozent_an      numeric(6,3) NOT NULL DEFAULT 0,   -- Arbeitnehmer
    prozent_ag      numeric(6,3) NOT NULL DEFAULT 0,   -- Arbeitgeber

    -- Freibetrag: dieser Teil des Lohns bleibt beitragsfrei (BVG-Koordinations-
    -- abzug). Höchstbetrag: darüber fallen keine Beiträge an (ALV-Grenze).
    basis_ab        numeric(12,2) NOT NULL DEFAULT 0,
    basis_bis       numeric(12,2),
    -- Unterhalb dieses Monatslohns entsteht gar keine Pflicht (BVG-Eintritt)
    schwelle        numeric(12,2) NOT NULL DEFAULT 0,

    -- Altersstaffel (BVG). NULL = gilt für jedes Alter.
    alter_von       smallint,
    alter_bis       smallint,

    reihenfolge     smallint NOT NULL DEFAULT 0,
    aktiv           boolean NOT NULL DEFAULT true,
    bemerkung       text,
    CONSTRAINT lohn_abzugsart_zeitraum_check
        CHECK (gueltig_bis IS NULL OR gueltig_bis >= gueltig_ab)
);

CREATE INDEX IF NOT EXISTS ix_lohn_abzugsart_mandant
    ON lohn_abzugsart (mandant_id, gueltig_ab);

COMMENT ON TABLE lohn_abzugsart IS
    'Beitragssaetze der Sozialversicherung je Mandant und Zeitraum. '
    'Grenzbetraege sind MONATSwerte. Saetze aendern jaehrlich - pruefen!';

-- ── 4. Belegzeilen ─────────────────────────────────────────────────────────
-- Der Monatsbeleg bekommt seine Einzelposten. Ohne sie ist eine Lohnabrechnung
-- nicht erklärbar: Man sieht nur eine Summe und kann nicht zeigen, woraus sie
-- entstanden ist.
CREATE TABLE IF NOT EXISTS lohn_periode_position (
    position_id     serial PRIMARY KEY,
    periode_id      integer NOT NULL
                      REFERENCES lohn_periode(periode_id) ON DELETE CASCADE,
    reihenfolge     smallint NOT NULL DEFAULT 0,
    art             varchar(20) NOT NULL
                      CHECK (art IN ('grundlohn', 'ueberstunden', 'zulage',
                                     'dreizehnter', 'ferien', 'abzug',
                                     'arbeitgeber')),
    code            varchar(20),
    bezeichnung     varchar(150) NOT NULL,
    menge           numeric(10,2),
    einheit         varchar(20),
    satz            numeric(12,3),
    -- Positiv = erhöht den Bruttolohn, negativ = Abzug. 'arbeitgeber'-Zeilen
    -- fliessen NICHT in den Bruttolohn, sondern nur in die Arbeitgeberkosten.
    betrag          numeric(12,2) NOT NULL
);

CREATE INDEX IF NOT EXISTS ix_lohn_position_periode
    ON lohn_periode_position (periode_id, reihenfolge);

-- ── 5. Beleg um die neuen Summen erweitern ─────────────────────────────────
ALTER TABLE lohn_periode ADD COLUMN IF NOT EXISTS abwesenheit_minuten
    integer NOT NULL DEFAULT 0;
ALTER TABLE lohn_periode ADD COLUMN IF NOT EXISTS zulagen_betrag
    numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE lohn_periode ADD COLUMN IF NOT EXISTS dreizehnter_betrag
    numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE lohn_periode ADD COLUMN IF NOT EXISTS ferien_betrag
    numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE lohn_periode ADD COLUMN IF NOT EXISTS abzuege_an
    numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE lohn_periode ADD COLUMN IF NOT EXISTS abzuege_ag
    numeric(12,2) NOT NULL DEFAULT 0;
ALTER TABLE lohn_periode ADD COLUMN IF NOT EXISTS netto
    numeric(12,2) NOT NULL DEFAULT 0;

-- ── 6. Bezahlte Abwesenheit in Minuten ─────────────────────────────────────
-- Für jeden Tag im Zeitraum, an dem eine Abwesenheit liegt, wird das SOLL
-- dieses Tages herangezogen (fn_soll_minuten kennt Betriebszeit, Pensum und
-- Feiertage). Halbtags zählt hälftig.
--
-- WARUM ueber Tage und nicht ueber die Zeitraumlaenge: Eine Ferienwoche
-- enthaelt Wochenenden und moeglicherweise einen Feiertag. Mit der reinen
-- Anzahl Kalendertage zu rechnen wuerde daraus sieben Arbeitstage machen.
CREATE OR REPLACE FUNCTION fn_abwesenheit_minuten(
    p_mandant_id integer, p_person_id integer,
    p_von date, p_bis date, p_nur_bezahlt boolean DEFAULT true)
RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(
             -- generate_series mit Intervall liefert timestamptz, nicht date
             fn_soll_minuten(p_person_id, d.tag::date)
             * CASE WHEN a.halbtags THEN 0.5 ELSE 1 END
           ), 0)::integer
      FROM abwesenheit a
      JOIN abwesenheitsart aa
        ON aa.mandant_id = a.mandant_id AND aa.art_id = a.art_id
      CROSS JOIN LATERAL generate_series(
             GREATEST(lower(a.zeitraum), p_von),
             LEAST(COALESCE(upper(a.zeitraum) - 1, p_bis), p_bis),
             interval '1 day') AS d(tag)
     WHERE a.mandant_id = p_mandant_id
       AND a.person_id  = p_person_id
       AND a.zeitraum && daterange(p_von, p_bis, '[]')
       AND (NOT p_nur_bezahlt OR aa.bezahlt);
$$;

-- ── 7. Überstunden neu: Abwesenheit zählt mit ──────────────────────────────
-- Ein Ferientag hat ein Soll, aber kein Ist — ohne Ausgleich entstünden
-- Minusstunden für jeden bezogenen Ferientag. Gezählt werden alle Arten mit
-- `zaehlt_als_soll`, nicht nur die bezahlten: unbezahlter Urlaub soll
-- tatsächlich Minus erzeugen, Militärdienst nicht.
--
-- ENTSCHEIDEND — am 01.08.2026 durch einen Test gefunden: Der Ausgleich darf
-- NUR für Tage gelten, an denen auch wirklich ein `anwesenheit_tag` mit Soll
-- gebucht ist. Er hat genau eine Aufgabe: das Minus zu neutralisieren, das
-- der Abwesenheitstag dort erzeugt hat.
--
-- Ohne diese Bedingung produzierte eine Ferienwoche, für die die
-- Zeiterfassung gar keinen Tagsatz geschrieben hatte, +40 Überstunden aus dem
-- Nichts — und damit bei Auszahlung 1734 CHF für Ferien, die bezogen wurden.
-- Kein gebuchtes Soll heisst: die Bilanz des Tages ist bereits neutral, es
-- gibt nichts auszugleichen.
CREATE OR REPLACE FUNCTION fn_ueberstunden_minuten(
    p_mandant_id integer, p_person_id integer,
    p_von date, p_bis date, p_nur_freigegeben boolean DEFAULT true)
RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT (
        COALESCE((SELECT SUM(ist_minuten - soll_minuten)
                    FROM anwesenheit_tag
                   WHERE mandant_id = p_mandant_id AND person_id = p_person_id
                     AND datum BETWEEN p_von AND p_bis
                     AND (NOT p_nur_freigegeben OR status = 'freigegeben')), 0)
      + COALESCE((SELECT SUM(
                    fn_soll_minuten(p_person_id, d.tag::date)
                    * CASE WHEN a.halbtags THEN 0.5 ELSE 1 END)
                   FROM abwesenheit a
                   JOIN abwesenheitsart aa
                     ON aa.mandant_id = a.mandant_id AND aa.art_id = a.art_id
                   CROSS JOIN LATERAL generate_series(
                          GREATEST(lower(a.zeitraum), p_von),
                          LEAST(COALESCE(upper(a.zeitraum) - 1, p_bis), p_bis),
                          interval '1 day') AS d(tag)
                  WHERE a.mandant_id = p_mandant_id
                    AND a.person_id  = p_person_id
                    AND a.zeitraum && daterange(p_von, p_bis, '[]')
                    AND aa.zaehlt_als_soll
                    -- Nur ausgleichen, wo auch ein Soll gebucht wurde
                    AND EXISTS (SELECT 1 FROM anwesenheit_tag at
                                 WHERE at.person_id = p_person_id
                                   AND at.mandant_id = p_mandant_id
                                   AND at.datum = d.tag::date
                                   AND at.soll_minuten > 0
                                   AND (NOT p_nur_freigegeben
                                        OR at.status = 'freigegeben'))), 0)
    )::integer;
$$;

-- ── 8. Der Lohnlauf, vollständig ───────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_lohn_berechnen(
    p_mandant_id integer, p_person_id integer, p_jahr integer, p_monat integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_von date := make_date(p_jahr, p_monat, 1);
    v_bis date := (make_date(p_jahr, p_monat, 1) + interval '1 month - 1 day')::date;
    v_lohn record; v_zul record; v_abz record;
    v_soll integer; v_ist integer; v_ueber integer; v_bezahlt integer;
    v_abw integer;
    v_einheiten numeric; v_stundensatz numeric; v_monatsstunden numeric;
    v_grund numeric; v_ueberbetrag numeric; v_brutto numeric;
    v_zulagen numeric; v_dreizehnter numeric; v_ferien numeric;
    v_sozialbasis numeric; v_abz_an numeric; v_abz_ag numeric;
    v_basis numeric; v_betrag_an numeric; v_betrag_ag numeric;
    v_alter integer; v_periode integer; v_anzahl integer := 0; v_rf smallint;
BEGIN
    SELECT EXTRACT(YEAR FROM age(v_bis, geburtsdatum))::integer INTO v_alter
      FROM person WHERE person_id = p_person_id;

    FOR v_lohn IN
        SELECT * FROM person_lohn
         WHERE mandant_id = p_mandant_id AND person_id = p_person_id
           AND gueltig_ab <= v_bis
           AND (gueltig_bis IS NULL OR gueltig_bis >= v_von)
    LOOP
        IF EXISTS (SELECT 1 FROM lohn_periode
                    WHERE mandant_id = p_mandant_id AND person_id = p_person_id
                      AND jahr = p_jahr AND monat = p_monat
                      AND lohnart = v_lohn.lohnart
                      AND status IN ('freigegeben', 'ausbezahlt')) THEN
            CONTINUE;
        END IF;

        SELECT COALESCE(SUM(soll_minuten), 0), COALESCE(SUM(ist_minuten), 0)
          INTO v_soll, v_ist
          FROM anwesenheit_tag
         WHERE mandant_id = p_mandant_id AND person_id = p_person_id
           AND datum BETWEEN v_von AND v_bis AND status = 'freigegeben';

        v_ueber := fn_ueberstunden_minuten(p_mandant_id, p_person_id, v_von, v_bis);
        v_abw   := fn_abwesenheit_minuten(p_mandant_id, p_person_id, v_von, v_bis);
        v_einheiten := 0; v_bezahlt := 0; v_ueberbetrag := 0;
        v_dreizehnter := 0; v_ferien := 0;

        -- ── Grundbetrag ───────────────────────────────────────────────────
        IF v_lohn.lohnart = 'festgehalt' THEN
            v_grund := v_lohn.betrag;
            v_monatsstunden := v_lohn.monatsstunden;
            IF v_monatsstunden <= 0 THEN
                SELECT 173.0 * COALESCE(MAX(pensum_prozent), 100) / 100.0
                  INTO v_monatsstunden
                  FROM person_arbeitszeit
                 WHERE mandant_id = p_mandant_id AND person_id = p_person_id
                   AND gueltig_ab <= v_bis
                   AND (gueltig_bis IS NULL OR gueltig_bis >= v_von);
            END IF;
            v_stundensatz := CASE WHEN COALESCE(v_monatsstunden, 0) > 0
                                  THEN v_lohn.betrag / v_monatsstunden ELSE 0 END;

        ELSIF v_lohn.lohnart = 'stundenlohn' THEN
            -- Bezahlte Abwesenheit wird wie geleistete Zeit verguetet — es sei
            -- denn, es gibt einen Ferienzuschlag; dann ist sie damit abgegolten.
            v_einheiten := ROUND((v_ist +
                CASE WHEN v_lohn.ferien_prozent > 0 THEN 0 ELSE v_abw END) / 60.0, 2);
            v_grund := ROUND(v_einheiten * v_lohn.betrag, 2);
            v_stundensatz := v_lohn.betrag;
            IF v_lohn.ferien_prozent > 0 THEN
                v_ferien := ROUND(v_grund * v_lohn.ferien_prozent / 100.0, 2);
            END IF;

        ELSE   -- honorar
            IF v_lohn.bezug = 'pauschal' THEN
                v_einheiten := 1; v_grund := v_lohn.betrag;
            ELSE
                v_einheiten := ROUND(fn_honorar_einheiten(p_mandant_id,
                    p_person_id, v_von, v_bis, v_lohn.bezug,
                    v_lohn.lektion_minuten), 2);
                v_grund := ROUND(v_einheiten * v_lohn.betrag, 2);
            END IF;
            v_stundensatz := 0;
        END IF;

        -- ── Überstunden ───────────────────────────────────────────────────
        IF v_lohn.ueberstunden = 'auszahlung' AND v_ueber > v_lohn.ueberstunden_ab_min
           AND v_lohn.lohnart IN ('festgehalt', 'stundenlohn') THEN
            v_bezahlt := v_ueber;
            IF v_lohn.lohnart = 'stundenlohn' THEN
                v_ueberbetrag := ROUND(v_bezahlt / 60.0 * v_stundensatz
                                       * (v_lohn.ueberstunden_faktor - 1), 2);
            ELSE
                v_ueberbetrag := ROUND(v_bezahlt / 60.0 * v_stundensatz
                                       * v_lohn.ueberstunden_faktor, 2);
            END IF;
        END IF;

        -- ── 13. Monatslohn ────────────────────────────────────────────────
        -- Nur im festgelegten Auszahlungsmonat. Zwei Monate = je die Hälfte.
        IF v_lohn.dreizehnter_prozent > 0 THEN
            IF v_lohn.dreizehnter_monat2 IS NOT NULL
               AND p_monat IN (v_lohn.dreizehnter_monat, v_lohn.dreizehnter_monat2) THEN
                v_dreizehnter := ROUND(v_grund * v_lohn.dreizehnter_prozent
                                       / 100.0 / 2, 2);
            ELSIF p_monat = v_lohn.dreizehnter_monat THEN
                v_dreizehnter := ROUND(v_grund * v_lohn.dreizehnter_prozent
                                       / 100.0, 2);
            END IF;
        END IF;

        -- ── Zulagen und feste Abzüge ──────────────────────────────────────
        v_zulagen := 0;
        v_sozialbasis := v_grund + v_ueberbetrag + v_dreizehnter + v_ferien;

        FOR v_zul IN
            SELECT * FROM lohn_zulage
             WHERE mandant_id = p_mandant_id AND person_id = p_person_id
               AND gueltig_ab <= v_bis
               AND (gueltig_bis IS NULL OR gueltig_bis >= v_von)
               AND (bezug <> 'einmalig'
                    OR (jahr = p_jahr AND monat = p_monat))
        LOOP
            DECLARE v_z numeric;
            BEGIN
                IF v_zul.bezug = 'stunde' THEN
                    v_z := ROUND(v_zul.betrag * (v_ist + v_abw) / 60.0, 2);
                ELSE
                    v_z := v_zul.betrag;
                END IF;
                IF v_zul.art = 'abzug' THEN
                    v_z := -v_z;
                END IF;
                v_zulagen := v_zulagen + v_z;
                IF v_zul.sozialpflichtig THEN
                    v_sozialbasis := v_sozialbasis + v_z;
                END IF;
            END;
        END LOOP;

        v_brutto := v_grund + v_ueberbetrag + v_dreizehnter + v_ferien + v_zulagen;

        -- ── Beleg schreiben ───────────────────────────────────────────────
        INSERT INTO lohn_periode (mandant_id, person_id, jahr, monat, lohn_id,
            lohnart, bezug, satz, waehrung, soll_minuten, ist_minuten,
            ueber_minuten, ueber_minuten_bezahlt, abwesenheit_minuten,
            einheiten, einheit_text, grundbetrag, ueber_betrag,
            zulagen_betrag, dreizehnter_betrag, ferien_betrag,
            brutto, nebenkosten, kosten_gesamt, status, berechnet_am)
        VALUES (p_mandant_id, p_person_id, p_jahr, p_monat, v_lohn.lohn_id,
            v_lohn.lohnart, v_lohn.bezug, v_lohn.betrag, v_lohn.waehrung,
            v_soll, v_ist, v_ueber, v_bezahlt, v_abw,
            v_einheiten, v_lohn.bezug, v_grund, v_ueberbetrag,
            v_zulagen, v_dreizehnter, v_ferien,
            v_brutto, 0, v_brutto, 'berechnet', now())
        ON CONFLICT (mandant_id, person_id, jahr, monat, lohnart)
        DO UPDATE SET
            lohn_id = EXCLUDED.lohn_id, bezug = EXCLUDED.bezug,
            satz = EXCLUDED.satz, waehrung = EXCLUDED.waehrung,
            soll_minuten = EXCLUDED.soll_minuten,
            ist_minuten = EXCLUDED.ist_minuten,
            ueber_minuten = EXCLUDED.ueber_minuten,
            ueber_minuten_bezahlt = EXCLUDED.ueber_minuten_bezahlt,
            abwesenheit_minuten = EXCLUDED.abwesenheit_minuten,
            einheiten = EXCLUDED.einheiten, einheit_text = EXCLUDED.einheit_text,
            grundbetrag = EXCLUDED.grundbetrag,
            ueber_betrag = EXCLUDED.ueber_betrag,
            zulagen_betrag = EXCLUDED.zulagen_betrag,
            dreizehnter_betrag = EXCLUDED.dreizehnter_betrag,
            ferien_betrag = EXCLUDED.ferien_betrag,
            brutto = EXCLUDED.brutto, berechnet_am = now()
        RETURNING periode_id INTO v_periode;

        DELETE FROM lohn_periode_position WHERE periode_id = v_periode;

        v_rf := 0;
        INSERT INTO lohn_periode_position (periode_id, reihenfolge, art,
            bezeichnung, menge, einheit, satz, betrag)
        VALUES (v_periode, v_rf, 'grundlohn',
            CASE v_lohn.lohnart WHEN 'festgehalt' THEN 'Monatslohn'
                                WHEN 'stundenlohn' THEN 'Stundenlohn'
                                ELSE 'Honorar' END,
            NULLIF(v_einheiten, 0), v_lohn.bezug, v_lohn.betrag, v_grund);

        IF v_ueberbetrag <> 0 THEN
            v_rf := v_rf + 1;
            INSERT INTO lohn_periode_position (periode_id, reihenfolge, art,
                bezeichnung, menge, einheit, satz, betrag)
            VALUES (v_periode, v_rf, 'ueberstunden',
                'Ueberstunden (Faktor ' || v_lohn.ueberstunden_faktor || ')',
                ROUND(v_bezahlt / 60.0, 2), 'stunde', v_stundensatz, v_ueberbetrag);
        END IF;

        IF v_dreizehnter <> 0 THEN
            v_rf := v_rf + 1;
            INSERT INTO lohn_periode_position (periode_id, reihenfolge, art,
                bezeichnung, betrag)
            VALUES (v_periode, v_rf, 'dreizehnter', '13. Monatslohn', v_dreizehnter);
        END IF;

        IF v_ferien <> 0 THEN
            v_rf := v_rf + 1;
            INSERT INTO lohn_periode_position (periode_id, reihenfolge, art,
                bezeichnung, satz, betrag)
            VALUES (v_periode, v_rf, 'ferien',
                'Ferienentschaedigung', v_lohn.ferien_prozent, v_ferien);
        END IF;

        FOR v_zul IN
            SELECT * FROM lohn_zulage
             WHERE mandant_id = p_mandant_id AND person_id = p_person_id
               AND gueltig_ab <= v_bis
               AND (gueltig_bis IS NULL OR gueltig_bis >= v_von)
               AND (bezug <> 'einmalig' OR (jahr = p_jahr AND monat = p_monat))
        LOOP
            v_rf := v_rf + 1;
            INSERT INTO lohn_periode_position (periode_id, reihenfolge, art,
                bezeichnung, satz, einheit, betrag)
            VALUES (v_periode, v_rf, 'zulage', v_zul.bezeichnung,
                v_zul.betrag, v_zul.bezug,
                CASE WHEN v_zul.art = 'abzug' THEN -1 ELSE 1 END *
                CASE WHEN v_zul.bezug = 'stunde'
                     THEN ROUND(v_zul.betrag * (v_ist + v_abw) / 60.0, 2)
                     ELSE v_zul.betrag END);
        END LOOP;

        -- ── Sozialabzüge ──────────────────────────────────────────────────
        -- Honorarkräfte sind selbständig und rechnen selbst ab — für sie
        -- werden keine Beiträge einbehalten.
        v_abz_an := 0; v_abz_ag := 0;
        IF v_lohn.lohnart <> 'honorar' THEN
            FOR v_abz IN
                SELECT * FROM lohn_abzugsart
                 WHERE mandant_id = p_mandant_id AND aktiv
                   AND gueltig_ab <= v_bis
                   AND (gueltig_bis IS NULL OR gueltig_bis >= v_von)
                   AND (alter_von IS NULL OR v_alter IS NULL OR v_alter >= alter_von)
                   AND (alter_bis IS NULL OR v_alter IS NULL OR v_alter <= alter_bis)
                 ORDER BY reihenfolge, code
            LOOP
                CONTINUE WHEN v_sozialbasis < v_abz.schwelle;

                -- Freibetrag abziehen, Höchstbetrag deckeln
                v_basis := GREATEST(v_sozialbasis - v_abz.basis_ab, 0);
                IF v_abz.basis_bis IS NOT NULL THEN
                    v_basis := LEAST(v_basis,
                        GREATEST(v_abz.basis_bis - v_abz.basis_ab, 0));
                END IF;
                CONTINUE WHEN v_basis <= 0;

                v_betrag_an := ROUND(v_basis * v_abz.prozent_an / 100.0, 2);
                v_betrag_ag := ROUND(v_basis * v_abz.prozent_ag / 100.0, 2);
                v_abz_an := v_abz_an + v_betrag_an;
                v_abz_ag := v_abz_ag + v_betrag_ag;

                IF v_betrag_an <> 0 THEN
                    v_rf := v_rf + 1;
                    INSERT INTO lohn_periode_position (periode_id, reihenfolge,
                        art, code, bezeichnung, menge, satz, betrag)
                    VALUES (v_periode, v_rf, 'abzug', v_abz.code,
                        v_abz.bezeichnung, v_basis, v_abz.prozent_an, -v_betrag_an);
                END IF;
                IF v_betrag_ag <> 0 THEN
                    v_rf := v_rf + 1;
                    INSERT INTO lohn_periode_position (periode_id, reihenfolge,
                        art, code, bezeichnung, menge, satz, betrag)
                    VALUES (v_periode, v_rf, 'arbeitgeber', v_abz.code,
                        v_abz.bezeichnung || ' (Arbeitgeber)', v_basis,
                        v_abz.prozent_ag, v_betrag_ag);
                END IF;
            END LOOP;
        END IF;

        -- Sind für den Mandanten gar keine Sätze hinterlegt, gilt weiterhin
        -- die Pauschale aus der Lohnvereinbarung. So rechnet das Modell auch
        -- dann etwas Brauchbares, wenn die Sozialversicherung noch nicht
        -- erfasst ist — aber nie beides zugleich.
        IF v_abz_ag = 0 AND v_lohn.nebenkosten_prozent > 0 THEN
            v_abz_ag := ROUND(v_brutto * v_lohn.nebenkosten_prozent / 100.0, 2);
        END IF;

        UPDATE lohn_periode
           SET abzuege_an = v_abz_an,
               abzuege_ag = v_abz_ag,
               nebenkosten = v_abz_ag,
               netto = v_brutto - v_abz_an,
               kosten_gesamt = v_brutto + v_abz_ag
         WHERE periode_id = v_periode;

        v_anzahl := v_anzahl + 1;
    END LOOP;

    RETURN v_anzahl;
END;
$$;

-- ── 9. Übersicht erweitern ─────────────────────────────────────────────────
-- DROP statt CREATE OR REPLACE: Letzteres kann nur Spalten ANHAENGEN, nicht
-- welche dazwischenschieben ("kann Namen der Sichtspalte nicht aendern").
-- Bewusst OHNE CASCADE — haengt etwas an der Sicht, soll es auffallen.
DROP VIEW IF EXISTS v_lohn_uebersicht;
CREATE VIEW v_lohn_uebersicht AS
SELECT lp.periode_id, lp.mandant_id, lp.person_id,
       p.vorname, p.nachname_firmenname,
       CASE
         WHEN bool_or(pb.ist_lehrer) AND bool_or(pb.ist_mitarbeiter)
              THEN 'Lohnmitarbeiter'
         WHEN bool_or(pb.ist_lehrer) THEN 'Honorarlehrer'
         WHEN bool_or(pb.ist_mitarbeiter) THEN 'Mitarbeiter'
         ELSE 'ohne Rolle'
       END AS anstellungsart,
       lp.jahr, lp.monat, lp.lohnart, lp.bezug, lp.satz, lp.waehrung,
       lp.soll_minuten, lp.ist_minuten, lp.abwesenheit_minuten,
       lp.ueber_minuten, lp.ueber_minuten_bezahlt,
       ROUND(lp.ueber_minuten / 60.0, 2) AS ueber_stunden,
       lp.einheiten, lp.grundbetrag, lp.ueber_betrag, lp.dreizehnter_betrag,
       lp.ferien_betrag, lp.zulagen_betrag, lp.brutto,
       lp.abzuege_an, lp.netto, lp.abzuege_ag, lp.kosten_gesamt, lp.status
  FROM lohn_periode lp
  JOIN person p ON p.person_id = lp.person_id
  LEFT JOIN person_beziehung pb
         ON pb.quell_person_id = lp.person_id
        AND pb.mandant_id = lp.mandant_id
 GROUP BY lp.periode_id, p.vorname, p.nachname_firmenname;

-- ── 10. Vorschlagswerte für die Schweiz ────────────────────────────────────
-- ACHTUNG: Beitragssätze und Grenzbeträge ändern sich JÄHRLICH. Die Werte
-- hier sind ein Startpunkt, damit das Modul nicht leer dasteht — sie sind
-- vor dem ersten echten Lohnlauf gegen die aktuelle AHV-/BVG-Mitteilung zu
-- prüfen. Deshalb steht der Prüfhinweis auch in der Bemerkung jeder Zeile,
-- wo ihn niemand übersehen kann.
--
-- Nur für Mandanten, die noch keine Sätze haben — bestehende bleiben.
INSERT INTO lohn_abzugsart (mandant_id, code, bezeichnung, gueltig_ab,
    prozent_an, prozent_ag, basis_ab, basis_bis, schwelle,
    alter_von, alter_bis, reihenfolge, bemerkung)
SELECT m.mandant_id, v.code, v.bez, DATE '2026-01-01',
       v.an, v.ag, v.ab, v.bis, v.schwelle, v.a_von, v.a_bis, v.rf,
       'VORSCHLAGSWERT - vor dem ersten Lohnlauf gegen die aktuelle '
       'AHV-/BVG-Mitteilung pruefen (Saetze aendern jaehrlich).'
  FROM mandant m
  CROSS JOIN (VALUES
    ('AHV', 'AHV / IV / EO',            5.300, 5.300,    0.00, NULL,        0.00, NULL, NULL, 1),
    -- ALV-Grenze: Monatswert des versicherten Jahreshoechstlohns
    ('ALV', 'Arbeitslosenversicherung', 1.100, 1.100,    0.00, 12350.00,    0.00, NULL, NULL, 2),
    ('NBU', 'Nichtberufsunfall',        1.000, 0.000,    0.00, 12350.00,    0.00, NULL, NULL, 3),
    ('BUV', 'Berufsunfall',             0.000, 0.500,    0.00, 12350.00,    0.00, NULL, NULL, 4),
    -- BVG: Koordinationsabzug als Freibetrag, Eintrittsschwelle, Altersstaffel
    ('BVG', 'BVG 25-34 Jahre',          3.500, 3.500, 2205.00,  8820.00, 1890.00,   25,   34, 5),
    ('BVG', 'BVG 35-44 Jahre',          5.000, 5.000, 2205.00,  8820.00, 1890.00,   35,   44, 6),
    ('BVG', 'BVG 45-54 Jahre',          7.500, 7.500, 2205.00,  8820.00, 1890.00,   45,   54, 7),
    ('BVG', 'BVG 55-65 Jahre',          9.000, 9.000, 2205.00,  8820.00, 1890.00,   55,   65, 8)
  ) AS v(code, bez, an, ag, ab, bis, schwelle, a_von, a_bis, rf)
 WHERE NOT EXISTS (SELECT 1 FROM lohn_abzugsart la
                    WHERE la.mandant_id = m.mandant_id);
