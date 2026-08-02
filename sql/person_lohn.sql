-- ============================================================================
-- Löhne für Mitarbeiter und Lehrer — Stand 01.08.2026
--
-- AUFSETZPUNKT: Es wird NICHTS neu erfunden, was schon da ist.
--   person_arbeitszeit  liefert Pensum und Erfassungsart (und ist das Vorbild
--                       für den Zeitraumschnitt hier: gueltig_ab/bis + EXCLUDE)
--   anwesenheit_tag     liefert soll_minuten/ist_minuten je Tag → daraus
--                       ergeben sich Überstunden, ohne sie neu zu rechnen
--   kurs_termin         liefert die geleiteten Termine (leiter_person_id,
--                       zeitraum, status) → daraus ergibt sich das Honorar
--   person_beziehung    liefert ist_mitarbeiter/ist_lehrer
--
-- DIE ROLLENREGEL BLEIBT ABGELEITET (siehe project_heisenberg_lehrer_rollen):
--   ist_lehrer + ist_mitarbeiter = Lohnmitarbeiter
--   ist_lehrer ohne ist_mitarbeiter = Honorarlehrer
-- Es gibt hier deshalb KEINE Spalte "ist_honorarkraft" — die Lohnart sagt,
-- wie bezahlt wird, die Flags sagen, was die Person ist. Zwei Fragen, zwei
-- Orte, keine dritte Wahrheit.
-- ============================================================================

-- ── 1. Die Lohnvereinbarung ────────────────────────────────────────────────
-- Zeitraumbezogen, weil Löhne sich ändern. Eine Lohnerhöhung ist ein NEUER
-- Satz ab dem Stichtag, kein Überschreiben — sonst rechnet man rückwirkend
-- alte Monate mit dem neuen Satz.
CREATE TABLE IF NOT EXISTS person_lohn (
    lohn_id         serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),

    gueltig_ab      date NOT NULL,
    gueltig_bis     date,                      -- NULL = laufend

    -- WIE bezahlt wird
    lohnart         varchar(20) NOT NULL
                      CHECK (lohnart IN ('festgehalt', 'stundenlohn', 'honorar')),
    -- WORAUF sich der Betrag bezieht. Getrennt von der Lohnart, weil Honorar
    -- je nach Vereinbarung pro Stunde, pro Lektion, pro Termin oder pauschal
    -- gezahlt wird — das ist genau die Stelle, an der eine feste Annahme im
    -- Code danebenläge.
    bezug           varchar(20) NOT NULL
                      CHECK (bezug IN ('monat', 'stunde', 'lektion', 'termin',
                                       'pauschal')),
    betrag          numeric(12,2) NOT NULL CHECK (betrag >= 0),
    waehrung        char(3) NOT NULL DEFAULT 'CHF',

    -- Nur sinnvolle Kombinationen zulassen: ein Festgehalt pro Lektion wäre
    -- ein Erfassungsfehler, kein Geschäftsmodell.
    CONSTRAINT person_lohn_art_bezug_check CHECK (
        (lohnart = 'festgehalt'  AND bezug IN ('monat', 'pauschal')) OR
        (lohnart = 'stundenlohn' AND bezug = 'stunde') OR
        (lohnart = 'honorar'     AND bezug IN ('stunde', 'lektion', 'termin',
                                               'pauschal'))
    ),

    -- ── Überstunden ────────────────────────────────────────────────────────
    -- 'nicht'        = mit dem Gehalt abgegolten (bei Kadern üblich)
    -- 'auszahlung'   = werden ausbezahlt, mit Faktor
    -- 'kompensation' = werden in Freizeit ausgeglichen (kein Geldfluss)
    ueberstunden        varchar(20) NOT NULL DEFAULT 'kompensation'
                          CHECK (ueberstunden IN ('nicht', 'auszahlung',
                                                  'kompensation')),
    -- 1.25 = 25 % Zuschlag. Wirkt nur bei 'auszahlung'.
    ueberstunden_faktor numeric(4,2) NOT NULL DEFAULT 1.00
                          CHECK (ueberstunden_faktor >= 0),
    -- Bagatellgrenze je Abrechnungsmonat: erst darüber wird ausbezahlt.
    -- Verhindert, dass drei Minuten Mehrarbeit eine Lohnzeile erzeugen.
    ueberstunden_ab_min integer NOT NULL DEFAULT 0
                          CHECK (ueberstunden_ab_min >= 0),
    -- Grundlage für den Stundensatz bei Festgehalt (sonst ist nicht bestimmbar,
    -- was eine Überstunde wert ist). 0 = aus person_arbeitszeit ableiten.
    monatsstunden       numeric(6,2) NOT NULL DEFAULT 0
                          CHECK (monatsstunden >= 0),

    -- Wie lang eine Lektion zählt. 45 Minuten ist der Regelfall im Unterricht,
    -- aber eben nicht überall — deshalb eine Spalte und keine Konstante.
    lektion_minuten     integer NOT NULL DEFAULT 45
                          CHECK (lektion_minuten > 0),

    -- ── Für die Kostenkalkulation ─────────────────────────────────────────
    -- Das Kalkulationskonzept verlangt Personalkosten "einschliesslich
    -- Sozialleistungen" (Prio 1). Der Arbeitgeberanteil ist ein Aufschlag auf
    -- den Bruttolohn und gehört deshalb an den Lohnsatz, nicht in die
    -- Kalkulation — sonst pflegt man ihn an zwei Stellen.
    nebenkosten_prozent numeric(5,2) NOT NULL DEFAULT 0
                          CHECK (nebenkosten_prozent >= 0),

    bemerkung       text,
    created_at      timestamp NOT NULL DEFAULT now(),

    CONSTRAINT person_lohn_zeitraum_check
        CHECK (gueltig_bis IS NULL OR gueltig_bis >= gueltig_ab)
);

