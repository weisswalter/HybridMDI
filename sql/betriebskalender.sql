-- ============================================================================
-- Betriebskalender — Stand 28.07.2026
--
-- Grundlage fuer die Zeiterfassung (Soll-Stunden) und fuer die grafische
-- Belegungsansicht (geschlossene Zeiten schattieren).
--
-- DREI EBENEN, bewusst getrennt:
--   betriebszeit      = die REGEL   (Mo-Fr 08:00-12:00 / 13:00-17:00)
--   feiertag          = die LANDES-/KANTONS-Ausnahme (poolweit, ohne mandant_id
--                       — genau wie `adresse`, weil ein Feiertag eine
--                       geografische Tatsache ist, keine Firmenentscheidung)
--   betriebs_ausnahme = die FIRMEN-Ausnahme (Betriebsferien, Sonderoeffnung)
--
-- Wiederverwendet: mandant, adresse, land, bezirk.
--
-- BEWUSST KEIN Constraint, der Termine in die Betriebszeit zwingt. Sonder-
-- veranstaltungen und Ueberstunden gibt es immer — die Anwendung warnt,
-- die DB verbietet nicht.
-- ============================================================================

-- ── 1. Regulaere Betriebszeiten ────────────────────────────────────────────
-- MEHRERE Zeilen pro Wochentag sind erlaubt und erwuenscht: Vormittag und
-- Nachmittag als zwei Zeilen, dazwischen faellt die Mittagspause automatisch
-- heraus. Deshalb KEIN UNIQUE auf (mandant, adresse, wochentag).
--
-- adresse_id NULL = gilt fuer alle Standorte des Mandanten. Existiert fuer
-- einen Standort mindestens eine eigene Zeile, gelten NUR diese (siehe
-- fn_betriebszeit_minuten) — Standortregeln ueberschreiben die Grundregel
-- vollstaendig, statt sich mit ihr zu vermischen.
CREATE TABLE IF NOT EXISTS betriebszeit (
    betriebszeit_id serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    adresse_id      integer REFERENCES adresse(adresse_id),
    -- ISO-Wochentag: 1 = Montag ... 7 = Sonntag (passt zu extract(isodow))
    wochentag       smallint NOT NULL CHECK (wochentag BETWEEN 1 AND 7),
    von_zeit        time NOT NULL,
    bis_zeit        time NOT NULL,
    -- Zeiten aendern sich (Sommer-/Winterbetrieb, neue Regelung ab Jahreswechsel).
    -- Historie bleibt erhalten, damit alte Soll-Stunden nachvollziehbar sind.
    gueltig_ab      date NOT NULL DEFAULT CURRENT_DATE,
    gueltig_bis     date,
    bezeichnung     varchar(100),
    CHECK (bis_zeit > von_zeit),
    CHECK (gueltig_bis IS NULL OR gueltig_bis >= gueltig_ab)
);

CREATE INDEX IF NOT EXISTS ix_betriebszeit_mandant
    ON betriebszeit (mandant_id, wochentag);

-- ── 2. Feiertage ───────────────────────────────────────────────────────────
-- POOLWEIT ohne mandant_id: der 1. August gilt fuer jeden Mandanten in der
-- Schweiz gleichermassen. Kantonale Unterschiede ueber bezirk_id
-- (St. Gallen != Zuerich), bezirk_id NULL = landesweit.
CREATE TABLE IF NOT EXISTS feiertag (
    feiertag_id     serial PRIMARY KEY,
    land_id         integer NOT NULL REFERENCES land(land_id),
    bezirk_id       integer REFERENCES bezirk(bezirk_id),
    datum           date NOT NULL,
    bezeichnung     varchar(150) NOT NULL,
    -- z.B. 24./31.12. in vielen Betrieben: halber Tag Soll
    halbtag         boolean NOT NULL DEFAULT false
);

-- Zwei partielle Unique-Indexe, weil bezirk_id nullable ist (gleiches Muster
-- wie artikel_fach)
CREATE UNIQUE INDEX IF NOT EXISTS ux_feiertag_land
    ON feiertag (land_id, datum, bezeichnung) WHERE bezirk_id IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS ux_feiertag_bezirk
    ON feiertag (bezirk_id, datum, bezeichnung) WHERE bezirk_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_feiertag_datum ON feiertag (datum);

