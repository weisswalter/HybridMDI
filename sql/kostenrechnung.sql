-- ============================================================================
-- Kostenarten, Kostenstellen, Betriebsabrechnung — Stand 02.08.2026
--
-- DREI FRAGEN, DREI STUFEN — so ist die Kostenrechnung aufgebaut:
--   WELCHE Kosten sind angefallen?  → Kostenart   (Material, Löhne, Miete)
--   WO sind sie angefallen?          → Kostenstelle (Fertigung, Verwaltung)
--   WOFÜR sind sie angefallen?       → Kostenträger (Auftrag, Artikel, Kurs)
-- Die dritte Stufe ist die Kalkulation und steht in sql/kalkulation.sql.
--
-- ZWEI UNTERSCHEIDUNGEN, die das Kalkulationskonzept ausdrücklich verlangt:
--
--   EINZEL / GEMEIN — Einzelkosten lassen sich einem Auftrag direkt zurechnen
--   (das Blech für dieses Gehäuse). Gemeinkosten nicht (die Hallenmiete) —
--   sie werden über Zuschlagssätze verteilt. Das ist der Punkt "Overhead-
--   Kosten ... verteile diese Kosten angemessen auf die produzierten
--   Einheiten" (Prio 1).
--
--   FIX / VARIABEL — ob die Kosten mit der Menge mitgehen. Entscheidend für
--   die Frage, was ein Zusatzauftrag wirklich kostet, und für die
--   Skalierbarkeit (Prio 2): Fixkosten je Stück sinken mit der Menge,
--   variable nicht.
--
-- KALKULATORISCHE Kostenarten (Abschreibung auf Wiederbeschaffungswert, Zins
-- auf gebundenes Kapital, Wagnis) tragen KEIN Konto — sie haben in der
-- Buchhaltung kein Gegenstück und dürfen dort nie gebucht werden.
-- ============================================================================

-- ── 1. Kostenarten ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS kostenart (
    kostenart_id    serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    nummer          varchar(20) NOT NULL,
    bezeichnung     varchar(200) NOT NULL,

    typ             varchar(10) NOT NULL DEFAULT 'gemein'
                      CHECK (typ IN ('einzel', 'gemein')),
    verhalten       varchar(10) NOT NULL DEFAULT 'fix'
                      CHECK (verhalten IN ('fix', 'variabel', 'gemischt')),
    -- Nur bei 'gemischt': welcher Anteil geht mit der Menge mit.
    -- Energie ist das Musterbeispiel — Grundlast fix, Verbrauch variabel.
    variabler_anteil_prozent numeric(5,2) NOT NULL DEFAULT 0
                      CHECK (variabler_anteil_prozent BETWEEN 0 AND 100),

    konto_id        integer REFERENCES konto(konto_id),
    kalkulatorisch  boolean NOT NULL DEFAULT false,

    aktiv           boolean NOT NULL DEFAULT true,
    bemerkung       text,
    UNIQUE (mandant_id, nummer),

    -- Eine kalkulatorische Kostenart darf kein Konto tragen: sie existiert
    -- nur in der Kalkulation. Umgekehrt ist ein Konto nicht Pflicht, solange
    -- keine Buchhaltung läuft.
    CONSTRAINT kostenart_kalk_ohne_konto
        CHECK (NOT kalkulatorisch OR konto_id IS NULL)
);

CREATE INDEX IF NOT EXISTS ix_kostenart_mandant ON kostenart (mandant_id, nummer);