-- Kein zweiter Satz DERSELBEN Lohnart im selben Zeitraum — genau das Muster
-- von person_arbeitszeit.
--
-- BEWUSST NICHT verboten: verschiedene Lohnarten gleichzeitig. Das ist ein
-- echter Fall — eine Teilzeitkraft mit Fixum, die zusätzlich Kurse auf
-- Honorarbasis gibt, hat beides nebeneinander.
CREATE EXTENSION IF NOT EXISTS btree_gist;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conname = 'person_lohn_kein_ueberlapp') THEN
        ALTER TABLE person_lohn ADD CONSTRAINT person_lohn_kein_ueberlapp
            EXCLUDE USING gist (
                person_id WITH =, mandant_id WITH =, lohnart WITH =,
                daterange(gueltig_ab, gueltig_bis, '[]') WITH &&);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS ix_person_lohn_person
    ON person_lohn (mandant_id, person_id, gueltig_ab DESC);

COMMENT ON TABLE person_lohn IS
    'Lohnvereinbarung je Person, Mandant und Zeitraum. Lohnerhoehung = neuer '
    'Satz ab Stichtag, kein Ueberschreiben.';

-- ── 2. Der Abrechnungsbeleg je Monat ───────────────────────────────────────
-- WARUM eine eigene Tabelle und nicht "bei Bedarf ausrechnen": Was einmal
-- ausbezahlt wurde, muss nachvollziehbar bleiben, auch wenn der Lohnsatz
-- später steigt oder ein Anwesenheitstag nachträglich korrigiert wird. Der
-- Beleg friert die verwendeten Werte ein.
CREATE TABLE IF NOT EXISTS lohn_periode (
    periode_id      serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    person_id       integer NOT NULL REFERENCES person(person_id),
    jahr            smallint NOT NULL CHECK (jahr BETWEEN 2000 AND 2100),
    monat           smallint NOT NULL CHECK (monat BETWEEN 1 AND 12),

    -- Kopie der Vereinbarung zum Abrechnungszeitpunkt (eingefroren)
    lohn_id         integer REFERENCES person_lohn(lohn_id),
    lohnart         varchar(20),
    bezug           varchar(20),
    satz            numeric(12,2),             -- verwendeter Betrag je Bezug
    waehrung        char(3) NOT NULL DEFAULT 'CHF',

    -- Zeitwirtschaft (aus anwesenheit_tag)
    soll_minuten    integer NOT NULL DEFAULT 0,
    ist_minuten     integer NOT NULL DEFAULT 0,
    ueber_minuten   integer NOT NULL DEFAULT 0,   -- ist - soll, kann negativ sein
    ueber_minuten_bezahlt integer NOT NULL DEFAULT 0,

    -- Honorar (aus kurs_termin)
    einheiten       numeric(10,2) NOT NULL DEFAULT 0,  -- Stunden/Lektionen/Termine
    einheit_text    varchar(20),

    -- Ergebnis
    grundbetrag     numeric(12,2) NOT NULL DEFAULT 0,
    ueber_betrag    numeric(12,2) NOT NULL DEFAULT 0,
    brutto          numeric(12,2) NOT NULL DEFAULT 0,
    nebenkosten     numeric(12,2) NOT NULL DEFAULT 0,  -- Arbeitgeberanteil
    -- Was die Stelle den Betrieb WIRKLICH kostet — der Wert, den die
    -- Kalkulation braucht.
    kosten_gesamt   numeric(12,2) NOT NULL DEFAULT 0,

    status          varchar(20) NOT NULL DEFAULT 'berechnet'
                      CHECK (status IN ('berechnet', 'freigegeben', 'ausbezahlt')),
    berechnet_am    timestamp NOT NULL DEFAULT now(),
    freigegeben_von integer REFERENCES person(person_id),
    freigegeben_am  timestamp,
    bemerkung       text,

    UNIQUE (mandant_id, person_id, jahr, monat, lohnart)
);

