-- ============================================================================
-- Anlagevermögen und Abschreibungen — Stand 02.08.2026
--
-- DER KERNGEDANKE: Eine Anlage führt ZWEI Wertreihen nebeneinander.
--
--   BILANZIELL   — nach Steuerrecht, für den Abschluss. Anschaffungswert,
--                  festgelegte Nutzungsdauer, danach steht die Anlage mit
--                  null (oder dem Restwert) in den Büchern.
--   KALKULATORISCH — für die Preisfindung. Auf den WIEDERBESCHAFFUNGSwert und
--                  über die TATSÄCHLICHE Nutzungsdauer.
--
-- Warum das nicht dasselbe sein darf: Eine Maschine für 120'000 mit 10 Jahren
-- Nutzungsdauer steht ab Jahr 11 buchhalterisch bei null. Wer damit
-- kalkuliert, rechnet mit null Maschinenkosten und unterbietet sich selbst —
-- die Maschine läuft ja weiter, und ihr Ersatz kostet inzwischen mehr als
-- 120'000. Genau dafür stehen "Abschreibungen" (Prio 1) und "Währung und
-- Inflation" (Prio 2) im Kalkulationskonzept.
--
-- Dazu kommt der kalkulatorische ZINS: Das in der Anlage gebundene Kapital
-- brächte anderswo Ertrag. Dieser Verzicht ist ein echter Kostenfaktor, taucht
-- aber in keiner Buchhaltung auf ("Finanzierungskosten", Prio 2).
-- ============================================================================

CREATE TABLE IF NOT EXISTS anlage (
    anlage_id       serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    inventar_nr     varchar(50),
    bezeichnung     varchar(200) NOT NULL,
    gruppe          varchar(50),        -- Maschinen, Informatik, Fahrzeuge ...

    -- Verbindung zur Buchhaltung. Beide dürfen leer bleiben, solange kein
    -- Buchhaltungsmodul läuft — die Kalkulation funktioniert auch ohne.
    konto_id        integer REFERENCES konto(konto_id),   -- Aktivkonto (1500)
    aufwand_konto_id integer REFERENCES konto(konto_id),  -- 6800 Abschreibungen

    -- ── Bilanziell ────────────────────────────────────────────────────────
    anschaffung_datum   date NOT NULL,
    anschaffung_wert    numeric(14,2) NOT NULL CHECK (anschaffung_wert >= 0),
    restwert            numeric(14,2) NOT NULL DEFAULT 0 CHECK (restwert >= 0),
    nutzungsdauer_jahre numeric(5,2) NOT NULL CHECK (nutzungsdauer_jahre > 0),
    methode             varchar(20) NOT NULL DEFAULT 'linear'
                          CHECK (methode IN ('linear', 'degressiv')),
    -- Nur bei degressiv: Satz auf den jeweiligen Buchwert
    degressiv_prozent   numeric(5,2) CHECK (degressiv_prozent > 0
                                            AND degressiv_prozent <= 100),

    -- ── Kalkulatorisch ────────────────────────────────────────────────────
    -- Leer = Anschaffungswert verwenden. Gefüllt = das, was ein Ersatz heute
    -- kosten würde.
    wiederbeschaffung_wert numeric(14,2) CHECK (wiederbeschaffung_wert >= 0),
    -- Jährliche Steigerung des Wiederbeschaffungswerts. Das ist der Ort, an
    -- dem Inflation in die Kalkulation eingeht.
    inflation_prozent   numeric(5,2) NOT NULL DEFAULT 0,
    -- Leer = wie bilanziell. Meist LÄNGER: steuerlich schnell abschreiben,
    -- tatsächlich lange nutzen.
    kalk_nutzungsdauer_jahre numeric(5,2) CHECK (kalk_nutzungsdauer_jahre > 0),
    -- Zinssatz auf das durchschnittlich gebundene Kapital
    kalk_zins_prozent   numeric(5,2) NOT NULL DEFAULT 0,

    -- ── Für den Maschinenstundensatz ──────────────────────────────────────
    betriebsstunden_jahr numeric(10,2) CHECK (betriebsstunden_jahr >= 0),
    unterhalt_jahr      numeric(14,2) NOT NULL DEFAULT 0,  -- Wartung, Reparatur
    energie_pro_stunde  numeric(10,4) NOT NULL DEFAULT 0,

    -- Wo sie steht. raum_id ist optional — nicht jede Anlage hat einen Raum.
    raum_id         integer REFERENCES raum(raum_id),

    ausser_betrieb_am date,
    aktiv           boolean NOT NULL DEFAULT true,
    bemerkung       text,
    created_at      timestamp NOT NULL DEFAULT now(),

    CONSTRAINT anlage_degressiv_check
        CHECK (methode <> 'degressiv' OR degressiv_prozent IS NOT NULL),
    UNIQUE (mandant_id, inventar_nr)
);

