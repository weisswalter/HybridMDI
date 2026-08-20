-- ============================================================================
-- Kalkulation erweitert: Gültigkeit, Break-Even, Wechselkurse, Risiko, Markt
-- Stand 03.08.2026 — Nachtarbeit unbeaufsichtigt, aus Walters User-Story-Paket
-- (FIN-03, FIN-04, FIN-05, RSM-01, MKT-01).
--
-- ALLES ADDITIV: `fn_kalkulation_rechnen` (das getestete Kernstück von gestern)
-- wird NICHT verändert. Jede Erweiterung liefert entweder eine eigene
-- Berechnung (Break-Even, Marktvergleich) oder schreibt in ein Feld, das die
-- bestehende Rechnung ohnehin schon kennt (Risiko -> wagnis_prozent), oder
-- fügt eine gekennzeichnete Position hinzu (Inflation) — nie wird die
-- getestete Kette umgeschrieben.
-- ============================================================================

-- ── FIN-03: Gültigkeit und Ablauf-Erinnerung ───────────────────────────────
-- Neue Spalte erscheint automatisch im bestehenden Grid (dbgrdKalkulation ist
-- ein data-aware TDBGrid ohne feste Spaltenliste) — dafür ist keine
-- Delphi-Änderung nötig.
ALTER TABLE kalkulation ADD COLUMN IF NOT EXISTS gueltig_bis date;

COMMENT ON COLUMN kalkulation.gueltig_bis IS
    'Ab wann die Kalkulation als veraltet gilt und neu geprueft werden sollte. '
    'NULL = keine Ueberwachung.';

CREATE OR REPLACE FUNCTION fn_kalkulation_gueltigkeit_setzen(
    p_kalkulation_id integer, p_tage integer DEFAULT 90)
RETURNS date
LANGUAGE plpgsql AS $$
DECLARE v_bis date;
BEGIN
    SELECT datum + p_tage INTO v_bis FROM kalkulation
     WHERE kalkulation_id = p_kalkulation_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Kalkulation % gibt es nicht.', p_kalkulation_id;
    END IF;
    UPDATE kalkulation SET gueltig_bis = v_bis
     WHERE kalkulation_id = p_kalkulation_id;
    RETURN v_bis;
END;
$$;

-- Nur freigegebene Kalkulationen brauchen Überwachung — ein Entwurf ist noch
-- kein Angebot, das jemand in Händen hält, und ein Archiv ist erledigt.
CREATE OR REPLACE VIEW v_kalkulation_ablauf AS
SELECT k.kalkulation_id, k.mandant_id, k.bezeichnung, k.datum, k.gueltig_bis,
       k.angebotspreis,
       CASE WHEN k.gueltig_bis IS NULL THEN 'ohne Frist'
            WHEN k.gueltig_bis < CURRENT_DATE THEN 'abgelaufen'
            WHEN k.gueltig_bis - CURRENT_DATE <= 14 THEN 'laeuft bald ab'
            ELSE 'gueltig' END AS status_ablauf,
       k.gueltig_bis - CURRENT_DATE AS tage_bis_ablauf
  FROM kalkulation k
 WHERE k.status = 'freigegeben';

-- ── FIN-04: Break-Even-Rechner ──────────────────────────────────────────────
-- Annahme, die hier eine Rolle spielt (Walters Prüfung wert): variable
-- Stückkosten sind Material+Lohn+Maschine (die drei Positionsarten, die mit
-- der Menge in der Kalkulation mitwachsen). Alles andere — Zuschläge,
-- Sondereinzelkosten, Wagnis, Zins — wird für DIESE Losgrösse als Pauschale
-- behandelt und zählt als Fixkosten der Kalkulation. Das ist eine bewusste
-- Vereinfachung der Zuschlagsmethode fürs Break-Even, keine Buchhaltungswahrheit.
CREATE OR REPLACE FUNCTION fn_kalkulation_breakeven(p_kalkulation_id integer)
RETURNS TABLE (
    fixkosten numeric, variable_stueckkosten numeric,
    deckungsbeitrag_je_einheit numeric, breakeven_menge numeric,
    aktuelle_menge numeric, ueber_breakeven boolean
)
LANGUAGE plpgsql AS $$
DECLARE
    k kalkulation%ROWTYPE;
    v_fix numeric; v_var_stueck numeric; v_db numeric; v_be numeric;