-- ── 2. Kostenstellen ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS kostenstelle (
    kostenstelle_id serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    nummer          varchar(20) NOT NULL,
    bezeichnung     varchar(200) NOT NULL,

    -- 'vor'   = Hilfskostenstelle, wird auf andere umgelegt (Gebäude, Kantine)
    -- 'haupt' = trägt am Ende den Zuschlagssatz
    art             varchar(10) NOT NULL DEFAULT 'haupt'
                      CHECK (art IN ('vor', 'haupt')),

    -- Bestimmt, in welchen Zuschlagssatz die Stelle einfliesst. Genau die
    -- vier Blöcke der Zuschlagskalkulation.
    bereich         varchar(20) NOT NULL DEFAULT 'allgemein'
                      CHECK (bereich IN ('material', 'fertigung',
                                         'verwaltung', 'vertrieb', 'allgemein')),

    parent_id       integer REFERENCES kostenstelle(kostenstelle_id),
    raum_id         integer REFERENCES raum(raum_id),
    aktiv           boolean NOT NULL DEFAULT true,
    bemerkung       text,
    UNIQUE (mandant_id, nummer)
);

-- ── 3. Angefallene Kosten je Stelle, Art und Periode ───────────────────────
-- Das Rohmaterial des Betriebsabrechnungsbogens. `quelle` hält fest, woher
-- der Wert kam — von Hand erfasst, aus dem Lohnlauf, aus dem
-- Abschreibungsplan. Ohne das weiss später niemand, ob eine Zahl gepflegt
-- oder abgeleitet ist.
CREATE TABLE IF NOT EXISTS kostenstelle_wert (
    wert_id         serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    kostenstelle_id integer NOT NULL REFERENCES kostenstelle(kostenstelle_id),
    kostenart_id    integer NOT NULL REFERENCES kostenart(kostenart_id),
    jahr            smallint NOT NULL,
    -- NULL = Jahreswert. Sonst der Monat.
    monat           smallint CHECK (monat BETWEEN 1 AND 12),
    betrag          numeric(14,2) NOT NULL DEFAULT 0,
    quelle          varchar(20) NOT NULL DEFAULT 'manuell'
                      CHECK (quelle IN ('manuell', 'lohn', 'anlage', 'beleg',
                                        'umlage')),
    bemerkung       text
);

CREATE INDEX IF NOT EXISTS ix_kostenstelle_wert
    ON kostenstelle_wert (mandant_id, jahr, kostenstelle_id);

-- ── 4. Umlage der Vorkostenstellen ─────────────────────────────────────────
-- Die Hallenmiete fällt im "Gebäude" an, gehört aber anteilig in Fertigung,
-- Verwaltung und Vertrieb. Der Schlüssel dafür steht hier.
CREATE TABLE IF NOT EXISTS umlage (
    umlage_id       serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    von_kostenstelle_id integer NOT NULL REFERENCES kostenstelle(kostenstelle_id),
    auf_kostenstelle_id integer NOT NULL REFERENCES kostenstelle(kostenstelle_id),
    prozent         numeric(6,3) NOT NULL CHECK (prozent >= 0),
    gueltig_ab      date NOT NULL DEFAULT CURRENT_DATE,
    gueltig_bis     date,
    bemerkung       text,
    CONSTRAINT umlage_nicht_auf_sich_selbst
        CHECK (von_kostenstelle_id <> auf_kostenstelle_id)
);

-- ── 5. Zuschlagssätze — das Ergebnis, das in die Kalkulation geht ──────────
CREATE TABLE IF NOT EXISTS zuschlagssatz (
    satz_id         serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    jahr            smallint NOT NULL,
    bereich         varchar(20) NOT NULL
                      CHECK (bereich IN ('material', 'fertigung',
                                         'verwaltung', 'vertrieb')),
    prozent         numeric(8,3) NOT NULL DEFAULT 0,
    -- Wie der Satz zustande kam: die Gemeinkosten der Stellen dieses Bereichs
    -- geteilt durch die Bezugsgrösse.
    gemeinkosten    numeric(14,2),
    basis_betrag    numeric(14,2),
    ermittelt_am    timestamp,
    manuell         boolean NOT NULL DEFAULT false,
    bemerkung       text,
    UNIQUE (mandant_id, jahr, bereich)
);

COMMENT ON TABLE zuschlagssatz IS
    'Gemeinkostenzuschlaege je Bereich und Jahr. Entweder von Hand gesetzt '
    '(manuell=true) oder aus kostenstelle_wert ermittelt.';

