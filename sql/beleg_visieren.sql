-- ============================================================================
-- Belege: Rechnung/Angebot, Visieren, Nummernkreis, Sperre — 09.08.2026
--
-- Grundgedanke (Walters Vorgabe): das Dokument IST der Datensatz. Es wird
-- nichts zusaetzlich abgelegt ausser der erzeugten .tex-Quelle. Ein visierter
-- Beleg darf nicht mehr geaendert werden.
--
-- Damit ein Nachdruck in zwei Jahren dasselbe Papier ergibt, werden beim
-- Visieren die Werte eingefroren, die sonst ueber Verweise wandern koennten:
-- Anschrift des Empfaengers, Bezeichnung und Einheit je Position, Steuersatz.
-- Der Einzelpreis lag schon vorher in der Zeile.
-- ============================================================================

-- ── 1. Belegart statt Vorgangsart ───────────────────────────────────────────
-- "Vorgang" ist in Heisenberg die Fallakte (Sanktion, Ueberwachung, Ticket,
-- Tabelle vorgang mit vorgang_dokument fuer den Schriftverkehr). Die Spalte
-- an beleg enthaelt aber die BELEGART. Der Name hat mich schon einmal einen
-- falschen Entwurf gekostet.
-- Wiederholbar: beim zweiten Lauf gibt es die alte Spalte nicht mehr, und ein
-- blankes RENAME wuerde das ganze Skript abbrechen.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema='public' AND table_name='beleg'
                  AND column_name='vorgangsart') THEN
        EXECUTE 'ALTER TABLE beleg RENAME COLUMN vorgangsart TO belegart';
    END IF;
END
$$;
ALTER TABLE beleg DROP CONSTRAINT IF EXISTS beleg_vorgangsart_check;
ALTER TABLE beleg DROP CONSTRAINT IF EXISTS beleg_belegart_check;
ALTER TABLE beleg ADD  CONSTRAINT beleg_belegart_check CHECK (belegart IN
       ('Bestellung','Lieferung','Entnahme','Angebot','Rechnung'));

ALTER TABLE beleg DROP CONSTRAINT IF EXISTS beleg_status_check;
ALTER TABLE beleg ADD  CONSTRAINT beleg_status_check CHECK (status IN
       ('offen','teilweise','abgeschlossen','storniert','visiert'));

-- ── 2. Was beim Visieren eingefroren wird ───────────────────────────────────
ALTER TABLE beleg
  ADD COLUMN IF NOT EXISTS visiert_am      timestamp,
  ADD COLUMN IF NOT EXISTS visiert_von     integer REFERENCES person(person_id),
  -- Empfaengeranschrift als Text, so wie sie auf dem Papier stand. Zieht der
  -- Kunde um, aendert sich die alte Rechnung sonst rueckwirkend.
  ADD COLUMN IF NOT EXISTS empfaenger_text text;

-- ABSENDER WIRD BEWUSST NICHT EINGEFROREN (Walters Vorgabe 09.08.2026).
-- Der Absender ist die Hauptperson des Mandanten
-- (person_mandant.ist_hauptperson) - in Heisenberg ist die Firma selbst eine
-- Person. Eine Firma kann aber verkauft oder umbenannt werden, und wenn sie
-- mit allen Rechten und Pflichten wechselt, muss auch die Hauptperson
-- wechselbar bleiben. Eine Visierung gehoert da nicht hin; auf den alten
-- Stand kommt man ueber eine Sicherung, nicht ueber eine Kopie in jedem
-- einzelnen Beleg. Der Briefkopf wird beim Drucken aufgeloest.

ALTER TABLE beleg_position
  -- aus artikel.bezeichnung bzw. leistung.bezeichnung
  ADD COLUMN IF NOT EXISTS bezeichnung    varchar(200),
  -- aus einheit.name
  ADD COLUMN IF NOT EXISTS einheit_text   varchar(50),
  ADD COLUMN IF NOT EXISTS steuer_code_id integer,
  -- der Satz gehoert eingefroren in die Zeile, aus demselben Grund wie der
  -- Einzelpreis: aendert sich der Satz spaeter, stimmt sonst die alte Rechnung
  -- nicht mehr.
  ADD COLUMN IF NOT EXISTS steuersatz     numeric(5,2);