CREATE INDEX IF NOT EXISTS ix_lohn_periode_zeit
    ON lohn_periode (mandant_id, jahr, monat);

COMMENT ON TABLE lohn_periode IS
    'Eingefrorener Abrechnungsbeleg je Person und Monat. Aendert sich der '
    'Lohnsatz spaeter, bleibt der Beleg wie er war.';

-- ── 3. Überstunden aus der bestehenden Zeitwirtschaft ──────────────────────
-- Rechnet NICHT neu, sondern summiert, was anwesenheit_tag ohnehin führt.
--
-- p_nur_freigegeben: Vorgabe true. Mit unfreigegebenen Tagen zu rechnen
-- hiesse, auf einem Stand abzurechnen, den noch niemand geprüft hat.
CREATE OR REPLACE FUNCTION fn_ueberstunden_minuten(
    p_mandant_id integer, p_person_id integer,
    p_von date, p_bis date, p_nur_freigegeben boolean DEFAULT true)
RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(ist_minuten - soll_minuten), 0)::integer
      FROM anwesenheit_tag
     WHERE mandant_id = p_mandant_id
       AND person_id  = p_person_id
       AND datum BETWEEN p_von AND p_bis
       AND (NOT p_nur_freigegeben OR status = 'freigegeben');
$$;

-- ── 4. Honorareinheiten aus den geleiteten Kursterminen ────────────────────
-- Gezählt wird nur, was STATTGEFUNDEN hat. Ein geplanter oder ausgefallener
-- Termin wird nicht bezahlt — sonst rechnet man Absagen ab.
CREATE OR REPLACE FUNCTION fn_honorar_einheiten(
    p_mandant_id integer, p_person_id integer,
    p_von date, p_bis date, p_bezug varchar, p_lektion_minuten integer DEFAULT 45)
RETURNS numeric
LANGUAGE sql STABLE AS $$
    SELECT CASE p_bezug
             WHEN 'termin' THEN COUNT(*)::numeric
             WHEN 'stunde' THEN COALESCE(SUM(
                 EXTRACT(EPOCH FROM (upper(zeitraum) - lower(zeitraum))) / 3600.0), 0)
             WHEN 'lektion' THEN COALESCE(SUM(
                 EXTRACT(EPOCH FROM (upper(zeitraum) - lower(zeitraum))) / 60.0
                 / GREATEST(p_lektion_minuten, 1)), 0)
             ELSE 0
           END
      FROM kurs_termin
     WHERE mandant_id = p_mandant_id
       AND leiter_person_id = p_person_id
       AND status = 'stattgefunden'
       AND lower(zeitraum)::date BETWEEN p_von AND p_bis;