BEGIN
    SELECT * INTO k FROM kalkulation WHERE kalkulation_id = p_kalkulation_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Kalkulation % gibt es nicht.', p_kalkulation_id;
    END IF;
    IF k.menge <= 0 OR k.herstellkosten = 0 THEN
        RAISE EXCEPTION 'Die Kalkulation ist noch nicht gerechnet - bitte '
            'zuerst fn_kalkulation_rechnen aufrufen.';
    END IF;

    v_fix := k.materialgemeinkosten + k.fertigungsgemeinkosten
           + k.verwaltungskosten + k.vertriebskosten
           + k.sondereinzelkosten + k.wagnis_betrag + k.zins_betrag;
    v_var_stueck := (k.materialeinzelkosten + k.fertigungsloehne
                    + k.maschinenkosten) / k.menge;
    v_db := k.preis_pro_einheit - v_var_stueck;

    IF v_db <= 0 THEN
        v_be := NULL;   -- der Preis deckt nicht einmal die variablen Kosten
    ELSE
        v_be := CEIL(v_fix / v_db);
    END IF;

    RETURN QUERY SELECT v_fix, v_var_stueck, v_db, v_be, k.menge,
                        (v_be IS NOT NULL AND k.menge >= v_be);
END;
$$;

COMMENT ON FUNCTION fn_kalkulation_breakeven IS
    'Bewusste Vereinfachung: variable Kosten = Material+Lohn+Maschine, alles '
    'andere gilt als Fixkosten DIESER Losgroesse. Fuer eine Szenario-Reihe '
    'ueber mehrere Mengen: fn_kalkulation_neu je Menge aufrufen und '
    'vergleichen.';

-- ── FIN-05: Wechselkurse und Inflationszuschlag ────────────────────────────
CREATE TABLE IF NOT EXISTS waehrungskurs (
    kurs_id       serial PRIMARY KEY,
    von_waehrung  char(3) NOT NULL,
    nach_waehrung char(3) NOT NULL DEFAULT 'CHF',
    datum         date NOT NULL DEFAULT CURRENT_DATE,
    kurs          numeric(14,6) NOT NULL CHECK (kurs > 0),
    quelle        varchar(100),
    UNIQUE (von_waehrung, nach_waehrung, datum),
    CONSTRAINT waehrungskurs_nicht_identisch CHECK (von_waehrung <> nach_waehrung)
);

CREATE INDEX IF NOT EXISTS ix_waehrungskurs_paar
    ON waehrungskurs (von_waehrung, nach_waehrung, datum DESC);

-- Stichtagskurs: der letzte bekannte Kurs AM ODER VOR dem gewünschten Datum,
-- nicht der nächstliegende — genau die im Aussenhandel übliche Definition.
CREATE OR REPLACE FUNCTION fn_wechselkurs(
    p_von char(3), p_nach char(3), p_datum date DEFAULT CURRENT_DATE)
RETURNS numeric
LANGUAGE plpgsql STABLE AS $$
DECLARE v_kurs numeric;
BEGIN
    IF p_von = p_nach THEN
        RETURN 1;
    END IF;
    SELECT kurs INTO v_kurs FROM waehrungskurs
     WHERE von_waehrung = p_von AND nach_waehrung = p_nach AND datum <= p_datum
     ORDER BY datum DESC LIMIT 1;
    IF v_kurs IS NOT NULL THEN
        RETURN v_kurs;
    END IF;
    -- Umgekehrte Notierung versuchen, bevor aufgegeben wird
    SELECT 1 / kurs INTO v_kurs FROM waehrungskurs
     WHERE von_waehrung = p_nach AND nach_waehrung = p_von AND datum <= p_datum
     ORDER BY datum DESC LIMIT 1;
    RETURN v_kurs;   -- NULL, wenn wirklich kein Kurs bekannt ist
END;
$$;

CREATE OR REPLACE FUNCTION fn_betrag_umrechnen(
    p_betrag numeric, p_von char(3), p_nach char(3), p_datum date DEFAULT CURRENT_DATE)
RETURNS numeric
LANGUAGE sql STABLE AS $$
    SELECT ROUND(p_betrag * fn_wechselkurs(p_von, p_nach, p_datum), 2);
$$;

-- Pauschaler Inflationszuschlag auf einen Kostenblock: fügt eine eigene,
-- klar beschriftete Position hinzu, statt bestehende Positionen zu ändern —
-- der ursprüngliche Materialpreis bleibt sichtbar und nachvollziehbar.
-- Danach muss fn_kalkulation_rechnen erneut laufen, damit der Zuschlag in die
-- Summen einfliesst (dieselbe Reihenfolge wie bei fn_kalkulation_material).
CREATE OR REPLACE FUNCTION fn_kalkulation_inflationszuschlag(
    p_kalkulation_id integer, p_block varchar, p_prozent numeric)
