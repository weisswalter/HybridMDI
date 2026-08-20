-- Kategorien und ihre Zuordnung zu Artikeln.
--
-- Namensgebung nach dem Muster des Hauses: eine Bruecke heisst a_b
-- (person_adresse, vorgang_beleg, artikel_fach). Die Zuordnung ist also
-- artikel_kategorie, und die Kategorie selbst heisst schlicht kategorie.
--
-- kategorie traegt ein Feld bereich. Heute steht dort ueberall 'ARTIKEL';
-- kommen spaeter Kurs- oder Dokumentkategorien dazu, braucht es dafuer
-- keine zweite Tabelle, nur einen anderen Wert.
--
-- Ein Artikel kann in mehreren Kategorien liegen - deshalb eine Bruecke und
-- kein Feld an artikel.

BEGIN;

CREATE TABLE IF NOT EXISTS kategorie (
    kategorie_id serial PRIMARY KEY,
    mandant_id   integer      NOT NULL REFERENCES mandant(mandant_id),
    bereich      varchar(20)  NOT NULL DEFAULT 'ARTIKEL',
    bezeichnung  varchar(100) NOT NULL,
    beschreibung text,
    sortierung   integer      NOT NULL DEFAULT 0,
    aktiv        boolean      NOT NULL DEFAULT true,
    created_at   timestamp    NOT NULL DEFAULT now(),
    UNIQUE (mandant_id, bereich, bezeichnung)
);
CREATE INDEX IF NOT EXISTS ix_kategorie_mandant ON kategorie(mandant_id, bereich);

CREATE TABLE IF NOT EXISTS artikel_kategorie (
    artikel_id   integer NOT NULL REFERENCES artikel(artikel_id) ON DELETE CASCADE,
    kategorie_id integer NOT NULL REFERENCES kategorie(kategorie_id) ON DELETE CASCADE,
    PRIMARY KEY (artikel_id, kategorie_id)
);
CREATE INDEX IF NOT EXISTS ix_artikel_kategorie_kategorie
    ON artikel_kategorie(kategorie_id);

-- Artikel und Kategorie muessen demselben Mandanten gehoeren. Als
-- Fremdschluessel nicht ausdrueckbar, weil artikel_kategorie bewusst keine
-- mandant_id fuehrt (die steht schon an beiden Enden).
CREATE OR REPLACE FUNCTION fn_artikel_kategorie_pruefen()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT a.mandant_id FROM artikel a WHERE a.artikel_id = NEW.artikel_id)
       IS DISTINCT FROM
       (SELECT k.mandant_id FROM kategorie k WHERE k.kategorie_id = NEW.kategorie_id) THEN
        RAISE EXCEPTION 'Artikel und Kategorie gehoeren zu verschiedenen Mandanten.';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_artikel_kategorie_pruefen ON artikel_kategorie;
CREATE TRIGGER tr_artikel_kategorie_pruefen
    BEFORE INSERT OR UPDATE ON artikel_kategorie
    FOR EACH ROW EXECUTE FUNCTION fn_artikel_kategorie_pruefen();

COMMIT;

