-- ============================================================================
-- Anwesenheit erfassen — der Weg des Coaches — Stand 02.08.2026
--
-- ANLASS: Der erste Mensch ausserhalb dieses Rechners, der Heisenberg
-- benutzt, ist ein Coach vom Werks Bahnhof. Er meldet sich an und hakt
-- Teilnehmer als anwesend ab. Mehr nicht — aber das muss ueber eine
-- Internetleitung sitzen.
--
-- WARUM ALS FUNKTION: Ueber WAN kostet jede Rundfahrt Zeit. Eine ganze
-- Klasse einzeln zu speichern waere ein Gang pro Teilnehmer. `fn_kurs_
-- anwesenheit_liste` nimmt den ganzen Termin auf einmal entgegen — eine
-- Fahrt statt zwanzig — und ist dabei atomar: entweder steht die ganze
-- Liste, oder keine Zeile davon.
--
-- Ausserdem wird hier geprueft, was die Oberflaeche nicht zuverlaessig
-- pruefen kann: Gehoert die Person ueberhaupt zu dieser Kursdurchfuehrung?
-- Passt der Termin zum Mandanten? Ohne das haengt die Richtigkeit daran,
-- dass die GUI immer korrekt vorbelegt.
-- ============================================================================

-- ── Einzelne Person ────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_kurs_anwesenheit_setzen(
    p_termin_id     integer,
    p_person_id     integer,
    p_anwesend      boolean,
    p_entschuldigt  boolean DEFAULT false,
    p_fehlminuten   integer DEFAULT NULL,
    p_bemerkung     text    DEFAULT NULL,
    p_erfasst_von   integer DEFAULT NULL
)
RETURNS boolean
LANGUAGE plpgsql AS $$
DECLARE
    v_mandant_id       integer;
    v_durchfuehrung_id integer;
    v_zeilen           integer;
BEGIN
    IF p_termin_id IS NULL OR p_person_id IS NULL THEN
        RAISE EXCEPTION 'Termin und Person muessen angegeben sein.'
            USING ERRCODE = '23502';
    END IF;

    -- Mandant und Durchfuehrung kommen aus dem Termin, nicht vom Aufrufer.
    -- Was der Server selbst herleiten kann, soll er nicht uebergeben
    -- bekommen — sonst haengt die Richtigkeit an der Oberflaeche.
    SELECT t.mandant_id, t.durchfuehrung_id
      INTO v_mandant_id, v_durchfuehrung_id
      FROM kurs_termin t
     WHERE t.termin_id = p_termin_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Termin % existiert nicht.', p_termin_id
            USING ERRCODE = '23503';
    END IF;

    -- Gehoert die Person zu dieser Durchfuehrung?
    IF NOT EXISTS (SELECT 1 FROM kurs_teilnehmer kt
                    WHERE kt.durchfuehrung_id = v_durchfuehrung_id
                      AND kt.person_id = p_person_id) THEN
        RAISE EXCEPTION
            'Person % ist nicht Teilnehmer dieser Kursdurchfuehrung.',
            p_person_id USING ERRCODE = '23503';
    END IF;

    -- Anwesend und entschuldigt zugleich ergibt keinen Sinn.
    IF COALESCE(p_anwesend, false) AND COALESCE(p_entschuldigt, false) THEN
        RAISE EXCEPTION
            'Anwesend und entschuldigt schliessen einander aus.'
            USING ERRCODE = '23514';
    END IF;

    INSERT INTO kurs_anwesenheit (termin_id, person_id, mandant_id, anwesend,
                                  entschuldigt, fehlminuten, bemerkung,
                                  erfasst_von_person_id, erfasst_am)
    VALUES (p_termin_id, p_person_id, v_mandant_id,
            COALESCE(p_anwesend, false), COALESCE(p_entschuldigt, false),
            p_fehlminuten, NULLIF(TRIM(p_bemerkung), ''),
            p_erfasst_von, clock_timestamp())
    ON CONFLICT (termin_id, person_id) DO UPDATE
       SET anwesend     = EXCLUDED.anwesend,
           entschuldigt = EXCLUDED.entschuldigt,
           fehlminuten  = EXCLUDED.fehlminuten,
           bemerkung    = EXCLUDED.bemerkung,
           -- Erfasser und Zeitpunkt nur nachziehen, wenn sich fachlich
           -- etwas geaendert hat. Sonst wuerde jedes erneute Speichern
           -- der unveraenderten Liste die Spur verfaelschen.
           erfasst_von_person_id = CASE
               WHEN kurs_anwesenheit.anwesend     IS DISTINCT FROM EXCLUDED.anwesend
                 OR kurs_anwesenheit.entschuldigt IS DISTINCT FROM EXCLUDED.entschuldigt
                 OR kurs_anwesenheit.fehlminuten  IS DISTINCT FROM EXCLUDED.fehlminuten
               THEN EXCLUDED.erfasst_von_person_id
               ELSE kurs_anwesenheit.erfasst_von_person_id END,
           erfasst_am = CASE
               WHEN kurs_anwesenheit.anwesend     IS DISTINCT FROM EXCLUDED.anwesend
                 OR kurs_anwesenheit.entschuldigt IS DISTINCT FROM EXCLUDED.entschuldigt
                 OR kurs_anwesenheit.fehlminuten  IS DISTINCT FROM EXCLUDED.fehlminuten
               THEN EXCLUDED.erfasst_am
               ELSE kurs_anwesenheit.erfasst_am END;

    GET DIAGNOSTICS v_zeilen = ROW_COUNT;
    RETURN v_zeilen > 0;
