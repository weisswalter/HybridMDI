-- ============================================================================
-- Buchhaltung: Journal und Buchungen — Stand 02.08.2026
--
-- Walters Vorgabe: "Rechnungen und Einnahmen koennten dann gleich in passende
-- Konten gebucht werden."
--
-- DIE TRAGENDE REGEL: Je Buchung muss die Summe im Soll gleich der Summe im
-- Haben sein. Sie steht hier als DEFERRED CONSTRAINT TRIGGER, nicht nur in
-- der Anwendung — sonst haengt die Richtigkeit der Buchhaltung daran, dass
-- jedes Formular korrekt programmiert ist. Deferred, weil eine Buchung erst
-- am Ende der Transaktion vollstaendig ist: Kopf und Zeilen entstehen
-- nacheinander.
--
-- WARUM ZEILEN UND NICHT "KONTO/GEGENKONTO": Zwei Felder reichen nur fuer den
-- einfachen Fall. Eine Lohnbuchung hat einen Aufwand und drei
-- Gegenbuchungen — mit einem Feldpaar nicht abbildbar. Das Feldpaar bleibt
-- als Erfassungshilfe fuer den Zweizeilenfall sinnvoll (fn_buchung_einfach).
--
-- KEIN LOESCHEN, NUR STORNIEREN: Eine festgeschriebene Buchung wird nie
-- veraendert. Wer korrigieren will, storniert und bucht neu. Alles andere ist
-- nicht revisionssicher.
-- ============================================================================

-- ── 1. Kontierung an den Stammdaten ────────────────────────────────────────
-- Damit "gleich ins passende Konto" gebucht wird, muss die Zuordnung an den
-- Stammdaten haengen und nicht im Programmcode. kostenart.konto_id und die
-- beiden Konten an der Anlage gibt es schon; hier kommt die Erloesseite dazu.
ALTER TABLE rechnungstyp ADD COLUMN IF NOT EXISTS erloes_konto_id integer
    REFERENCES konto(konto_id);
ALTER TABLE rechnungstyp ADD COLUMN IF NOT EXISTS aufwand_konto_id integer
    REFERENCES konto(konto_id);
ALTER TABLE artikel ADD COLUMN IF NOT EXISTS erloes_konto_id integer
    REFERENCES konto(konto_id);
ALTER TABLE artikel ADD COLUMN IF NOT EXISTS aufwand_konto_id integer
    REFERENCES konto(konto_id);
ALTER TABLE leistung ADD COLUMN IF NOT EXISTS erloes_konto_id integer
    REFERENCES konto(konto_id);

COMMENT ON COLUMN rechnungstyp.erloes_konto_id IS
    'Erloeskonto fuer ausgehende Belege dieses Typs. Der Artikel kann es je '
    'Position uebersteuern.';

-- ── 2. Steuersaetze ────────────────────────────────────────────────────────
-- Als Daten, nicht als Konstanten: Saetze aendern, und die Arbeitsagogik hat
-- teilweise ausgenommene Leistungen.
CREATE TABLE IF NOT EXISTS steuer_code (
    steuer_code_id  serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    code            varchar(20) NOT NULL,
    bezeichnung     varchar(150) NOT NULL,
    satz            numeric(5,2) NOT NULL DEFAULT 0,
    richtung        varchar(10) NOT NULL
                      CHECK (richtung IN ('umsatz', 'vorsteuer', 'keine')),
    konto_id        integer REFERENCES konto(konto_id),  -- 2200 bzw. 1170
    gueltig_ab      date NOT NULL DEFAULT '2026-01-01',
    gueltig_bis     date,
    aktiv           boolean NOT NULL DEFAULT true,
    bemerkung       text,
    UNIQUE (mandant_id, code, gueltig_ab)
);