-- ── 6. Umlage rechnen ──────────────────────────────────────────────────────
-- Verteilt die Kosten der Vorkostenstellen nach Schlüssel auf die Zielstellen
-- und schreibt das Ergebnis als Werte mit quelle='umlage' zurück.
--
-- EINSTUFIG, mit Absicht: Eine Vorkostenstelle, die auf eine andere
-- Vorkostenstelle umlegt, ergäbe ein Gleichungssystem (das
-- Gleichungsverfahren). Das ist für einen Betrieb dieser Grösse überzogen;
-- stattdessen wird geprüft und gemeldet, falls jemand so einen Schlüssel
-- anlegt.
CREATE OR REPLACE FUNCTION fn_umlage_rechnen(
    p_mandant_id integer, p_jahr integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_u record;
    v_summe numeric(14,2);
    v_anzahl integer := 0;
    v_kette integer;
BEGIN
    -- Frühere Umlagen desselben Jahres verwerfen, sonst summiert sich jeder
    -- Lauf auf den vorherigen drauf.
    DELETE FROM kostenstelle_wert
     WHERE mandant_id = p_mandant_id AND jahr = p_jahr AND quelle = 'umlage';

    SELECT count(*) INTO v_kette
      FROM umlage u
      JOIN kostenstelle z ON z.kostenstelle_id = u.auf_kostenstelle_id
     WHERE u.mandant_id = p_mandant_id AND z.art = 'vor';
    IF v_kette > 0 THEN
        RAISE EXCEPTION 'Umlage von einer Vorkostenstelle auf eine andere '
            'wird nicht unterstuetzt (% Schluessel betroffen). Bitte direkt '
            'auf Hauptkostenstellen umlegen.', v_kette;
    END IF;

    FOR v_u IN
        SELECT u.*, k.bereich
          FROM umlage u
          JOIN kostenstelle k ON k.kostenstelle_id = u.auf_kostenstelle_id
         WHERE u.mandant_id = p_mandant_id
           AND u.gueltig_ab <= make_date(p_jahr, 12, 31)
           AND (u.gueltig_bis IS NULL OR u.gueltig_bis >= make_date(p_jahr, 1, 1))
    LOOP
        -- Was auf der Vorkostenstelle liegt (ohne bereits umgelegte Beträge)
        SELECT COALESCE(SUM(betrag), 0) INTO v_summe
          FROM kostenstelle_wert
         WHERE mandant_id = p_mandant_id AND jahr = p_jahr
           AND kostenstelle_id = v_u.von_kostenstelle_id
           AND quelle <> 'umlage';

        CONTINUE WHEN v_summe = 0;

        INSERT INTO kostenstelle_wert (mandant_id, kostenstelle_id,
            kostenart_id, jahr, betrag, quelle, bemerkung)
        SELECT p_mandant_id, v_u.auf_kostenstelle_id,
               -- Die Kostenart der Umlage: die häufigste der Quellstelle,
               -- damit die Zeile nicht ohne Art dasteht.
               (SELECT kostenart_id FROM kostenstelle_wert
                 WHERE mandant_id = p_mandant_id AND jahr = p_jahr
                   AND kostenstelle_id = v_u.von_kostenstelle_id
                 GROUP BY kostenart_id ORDER BY SUM(betrag) DESC LIMIT 1),
               p_jahr,
               ROUND(v_summe * v_u.prozent / 100.0, 2),
               'umlage',
               'Umlage von Kostenstelle ' || v_u.von_kostenstelle_id ||
               ' (' || v_u.prozent || ' %)';

        v_anzahl := v_anzahl + 1;
    END LOOP;

    RETURN v_anzahl;
END;
$$;

-- ── 7. Zuschlagssätze ermitteln ────────────────────────────────────────────
-- Gemeinkosten eines Bereichs geteilt durch seine Bezugsgrösse:
--   Material    → auf die Materialeinzelkosten
--   Fertigung   → auf die Fertigungslöhne
--   Verwaltung  → auf die Herstellkosten
--   Vertrieb    → auf die Herstellkosten
--
-- Die Bezugsgrössen kommen als Parameter, weil sie aus der Buchhaltung oder
-- der Nachkalkulation des Vorjahres stammen — die es hier noch nicht gibt.
-- Wer nichts übergibt, bekommt für den Bereich keinen Satz statt einer
-- Division durch null.
CREATE OR REPLACE FUNCTION fn_zuschlagssaetze_ermitteln(
    p_mandant_id integer, p_jahr integer,
    p_materialeinzelkosten numeric DEFAULT NULL,
    p_fertigungsloehne numeric DEFAULT NULL,
    p_herstellkosten numeric DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_bereich text;
    v_gk numeric(14,2);
    v_basis numeric(14,2);
    v_anzahl integer := 0;
BEGIN
    FOREACH v_bereich IN ARRAY ARRAY['material', 'fertigung', 'verwaltung',
                                     'vertrieb']
    LOOP
        SELECT COALESCE(SUM(w.betrag), 0) INTO v_gk
          FROM kostenstelle_wert w
          JOIN kostenstelle k ON k.kostenstelle_id = w.kostenstelle_id
          JOIN kostenart a ON a.kostenart_id = w.kostenart_id
         WHERE w.mandant_id = p_mandant_id AND w.jahr = p_jahr
           AND k.bereich = v_bereich AND k.art = 'haupt'
           -- Einzelkosten gehören direkt auf den Auftrag, nicht in den
           -- Zuschlag — sonst würden sie doppelt verrechnet.
           AND a.typ = 'gemein';

        v_basis := CASE v_bereich
                     WHEN 'material'   THEN p_materialeinzelkosten
                     WHEN 'fertigung'  THEN p_fertigungsloehne
                     ELSE p_herstellkosten
                   END;

        CONTINUE WHEN v_basis IS NULL OR v_basis <= 0;

        INSERT INTO zuschlagssatz (mandant_id, jahr, bereich, prozent,
            gemeinkosten, basis_betrag, ermittelt_am, manuell)
        VALUES (p_mandant_id, p_jahr, v_bereich,
                ROUND(v_gk / v_basis * 100, 3), v_gk, v_basis, now(), false)
        ON CONFLICT (mandant_id, jahr, bereich) DO UPDATE SET
            prozent = EXCLUDED.prozent,
            gemeinkosten = EXCLUDED.gemeinkosten,
            basis_betrag = EXCLUDED.basis_betrag,
            ermittelt_am = now(),
            manuell = false
        -- Von Hand gesetzte Sätze werden nicht überschrieben
        WHERE zuschlagssatz.manuell = false;

        v_anzahl := v_anzahl + 1;
    END LOOP;

    RETURN v_anzahl;
END;
$$;

-- ── 8. Kosten aus dem Abschreibungsplan übernehmen ─────────────────────────
-- Schlägt die Brücke von Punkt 2 hierher: Die kalkulatorischen Kosten einer
-- Anlage landen auf der Kostenstelle, in deren Raum sie steht.
CREATE OR REPLACE FUNCTION fn_anlagekosten_uebernehmen(
    p_mandant_id integer, p_jahr integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_art_abschr integer;
    v_art_zins integer;
    v_anzahl integer := 0;
BEGIN
    SELECT kostenart_id INTO v_art_abschr FROM kostenart
     WHERE mandant_id = p_mandant_id AND nummer = 'K800';
    SELECT kostenart_id INTO v_art_zins FROM kostenart
     WHERE mandant_id = p_mandant_id AND nummer = 'K810';
    IF v_art_abschr IS NULL OR v_art_zins IS NULL THEN
        RAISE EXCEPTION 'Die kalkulatorischen Kostenarten K800/K810 fehlen - '
            'bitte zuerst fn_kostenarten_standard aufrufen.';
    END IF;

    DELETE FROM kostenstelle_wert
     WHERE mandant_id = p_mandant_id AND jahr = p_jahr AND quelle = 'anlage';

    INSERT INTO kostenstelle_wert (mandant_id, kostenstelle_id, kostenart_id,
        jahr, betrag, quelle, bemerkung)
    SELECT p_mandant_id, ks.kostenstelle_id, v_art_abschr, p_jahr,
           SUM(ab.abschreibung_kalk), 'anlage',
           'Kalkulatorische Abschreibung aus dem Anlagenplan'
      FROM anlage a
      JOIN anlage_abschreibung ab ON ab.anlage_id = a.anlage_id
      JOIN kostenstelle ks ON ks.raum_id = a.raum_id
                          AND ks.mandant_id = a.mandant_id
     WHERE a.mandant_id = p_mandant_id AND ab.jahr = p_jahr AND a.aktiv
     GROUP BY ks.kostenstelle_id
    HAVING SUM(ab.abschreibung_kalk) > 0;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;

    INSERT INTO kostenstelle_wert (mandant_id, kostenstelle_id, kostenart_id,
        jahr, betrag, quelle, bemerkung)
    SELECT p_mandant_id, ks.kostenstelle_id, v_art_zins, p_jahr,
           SUM(ab.kalk_zins), 'anlage',
           'Kalkulatorischer Zins auf gebundenes Kapital'
      FROM anlage a
      JOIN anlage_abschreibung ab ON ab.anlage_id = a.anlage_id
      JOIN kostenstelle ks ON ks.raum_id = a.raum_id
                          AND ks.mandant_id = a.mandant_id
     WHERE a.mandant_id = p_mandant_id AND ab.jahr = p_jahr AND a.aktiv
     GROUP BY ks.kostenstelle_id
    HAVING SUM(ab.kalk_zins) > 0;

    RETURN v_anzahl;
END;
$$;

-- ── 9. Standard-Kostenarten und -stellen ───────────────────────────────────
-- Bildet die Liste aus dem Kalkulationskonzept ab. Idempotent.
CREATE OR REPLACE FUNCTION fn_kostenarten_standard(p_mandant_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_z record;
    v_anzahl integer := 0;
BEGIN
    FOR v_z IN
        SELECT * FROM (VALUES
        -- nummer, bezeichnung, typ, verhalten, var%, konto, kalkulatorisch
        ('K100', 'Materialkosten',              'einzel', 'variabel', 100, '4000', false),
        ('K110', 'Hilfs- und Betriebsstoffe',   'gemein', 'variabel', 100, '4000', false),
        ('K120', 'Fremdleistungen',             'einzel', 'variabel', 100, '4400', false),
        ('K200', 'Fertigungsloehne',            'einzel', 'variabel', 100, '5000', false),
        ('K210', 'Gehaelter',                   'gemein', 'fix',        0, '5000', false),
        ('K220', 'Sozialleistungen',            'gemein', 'gemischt',  50, '5700', false),
        ('K230', 'Honorare Dritter',            'gemein', 'variabel', 100, '5900', false),
        ('K300', 'Raumkosten / Miete',          'gemein', 'fix',        0, '6000', false),
        ('K310', 'Unterhalt und Reparaturen',   'gemein', 'gemischt',  40, '6100', false),
        ('K320', 'Energie und Entsorgung',      'gemein', 'gemischt',  70, '6400', false),
        ('K330', 'Versicherungen und Abgaben',  'gemein', 'fix',        0, '6300', false),
        ('K340', 'Fahrzeugkosten',              'gemein', 'gemischt',  60, '6200', false),
        ('K350', 'Verwaltungskosten',           'gemein', 'fix',        0, '6500', false),
        ('K360', 'Softwarelizenzen',            'gemein', 'fix',        0, '6570', false),
        ('K370', 'Werbung und Vertrieb',        'gemein', 'fix',        0, '6600', false),
        ('K380', 'Entwicklungskosten',          'gemein', 'fix',        0, '6700', false),
        ('K400', 'Abschreibungen (bilanziell)', 'gemein', 'fix',        0, '6800', false),
        -- Ab hier ohne Konto: existiert nur in der Kalkulation
        ('K800', 'Kalk. Abschreibung',          'gemein', 'fix',        0, NULL,   true),
        ('K810', 'Kalk. Zinsen',                'gemein', 'fix',        0, NULL,   true),
        ('K820', 'Kalk. Wagnis',                'gemein', 'variabel', 100, NULL,   true),
        ('K830', 'Kalk. Unternehmerlohn',       'gemein', 'fix',        0, NULL,   true)
        ) AS t(nummer, bez, typ, verhalten, var, konto, kalk)
    LOOP
        INSERT INTO kostenart (mandant_id, nummer, bezeichnung, typ, verhalten,
            variabler_anteil_prozent, konto_id, kalkulatorisch)
        SELECT p_mandant_id, v_z.nummer, v_z.bez, v_z.typ, v_z.verhalten,
               CASE WHEN v_z.verhalten = 'gemischt' THEN v_z.var ELSE 0 END,
               CASE WHEN v_z.kalk THEN NULL
                    ELSE fn_konto_id(p_mandant_id, v_z.konto) END,
               v_z.kalk
        WHERE NOT EXISTS (SELECT 1 FROM kostenart k
                           WHERE k.mandant_id = p_mandant_id
                             AND k.nummer = v_z.nummer);
        IF FOUND THEN v_anzahl := v_anzahl + 1; END IF;
    END LOOP;

    FOR v_z IN
        SELECT * FROM (VALUES
        ('900', 'Gebaeude und Allgemeines', 'vor',   'allgemein'),
        ('100', 'Material und Einkauf',     'haupt', 'material'),
        ('200', 'Fertigung',                'haupt', 'fertigung'),
        ('210', 'Maschinen',                'haupt', 'fertigung'),
        ('300', 'Verwaltung',               'haupt', 'verwaltung'),
        ('400', 'Vertrieb',                 'haupt', 'vertrieb')
        ) AS t(nummer, bez, art, bereich)
    LOOP
        INSERT INTO kostenstelle (mandant_id, nummer, bezeichnung, art, bereich)
        SELECT p_mandant_id, v_z.nummer, v_z.bez, v_z.art, v_z.bereich
        WHERE NOT EXISTS (SELECT 1 FROM kostenstelle k
                           WHERE k.mandant_id = p_mandant_id
                             AND k.nummer = v_z.nummer);
        IF FOUND THEN v_anzahl := v_anzahl + 1; END IF;
    END LOOP;

    RETURN v_anzahl;
END;
$$;

-- ── 10. Betriebsabrechnungsbogen als Sicht ─────────────────────────────────
CREATE OR REPLACE VIEW v_bab AS
SELECT w.mandant_id, w.jahr,
       ks.nummer AS kostenstelle_nr, ks.bezeichnung AS kostenstelle,
       ks.art, ks.bereich,
       ka.nummer AS kostenart_nr, ka.bezeichnung AS kostenart,
       ka.typ, ka.verhalten, ka.kalkulatorisch,
       w.quelle, SUM(w.betrag) AS betrag,
       -- Aufteilung nach Verhalten: was geht mit der Menge mit, was nicht
       SUM(CASE ka.verhalten
             WHEN 'variabel' THEN w.betrag
             WHEN 'gemischt' THEN w.betrag * ka.variabler_anteil_prozent / 100
             ELSE 0 END) AS variabel_anteil,
       SUM(CASE ka.verhalten
             WHEN 'fix' THEN w.betrag
             WHEN 'gemischt' THEN w.betrag * (100 - ka.variabler_anteil_prozent) / 100
             ELSE 0 END) AS fix_anteil
  FROM kostenstelle_wert w
  JOIN kostenstelle ks ON ks.kostenstelle_id = w.kostenstelle_id
  JOIN kostenart ka ON ka.kostenart_id = w.kostenart_id
 GROUP BY w.mandant_id, w.jahr, ks.nummer, ks.bezeichnung, ks.art, ks.bereich,
          ka.nummer, ka.bezeichnung, ka.typ, ka.verhalten, ka.kalkulatorisch,
          w.quelle;
