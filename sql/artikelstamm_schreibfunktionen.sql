-- Schreibfunktionen fuer den Artikelstamm.
--
-- Bis hierher hat ArtikelStammDm an sechs Stellen noch direkt SQL abgesetzt
-- (UPDATE/DELETE/INSERT ueber eine TFDQuery). Geschrieben wird ausschliesslich
-- ueber Funktionen; diese Datei liefert die fehlenden nach.
--
-- Jede Funktion protokolliert ihren Aufruf in funktion_aufruf, wie alle
-- anderen auch. Die Eintraege in funktion/funktion_tabelle stehen am Ende.

-- ---------------------------------------------------------------------------
-- 1. Auspraegung umbenennen
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_variante_umbenennen(
    p_variante_id integer,
    p_name        varchar)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_variante_id, p_name)
      FROM funktion WHERE name = 'fn_variante_umbenennen';

    IF p_name IS NULL OR btrim(p_name) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung eingeben';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM variante WHERE variante_id = p_variante_id) THEN
        RAISE EXCEPTION 'Die Auspraegung gibt es nicht mehr';
    END IF;

    -- Die Eindeutigkeit je Ebene prueft der Trigger variante_name_pruefen.
    UPDATE variante SET name = btrim(p_name) WHERE variante_id = p_variante_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- 2. Auspraegung loeschen
--    Erst pruefen, dann loeschen: das ON DELETE CASCADE auf
--    variante_variante wuerde sonst stillschweigend den ganzen Ast mitnehmen.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_variante_loeschen(p_variante_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_variante_id)
      FROM funktion WHERE name = 'fn_variante_loeschen';

    IF EXISTS (SELECT 1 FROM variante_variante
                WHERE nach_id = p_variante_id AND bezug = 'child') THEN
        RAISE EXCEPTION 'Der Eintrag hat noch Unterelemente. Diese zuerst entfernen.';
    END IF;
    IF EXISTS (SELECT 1 FROM artikel_variante_wert
                WHERE variante_id = p_variante_id) THEN
        RAISE EXCEPTION 'Der Eintrag wird von Artikelvarianten verwendet.';
    END IF;

    DELETE FROM variante WHERE variante_id = p_variante_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- 3. Gleichwertigkeit aufheben
--    Beide Richtungen loeschen: erfasst wurde nur eine, welche ist von
--    aussen nicht erkennbar.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_aequivalenz_aufheben(
    p_a_id integer,
    p_b_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_a_id, p_b_id)
      FROM funktion WHERE name = 'fn_aequivalenz_aufheben';

    DELETE FROM variante_variante
     WHERE bezug = 'aequivalenz'
       AND ((von_id = p_a_id AND nach_id = p_b_id)
         OR (von_id = p_b_id AND nach_id = p_a_id));
END;
$$;

-- ---------------------------------------------------------------------------
-- 4. Neue Adresse fuer die Hauptperson, gleich als Lager markiert
--    Drei Einfuegungen in einem Rutsch - entweder alle oder keine. Vorher
--    lagen sie als drei einzelne Anweisungen im Delphi-Code; brach die
--    zweite ab, blieb eine Adresse ohne Person stehen.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_adresse_fuer_hauptperson(
    p_mandant_id integer,
    p_strasse    varchar,
    p_hausnummer varchar,
    p_plz        varchar,
    p_ort        varchar)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_person_id  integer;
    v_adresse_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_mandant_id, p_strasse,
                                          p_hausnummer, p_plz, p_ort)
      FROM funktion WHERE name = 'fn_adresse_fuer_hauptperson';

    SELECT pm.person_id INTO v_person_id
      FROM person_mandant pm
     WHERE pm.mandant_id = p_mandant_id AND pm.ist_hauptperson = true;
    IF v_person_id IS NULL THEN
        RAISE EXCEPTION 'Keine Hauptperson fuer diesen Mandanten gefunden.';
    END IF;
    IF btrim(COALESCE(p_ort, '')) = '' THEN
        RAISE EXCEPTION 'Bitte mindestens den Ort angeben.';
    END IF;

    INSERT INTO adresse (strasse, hausnummer, plz, ort)
    VALUES (p_strasse, p_hausnummer, p_plz, p_ort)
    RETURNING adresse_id INTO v_adresse_id;

    INSERT INTO person_adresse (person_id, adresse_id, mandant_id)
    VALUES (v_person_id, v_adresse_id, p_mandant_id);

    -- Ohne Eintrag in lager taucht der Standort im Bestand-Baum nie auf.
    INSERT INTO lager (mandant_id, adresse_id, beschreibung)
    VALUES (p_mandant_id, v_adresse_id,
            'Automatisch angelegt beim Ablegen im Bestand-Baum');

    RETURN v_adresse_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- 5. Stueckliste: Unterartikel einhaengen oder Menge aendern
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_stueckliste_hinzufuegen(
    p_mandant_id       integer,
    p_artikel_id       integer,
    p_unter_artikel_id integer,
    -- double precision, nicht numeric: Delphi schickt die Menge als Double.
    -- Bei numeric findet Postgres keine passende Signatur.
    p_menge            double precision)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_mandant_id, p_artikel_id,
                                          p_unter_artikel_id, p_menge)
      FROM funktion WHERE name = 'fn_stueckliste_hinzufuegen';

    IF p_artikel_id = p_unter_artikel_id THEN
        RAISE EXCEPTION 'Ein Artikel kann nicht sein eigener Bestandteil sein.';
    END IF;

    -- Ringpruefung ueber mehrere Ebenen. Auf artikel_artikel gibt es keinen
    -- Trigger dafuer - der Delphi-Code hat frueher auf eine Meldung gewartet,
    -- die nie kam. Ein Ring liegt vor, wenn der Hauptartikel schon irgendwo
    -- unterhalb des einzuhaengenden Unterartikels steckt.
    IF EXISTS (
        WITH RECURSIVE unterhalb AS (
            SELECT p_unter_artikel_id AS id
            UNION
            SELECT aa.unter_artikel_id
              FROM artikel_artikel aa
              JOIN unterhalb u ON u.id = aa.artikel_id
        )
        SELECT 1 FROM unterhalb WHERE id = p_artikel_id
    ) THEN
        RAISE EXCEPTION 'Das ergaebe eine Ringbeziehung: der Unterartikel enthaelt diesen Artikel bereits (direkt oder ueber mehrere Ebenen).';
    END IF;

    INSERT INTO artikel_artikel (mandant_id, artikel_id, unter_artikel_id,
                                 menge, position)
    VALUES (p_mandant_id, p_artikel_id, p_unter_artikel_id, p_menge::numeric,
            (SELECT COALESCE(MAX(position), 0) + 1
               FROM artikel_artikel WHERE artikel_id = p_artikel_id))
    ON CONFLICT (artikel_id, unter_artikel_id)
    DO UPDATE SET menge = EXCLUDED.menge;