-- ── 3. Buchung ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS buchung (
    buchung_id      serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    buchungsnummer  varchar(30),
    datum           date NOT NULL DEFAULT CURRENT_DATE,
    -- Wertstellung: kann vom Buchungsdatum abweichen (Bankauszug)
    valuta          date,
    jahr            smallint NOT NULL,
    monat           smallint NOT NULL CHECK (monat BETWEEN 1 AND 12),
    buchungstext    varchar(300) NOT NULL,

    beleg_nr        varchar(50),
    beleg_datum     date,

    -- Woraus die Buchung entstanden ist. Damit laesst sich jederzeit
    -- zurueckverfolgen, und eine Automatik erkennt, was sie schon gebucht hat.
    quelle          varchar(20) NOT NULL DEFAULT 'manuell'
                      CHECK (quelle IN ('manuell', 'rechnung', 'lohn',
                                        'abschreibung', 'bank', 'zuwendung',
                                        'storno')),
    quelle_id       integer,

    -- Storno: zeigt auf die Buchung, die hiermit aufgehoben wird
    storniert_buchung_id integer REFERENCES buchung(buchung_id),
    -- Ist ueber `festgeschrieben` hinaus unveraenderlich
    festgeschrieben boolean NOT NULL DEFAULT false,
    festgeschrieben_am timestamp,
    erfasst_von_person_id integer REFERENCES person(person_id),
    created_at      timestamp NOT NULL DEFAULT now(),
    UNIQUE (mandant_id, buchungsnummer)
);

CREATE INDEX IF NOT EXISTS ix_buchung_periode
    ON buchung (mandant_id, jahr, monat, datum);
CREATE INDEX IF NOT EXISTS ix_buchung_quelle
    ON buchung (quelle, quelle_id) WHERE quelle <> 'manuell';

CREATE TABLE IF NOT EXISTS buchung_zeile (
    zeile_id        serial PRIMARY KEY,
    buchung_id      integer NOT NULL
                      REFERENCES buchung(buchung_id) ON DELETE CASCADE,
    reihenfolge     smallint NOT NULL DEFAULT 0,
    konto_id        integer NOT NULL REFERENCES konto(konto_id),
    -- Eine Zeile steht entweder im Soll oder im Haben, nie in beidem.
    soll            numeric(14,2) NOT NULL DEFAULT 0 CHECK (soll >= 0),
    haben           numeric(14,2) NOT NULL DEFAULT 0 CHECK (haben >= 0),
    kostenstelle_id integer REFERENCES kostenstelle(kostenstelle_id),
    steuer_code_id  integer REFERENCES steuer_code(steuer_code_id),
    steuer_betrag   numeric(14,2) NOT NULL DEFAULT 0,
    zeilentext      varchar(300),
    CONSTRAINT buchung_zeile_eine_seite
        CHECK ((soll = 0) <> (haben = 0)),
    CONSTRAINT buchung_zeile_nicht_null
        CHECK (soll + haben > 0)
);

CREATE INDEX IF NOT EXISTS ix_buchung_zeile_buchung
    ON buchung_zeile (buchung_id, reihenfolge);
CREATE INDEX IF NOT EXISTS ix_buchung_zeile_konto
    ON buchung_zeile (konto_id);

-- Der Beleg zur Buchung — schliesst den Kreis zur Belegpflicht
CREATE TABLE IF NOT EXISTS buchung_dokument (
    buchung_id  integer NOT NULL REFERENCES buchung(buchung_id) ON DELETE CASCADE,
    dokument_id integer NOT NULL REFERENCES dokument(dokument_id),
    PRIMARY KEY (buchung_id, dokument_id)
);

-- ── 4. Soll = Haben, erzwungen ─────────────────────────────────────────────
-- DEFERRED: Kopf und Zeilen entstehen nacheinander; geprueft wird erst am
-- Ende der Transaktion, wenn die Buchung vollstaendig ist.
--
-- Eine Buchung ganz OHNE Zeilen ist erlaubt (sie entsteht so, bevor die
-- Zeilen kommen) — nur eine unausgeglichene ist es nicht.
CREATE OR REPLACE FUNCTION fn_buchung_pruefen()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_buchung integer;
    v_soll numeric(14,2);
    v_haben numeric(14,2);