-- Eine Nummer darf es nur einmal geben, sonst ist der Kreis Zierde.
ALTER TABLE beleg DROP CONSTRAINT IF EXISTS beleg_nr_eindeutig;
ALTER TABLE beleg ADD  CONSTRAINT beleg_nr_eindeutig UNIQUE (mandant_id, beleg_nr);

-- ── 3. Die erzeugte .tex-Quelle ─────────────────────────────────────────────
-- Eigene Tabelle, NICHT als Spalte an beleg: das zentrale Datenmodul laedt
-- beim Start jede Tabelle vollstaendig in den Speicher. Eine Textspalte mit
-- der kompletten Vorlage je Rechnung wuerde den Ladebalken mit Daten fuellen,
-- die beim Arbeiten niemand braucht.
CREATE TABLE IF NOT EXISTS beleg_tex (
    beleg_id   integer   PRIMARY KEY REFERENCES beleg(beleg_id) ON DELETE CASCADE,
    tex_quelle text      NOT NULL,
    erzeugt_am timestamp NOT NULL DEFAULT clock_timestamp()
);

COMMENT ON TABLE beleg_tex IS
    'Erzeugte LaTeX-Quelle eines visierten Belegs. Friert die Darstellung ein, '
    'damit ein Nachdruck dasselbe Papier ergibt.';

-- ── 4. Nummernkreis ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS beleg_nummernkreis (
    mandant_id integer     NOT NULL REFERENCES mandant(mandant_id),
    belegart   varchar(20) NOT NULL,
    jahr       integer     NOT NULL,
    praefix    varchar(10) NOT NULL DEFAULT '',
    stellen    smallint    NOT NULL DEFAULT 4,
    letzte_nr  integer     NOT NULL DEFAULT 0,
    PRIMARY KEY (mandant_id, belegart, jahr)
);

COMMENT ON TABLE beleg_nummernkreis IS
    'Zaehler je Mandant, Belegart und Jahr. Bewusst eine Tabelle und keine '
    'SEQUENCE: eine Sequenz zaehlt auch bei einem Rollback weiter und risse '
    'damit Loecher in eine Reihe, die lueckenlos sein muss.';

CREATE OR REPLACE FUNCTION fn_beleg_nummer(
    p_mandant_id integer, p_belegart varchar, p_datum date)
RETURNS varchar
LANGUAGE plpgsql AS $$
DECLARE
    v_jahr integer; v_nr integer; v_praefix varchar; v_stellen smallint;
BEGIN
    v_jahr := EXTRACT(year FROM COALESCE(p_datum, CURRENT_DATE));

    -- UPDATE .. RETURNING sperrt die Zeile und zaehlt in einem Zug hoch: zwei
    -- gleichzeitige Visierungen warten aufeinander, statt dieselbe Nummer zu
    -- bekommen. Weil die Funktion in der Transaktion des Aufrufers laeuft,
    -- gibt ein Fehlschlag die Nummer wieder frei.
    UPDATE beleg_nummernkreis
       SET letzte_nr = letzte_nr + 1
     WHERE mandant_id = p_mandant_id AND belegart = p_belegart AND jahr = v_jahr
    RETURNING letzte_nr, praefix, stellen INTO v_nr, v_praefix, v_stellen;

    IF NOT FOUND THEN
        -- Bewusst kein stillschweigendes Anlegen: ein selbst erzeugter Kreis
        -- mit leerem Praefix waere beim ersten Januarbeleg das falsche
        -- Geschenk.
        RAISE EXCEPTION
          'Fuer Mandant % und Belegart % gibt es keinen Nummernkreis fuer %.',
          p_mandant_id, p_belegart, v_jahr;
    END IF;

    RETURN v_praefix || v_jahr::text || '-' || lpad(v_nr::text, v_stellen, '0');
