-- Loeschfunktionen fuer das Einstellungsfenster.
--
-- Ob ein Typ noch verwendet wird, weiss die Datenbank selbst - dafuer gibt
-- es die Fremdschluessel. Statt in jeder Funktion die verweisenden Tabellen
-- aufzuzaehlen (und beim naechsten neuen Verweis eine zu vergessen), wird
-- geloescht und die Verletzung abgefangen.
--
-- fn_kategorie_loeschen gibt es schon (sql/artikel_kategorie.sql) und
-- bleibt, wie es ist: dort haengt kein Fremdschluessel, sondern eine
-- Bruecke mit ON DELETE CASCADE, die stillschweigend mitginge.

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_person_typ_loeschen(p_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id)
      FROM funktion WHERE name = 'fn_person_typ_loeschen';

    DELETE FROM person_typ WHERE typ_id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Der Eintrag wird noch verwendet und laesst sich nicht loeschen. Wo es die Spalte aktiv gibt, dort den Haken wegnehmen statt zu loeschen.';
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_rolle_typ_loeschen(p_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id)
      FROM funktion WHERE name = 'fn_rolle_typ_loeschen';

    DELETE FROM rolle_typ WHERE rolle_id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Der Eintrag wird noch verwendet und laesst sich nicht loeschen. Wo es die Spalte aktiv gibt, dort den Haken wegnehmen statt zu loeschen.';
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_adressentyp_loeschen(p_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id)
      FROM funktion WHERE name = 'fn_adressentyp_loeschen';

    DELETE FROM adressentyp WHERE adressentyp_id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Der Eintrag wird noch verwendet und laesst sich nicht loeschen. Wo es die Spalte aktiv gibt, dort den Haken wegnehmen statt zu loeschen.';
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_emailtyp_loeschen(p_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id)
      FROM funktion WHERE name = 'fn_emailtyp_loeschen';

    DELETE FROM emailtyp WHERE emailtyp_id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Der Eintrag wird noch verwendet und laesst sich nicht loeschen. Wo es die Spalte aktiv gibt, dort den Haken wegnehmen statt zu loeschen.';
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_telefonnummertyp_loeschen(p_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id)
      FROM funktion WHERE name = 'fn_telefonnummertyp_loeschen';

    DELETE FROM telefonnummertyp WHERE telefonnummertyp_id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Der Eintrag wird noch verwendet und laesst sich nicht loeschen. Wo es die Spalte aktiv gibt, dort den Haken wegnehmen statt zu loeschen.';
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_leadquelle_typ_loeschen(p_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id)
      FROM funktion WHERE name = 'fn_leadquelle_typ_loeschen';

    DELETE FROM leadquelle_typ WHERE leadquelle_id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Der Eintrag wird noch verwendet und laesst sich nicht loeschen. Wo es die Spalte aktiv gibt, dort den Haken wegnehmen statt zu loeschen.';
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_kompetenz_typ_loeschen(p_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id)
      FROM funktion WHERE name = 'fn_kompetenz_typ_loeschen';

    DELETE FROM kompetenz_typ WHERE kompetenz_id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Der Eintrag wird noch verwendet und laesst sich nicht loeschen. Wo es die Spalte aktiv gibt, dort den Haken wegnehmen statt zu loeschen.';
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_rechnungstyp_loeschen(p_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id)
      FROM funktion WHERE name = 'fn_rechnungstyp_loeschen';

    DELETE FROM rechnungstyp WHERE rechnungstyp_id = p_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Der Eintrag wird noch verwendet und laesst sich nicht loeschen. Wo es die Spalte aktiv gibt, dort den Haken wegnehmen statt zu loeschen.';
END;
$$;

INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public' AND p.proname IN ('fn_person_typ_loeschen', 'fn_rolle_typ_loeschen', 'fn_adressentyp_loeschen', 'fn_emailtyp_loeschen', 'fn_telefonnummertyp_loeschen', 'fn_leadquelle_typ_loeschen', 'fn_kompetenz_typ_loeschen', 'fn_rechnungstyp_loeschen')
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, 'direkt'
  FROM (VALUES
    ('fn_person_typ_loeschen', 'person_typ', 'DELETE'),
    ('fn_rolle_typ_loeschen', 'rolle_typ', 'DELETE'),
    ('fn_adressentyp_loeschen', 'adressentyp', 'DELETE'),
    ('fn_emailtyp_loeschen', 'emailtyp', 'DELETE'),
    ('fn_telefonnummertyp_loeschen', 'telefonnummertyp', 'DELETE'),
    ('fn_leadquelle_typ_loeschen', 'leadquelle_typ', 'DELETE'),
    ('fn_kompetenz_typ_loeschen', 'kompetenz_typ', 'DELETE'),
    ('fn_rechnungstyp_loeschen', 'rechnungstyp', 'DELETE'),
    ('fn_person_typ_loeschen', 'funktion_aufruf', 'INSERT'),
    ('fn_rolle_typ_loeschen', 'funktion_aufruf', 'INSERT'),
    ('fn_adressentyp_loeschen', 'funktion_aufruf', 'INSERT'),
    ('fn_emailtyp_loeschen', 'funktion_aufruf', 'INSERT'),
    ('fn_telefonnummertyp_loeschen', 'funktion_aufruf', 'INSERT'),
    ('fn_leadquelle_typ_loeschen', 'funktion_aufruf', 'INSERT'),
    ('fn_kompetenz_typ_loeschen', 'funktion_aufruf', 'INSERT'),
    ('fn_rechnungstyp_loeschen', 'funktion_aufruf', 'INSERT')
  ) AS t(fname, tabelle, wirkung)
  JOIN funktion f ON f.name = t.fname
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle AND ft.wirkung = t.wirkung);
