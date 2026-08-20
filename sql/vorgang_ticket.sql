-- Vorgang als Ticket: Nummer, Typ, Zustandsfolge, Verlauf, Verknuepfung.
--
-- Ausgangslage war eine Tabelle vorgang mit fest verdrahtetem status-CHECK
-- (offen/wartend/abgeschlossen/abgebrochen), einer nullbaren vorgang_nr ohne
-- Vergabe und den drei Anhaengen Beleg/Dokument/E-Mail.
--
-- Regeln, die hier verankert werden:
--   1. Jeder Vorgang bekommt beim Anlegen eine Nummer aus dem Nummernkreis.
--   2. Er durchlaeuft Zustaende; erlaubt ist nur, was in vorgang_uebergang
--      steht - je Vorgangstyp verschieden.
--   3. Ein abgeschlossener Vorgang wird nicht wieder geoeffnet. Zwei
--      Schloesser: aus einem Abschlusszustand gibt es keinen Uebergang
--      (Daten), und der Satz wird eingefroren (Trigger).
--   4. Statt Wiedereroeffnen: ein neuer Vorgang, verknuepft mit dem alten.

BEGIN;

-- ===========================================================================
-- 1. Nummernkreis verallgemeinern
--    beleg_nummernkreis konnte das schon lueckenlos (UPDATE .. RETURNING
--    sperrt die Zeile). Ein zweiter Mechanismus fuer Vorgaenge waere eine
--    Wahrheit zu viel - also wird der vorhandene allgemein gemacht.
--    Die Tabelle ist leer und ausser fn_beleg_nummer greift niemand darauf zu.
-- ===========================================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'beleg_nummernkreis') THEN
    ALTER TABLE beleg_nummernkreis RENAME COLUMN belegart TO schluessel;
    ALTER TABLE beleg_nummernkreis RENAME TO nummernkreis;
  END IF;
END $$;

CREATE OR REPLACE FUNCTION fn_nummer_ziehen(
    p_mandant_id integer,
    p_schluessel varchar,
    p_datum      date)
RETURNS varchar
LANGUAGE plpgsql
AS $$
DECLARE
    v_jahr integer; v_nr integer; v_praefix varchar; v_stellen smallint;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_mandant_id, p_schluessel, p_datum)
      FROM funktion WHERE name = 'fn_nummer_ziehen';

    v_jahr := EXTRACT(year FROM COALESCE(p_datum, CURRENT_DATE));

    -- UPDATE .. RETURNING sperrt die Zeile und zaehlt in einem Zug hoch: zwei
    -- gleichzeitige Vergaben warten aufeinander, statt dieselbe Nummer zu
    -- bekommen. Weil die Funktion in der Transaktion des Aufrufers laeuft,
    -- gibt ein Fehlschlag die Nummer wieder frei.
    UPDATE nummernkreis
       SET letzte_nr = letzte_nr + 1
     WHERE mandant_id = p_mandant_id AND schluessel = p_schluessel
       AND jahr = v_jahr
    RETURNING letzte_nr, praefix, stellen INTO v_nr, v_praefix, v_stellen;

    IF NOT FOUND THEN
        -- Bewusst kein stillschweigendes Anlegen: ein selbst erzeugter Kreis
        -- mit leerem Praefix waere beim ersten Januareintrag das falsche
        -- Geschenk.
        RAISE EXCEPTION
          'Fuer Mandant % und Schluessel % gibt es keinen Nummernkreis fuer %.',
          p_mandant_id, p_schluessel, v_jahr;
    END IF;

    RETURN v_praefix || v_jahr::text || '-' || lpad(v_nr::text, v_stellen, '0');
END;
$$;

-- Der Belegweg ruft weiter fn_beleg_nummer; die Huelle haelt ihn unveraendert.
CREATE OR REPLACE FUNCTION fn_beleg_nummer(
    p_mandant_id integer,
    p_belegart   varchar,
    p_datum      date)
RETURNS varchar
LANGUAGE sql
AS $$
    SELECT fn_nummer_ziehen(p_mandant_id, p_belegart, p_datum);
$$;

-- ===========================================================================
-- 2. Typ, Zustand, Uebergang
-- ===========================================================================
CREATE TABLE IF NOT EXISTS vorgang_typ (
    typ_id      serial PRIMARY KEY,
    mandant_id  integer      NOT NULL REFERENCES mandant(mandant_id),
    code        varchar(20)  NOT NULL,
    bezeichnung varchar(100) NOT NULL,
    -- Praefix der Ticketnummer, zugleich Schluessel im Nummernkreis.
    praefix     varchar(10)  NOT NULL DEFAULT '',
    aktiv       boolean      NOT NULL DEFAULT true,
    UNIQUE (mandant_id, code)
);

