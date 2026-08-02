-- ============================================================================
-- Zuwendungen und Budget — Stand 02.08.2026
--
-- Walters Vorgabe: "bei der Arbeitsagogik koennen Zuwendungen von staatlicher
-- Stelle eine Rolle spielen bzw. Budget".
--
-- DER FACHLICHE KERN: Nicht der Leistungsempfaenger zahlt, sondern eine
-- Behoerde. Drei Formen, die man NICHT vermischen darf:
--
--   KOSTENGUTSPRACHE      fuer EINEN Klienten, Zeitraum, Hoechstbetrag
--   LEISTUNGSVEREINBARUNG Rahmenvertrag ueber Plaetze, meist mehrjaehrig
--   BETRIEBSBEITRAG       pauschal, oft zweckgebunden
--
-- DER EIGENTLICHE NUTZEN IST DIE WARNUNG. Die Erfassung ist die leichte
-- Uebung; entscheidend ist, rechtzeitig zu sehen, dass eine Gutsprache
-- auslaeuft oder ausgeschoepft ist. Wer es erst bei der Abrechnung merkt, hat
-- die Leistung erbracht und niemanden, der sie zahlt.
--
-- DIE FOERDERSTELLE IST EINE `person`, keine eigene Stammtabelle: Sie hat
-- Adressen, Ansprechpartner und Telefonnummern wie jede juristische Person.
-- Eine zweite Stammtabelle hiesse doppelte Pflege.
-- ============================================================================