-- ── 3. Betriebliche Ausnahmen ──────────────────────────────────────────────
-- Betriebsferien, Brueckentage, Sonderoeffnung fuer eine Abendveranstaltung.
-- Mandantengebunden, weil das eine Firmenentscheidung ist.
CREATE TABLE IF NOT EXISTS betriebs_ausnahme (
    ausnahme_id     serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    adresse_id      integer REFERENCES adresse(adresse_id),
    zeitraum        daterange NOT NULL,
    art             varchar(20) NOT NULL
                    CHECK (art IN ('geschlossen', 'sonderoeffnung')),
    -- nur bei 'sonderoeffnung' gefuellt; ersetzt dann die Regel des Tages
    von_zeit        time,
    bis_zeit        time,
    bezeichnung     varchar(150) NOT NULL,
    beschreibung    text,
    CHECK (art <> 'sonderoeffnung'
           OR (von_zeit IS NOT NULL AND bis_zeit IS NOT NULL AND bis_zeit > von_zeit))
);

CREATE INDEX IF NOT EXISTS ix_betriebs_ausnahme_zeitraum
    ON betriebs_ausnahme USING gist (zeitraum);

-- ── 4. Funktionen ──────────────────────────────────────────────────────────

-- Ist das Datum am Standort ein Feiertag? Prueft landesweite UND bezirks-
-- eigene Eintraege. Rueckgabe: NULL = kein Feiertag, sonst die Bezeichnung.
CREATE OR REPLACE FUNCTION fn_feiertag_name(p_datum date, p_bezirk_id integer)
RETURNS varchar
LANGUAGE sql STABLE AS $$
    SELECT f.bezeichnung
      FROM feiertag f
      JOIN bezirk b ON b.bezirk_id = p_bezirk_id
     WHERE f.datum = p_datum
       AND (f.bezirk_id = p_bezirk_id          -- kantonal/bundeslandspezifisch
        OR (f.bezirk_id IS NULL AND f.land_id = b.land_id))  -- landesweit
     ORDER BY f.bezirk_id NULLS LAST
     LIMIT 1;
$$;

-- Wie viele Minuten ist der Betrieb an diesem Tag offen?
-- 0 = Feiertag, Wochenende oder geschlossen.
-- Das ist die Basis der Soll-Stunden: Soll = Betriebsminuten x Pensum.
CREATE OR REPLACE FUNCTION fn_betriebszeit_minuten(
    p_mandant_id integer, p_adresse_id integer, p_datum date)
RETURNS integer
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_bezirk_id integer;
    v_minuten   integer;
    v_hat_eigene boolean;
    r           record;
BEGIN
    SELECT bezirk_id INTO v_bezirk_id FROM adresse WHERE adresse_id = p_adresse_id;

    -- Feiertag schlaegt alles
    IF v_bezirk_id IS NOT NULL
       AND fn_feiertag_name(p_datum, v_bezirk_id) IS NOT NULL THEN
        RETURN 0;
    END IF;

    -- Betriebsferien / geschlossen
    IF EXISTS (SELECT 1 FROM betriebs_ausnahme a
                WHERE a.mandant_id = p_mandant_id
                  AND a.art = 'geschlossen'
                  AND a.zeitraum @> p_datum
                  AND (a.adresse_id IS NULL OR a.adresse_id = p_adresse_id)) THEN
        RETURN 0;
    END IF;

    -- Sonderoeffnung ersetzt die Regel des Tages
    SELECT a.von_zeit, a.bis_zeit INTO r
      FROM betriebs_ausnahme a
     WHERE a.mandant_id = p_mandant_id
       AND a.art = 'sonderoeffnung'
       AND a.zeitraum @> p_datum
       AND (a.adresse_id IS NULL OR a.adresse_id = p_adresse_id)
     ORDER BY a.adresse_id NULLS LAST
     LIMIT 1;
    IF FOUND THEN
        RETURN EXTRACT(epoch FROM (r.bis_zeit - r.von_zeit))::integer / 60;
    END IF;

    -- Regulaere Betriebszeit. Standorteigene Zeilen ersetzen die Grundregel
    -- komplett (nicht mischen!).
    SELECT EXISTS (SELECT 1 FROM betriebszeit z
                    WHERE z.mandant_id = p_mandant_id
                      AND z.adresse_id = p_adresse_id
                      AND z.wochentag = EXTRACT(isodow FROM p_datum)::smallint
                      AND z.gueltig_ab <= p_datum
                      AND (z.gueltig_bis IS NULL OR z.gueltig_bis >= p_datum))
      INTO v_hat_eigene;

    SELECT COALESCE(SUM(EXTRACT(epoch FROM (z.bis_zeit - z.von_zeit))::integer / 60), 0)
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