CREATE INDEX IF NOT EXISTS ix_anlage_mandant ON anlage (mandant_id, gruppe);

COMMENT ON COLUMN anlage.wiederbeschaffung_wert IS
    'Was ein Ersatz heute kosten wuerde. Grundlage der KALKULATORISCHEN '
    'Abschreibung - leer bedeutet: Anschaffungswert verwenden.';

-- ── Der Abschreibungsplan, Jahr für Jahr ───────────────────────────────────
CREATE TABLE IF NOT EXISTS anlage_abschreibung (
    abschreibung_id serial PRIMARY KEY,
    anlage_id       integer NOT NULL
                      REFERENCES anlage(anlage_id) ON DELETE CASCADE,
    jahr            smallint NOT NULL,
    nutzungsjahr    smallint NOT NULL,      -- 1 = erstes Jahr

    -- bilanziell
    buchwert_anfang     numeric(14,2) NOT NULL DEFAULT 0,
    abschreibung_bilanz numeric(14,2) NOT NULL DEFAULT 0,
    buchwert_ende       numeric(14,2) NOT NULL DEFAULT 0,

    -- kalkulatorisch
    kalk_basis          numeric(14,2) NOT NULL DEFAULT 0,  -- WBW im Jahr
    abschreibung_kalk   numeric(14,2) NOT NULL DEFAULT 0,
    kalk_zins           numeric(14,2) NOT NULL DEFAULT 0,
    -- Was die Anlage den Betrieb in diesem Jahr wirklich kostet
    kalk_gesamt         numeric(14,2) NOT NULL DEFAULT 0,

    UNIQUE (anlage_id, jahr)
);

COMMENT ON TABLE anlage_abschreibung IS
    'Zwei Wertreihen je Jahr: bilanziell fuer den Abschluss, kalkulatorisch '
    'fuer die Preisfindung. Wird von fn_anlage_plan erzeugt.';