-- ---------------------------------------------------------------------------
-- Anlegen und Aendern in einem: p_kategorie_id = 0 heisst "neu".
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_kategorie_speichern(
    p_kategorie_id integer,
    p_mandant_id   integer,
    p_bezeichnung  varchar,
    p_beschreibung text    DEFAULT NULL,
    p_sortierung   integer DEFAULT 0,
    p_aktiv        boolean DEFAULT true,
    p_bereich      varchar DEFAULT 'ARTIKEL')
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_kategorie_id, p_mandant_id,
             p_bezeichnung, p_beschreibung, p_sortierung, p_aktiv, p_bereich)
      FROM funktion WHERE name = 'fn_kategorie_speichern';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung fuer die Kategorie eingeben.';
    END IF;

    IF COALESCE(p_kategorie_id, 0) = 0 THEN
        INSERT INTO kategorie (mandant_id, bereich, bezeichnung, beschreibung,
                               sortierung, aktiv)
        VALUES (p_mandant_id, p_bereich, btrim(p_bezeichnung), p_beschreibung,
                COALESCE(p_sortierung, 0), COALESCE(p_aktiv, true))
        RETURNING kategorie_id INTO v_id;
    ELSE
        UPDATE kategorie
           SET bezeichnung  = btrim(p_bezeichnung),
               beschreibung = p_beschreibung,
               sortierung   = COALESCE(p_sortierung, 0),
               aktiv        = COALESCE(p_aktiv, true)
         WHERE kategorie_id = p_kategorie_id
        RETURNING kategorie_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Diese Kategorie gibt es nicht mehr.';
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- Loeschen nur, wenn nichts daran haengt. Das ON DELETE CASCADE auf
-- artikel_kategorie wuerde die Zuordnungen sonst stillschweigend mitnehmen.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_kategorie_loeschen(p_kategorie_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_anzahl integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_kategorie_id)
      FROM funktion WHERE name = 'fn_kategorie_loeschen';

    SELECT count(*) INTO v_anzahl
      FROM artikel_kategorie WHERE kategorie_id = p_kategorie_id;
    IF v_anzahl > 0 THEN
        RAISE EXCEPTION
          'Der Kategorie sind noch % Artikel zugeordnet. Erst dort entfernen, oder die Kategorie stilllegen statt loeschen.',
          v_anzahl;
    END IF;

    DELETE FROM kategorie WHERE kategorie_id = p_kategorie_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- Haken setzen oder wegnehmen. Eine Funktion fuer beides, damit das Fenster
-- nicht wissen muss, ob die Zuordnung schon besteht.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_artikel_kategorie_setzen(
    p_artikel_id   integer,
    p_kategorie_id integer,
    p_zuordnen     boolean)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_artikel_id, p_kategorie_id, p_zuordnen)
      FROM funktion WHERE name = 'fn_artikel_kategorie_setzen';

    IF p_zuordnen THEN
        INSERT INTO artikel_kategorie (artikel_id, kategorie_id)
        VALUES (p_artikel_id, p_kategorie_id)
        ON CONFLICT DO NOTHING;
    ELSE
        DELETE FROM artikel_kategorie
         WHERE artikel_id = p_artikel_id AND kategorie_id = p_kategorie_id;
    END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- Register nachziehen
-- ---------------------------------------------------------------------------
INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public'
   AND p.proname IN ('fn_kategorie_speichern', 'fn_kategorie_loeschen',
                     'fn_artikel_kategorie_setzen')
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, t.ueber
  FROM (VALUES
    ('fn_kategorie_speichern',      'kategorie',         'INSERT', 'direkt'),
    ('fn_kategorie_speichern',      'kategorie',         'UPDATE', 'direkt'),
    ('fn_kategorie_speichern',      'funktion_aufruf',   'INSERT', 'direkt'),
    ('fn_kategorie_loeschen',       'kategorie',         'DELETE', 'direkt'),
    ('fn_kategorie_loeschen',       'funktion_aufruf',   'INSERT', 'direkt'),
    ('fn_artikel_kategorie_setzen', 'artikel_kategorie', 'INSERT', 'direkt'),
    ('fn_artikel_kategorie_setzen', 'artikel_kategorie', 'DELETE', 'direkt'),
    ('fn_artikel_kategorie_setzen', 'funktion_aufruf',   'INSERT', 'direkt')
  ) AS t(fname, tabelle, wirkung, ueber)
  JOIN funktion f ON f.name = t.fname
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle AND ft.wirkung = t.wirkung);

-- Ein brauchbarer Anfang je Mandant, damit das Fenster nicht leer aufgeht.
INSERT INTO kategorie (mandant_id, bereich, bezeichnung, sortierung)
SELECT m.mandant_id, 'ARTIKEL', k.bezeichnung, k.sortierung
  FROM mandant m
  CROSS JOIN (VALUES
      ('Rohmaterial',   10),
      ('Halbfertig',    20),
      ('Fertigprodukt', 30),
      ('Werkzeug',      40),
      ('Verbrauch',     50),
      ('Handelsware',   60)
  ) AS k(bezeichnung, sortierung)
 WHERE NOT EXISTS (SELECT 1 FROM kategorie x
                    WHERE x.mandant_id = m.mandant_id
                      AND x.bereich = 'ARTIKEL'
                      AND x.bezeichnung = k.bezeichnung);