BEGIN
    v_buchung := COALESCE(NEW.buchung_id, OLD.buchung_id);

    SELECT COALESCE(SUM(soll), 0), COALESCE(SUM(haben), 0)
      INTO v_soll, v_haben
      FROM buchung_zeile WHERE buchung_id = v_buchung;

    IF v_soll = 0 AND v_haben = 0 THEN
        RETURN NULL;      -- noch keine Zeilen
    END IF;

    IF v_soll <> v_haben THEN
        RAISE EXCEPTION 'Buchung % ist nicht ausgeglichen: Soll % / Haben % '
            '(Differenz %).', v_buchung, v_soll, v_haben, v_soll - v_haben;
    END IF;
    RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS tr_buchung_zeile_pruefen ON buchung_zeile;
CREATE CONSTRAINT TRIGGER tr_buchung_zeile_pruefen
    AFTER INSERT OR UPDATE OR DELETE ON buchung_zeile
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fn_buchung_pruefen();

-- Festgeschriebene Buchungen sind unveraenderlich. Das ist der Kern der
-- Revisionssicherheit — deshalb in der Datenbank und nicht in der Anwendung.
CREATE OR REPLACE FUNCTION fn_buchung_schutz()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_fest boolean;
BEGIN
    IF TG_TABLE_NAME = 'buchung' THEN
        IF TG_OP = 'UPDATE' AND OLD.festgeschrieben
           -- Das Festschreiben selbst und ein spaeterer Storno-Verweis
           -- muessen moeglich bleiben.
           AND (NEW.festgeschrieben IS DISTINCT FROM OLD.festgeschrieben
                OR NEW.storniert_buchung_id IS DISTINCT FROM OLD.storniert_buchung_id)
        THEN
            RETURN NEW;
        END IF;
        IF OLD.festgeschrieben THEN
            RAISE EXCEPTION 'Buchung % ist festgeschrieben und kann nicht '
                'mehr geaendert oder geloescht werden. Bitte stornieren.',
                OLD.buchung_id;
        END IF;
        RETURN COALESCE(NEW, OLD);
    ELSE
        SELECT festgeschrieben INTO v_fest FROM buchung
         WHERE buchung_id = COALESCE(NEW.buchung_id, OLD.buchung_id);
        IF v_fest THEN
            RAISE EXCEPTION 'Die Buchung ist festgeschrieben - ihre Zeilen '
                'koennen nicht mehr geaendert werden. Bitte stornieren.';
        END IF;
        RETURN COALESCE(NEW, OLD);
    END IF;
END;
$$;

DROP TRIGGER IF EXISTS tr_buchung_schutz ON buchung;
CREATE TRIGGER tr_buchung_schutz BEFORE UPDATE OR DELETE ON buchung
    FOR EACH ROW EXECUTE FUNCTION fn_buchung_schutz();
DROP TRIGGER IF EXISTS tr_buchung_zeile_schutz ON buchung_zeile;
CREATE TRIGGER tr_buchung_zeile_schutz
    BEFORE INSERT OR UPDATE OR DELETE ON buchung_zeile
    FOR EACH ROW EXECUTE FUNCTION fn_buchung_schutz();

-- ── 5. Buchungsnummer ──────────────────────────────────────────────────────
-- Fortlaufend je Mandant und Jahr. Eine Luecke waere in einer Buchhaltung
-- erklaerungsbeduerftig, deshalb wird die Nummer erst beim Festschreiben
-- vergeben — ein verworfener Entwurf reisst dann kein Loch.
CREATE OR REPLACE FUNCTION fn_buchungsnummer(p_mandant_id integer, p_jahr integer)
RETURNS varchar
LANGUAGE plpgsql AS $$
DECLARE v_nr integer;
BEGIN
    SELECT COALESCE(MAX(SUBSTRING(buchungsnummer FROM '[0-9]+$')::integer), 0) + 1
      INTO v_nr
      FROM buchung
     WHERE mandant_id = p_mandant_id AND jahr = p_jahr
       AND buchungsnummer IS NOT NULL;
    RETURN p_jahr::text || '-' || LPAD(v_nr::text, 6, '0');