-- ── 5. Seeds ───────────────────────────────────────────────────────────────
-- ACHTUNG: Feiertage sind ein STARTPUNKT, kein Gesetzestext. Karfreitag gilt
-- z.B. im Tessin und Wallis nicht, Mariae Himmelfahrt nur in ueberwiegend
-- katholischen bayerischen Gemeinden. Vor dem Produktivbetrieb im
-- Einstellungen-Fenster pruefen und je Bezirk korrigieren.

-- Schweiz, landesweit (die acht eidgenoessisch anerkannten), 2026 + 2027
INSERT INTO feiertag (land_id, bezirk_id, datum, bezeichnung)
SELECT 1, NULL, d.datum, d.bez FROM (VALUES
    (DATE '2026-01-01', 'Neujahr'),
    (DATE '2026-04-03', 'Karfreitag'),
    (DATE '2026-04-06', 'Ostermontag'),
    (DATE '2026-05-14', 'Auffahrt'),
    (DATE '2026-05-25', 'Pfingstmontag'),
    (DATE '2026-08-01', 'Bundesfeier'),
    (DATE '2026-12-25', 'Weihnachten'),
    (DATE '2026-12-26', 'Stephanstag'),
    (DATE '2027-01-01', 'Neujahr'),
    (DATE '2027-03-26', 'Karfreitag'),
    (DATE '2027-03-29', 'Ostermontag'),
    (DATE '2027-05-06', 'Auffahrt'),
    (DATE '2027-05-17', 'Pfingstmontag'),
    (DATE '2027-08-01', 'Bundesfeier'),
    (DATE '2027-12-25', 'Weihnachten'),
    (DATE '2027-12-26', 'Stephanstag')
) AS d(datum, bez)
ON CONFLICT DO NOTHING;

-- Bayern (Standort Muenchen), 2026 + 2027
INSERT INTO feiertag (land_id, bezirk_id, datum, bezeichnung)
SELECT 2, b.bezirk_id, d.datum, d.bez
  FROM bezirk b, (VALUES
    (DATE '2026-01-01', 'Neujahr'),
    (DATE '2026-01-06', 'Heilige Drei Koenige'),
    (DATE '2026-04-03', 'Karfreitag'),
    (DATE '2026-04-06', 'Ostermontag'),
    (DATE '2026-05-01', 'Tag der Arbeit'),
    (DATE '2026-05-14', 'Christi Himmelfahrt'),
    (DATE '2026-05-25', 'Pfingstmontag'),
    (DATE '2026-06-04', 'Fronleichnam'),
    (DATE '2026-08-15', 'Mariae Himmelfahrt'),
    (DATE '2026-10-03', 'Tag der Deutschen Einheit'),
    (DATE '2026-11-01', 'Allerheiligen'),
    (DATE '2026-12-25', '1. Weihnachtstag'),
    (DATE '2026-12-26', '2. Weihnachtstag'),
    (DATE '2027-01-01', 'Neujahr'),
    (DATE '2027-01-06', 'Heilige Drei Koenige'),
    (DATE '2027-03-26', 'Karfreitag'),
    (DATE '2027-03-29', 'Ostermontag'),
    (DATE '2027-05-01', 'Tag der Arbeit'),
    (DATE '2027-05-06', 'Christi Himmelfahrt'),
    (DATE '2027-05-17', 'Pfingstmontag'),
    (DATE '2027-05-27', 'Fronleichnam'),
    (DATE '2027-08-15', 'Mariae Himmelfahrt'),
    (DATE '2027-10-03', 'Tag der Deutschen Einheit'),
    (DATE '2027-11-01', 'Allerheiligen'),
    (DATE '2027-12-25', '1. Weihnachtstag'),
    (DATE '2027-12-26', '2. Weihnachtstag')
) AS d(datum, bez)
 WHERE b.land_id = 2 AND b.bezirk_name = 'Bayern'
ON CONFLICT DO NOTHING;

-- Grundbetriebszeit je Mandant: Mo-Fr, geteilt durch die Mittagspause.
-- Zwei Zeilen pro Tag demonstrieren genau den Fall, fuer den es kein UNIQUE gibt.
INSERT INTO betriebszeit (mandant_id, adresse_id, wochentag, von_zeit, bis_zeit,
                          gueltig_ab, bezeichnung)
SELECT m.mandant_id, NULL, wt.tag, z.von, z.bis, DATE '2026-01-01', z.bez
  FROM mandant m,
       generate_series(1, 5) AS wt(tag),
       (VALUES (TIME '08:00', TIME '12:00', 'Vormittag'),
               (TIME '13:00', TIME '17:00', 'Nachmittag')) AS z(von, bis, bez)
 WHERE NOT EXISTS (SELECT 1 FROM betriebszeit b WHERE b.mandant_id = m.mandant_id);