-- ── 1. Ertragskonten fuer Beitraege ────────────────────────────────────────
-- Der Kontenrahmen KMU kennt keine oeffentlichen Beitraege - er ist fuer
-- Gewerbebetriebe gedacht. Fuer einen Agogikbetrieb fehlt genau das.
CREATE OR REPLACE FUNCTION fn_kontenrahmen_beitraege(p_mandant_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_z record; v_anzahl integer := 0;
BEGIN
    FOR v_z IN
        SELECT * FROM (VALUES
        ('3500', 'Beitraege oeffentliche Hand',        'ertrag',  '3'),
        ('3510', 'Kostengutsprachen Klienten',         'ertrag',  '3'),
        ('3520', 'Zweckgebundene Beitraege',           'ertrag',  '3'),
        ('3530', 'Spenden und private Zuwendungen',    'ertrag',  '3'),
        -- Nicht verbrauchte zweckgebundene Mittel gehoeren NICHT in den
        -- Gewinn: sie sind abzugrenzen, weil sie zurueckzuzahlen sein koennen.
        ('2301', 'Noch nicht verwendete Zweckmittel',  'passiv',  '20')
        ) AS t(nummer, bez, typ, parent)
    LOOP
        INSERT INTO konto (mandant_id, nummer, bezeichnung, typ, parent_id)
        SELECT p_mandant_id, v_z.nummer, v_z.bez, v_z.typ,
               (SELECT konto_id FROM konto
                 WHERE mandant_id = p_mandant_id AND nummer = v_z.parent)
        WHERE NOT EXISTS (SELECT 1 FROM konto k
                           WHERE k.mandant_id = p_mandant_id
                             AND k.nummer = v_z.nummer);
        IF FOUND THEN v_anzahl := v_anzahl + 1; END IF;
    END LOOP;
    RETURN v_anzahl;
END;
$$;

-- ── 2. Kostengutsprache ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS kostengutsprache (
    gutsprache_id   serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    -- Fuer wen. NULL bei Betriebsbeitraegen, die keinem Klienten gelten.
    person_id       integer REFERENCES person(person_id),
    -- Wer zahlt: IV-Stelle, Sozialamt, Gemeinde - eine juristische `person`
    foerderstelle_person_id integer NOT NULL REFERENCES person(person_id),

    art             varchar(25) NOT NULL DEFAULT 'gutsprache'
                      CHECK (art IN ('gutsprache', 'vereinbarung', 'beitrag')),
    zeichen         varchar(100),          -- Aktenzeichen der Behoerde
    zeitraum        daterange NOT NULL,

    -- Wie abgerechnet wird
    ansatz_art      varchar(15) NOT NULL DEFAULT 'tag'
                      CHECK (ansatz_art IN ('tag', 'stunde', 'monat',
                                            'platz', 'pauschal')),
    ansatz_betrag   numeric(12,2) NOT NULL DEFAULT 0,
    bewilligte_menge numeric(12,2),        -- Tage, Stunden, Plaetze
    -- Die Obergrenze in Geld. Auch wenn die Menge noch reicht: hier ist Schluss.
    hoechstbetrag   numeric(14,2),

    zweckgebunden   boolean NOT NULL DEFAULT false,
    rueckzahlbar    boolean NOT NULL DEFAULT false,

    ertrag_konto_id integer REFERENCES konto(konto_id),
    status          varchar(20) NOT NULL DEFAULT 'beantragt'
                      CHECK (status IN ('beantragt', 'bewilligt', 'abgelehnt',
                                        'abgelaufen', 'abgerechnet')),
    dokument_id     integer REFERENCES dokument(dokument_id),   -- der Bescheid
    bemerkung       text,
    created_at      timestamp NOT NULL DEFAULT now(),

    -- Eine Gutsprache gilt einem Klienten, ein Betriebsbeitrag nicht.
    CONSTRAINT gutsprache_person_check
        CHECK (art <> 'gutsprache' OR person_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS ix_gutsprache_mandant
    ON kostengutsprache (mandant_id, status);
CREATE INDEX IF NOT EXISTS ix_gutsprache_person
    ON kostengutsprache (person_id);

COMMENT ON TABLE kostengutsprache IS
    'Zusagen von Foerderstellen. Der Nutzen liegt in der Ueberwachung: '
    'siehe v_gutsprache_status.';

-- ── 3. Abrufe: was bereits verbraucht wurde ────────────────────────────────
-- Ohne diese Sätze wüsste niemand, wie viel von einer Gutsprache noch übrig
-- ist. Ein Abruf kann an einer Rechnung hängen (dann ist er abgerechnet) oder
-- vorerst nur erfasst sein.
CREATE TABLE IF NOT EXISTS gutsprache_abruf (
    abruf_id        serial PRIMARY KEY,
    gutsprache_id   integer NOT NULL
                      REFERENCES kostengutsprache(gutsprache_id) ON DELETE CASCADE,
    datum           date NOT NULL DEFAULT CURRENT_DATE,
    menge           numeric(12,2) NOT NULL DEFAULT 0,
    betrag          numeric(14,2) NOT NULL DEFAULT 0,
    beleg_id        integer REFERENCES beleg(beleg_id),
    buchung_id      integer REFERENCES buchung(buchung_id),
    bemerkung       text
);

CREATE INDEX IF NOT EXISTS ix_gutsprache_abruf
    ON gutsprache_abruf (gutsprache_id, datum);

-- ── 4. Budget ──────────────────────────────────────────────────────────────
-- Geplante Werte je Jahr. Wahlweise je Kostenstelle, je Konto oder je
-- Kursdurchfuehrung — deshalb alle drei optional, aber mindestens eines.
CREATE TABLE IF NOT EXISTS budget (
    budget_id       serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    jahr            smallint NOT NULL,
    bezeichnung     varchar(200) NOT NULL,
    kostenstelle_id integer REFERENCES kostenstelle(kostenstelle_id),
    konto_id        integer REFERENCES konto(konto_id),
    durchfuehrung_id integer REFERENCES kurs_durchfuehrung(durchfuehrung_id),
    betrag_geplant  numeric(14,2) NOT NULL DEFAULT 0,
    -- Warnschwelle in Prozent: ab hier soll die Oberflaeche auffallen
    warnschwelle_prozent numeric(5,2) NOT NULL DEFAULT 80
                      CHECK (warnschwelle_prozent BETWEEN 0 AND 100),
    zweckgebunden   boolean NOT NULL DEFAULT false,
    bemerkung       text,
    CONSTRAINT budget_bezug_check
        CHECK (kostenstelle_id IS NOT NULL OR konto_id IS NOT NULL
               OR durchfuehrung_id IS NOT NULL),
    UNIQUE (mandant_id, jahr, bezeichnung)
);

-- ── 5. Die Ueberwachung ────────────────────────────────────────────────────
-- Das eigentliche Ziel: rechtzeitig sehen, was zur Neige geht.
--
-- `ampel` fasst zusammen, was sonst niemand im Blick behaelt: erschoepft,
-- kritisch (ueber der Schwelle), laeuft bald aus, oder in Ordnung.
CREATE OR REPLACE VIEW v_gutsprache_status AS
SELECT g.gutsprache_id, g.mandant_id, g.art, g.zeichen, g.status,
       g.person_id,
       p.nachname_firmenname || ', ' || COALESCE(p.vorname, '') AS klient,
       f.nachname_firmenname AS foerderstelle,
       lower(g.zeitraum) AS gilt_ab,
       upper(g.zeitraum) - 1 AS gilt_bis,
       (upper(g.zeitraum) - 1) - CURRENT_DATE AS tage_offen,
       g.ansatz_art, g.ansatz_betrag,
       g.bewilligte_menge, g.hoechstbetrag,
       COALESCE(SUM(a.menge), 0) AS menge_verbraucht,
       COALESCE(SUM(a.betrag), 0) AS betrag_verbraucht,
       g.bewilligte_menge - COALESCE(SUM(a.menge), 0) AS menge_rest,
       g.hoechstbetrag - COALESCE(SUM(a.betrag), 0) AS betrag_rest,
       CASE WHEN COALESCE(g.hoechstbetrag, 0) > 0
            THEN ROUND(100.0 * COALESCE(SUM(a.betrag), 0) / g.hoechstbetrag, 1)
       END AS ausgeschoepft_prozent,
       CASE
         WHEN g.status NOT IN ('bewilligt') THEN g.status
         WHEN COALESCE(g.hoechstbetrag, 0) > 0
              AND COALESCE(SUM(a.betrag), 0) >= g.hoechstbetrag
              THEN 'erschoepft'
         WHEN COALESCE(g.bewilligte_menge, 0) > 0
              AND COALESCE(SUM(a.menge), 0) >= g.bewilligte_menge
              THEN 'erschoepft'
         WHEN (upper(g.zeitraum) - 1) < CURRENT_DATE THEN 'abgelaufen'
         WHEN (upper(g.zeitraum) - 1) - CURRENT_DATE <= 30 THEN 'laeuft aus'
         WHEN COALESCE(g.hoechstbetrag, 0) > 0
              AND COALESCE(SUM(a.betrag), 0) >= g.hoechstbetrag * 0.8
              THEN 'kritisch'
         ELSE 'ok'
       END AS ampel
  FROM kostengutsprache g
  LEFT JOIN person p ON p.person_id = g.person_id
  LEFT JOIN person f ON f.person_id = g.foerderstelle_person_id
  LEFT JOIN gutsprache_abruf a ON a.gutsprache_id = g.gutsprache_id
 GROUP BY g.gutsprache_id, p.nachname_firmenname, p.vorname,
          f.nachname_firmenname;

-- Budget gegen die tatsaechlichen Kosten. Zieht die Ist-Werte aus der
-- Kostenrechnung, nicht aus der Buchhaltung — Budgets werden auf
-- Kostenstellen geplant, und dort liegen auch die kalkulatorischen Werte.
CREATE OR REPLACE VIEW v_budget_status AS
SELECT b.budget_id, b.mandant_id, b.jahr, b.bezeichnung,
       ks.nummer AS kostenstelle, k.nummer AS konto,
       b.betrag_geplant, b.zweckgebunden, b.warnschwelle_prozent,
       COALESCE(w.ist, 0) AS betrag_ist,
       b.betrag_geplant - COALESCE(w.ist, 0) AS rest,
       CASE WHEN b.betrag_geplant > 0
            THEN ROUND(100.0 * COALESCE(w.ist, 0) / b.betrag_geplant, 1)
       END AS verbraucht_prozent,
       CASE
         WHEN b.betrag_geplant <= 0 THEN 'kein Budget'
         WHEN COALESCE(w.ist, 0) > b.betrag_geplant THEN 'ueberschritten'
         WHEN COALESCE(w.ist, 0) >= b.betrag_geplant
              * b.warnschwelle_prozent / 100 THEN 'kritisch'
         ELSE 'ok'
       END AS ampel
  FROM budget b
  LEFT JOIN kostenstelle ks ON ks.kostenstelle_id = b.kostenstelle_id
  LEFT JOIN konto k ON k.konto_id = b.konto_id
  LEFT JOIN LATERAL (
        SELECT SUM(betrag) AS ist
          FROM kostenstelle_wert w2
         WHERE w2.mandant_id = b.mandant_id AND w2.jahr = b.jahr
           AND (b.kostenstelle_id IS NULL
                OR w2.kostenstelle_id = b.kostenstelle_id)) w ON true;

-- ── 6. Abruf verbuchen ─────────────────────────────────────────────────────
-- Bucht einen Abruf als Ertrag: Forderung an Beitragskonto.
-- Zweckgebundene Mittel gehen NICHT in den Ertrag, sondern in die Abgrenzung
-- (2301) — sie sind erst verdient, wenn der Zweck erfuellt ist.
CREATE OR REPLACE FUNCTION fn_buchung_aus_abruf(p_abruf_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    a gutsprache_abruf%ROWTYPE;
    g kostengutsprache%ROWTYPE;
    v_haben integer; v_soll integer; v_id integer;
BEGIN
    SELECT * INTO a FROM gutsprache_abruf WHERE abruf_id = p_abruf_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Abruf % gibt es nicht.', p_abruf_id;
    END IF;
    IF a.buchung_id IS NOT NULL THEN
        RAISE EXCEPTION 'Dieser Abruf ist bereits gebucht (Buchung %).',
            a.buchung_id;
    END IF;
    IF a.betrag <= 0 THEN
        RAISE EXCEPTION 'Ein Abruf ohne Betrag wird nicht gebucht.';
    END IF;

    SELECT * INTO g FROM kostengutsprache
     WHERE gutsprache_id = a.gutsprache_id;

    v_soll := fn_konto_id(g.mandant_id, '1100');     -- Forderung
    v_haben := COALESCE(g.ertrag_konto_id,
                 CASE WHEN g.zweckgebunden
                      THEN fn_konto_id(g.mandant_id, '2301')
                      WHEN g.art = 'gutsprache'
                      THEN fn_konto_id(g.mandant_id, '3510')
                      ELSE fn_konto_id(g.mandant_id, '3500') END);
    IF v_soll IS NULL OR v_haben IS NULL THEN
        RAISE EXCEPTION 'Es fehlen Konten - bitte fn_kontenrahmen_beitraege '
            'fuer diesen Mandanten aufrufen.';
    END IF;

    v_id := fn_buchung_einfach(g.mandant_id, a.datum,
              'Zuwendung ' || COALESCE(g.zeichen, g.gutsprache_id::text),
              v_soll, v_haben, a.betrag, NULL, NULL, 'zuwendung', p_abruf_id);

    UPDATE gutsprache_abruf SET buchung_id = v_id WHERE abruf_id = p_abruf_id;
    RETURN v_id;
END;
$$;