RETURNS numeric
LANGUAGE plpgsql AS $$
DECLARE
    k kalkulation%ROWTYPE;
    v_basis numeric; v_zuschlag numeric; v_rf smallint;
BEGIN
    SELECT * INTO k FROM kalkulation WHERE kalkulation_id = p_kalkulation_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Kalkulation % gibt es nicht.', p_kalkulation_id;
    END IF;

    v_basis := CASE p_block
                 WHEN 'material'   THEN k.materialeinzelkosten
                 WHEN 'fertigung'  THEN k.fertigungsloehne
                 WHEN 'sonder'     THEN k.sondereinzelkosten
                 ELSE NULL END;
    IF v_basis IS NULL THEN
        RAISE EXCEPTION 'Unbekannter Kostenblock "%" - erlaubt sind material, '
            'fertigung, sonder.', p_block;
    END IF;
    IF v_basis = 0 THEN
        RAISE EXCEPTION 'Der Kostenblock "%" ist noch leer (0) - bitte zuerst '
            'die Positionen erfassen und fn_kalkulation_rechnen aufrufen.', p_block;
    END IF;

    v_zuschlag := ROUND(v_basis * p_prozent / 100.0, 2);

    SELECT COALESCE(MAX(reihenfolge), 0) + 1 INTO v_rf
      FROM kalkulation_position WHERE kalkulation_id = p_kalkulation_id;

    INSERT INTO kalkulation_position (kalkulation_id, reihenfolge, art,
        bezeichnung, satz, betrag, bemerkung)
    VALUES (p_kalkulation_id, v_rf, 'sonder',
        'Inflationszuschlag ' || p_block || ' (' || p_prozent || ' %)',
        p_prozent, v_zuschlag,
        'Pauschal auf Basis ' || v_basis || ' zum Zeitpunkt der Erfassung - '
        'bei erneuter Materialuebernahme ggf. neu setzen.');

    RETURN v_zuschlag;
END;
$$;

-- ── RSM-01: Strukturierte Risikofaktoren ────────────────────────────────────
CREATE TABLE IF NOT EXISTS kalkulation_risiko (
    risiko_id       serial PRIMARY KEY,
    kalkulation_id  integer NOT NULL
                      REFERENCES kalkulation(kalkulation_id) ON DELETE CASCADE,
    bezeichnung     varchar(200) NOT NULL,
    wahrscheinlichkeit_prozent numeric(5,2) NOT NULL
                      CHECK (wahrscheinlichkeit_prozent BETWEEN 0 AND 100),
    -- Der Schaden, WENN das Risiko eintritt (nicht der Erwartungswert)
    finanzielle_auswirkung numeric(14,2) NOT NULL DEFAULT 0
                      CHECK (finanzielle_auswirkung >= 0),
    bemerkung       text
);

CREATE INDEX IF NOT EXISTS ix_kalkulation_risiko
    ON kalkulation_risiko (kalkulation_id);

CREATE OR REPLACE VIEW v_kalkulation_risiko_summe AS
SELECT kalkulation_id,
       count(*) AS anzahl_risiken,
       SUM(finanzielle_auswirkung) AS schaden_worst_case,
       SUM(wahrscheinlichkeit_prozent / 100.0 * finanzielle_auswirkung) AS erwarteter_schaden
  FROM kalkulation_risiko
 GROUP BY kalkulation_id;

-- Schreibt den erwarteten Schaden als Prozentsatz auf die Selbstkosten in
-- das VORHANDENE Feld kalkulation.wagnis_prozent — dadurch übernimmt das
-- bereits getestete fn_kalkulation_rechnen die eigentliche Anwendung, es gibt
-- keine zweite, parallele Wagnis-Rechnung.
-- ACHTUNG: überschreibt einen von Hand eingetragenen wagnis_prozent. Das ist
-- gewollt — sobald strukturierte Risiken erfasst sind, sollen sie
-- massgebend sein, nicht eine zusätzliche Schätzung daneben.
CREATE OR REPLACE FUNCTION fn_kalkulation_risiko_anwenden(p_kalkulation_id integer)
RETURNS numeric
LANGUAGE plpgsql AS $$
DECLARE
    v_selbstkosten numeric; v_erwartet numeric; v_prozent numeric;