-- ── Plan berechnen ─────────────────────────────────────────────────────────
-- Wirft den bestehenden Plan weg und baut ihn neu. Das ist hier richtig: Der
-- Plan ist reine Ableitung aus den Stammdaten, es steckt keine Handarbeit
-- darin, die verloren gehen könnte.
--
-- Der Plan läuft über die LÄNGERE der beiden Nutzungsdauern — sonst fehlte
-- genau der Bereich, um den es geht: die Jahre, in denen bilanziell nichts
-- mehr, kalkulatorisch aber sehr wohl etwas anfällt.
CREATE OR REPLACE FUNCTION fn_anlage_plan(p_anlage_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    a               anlage%ROWTYPE;
    v_jahre         integer;
    v_start_jahr    integer;
    v_i             integer;
    v_buchwert      numeric(14,2);
    v_abschr        numeric(14,2);
    v_linear        numeric(14,2);
    v_kalk_basis    numeric(14,2);
    v_kalk_wert     numeric(14,2);
    v_kalk_nd       numeric(5,2);
    v_kalk_abschr   numeric(14,2);
    v_kalk_zins     numeric(14,2);
BEGIN
    SELECT * INTO a FROM anlage WHERE anlage_id = p_anlage_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Anlage % gibt es nicht.', p_anlage_id;
    END IF;

    DELETE FROM anlage_abschreibung WHERE anlage_id = p_anlage_id;

    v_start_jahr := EXTRACT(YEAR FROM a.anschaffung_datum)::integer;
    v_kalk_wert  := COALESCE(NULLIF(a.wiederbeschaffung_wert, 0),
                             a.anschaffung_wert);
    v_kalk_nd    := COALESCE(a.kalk_nutzungsdauer_jahre, a.nutzungsdauer_jahre);
    v_jahre      := CEIL(GREATEST(a.nutzungsdauer_jahre, v_kalk_nd))::integer;

    v_buchwert := a.anschaffung_wert;
    v_linear   := (a.anschaffung_wert - a.restwert) / a.nutzungsdauer_jahre;

    FOR v_i IN 1..v_jahre LOOP
        -- ── bilanziell ────────────────────────────────────────────────────
        IF v_i > a.nutzungsdauer_jahre THEN
            v_abschr := 0;                       -- fertig abgeschrieben
        ELSIF a.methode = 'degressiv' THEN
            v_abschr := ROUND(v_buchwert * a.degressiv_prozent / 100.0, 2);
        ELSE
            v_abschr := ROUND(v_linear, 2);
        END IF;

        -- Im LETZTEN Nutzungsjahr den ganzen Rest bis zum Restwert abschreiben.
        --
        -- Für die degressive Methode ist das zwingend: Sie nimmt jedes Jahr
        -- einen Prozentsatz vom verbleibenden Buchwert und erreicht den
        -- Restwert deshalb NIE — eine geometrische Reihe wird nur beliebig
        -- klein. Ein Test mit 20'000 auf 5 Jahre zu 40 % endete bei 1'555
        -- statt bei den vereinbarten 1'000, und die Summe der Abschreibungen
        -- stimmte entsprechend nicht mit (Anschaffung − Restwert) überein.
        IF v_i = CEIL(a.nutzungsdauer_jahre)::integer THEN
            v_abschr := GREATEST(v_buchwert - a.restwert, 0);
        END IF;

        -- Nie unter den Restwert. Fängt zusätzlich den Fall ab, dass die
        -- lineare Rate durch Rundung im vorletzten Jahr schon zu weit führt.
        IF v_buchwert - v_abschr < a.restwert THEN
            v_abschr := GREATEST(v_buchwert - a.restwert, 0);
        END IF;

        -- ── kalkulatorisch ────────────────────────────────────────────────
        -- Der Wiederbeschaffungswert wächst mit der Inflation. Deshalb steigt
        -- auch die kalkulatorische Abschreibung von Jahr zu Jahr — genau das
        -- ist Substanzerhaltung: am Ende soll das Geld für den Ersatz da sein.
        v_kalk_basis := ROUND(v_kalk_wert
                              * POWER(1 + a.inflation_prozent / 100.0, v_i - 1), 2);

        IF v_i > v_kalk_nd THEN
            v_kalk_abschr := 0;
        ELSE
            v_kalk_abschr := ROUND(v_kalk_basis / v_kalk_nd, 2);
        END IF;

        -- Durchschnittlich gebundenes Kapital = halber Wert. Das ist die
        -- übliche Durchschnittswertmethode: über die Nutzungsdauer gemittelt
        -- ist im Schnitt die Hälfte gebunden.
        IF v_i > v_kalk_nd THEN
            v_kalk_zins := 0;
        ELSE
            v_kalk_zins := ROUND(v_kalk_basis / 2 * a.kalk_zins_prozent / 100.0, 2);
        END IF;

        INSERT INTO anlage_abschreibung (anlage_id, jahr, nutzungsjahr,
            buchwert_anfang, abschreibung_bilanz, buchwert_ende,
            kalk_basis, abschreibung_kalk, kalk_zins, kalk_gesamt)
        VALUES (p_anlage_id, v_start_jahr + v_i - 1, v_i,
            v_buchwert, v_abschr, v_buchwert - v_abschr,
            v_kalk_basis, v_kalk_abschr, v_kalk_zins,
            v_kalk_abschr + v_kalk_zins + COALESCE(a.unterhalt_jahr, 0));

        v_buchwert := v_buchwert - v_abschr;
    END LOOP;

    RETURN v_jahre;
END;
$$;

-- ── Maschinenstundensatz ───────────────────────────────────────────────────
-- Der Wert, der später in die Kalkulation eingeht: was eine Betriebsstunde
-- dieser Anlage kostet.
--
-- Ohne hinterlegte Betriebsstunden ist die Frage nicht beantwortbar — dann
-- kommt NULL zurück und nicht etwa 0, damit ein fehlender Wert auffällt statt
-- die Kalkulation stillschweigend zu verbilligen.
CREATE OR REPLACE FUNCTION fn_maschinenstundensatz(
    p_anlage_id integer, p_jahr integer)
RETURNS numeric
LANGUAGE sql STABLE AS $$
    SELECT CASE
             WHEN COALESCE(a.betriebsstunden_jahr, 0) <= 0 THEN NULL
             ELSE ROUND(ab.kalk_gesamt / a.betriebsstunden_jahr
                        + a.energie_pro_stunde, 4)
           END
      FROM anlage a
      JOIN anlage_abschreibung ab ON ab.anlage_id = a.anlage_id
     WHERE a.anlage_id = p_anlage_id AND ab.jahr = p_jahr;
$$;

-- ── Übersicht ──────────────────────────────────────────────────────────────
-- Zeigt beide Reihen nebeneinander. Die Spalte `differenz` macht sichtbar,
-- worum es geht: was die Kalkulation ansetzt, das die Buchhaltung nicht kennt.
CREATE OR REPLACE VIEW v_anlage_jahr AS
SELECT a.mandant_id, a.anlage_id, a.inventar_nr, a.bezeichnung, a.gruppe,
       ab.jahr, ab.nutzungsjahr,
       ab.buchwert_anfang, ab.abschreibung_bilanz, ab.buchwert_ende,
       ab.kalk_basis, ab.abschreibung_kalk, ab.kalk_zins,
       a.unterhalt_jahr, ab.kalk_gesamt,
       ab.abschreibung_kalk - ab.abschreibung_bilanz AS differenz,
       a.betriebsstunden_jahr,
       CASE WHEN COALESCE(a.betriebsstunden_jahr, 0) > 0
            THEN ROUND(ab.kalk_gesamt / a.betriebsstunden_jahr
                       + a.energie_pro_stunde, 4) END AS stundensatz
  FROM anlage a
  JOIN anlage_abschreibung ab ON ab.anlage_id = a.anlage_id;