$$;

-- ── 5. Der Lohnlauf ────────────────────────────────────────────────────────
-- Berechnet EINE Person für EINEN Monat und schreibt den Beleg. Idempotent:
-- ein erneuter Lauf überschreibt einen noch nicht freigegebenen Beleg und
-- lässt freigegebene/ausbezahlte unangetastet.
--
-- Läuft über ALLE Lohnarten, die im Monat gültig sind — die Teilzeitkraft mit
-- Fixum und zusätzlichem Honorar bekommt zwei Belege.
CREATE OR REPLACE FUNCTION fn_lohn_berechnen(
    p_mandant_id integer, p_person_id integer, p_jahr integer, p_monat integer)
RETURNS integer                       -- Anzahl geschriebener/aktualisierter Belege
LANGUAGE plpgsql AS $$
DECLARE
    v_von date := make_date(p_jahr, p_monat, 1);
    v_bis date := (make_date(p_jahr, p_monat, 1) + interval '1 month - 1 day')::date;
    v_lohn record;
    v_soll integer; v_ist integer; v_ueber integer; v_bezahlt integer;
    v_einheiten numeric; v_stundensatz numeric;
    v_grund numeric; v_ueberbetrag numeric; v_brutto numeric; v_neben numeric;
    v_anzahl integer := 0;
    v_monatsstunden numeric;
BEGIN
    FOR v_lohn IN
        SELECT * FROM person_lohn
         WHERE mandant_id = p_mandant_id AND person_id = p_person_id
           -- im Monat überhaupt gültig
           AND gueltig_ab <= v_bis
           AND (gueltig_bis IS NULL OR gueltig_bis >= v_von)
    LOOP
        -- Bereits freigegebene Belege sind tabu
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
        v_einheiten := 0;
        v_bezahlt := 0;
        v_ueberbetrag := 0;

        -- ── Grundbetrag je Lohnart ────────────────────────────────────────
        IF v_lohn.lohnart = 'festgehalt' THEN
            v_grund := v_lohn.betrag;
            -- Stundensatz für Überstunden: aus den vereinbarten Monatsstunden.
            -- Steht dort nichts, wird das Pensum aus person_arbeitszeit
            -- herangezogen (100 % = 173 Stunden, der übliche Monatsdurchschnitt
            -- bei 40 Stunden pro Woche).
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
            -- Beim Stundenlohn wird die geleistete Zeit bezahlt, nicht das Soll
            v_einheiten := ROUND(v_ist / 60.0, 2);
            v_grund := ROUND(v_einheiten * v_lohn.betrag, 2);
            v_stundensatz := v_lohn.betrag;

        ELSE   -- honorar
            IF v_lohn.bezug = 'pauschal' THEN
                v_einheiten := 1;
                v_grund := v_lohn.betrag;
            ELSE
                v_einheiten := ROUND(fn_honorar_einheiten(p_mandant_id,
                    p_person_id, v_von, v_bis, v_lohn.bezug,
                    v_lohn.lektion_minuten), 2);
                v_grund := ROUND(v_einheiten * v_lohn.betrag, 2);
            END IF;
            v_stundensatz := 0;   -- Honorarkräfte haben keine Überstunden
        END IF;

        -- ── Überstunden ───────────────────────────────────────────────────
        -- Nur bei 'auszahlung', nur über der Bagatellgrenze, und nur bei
        -- Anstellung. Beim Stundenlohn steckt die Mehrarbeit bereits im
        -- Grundbetrag — sie ein zweites Mal zu vergüten wäre doppelt gezahlt;
        -- der Zuschlag wird deshalb nur auf den Faktor-Anteil gerechnet.
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

        v_brutto := v_grund + v_ueberbetrag;
        v_neben  := ROUND(v_brutto * v_lohn.nebenkosten_prozent / 100.0, 2);

        INSERT INTO lohn_periode (mandant_id, person_id, jahr, monat, lohn_id,
            lohnart, bezug, satz, waehrung, soll_minuten, ist_minuten,
            ueber_minuten, ueber_minuten_bezahlt, einheiten, einheit_text,
            grundbetrag, ueber_betrag, brutto, nebenkosten, kosten_gesamt,
            status, berechnet_am)
        VALUES (p_mandant_id, p_person_id, p_jahr, p_monat, v_lohn.lohn_id,
            v_lohn.lohnart, v_lohn.bezug, v_lohn.betrag, v_lohn.waehrung,
            v_soll, v_ist, v_ueber, v_bezahlt, v_einheiten, v_lohn.bezug,
            v_grund, v_ueberbetrag, v_brutto, v_neben, v_brutto + v_neben,
            'berechnet', now())
        ON CONFLICT (mandant_id, person_id, jahr, monat, lohnart)
        DO UPDATE SET
            lohn_id = EXCLUDED.lohn_id, bezug = EXCLUDED.bezug,
            satz = EXCLUDED.satz, waehrung = EXCLUDED.waehrung,
            soll_minuten = EXCLUDED.soll_minuten,
            ist_minuten = EXCLUDED.ist_minuten,
            ueber_minuten = EXCLUDED.ueber_minuten,
            ueber_minuten_bezahlt = EXCLUDED.ueber_minuten_bezahlt,
            einheiten = EXCLUDED.einheiten, einheit_text = EXCLUDED.einheit_text,
            grundbetrag = EXCLUDED.grundbetrag,
            ueber_betrag = EXCLUDED.ueber_betrag, brutto = EXCLUDED.brutto,
            nebenkosten = EXCLUDED.nebenkosten,
            kosten_gesamt = EXCLUDED.kosten_gesamt,
            berechnet_am = now();

        v_anzahl := v_anzahl + 1;
    END LOOP;

    RETURN v_anzahl;