END;
$$;

-- ---------------------------------------------------------------------------
-- 6. Stueckliste: Unterartikel aushaengen
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_stueckliste_entfernen(
    p_artikel_id       integer,
    p_unter_artikel_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_artikel_id, p_unter_artikel_id)
      FROM funktion WHERE name = 'fn_stueckliste_entfernen';

    DELETE FROM artikel_artikel
     WHERE artikel_id = p_artikel_id
       AND unter_artikel_id = p_unter_artikel_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- Register nachziehen
-- ---------------------------------------------------------------------------
INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public'
   AND p.proname IN ('fn_variante_umbenennen', 'fn_variante_loeschen',
                     'fn_aequivalenz_aufheben', 'fn_adresse_fuer_hauptperson',
                     'fn_stueckliste_hinzufuegen', 'fn_stueckliste_entfernen')
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, t.ueber
  FROM (VALUES
    ('fn_variante_umbenennen',      'variante',           'UPDATE', 'direkt'),
    ('fn_variante_umbenennen',      'funktion_aufruf',    'INSERT', 'direkt'),
    ('fn_variante_loeschen',        'variante',           'DELETE', 'direkt'),
    ('fn_variante_loeschen',        'variante_variante',  'DELETE', 'kaskade'),
    ('fn_variante_loeschen',        'funktion_aufruf',    'INSERT', 'direkt'),
    ('fn_aequivalenz_aufheben',     'variante_variante',  'DELETE', 'direkt'),
    ('fn_aequivalenz_aufheben',     'funktion_aufruf',    'INSERT', 'direkt'),
    ('fn_adresse_fuer_hauptperson', 'adresse',            'INSERT', 'direkt'),
    ('fn_adresse_fuer_hauptperson', 'person_adresse',     'INSERT', 'direkt'),
    ('fn_adresse_fuer_hauptperson', 'lager',              'INSERT', 'direkt'),
    ('fn_adresse_fuer_hauptperson', 'person_mandant',     'SELECT', 'direkt'),
    ('fn_adresse_fuer_hauptperson', 'funktion_aufruf',    'INSERT', 'direkt'),
    ('fn_stueckliste_hinzufuegen',  'artikel_artikel',    'INSERT', 'direkt'),
    ('fn_stueckliste_hinzufuegen',  'artikel_artikel',    'UPDATE', 'direkt'),
    ('fn_stueckliste_hinzufuegen',  'funktion_aufruf',    'INSERT', 'direkt'),
    ('fn_stueckliste_entfernen',    'artikel_artikel',    'DELETE', 'direkt'),
    ('fn_stueckliste_entfernen',    'funktion_aufruf',    'INSERT', 'direkt')
  ) AS t(fname, tabelle, wirkung, ueber)
  JOIN funktion f ON f.name = t.fname
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle
                      AND ft.wirkung = t.wirkung);