END;
$$;

-- ── 4b. Anschrift einer Person als Briefblock ───────────────────────────────
-- Wird zweimal gebraucht: fuer den Empfaenger und fuer den Absender. Der
-- Absender ist die Hauptperson des Mandanten - in Heisenberg ist die Firma
-- selbst eine Person, gekennzeichnet ueber person_mandant.ist_hauptperson.
--
-- Es gibt (noch) keinen Adresstyp "Rechnungsadresse", die Typen heissen je
-- Mandant anders (Mandant 1: Hauptwohnsitz/Geschaeftsadresse/Firmenadresse/
-- Baumhaus, Mandant 3: Standard/Lager/Feriendomizil). Deshalb die niedrigste
-- Typnummer als feste Regel statt zu raten. Ein eigener Typ waere sauberer.
CREATE OR REPLACE FUNCTION fn_person_anschrift(
    p_person_id integer, p_mandant_id integer)
RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT trim(both E'\n' FROM
             COALESCE(p.titel || ' ', '') ||
             COALESCE(p.vorname || ' ', '') || p.nachname_firmenname ||
             COALESCE(E'\n' || ad.strasse ||
                      COALESCE(' ' || ad.hausnummer, ''), '') ||
             COALESCE(E'\n' || COALESCE(ad.plz || ' ', '') || ad.ort, ''))
      FROM person p
      LEFT JOIN LATERAL (
            SELECT a2.*
              FROM person_adresse pa
              JOIN adresse a2 ON a2.adresse_id = pa.adresse_id
             WHERE pa.person_id = p.person_id AND pa.mandant_id = p_mandant_id
             ORDER BY pa.adressentyp_id NULLS LAST, a2.adresse_id
             LIMIT 1) ad ON TRUE
     WHERE p.person_id = p_person_id;
$$;

-- Briefkopf des Mandanten zur Druckzeit. Bewusst eine eigene Funktion, damit
-- das Modul nur einen SpAufrufen braucht und nicht selbst abfragen muss.
CREATE OR REPLACE FUNCTION fn_mandant_absender(p_mandant_id integer)
RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT fn_person_anschrift(pm.person_id, p_mandant_id)
      FROM person_mandant pm
     WHERE pm.mandant_id = p_mandant_id AND pm.ist_hauptperson
     LIMIT 1;
$$;

-- Die erzeugte Quelle ablegen. Ueberschreibt bewusst: wird ein Beleg vor dem
-- Visieren mehrfach gedruckt, gilt der letzte Stand. Nach dem Visieren aendert
-- sich der Beleg ohnehin nicht mehr.
CREATE OR REPLACE FUNCTION fn_beleg_tex_speichern(
    p_beleg_id integer, p_tex text)
RETURNS integer
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO beleg_tex (beleg_id, tex_quelle)
    VALUES (p_beleg_id, p_tex)
    ON CONFLICT (beleg_id) DO UPDATE
        SET tex_quelle = EXCLUDED.tex_quelle,
            erzeugt_am = clock_timestamp();
    RETURN p_beleg_id;
END;
$$;

-- ── 5. Visieren ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_beleg_visieren(
    p_beleg_id integer, p_visiert_von integer DEFAULT NULL)
RETURNS varchar
LANGUAGE plpgsql AS $$
DECLARE
    v_mandant  integer;
    v_belegart varchar;
    v_datum    date;
    v_status   varchar;
    v_person   integer;
    v_nr       varchar;
    v_anschrift text;