END;
$$;

COMMENT ON FUNCTION fn_kurs_anwesenheit_setzen IS
    'Setzt die Anwesenheit einer Person zu einem Termin. Mandant und '
    'Durchfuehrung werden aus dem Termin hergeleitet, nicht uebergeben.';

-- ── Ganzer Termin auf einmal ───────────────────────────────────────────────
-- Erwartet ein jsonb-Array:
--   [{"person_id":1,"anwesend":true},
--    {"person_id":2,"anwesend":false,"entschuldigt":true,"bemerkung":"krank"}]
-- Eine Fahrt fuer die ganze Klasse — und entweder steht alles oder nichts.
CREATE OR REPLACE FUNCTION fn_kurs_anwesenheit_liste(
    p_termin_id   integer,
    p_eintraege   jsonb,
    p_erfasst_von integer DEFAULT NULL
)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_e     jsonb;
    v_zahl  integer := 0;
BEGIN
    IF p_eintraege IS NULL OR jsonb_typeof(p_eintraege) <> 'array' THEN
        RAISE EXCEPTION 'Es wird ein jsonb-Array erwartet.'
            USING ERRCODE = '22023';
    END IF;

    FOR v_e IN SELECT * FROM jsonb_array_elements(p_eintraege)
    LOOP
        PERFORM fn_kurs_anwesenheit_setzen(
            p_termin_id,
            (v_e ->> 'person_id')::integer,
            COALESCE((v_e ->> 'anwesend')::boolean, false),
            COALESCE((v_e ->> 'entschuldigt')::boolean, false),
            (v_e ->> 'fehlminuten')::integer,
            v_e ->> 'bemerkung',
            p_erfasst_von);
        v_zahl := v_zahl + 1;
    END LOOP;

    RETURN v_zahl;
END;
$$;

COMMENT ON FUNCTION fn_kurs_anwesenheit_liste IS
    'Erfasst die Anwesenheit eines ganzen Termins in einem Aufruf. Atomar: '
    'faellt ein Eintrag durch, wird keiner geschrieben.';

-- ── Was der Coach zum Abhaken sieht ────────────────────────────────────────
-- Alle Teilnehmer der Durchfuehrung zu einem Termin, mit dem bisherigen
-- Stand. LEFT JOIN, damit auch die auftauchen, die noch nicht abgehakt sind.
CREATE OR REPLACE FUNCTION fn_kurs_anwesenheit_blatt(p_termin_id integer)
RETURNS TABLE (
    person_id      integer,
    vorname        varchar,
    nachname       varchar,
    anwesend       boolean,
    entschuldigt   boolean,
    fehlminuten    integer,
    bemerkung      text,
    erfasst_am     timestamp,
    schon_erfasst  boolean
)
LANGUAGE sql STABLE AS $$
    SELECT p.person_id,
           COALESCE(p.vorname, '')::varchar,
           p.nachname_firmenname::varchar,
           COALESCE(ka.anwesend, false),
           COALESCE(ka.entschuldigt, false),
           ka.fehlminuten,
           ka.bemerkung,
           ka.erfasst_am,
           (ka.person_id IS NOT NULL)
      FROM kurs_termin t
      JOIN kurs_teilnehmer kt ON kt.durchfuehrung_id = t.durchfuehrung_id
      JOIN person p           ON p.person_id = kt.person_id
      LEFT JOIN kurs_anwesenheit ka ON ka.termin_id = t.termin_id
                                   AND ka.person_id = p.person_id
     WHERE t.termin_id = p_termin_id
     ORDER BY p.nachname_firmenname, p.vorname;
$$;