END;
$$;

CREATE OR REPLACE FUNCTION fn_buchung_festschreiben(p_buchung_id integer)
RETURNS varchar
LANGUAGE plpgsql AS $$
DECLARE b buchung%ROWTYPE; v_nr varchar;
BEGIN
    SELECT * INTO b FROM buchung WHERE buchung_id = p_buchung_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Buchung % gibt es nicht.', p_buchung_id;
    END IF;
    IF b.festgeschrieben THEN
        RETURN b.buchungsnummer;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM buchung_zeile WHERE buchung_id = p_buchung_id) THEN
        RAISE EXCEPTION 'Eine Buchung ohne Zeilen kann nicht festgeschrieben '
            'werden.';
    END IF;

    v_nr := COALESCE(b.buchungsnummer, fn_buchungsnummer(b.mandant_id, b.jahr));
    UPDATE buchung SET buchungsnummer = v_nr, festgeschrieben = true,
           festgeschrieben_am = now()
     WHERE buchung_id = p_buchung_id;
    RETURN v_nr;
END;
$$;

-- ── 6. Buchen ──────────────────────────────────────────────────────────────
-- Der einfache Fall: Konto an Gegenkonto. Genau das Feldpaar, das Walter
-- gemeint hat — als Erfassungshilfe, waehrend darunter Zeilen entstehen.
CREATE OR REPLACE FUNCTION fn_buchung_einfach(
    p_mandant_id integer, p_datum date, p_text varchar,
    p_soll_konto_id integer, p_haben_konto_id integer, p_betrag numeric,
    p_beleg_nr varchar DEFAULT NULL,
    p_kostenstelle_id integer DEFAULT NULL,
    p_quelle varchar DEFAULT 'manuell', p_quelle_id integer DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    IF p_betrag <= 0 THEN
        RAISE EXCEPTION 'Der Betrag muss groesser als null sein.';
    END IF;
    IF p_soll_konto_id = p_haben_konto_id THEN
        RAISE EXCEPTION 'Soll- und Habenkonto duerfen nicht dasselbe sein.';
    END IF;

    INSERT INTO buchung (mandant_id, datum, jahr, monat, buchungstext,
        beleg_nr, quelle, quelle_id)
    VALUES (p_mandant_id, p_datum, EXTRACT(YEAR FROM p_datum),
        EXTRACT(MONTH FROM p_datum), p_text, p_beleg_nr, p_quelle, p_quelle_id)
    RETURNING buchung_id INTO v_id;

    INSERT INTO buchung_zeile (buchung_id, reihenfolge, konto_id, soll, haben,
                               kostenstelle_id, zeilentext)
    VALUES (v_id, 1, p_soll_konto_id, p_betrag, 0, p_kostenstelle_id, p_text),
           (v_id, 2, p_haben_konto_id, 0, p_betrag, p_kostenstelle_id, p_text);

    RETURN v_id;
END;
$$;

-- Storno: erzeugt die spiegelbildliche Buchung. Die ursprüngliche bleibt
-- unangetastet stehen — das ist der Sinn.
CREATE OR REPLACE FUNCTION fn_buchung_stornieren(
    p_buchung_id integer, p_datum date DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    b buchung%ROWTYPE;
    v_neu integer;
    v_datum date;
BEGIN
    SELECT * INTO b FROM buchung WHERE buchung_id = p_buchung_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Buchung % gibt es nicht.', p_buchung_id;
    END IF;
    IF EXISTS (SELECT 1 FROM buchung
                WHERE storniert_buchung_id = p_buchung_id) THEN
        RAISE EXCEPTION 'Buchung % wurde bereits storniert.', p_buchung_id;
    END IF;

    v_datum := COALESCE(p_datum, CURRENT_DATE);

    INSERT INTO buchung (mandant_id, datum, jahr, monat, buchungstext,
        beleg_nr, beleg_datum, quelle, quelle_id, storniert_buchung_id)
    VALUES (b.mandant_id, v_datum, EXTRACT(YEAR FROM v_datum),
        EXTRACT(MONTH FROM v_datum),
        'STORNO: ' || b.buchungstext, b.beleg_nr, b.beleg_datum,
        'storno', p_buchung_id, p_buchung_id)
    RETURNING buchung_id INTO v_neu;

    -- Soll und Haben tauschen
    INSERT INTO buchung_zeile (buchung_id, reihenfolge, konto_id, soll, haben,
        kostenstelle_id, steuer_code_id, steuer_betrag, zeilentext)
    SELECT v_neu, reihenfolge, konto_id, haben, soll,
           kostenstelle_id, steuer_code_id, -steuer_betrag,
           'STORNO: ' || COALESCE(zeilentext, '')
      FROM buchung_zeile WHERE buchung_id = p_buchung_id;

    RETURN v_neu;
END;
$$;

-- ── 7. Automatik: Lohn ─────────────────────────────────────────────────────
-- Der Musterfall fuer mehrzeilige Buchungen:
--   5000 Lohnaufwand   an 1020 Bank               (netto)
--   5000 Lohnaufwand   an 2270 Sozialversicherung (Arbeitnehmerabzuege)
--   5700 AG-Beitraege  an 2270 Sozialversicherung (Arbeitgeberanteil)
-- Honorare laufen ueber 5900 statt 5000.
CREATE OR REPLACE FUNCTION fn_buchung_aus_lohn(p_periode_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    lp lohn_periode%ROWTYPE;
    v_id integer;
    v_aufwand integer; v_bank integer; v_soz integer; v_agk integer;
    v_rf smallint := 0;
BEGIN
    SELECT * INTO lp FROM lohn_periode WHERE periode_id = p_periode_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Lohnbeleg % gibt es nicht.', p_periode_id;
    END IF;
    IF lp.status = 'berechnet' THEN
        RAISE EXCEPTION 'Der Lohnbeleg ist erst berechnet. Bitte zuerst '
            'freigeben - sonst bucht man Zahlen, die sich noch aendern.';
    END IF;
    IF EXISTS (SELECT 1 FROM buchung WHERE quelle = 'lohn'
                AND quelle_id = p_periode_id
                AND NOT EXISTS (SELECT 1 FROM buchung s
                                 WHERE s.storniert_buchung_id = buchung.buchung_id))
    THEN
        RAISE EXCEPTION 'Fuer diesen Lohnbeleg gibt es bereits eine Buchung.';
    END IF;

    v_aufwand := fn_konto_id(lp.mandant_id,
                   CASE WHEN lp.lohnart = 'honorar' THEN '5900' ELSE '5000' END);
    v_bank    := fn_konto_id(lp.mandant_id, '1020');
    v_soz     := fn_konto_id(lp.mandant_id, '2270');
    v_agk     := fn_konto_id(lp.mandant_id, '5700');
    IF v_aufwand IS NULL OR v_bank IS NULL OR v_soz IS NULL THEN
        RAISE EXCEPTION 'Es fehlen Konten (5000/5900, 1020, 2270) - bitte '
            'zuerst den Kontenrahmen anlegen.';
    END IF;

    INSERT INTO buchung (mandant_id, datum, jahr, monat, buchungstext,
        quelle, quelle_id)
    VALUES (lp.mandant_id,
            (make_date(lp.jahr, lp.monat, 1) + interval '1 month - 1 day')::date,
            lp.jahr, lp.monat,
            'Lohn ' || lp.monat || '/' || lp.jahr || ' Person ' || lp.person_id,
            'lohn', p_periode_id)
    RETURNING buchung_id INTO v_id;

    -- Bruttolohn in den Aufwand
    v_rf := v_rf + 1;
    INSERT INTO buchung_zeile (buchung_id, reihenfolge, konto_id, soll, haben,
                               zeilentext)
    VALUES (v_id, v_rf, v_aufwand, lp.brutto, 0, 'Bruttolohn');

    -- Auszahlung
    IF lp.netto > 0 THEN
        v_rf := v_rf + 1;
        INSERT INTO buchung_zeile (buchung_id, reihenfolge, konto_id, soll,
                                   haben, zeilentext)
        VALUES (v_id, v_rf, v_bank, 0, lp.netto, 'Auszahlung netto');
    END IF;

    -- Einbehaltene Arbeitnehmerbeitraege
    IF lp.abzuege_an > 0 THEN
        v_rf := v_rf + 1;
        INSERT INTO buchung_zeile (buchung_id, reihenfolge, konto_id, soll,
                                   haben, zeilentext)
        VALUES (v_id, v_rf, v_soz, 0, lp.abzuege_an, 'Abzuege Arbeitnehmer');
    END IF;

    -- Arbeitgeberanteil: zusaetzlicher Aufwand, zusaetzliche Schuld
    IF lp.abzuege_ag > 0 AND v_agk IS NOT NULL THEN
        v_rf := v_rf + 1;
        INSERT INTO buchung_zeile (buchung_id, reihenfolge, konto_id, soll,
                                   haben, zeilentext)
        VALUES (v_id, v_rf, v_agk, lp.abzuege_ag, 0, 'Arbeitgeberbeitraege');
        v_rf := v_rf + 1;
        INSERT INTO buchung_zeile (buchung_id, reihenfolge, konto_id, soll,
                                   haben, zeilentext)
        VALUES (v_id, v_rf, v_soz, 0, lp.abzuege_ag, 'Arbeitgeberbeitraege');
    END IF;

    RETURN v_id;
END;
$$;

-- ── 8. Automatik: Abschreibungen ───────────────────────────────────────────
-- Nur die BILANZIELLE Reihe wird gebucht. Die kalkulatorische hat in der
-- Buchhaltung kein Gegenstueck — sie dort einzubuchen waere schlicht falsch.
CREATE OR REPLACE FUNCTION fn_buchung_aus_abschreibung(
    p_mandant_id integer, p_jahr integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_a record;
    v_id integer;
    v_anzahl integer := 0;
    v_aufwand integer;
BEGIN
    FOR v_a IN
        SELECT a.anlage_id, a.bezeichnung, a.konto_id, a.aufwand_konto_id,
               ab.abschreibung_bilanz
          FROM anlage a
          JOIN anlage_abschreibung ab ON ab.anlage_id = a.anlage_id
         WHERE a.mandant_id = p_mandant_id AND ab.jahr = p_jahr
           AND ab.abschreibung_bilanz > 0 AND a.aktiv
    LOOP
        CONTINUE WHEN EXISTS (
            SELECT 1 FROM buchung
             WHERE quelle = 'abschreibung' AND quelle_id = v_a.anlage_id
               AND jahr = p_jahr);

        v_aufwand := COALESCE(v_a.aufwand_konto_id,
                              fn_konto_id(p_mandant_id, '6800'));
        IF v_aufwand IS NULL OR v_a.konto_id IS NULL THEN
            CONTINUE;   -- ohne Konten nicht buchbar; erscheint in v_beleg_fehlt
        END IF;

        v_id := fn_buchung_einfach(p_mandant_id,
                  make_date(p_jahr, 12, 31),
                  'Abschreibung ' || v_a.bezeichnung,
                  v_aufwand, v_a.konto_id, v_a.abschreibung_bilanz,
                  NULL, NULL, 'abschreibung', v_a.anlage_id);
        UPDATE buchung SET quelle_id = v_a.anlage_id WHERE buchung_id = v_id;
        v_anzahl := v_anzahl + 1;
    END LOOP;
    RETURN v_anzahl;
END;
$$;

-- ── 9. Automatik: Ausgangsrechnung ─────────────────────────────────────────
-- Kontierung je Position: Artikel oder Leistung koennen ein eigenes
-- Erloeskonto tragen, sonst gilt das des Rechnungstyps. So landet der Erloes
-- ohne Zutun auf dem richtigen Konto.
CREATE OR REPLACE FUNCTION fn_buchung_aus_beleg(p_beleg_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    b beleg%ROWTYPE;
    v_id integer;
    v_debitor integer; v_summe numeric(14,2) := 0;
    v_p record; v_rf smallint := 1;
    v_richtung varchar(20);
BEGIN
    SELECT * INTO b FROM beleg WHERE beleg_id = p_beleg_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Beleg % gibt es nicht.', p_beleg_id;
    END IF;
    IF EXISTS (SELECT 1 FROM buchung WHERE quelle = 'rechnung'
                AND quelle_id = p_beleg_id) THEN
        RAISE EXCEPTION 'Fuer diesen Beleg gibt es bereits eine Buchung.';
    END IF;

    SELECT richtung INTO v_richtung FROM rechnungstyp
     WHERE mandant_id = b.mandant_id AND rechnungstyp_id = b.rechnungstyp_id;
    IF v_richtung IS DISTINCT FROM 'ausgehend' THEN
        RAISE EXCEPTION 'Bisher werden nur ausgehende Rechnungen gebucht '
            '(Richtung des Rechnungstyps: %).', COALESCE(v_richtung, '?');
    END IF;

    v_debitor := fn_konto_id(b.mandant_id, '1100');
    IF v_debitor IS NULL THEN
        RAISE EXCEPTION 'Das Konto 1100 (Forderungen) fehlt.';
    END IF;

    INSERT INTO buchung (mandant_id, datum, jahr, monat, buchungstext,
        beleg_nr, beleg_datum, quelle, quelle_id)
    VALUES (b.mandant_id, b.beleg_datum,
        EXTRACT(YEAR FROM b.beleg_datum), EXTRACT(MONTH FROM b.beleg_datum),
        'Rechnung ' || COALESCE(b.beleg_nr, b.beleg_id::text),
        b.beleg_nr, b.beleg_datum, 'rechnung', p_beleg_id)
    RETURNING buchung_id INTO v_id;

    FOR v_p IN
        SELECT bp.position_nr, bp.menge, bp.einzelpreis,
               COALESCE(bp.menge * bp.einzelpreis, 0) AS betrag,
               COALESCE(ar.erloes_konto_id, le.erloes_konto_id,
                        rt.erloes_konto_id,
                        fn_konto_id(b.mandant_id, '3400')) AS konto_id,
               COALESCE(ar.artikelname, le.bezeichnung, 'Position') AS text
          FROM beleg_position bp
          LEFT JOIN artikel ar ON ar.artikel_id = bp.artikel_id
          LEFT JOIN leistung le ON le.leistung_id = bp.leistung_id
          LEFT JOIN rechnungstyp rt ON rt.mandant_id = b.mandant_id
                                   AND rt.rechnungstyp_id = b.rechnungstyp_id
         WHERE bp.beleg_id = p_beleg_id
         ORDER BY bp.position_nr
    LOOP
        CONTINUE WHEN v_p.betrag = 0;
        IF v_p.konto_id IS NULL THEN
            RAISE EXCEPTION 'Fuer die Position "%" ist kein Erloeskonto '
                'hinterlegt - weder am Artikel/der Leistung noch am '
                'Rechnungstyp, und 3400 fehlt.', v_p.text;
        END IF;
        v_rf := v_rf + 1;
        INSERT INTO buchung_zeile (buchung_id, reihenfolge, konto_id, soll,
                                   haben, zeilentext)
        VALUES (v_id, v_rf, v_p.konto_id, 0, v_p.betrag, v_p.text);
        v_summe := v_summe + v_p.betrag;
    END LOOP;

    IF v_summe = 0 THEN
        RAISE EXCEPTION 'Der Beleg hat keine Positionen mit Betrag.';
    END IF;

    -- Die Forderung als Gegenbuchung, an den Anfang
    INSERT INTO buchung_zeile (buchung_id, reihenfolge, konto_id, soll, haben,
                               zeilentext)
    VALUES (v_id, 1, v_debitor, v_summe, 0, 'Forderung');

    RETURN v_id;
END;
$$;

-- ── 10. Auswertungen ───────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_journal AS
SELECT b.mandant_id, b.buchung_id, b.buchungsnummer, b.datum, b.jahr, b.monat,
       b.buchungstext, b.beleg_nr, b.quelle, b.festgeschrieben,
       z.reihenfolge, k.nummer AS konto, k.bezeichnung AS kontobezeichnung,
       z.soll, z.haben, z.zeilentext,
       ks.nummer AS kostenstelle,
       (b.storniert_buchung_id IS NOT NULL) AS ist_storno,
       EXISTS (SELECT 1 FROM buchung s
                WHERE s.storniert_buchung_id = b.buchung_id) AS wurde_storniert
  FROM buchung b
  JOIN buchung_zeile z ON z.buchung_id = b.buchung_id
  JOIN konto k ON k.konto_id = z.konto_id
  LEFT JOIN kostenstelle ks ON ks.kostenstelle_id = z.kostenstelle_id;

-- Saldenliste: Grundlage von Bilanz und Erfolgsrechnung.
-- Die Mehrungsseite haengt am Kontotyp — deshalb das CASE.
CREATE OR REPLACE VIEW v_saldenliste AS
SELECT k.mandant_id, k.konto_id, k.nummer, k.bezeichnung, k.typ,
       b.jahr,
       COALESCE(SUM(z.soll), 0) AS summe_soll,
       COALESCE(SUM(z.haben), 0) AS summe_haben,
       CASE WHEN k.typ IN ('aktiv', 'aufwand')
            THEN COALESCE(SUM(z.soll), 0) - COALESCE(SUM(z.haben), 0)
            ELSE COALESCE(SUM(z.haben), 0) - COALESCE(SUM(z.soll), 0)
       END AS saldo
  FROM konto k
  LEFT JOIN buchung_zeile z ON z.konto_id = k.konto_id
  LEFT JOIN buchung b ON b.buchung_id = z.buchung_id
 WHERE NOT k.ist_sammelkonto
 GROUP BY k.mandant_id, k.konto_id, k.nummer, k.bezeichnung, k.typ, b.jahr;

CREATE OR REPLACE VIEW v_erfolgsrechnung AS
SELECT mandant_id, jahr, typ, nummer, bezeichnung, saldo
  FROM v_saldenliste
 WHERE typ IN ('aufwand', 'ertrag') AND jahr IS NOT NULL AND saldo <> 0;

CREATE OR REPLACE VIEW v_bilanz AS
SELECT mandant_id, jahr, typ, nummer, bezeichnung, saldo
  FROM v_saldenliste
 WHERE typ IN ('aktiv', 'passiv') AND jahr IS NOT NULL AND saldo <> 0;

-- Das Ergebnis in einer Zahl — und zugleich die Probe, ob die Buchhaltung
-- in sich stimmt.
CREATE OR REPLACE FUNCTION fn_erfolg(p_mandant_id integer, p_jahr integer)
RETURNS TABLE (ertrag numeric, aufwand numeric, gewinn numeric)
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(saldo) FILTER (WHERE typ = 'ertrag'), 0),
           COALESCE(SUM(saldo) FILTER (WHERE typ = 'aufwand'), 0),
           COALESCE(SUM(saldo) FILTER (WHERE typ = 'ertrag'), 0)
         - COALESCE(SUM(saldo) FILTER (WHERE typ = 'aufwand'), 0)
      FROM v_saldenliste
     WHERE mandant_id = p_mandant_id AND jahr = p_jahr;
$$;