END;
$$;

-- Alle Personen eines Mandanten auf einmal
CREATE OR REPLACE FUNCTION fn_lohnlauf(
    p_mandant_id integer, p_jahr integer, p_monat integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_person integer; v_summe integer := 0;
BEGIN
    FOR v_person IN
        SELECT DISTINCT person_id FROM person_lohn
         WHERE mandant_id = p_mandant_id
           AND gueltig_ab <= (make_date(p_jahr, p_monat, 1)
                              + interval '1 month - 1 day')::date
           AND (gueltig_bis IS NULL
                OR gueltig_bis >= make_date(p_jahr, p_monat, 1))
    LOOP
        v_summe := v_summe + fn_lohn_berechnen(p_mandant_id, v_person,
                                               p_jahr, p_monat);
    END LOOP;
    RETURN v_summe;
END;
$$;

-- ── 6. Anzeigesicht ────────────────────────────────────────────────────────
-- Zeigt Namen und die abgeleitete Anstellungsart mit — die Rollenregel wird
-- hier ausgerechnet, nicht gespeichert.
--
-- ACHTUNG BEI DER VERKNUEPFUNG: Die Flags haengen an der QUELLPERSON. Die
-- Zielperson ist die Hauptperson des Mandanten ("X ist Mitarbeiter VON
-- Huber"). Ueber ziel_person_id zu verknuepfen — mein erster Entwurf — liefert
-- deshalb fuer jeden ausser der Hauptperson "ohne Rolle". Am 01.08.2026 an
-- den echten Saetzen von Mandant 3 geprueft.
CREATE OR REPLACE VIEW v_lohn_uebersicht AS
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
       lp.soll_minuten, lp.ist_minuten, lp.ueber_minuten,
       lp.ueber_minuten_bezahlt,
       ROUND(lp.ueber_minuten / 60.0, 2) AS ueber_stunden,
       lp.einheiten, lp.grundbetrag, lp.ueber_betrag, lp.brutto,
       lp.nebenkosten, lp.kosten_gesamt, lp.status
  FROM lohn_periode lp
  JOIN person p ON p.person_id = lp.person_id
  LEFT JOIN person_beziehung pb
         ON pb.quell_person_id = lp.person_id
        AND pb.mandant_id = lp.mandant_id
 GROUP BY lp.periode_id, p.vorname, p.nachname_firmenname;