BEGIN
    SELECT mandant_id, belegart, beleg_datum, status, person_id
      INTO v_mandant, v_belegart, v_datum, v_status, v_person
      FROM beleg WHERE beleg_id = p_beleg_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Beleg % gibt es nicht.', p_beleg_id;
    END IF;
    IF v_status = 'visiert' THEN
        RAISE EXCEPTION 'Beleg % ist bereits visiert.', p_beleg_id;
    END IF;
    IF v_status = 'storniert' THEN
        RAISE EXCEPTION 'Beleg % ist storniert.', p_beleg_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM beleg_position WHERE beleg_id = p_beleg_id) THEN
        RAISE EXCEPTION 'Beleg % hat keine Positionen.', p_beleg_id;
    END IF;

    -- Positionen ZUERST einfrieren: danach sperrt der Trigger sie ueber den
    -- Kopfstatus.
    UPDATE beleg_position bp
       -- artikel heisst die Spalte artikelname, leistung bezeichnung
       SET bezeichnung  = COALESCE(bp.bezeichnung,
                            a.artikelname, l.bezeichnung),
           einheit_text = COALESCE(bp.einheit_text, e.name),
           steuersatz   = COALESCE(bp.steuersatz, sc.satz)
      FROM beleg_position q
      LEFT JOIN artikel  a  ON a.artikel_id   = q.artikel_id
      LEFT JOIN leistung l  ON l.leistung_id  = q.leistung_id
      LEFT JOIN einheit  e  ON e.einheit_id   = q.einheit_id
                           AND e.mandant_id   = q.mandant_id
      LEFT JOIN steuer_code sc ON sc.steuer_code_id = q.steuer_code_id
     WHERE bp.position_id = q.position_id
       AND bp.beleg_id    = p_beleg_id;

    -- Nur die Empfaengeranschrift einfrieren, so wie sie heute lautet.
    v_anschrift := fn_person_anschrift(v_person, v_mandant);

    v_nr := fn_beleg_nummer(v_mandant, v_belegart, v_datum);

    UPDATE beleg
       SET status          = 'visiert',
           beleg_nr        = COALESCE(beleg_nr, v_nr),
           visiert_am      = clock_timestamp(),
           visiert_von     = p_visiert_von,
           empfaenger_text = COALESCE(empfaenger_text, v_anschrift)
     WHERE beleg_id = p_beleg_id;

    RETURN v_nr;
END;
$$;

-- ── 6. Sperre ───────────────────────────────────────────────────────────────
-- Nach dem Muster von fn_buchung_schutz. Als Trigger greift das auch beim
-- Superuser - ein REVOKE haette nur so ausgesehen, weil die Anwendung frueher
-- ohnehin mit hohen Rechten verbunden war.
CREATE OR REPLACE FUNCTION fn_beleg_schutz()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Beleg % ist visiert und kann nicht geloescht werden.',
                        OLD.beleg_id;
    END IF;

    -- Einzige erlaubte Aenderung an einem visierten Beleg: das Stornieren.
    -- Die Nummer bleibt dabei stehen und wird nie neu vergeben; die Korrektur
    -- bekommt einen eigenen Beleg mit eigener Nummer.
    IF NEW.status = 'storniert' AND OLD.status = 'visiert' THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION 'Beleg % ist visiert und kann nicht geaendert werden.',
                    OLD.beleg_id;
END;
$$;

DROP TRIGGER IF EXISTS tr_beleg_schutz ON beleg;
CREATE TRIGGER tr_beleg_schutz
    BEFORE UPDATE OR DELETE ON beleg
    FOR EACH ROW WHEN (OLD.status = 'visiert')
    EXECUTE FUNCTION fn_beleg_schutz();

CREATE OR REPLACE FUNCTION fn_beleg_position_schutz()
RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_status varchar;
    v_beleg  integer;
BEGIN
    v_beleg := COALESCE(NEW.beleg_id, OLD.beleg_id);
    SELECT status INTO v_status FROM beleg WHERE beleg_id = v_beleg;
    IF v_status = 'visiert' THEN
        RAISE EXCEPTION
          'Beleg % ist visiert, seine Positionen sind unveraenderlich.', v_beleg;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS tr_beleg_position_schutz ON beleg_position;
CREATE TRIGGER tr_beleg_position_schutz
    BEFORE INSERT OR UPDATE OR DELETE ON beleg_position
    FOR EACH ROW EXECUTE FUNCTION fn_beleg_position_schutz();