BEGIN
    SELECT selbstkosten INTO v_selbstkosten FROM kalkulation
     WHERE kalkulation_id = p_kalkulation_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Kalkulation % gibt es nicht.', p_kalkulation_id;
    END IF;
    IF COALESCE(v_selbstkosten, 0) = 0 THEN
        RAISE EXCEPTION 'Die Kalkulation ist noch nicht gerechnet - bitte '
            'zuerst fn_kalkulation_rechnen aufrufen.';
    END IF;

    SELECT COALESCE(erwarteter_schaden, 0) INTO v_erwartet
      FROM v_kalkulation_risiko_summe WHERE kalkulation_id = p_kalkulation_id;

    v_prozent := ROUND(v_erwartet / v_selbstkosten * 100.0, 3);

    UPDATE kalkulation SET wagnis_prozent = v_prozent
     WHERE kalkulation_id = p_kalkulation_id;

    RETURN v_prozent;
END;
$$;

-- ── MKT-01: Marktpreisvergleich ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS marktpreis (
    marktpreis_id serial PRIMARY KEY,
    mandant_id    integer NOT NULL REFERENCES mandant(mandant_id),
    -- Mindestens eines von beiden: an einen Artikel gebunden (gilt für jede
    -- Kalkulation dieses Artikels) oder an eine einzelne Kalkulation.
    artikel_id      integer REFERENCES artikel(artikel_id),
    kalkulation_id  integer REFERENCES kalkulation(kalkulation_id),
    quelle        varchar(150) NOT NULL,   -- Wettbewerbername oder 'Marktforschung'
    preis         numeric(14,2) NOT NULL CHECK (preis >= 0),
    waehrung      char(3) NOT NULL DEFAULT 'CHF',
    datum         date NOT NULL DEFAULT CURRENT_DATE,
    bemerkung     text,
    CONSTRAINT marktpreis_bezug_check
        CHECK (artikel_id IS NOT NULL OR kalkulation_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS ix_marktpreis_artikel ON marktpreis (artikel_id);
CREATE INDEX IF NOT EXISTS ix_marktpreis_kalkulation ON marktpreis (kalkulation_id);

-- Schwelle 15 % ist ein vernünftiger Startwert, keine feste Wahrheit — hier
-- als Parameter der Funktion, nicht in der Sicht verdrahtet, damit man ihn
-- bei Bedarf pro Abfrage ändern kann.
CREATE OR REPLACE FUNCTION fn_marktvergleich(
    p_kalkulation_id integer, p_schwelle_prozent numeric DEFAULT 15)
RETURNS TABLE (
    eigener_preis numeric, markt_preise_anzahl integer,
    markt_preis_min numeric, markt_preis_durchschnitt numeric,
    markt_preis_max numeric, abweichung_prozent numeric, urteil text
)
LANGUAGE plpgsql AS $$
DECLARE
    k kalkulation%ROWTYPE;
    v_min numeric; v_avg numeric; v_max numeric; v_n integer;
    v_abw numeric; v_urteil text;
BEGIN
    SELECT * INTO k FROM kalkulation WHERE kalkulation_id = p_kalkulation_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Kalkulation % gibt es nicht.', p_kalkulation_id;
    END IF;

    SELECT count(*), MIN(fn_betrag_umrechnen(preis, waehrung, k.waehrung, datum)),
           AVG(fn_betrag_umrechnen(preis, waehrung, k.waehrung, datum)),
           MAX(fn_betrag_umrechnen(preis, waehrung, k.waehrung, datum))
      INTO v_n, v_min, v_avg, v_max
      FROM marktpreis
     WHERE kalkulation_id = p_kalkulation_id
        OR (artikel_id = k.artikel_id AND k.artikel_id IS NOT NULL);

    IF COALESCE(v_n, 0) = 0 THEN
        RETURN QUERY SELECT k.preis_pro_einheit, 0, NULL::numeric, NULL::numeric,
                            NULL::numeric, NULL::numeric,
                            'keine Marktpreise erfasst'::text;
        RETURN;
    END IF;

    v_abw := ROUND((k.preis_pro_einheit - v_avg) / NULLIF(v_avg, 0) * 100, 1);
    v_urteil := CASE
                  WHEN v_abw IS NULL THEN 'nicht bestimmbar'
                  WHEN v_abw > p_schwelle_prozent THEN 'deutlich teurer als der Markt'
                  WHEN v_abw < -p_schwelle_prozent THEN 'deutlich guenstiger als der Markt'
                  ELSE 'im Marktrahmen'
                END;

    RETURN QUERY SELECT k.preis_pro_einheit, v_n, ROUND(v_min, 2), ROUND(v_avg, 2),
                        ROUND(v_max, 2), v_abw, v_urteil;
END;
$$;