-- Die Stufen haengen am Mandanten, nicht am Typ - sonst steht "In Arbeit"
-- fuenfmal in der Datenbank. Welcher Typ welchen Weg durch die Stufen nehmen
-- darf, sagt vorgang_uebergang.
CREATE TABLE IF NOT EXISTS vorgang_zustand (
    zustand_id    serial PRIMARY KEY,
    mandant_id    integer      NOT NULL REFERENCES mandant(mandant_id),
    code          varchar(20)  NOT NULL,
    bezeichnung   varchar(100) NOT NULL,
    reihenfolge   integer      NOT NULL DEFAULT 0,
    ist_start     boolean      NOT NULL DEFAULT false,
    ist_abschluss boolean      NOT NULL DEFAULT false,
    aktiv         boolean      NOT NULL DEFAULT true,
    UNIQUE (mandant_id, code)
);

CREATE TABLE IF NOT EXISTS vorgang_uebergang (
    typ_id          integer NOT NULL REFERENCES vorgang_typ(typ_id) ON DELETE CASCADE,
    von_zustand_id  integer NOT NULL REFERENCES vorgang_zustand(zustand_id),
    nach_zustand_id integer NOT NULL REFERENCES vorgang_zustand(zustand_id),
    PRIMARY KEY (typ_id, von_zustand_id, nach_zustand_id),
    CHECK (von_zustand_id <> nach_zustand_id)
);

-- Aus einem Abschlusszustand fuehrt kein Weg heraus. Als CHECK nicht
-- moeglich, weil dafuer eine andere Tabelle gelesen werden muss.
CREATE OR REPLACE FUNCTION fn_vorgang_uebergang_pruefen()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM vorgang_zustand z
                WHERE z.zustand_id = NEW.von_zustand_id AND z.ist_abschluss) THEN
        RAISE EXCEPTION
          'Aus einem Abschlusszustand darf kein Uebergang wegfuehren - ein abgeschlossener Vorgang wird nicht wieder geoeffnet.';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_vorgang_uebergang_pruefen ON vorgang_uebergang;
CREATE TRIGGER tr_vorgang_uebergang_pruefen
    BEFORE INSERT OR UPDATE ON vorgang_uebergang
    FOR EACH ROW EXECUTE FUNCTION fn_vorgang_uebergang_pruefen();

-- ===========================================================================
-- 3. vorgang erweitern, status abloesen
-- ===========================================================================
ALTER TABLE vorgang ADD COLUMN IF NOT EXISTS typ_id       integer REFERENCES vorgang_typ(typ_id);
ALTER TABLE vorgang ADD COLUMN IF NOT EXISTS zustand_id   integer REFERENCES vorgang_zustand(zustand_id);
ALTER TABLE vorgang ADD COLUMN IF NOT EXISTS bearbeiter_id integer REFERENCES person(person_id);
ALTER TABLE vorgang ADD COLUMN IF NOT EXISTS faellig_am   date;

CREATE INDEX IF NOT EXISTS ix_vorgang_zustand    ON vorgang(zustand_id);
CREATE INDEX IF NOT EXISTS ix_vorgang_typ        ON vorgang(typ_id);
CREATE INDEX IF NOT EXISTS ix_vorgang_bearbeiter ON vorgang(bearbeiter_id);

-- ===========================================================================
-- 4. Verlauf und Verknuepfung
-- ===========================================================================
CREATE TABLE IF NOT EXISTS vorgang_verlauf (
    verlauf_id      serial PRIMARY KEY,
    vorgang_id      integer   NOT NULL REFERENCES vorgang(vorgang_id) ON DELETE CASCADE,
    -- NULL beim Anlegen: davor gab es keinen Zustand.
    von_zustand_id  integer   REFERENCES vorgang_zustand(zustand_id),
    nach_zustand_id integer   NOT NULL REFERENCES vorgang_zustand(zustand_id),
    benutzer_id     integer   REFERENCES benutzer(benutzer_id),
    zeitpunkt       timestamp NOT NULL DEFAULT now(),
    bemerkung       text
);
CREATE INDEX IF NOT EXISTS ix_vorgang_verlauf_vorgang ON vorgang_verlauf(vorgang_id);

-- Gleiches Muster wie variante_variante und artikel_artikel: eine Kante
-- zwischen zwei Saetzen derselben Tabelle, die Art steht im Bezug.
CREATE TABLE IF NOT EXISTS vorgang_vorgang (
    von_id  integer     NOT NULL REFERENCES vorgang(vorgang_id) ON DELETE CASCADE,
    nach_id integer     NOT NULL REFERENCES vorgang(vorgang_id) ON DELETE CASCADE,
    bezug   varchar(20) NOT NULL DEFAULT 'nachfolger',
    PRIMARY KEY (von_id, nach_id, bezug),
    CHECK (von_id <> nach_id)
);
CREATE INDEX IF NOT EXISTS ix_vorgang_vorgang_nach ON vorgang_vorgang(nach_id);

COMMIT;
