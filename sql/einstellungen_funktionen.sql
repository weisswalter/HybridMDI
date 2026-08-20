-- Speicherfunktionen fuer das Einstellungsfenster.
--
-- Die Typ-Reiter haben bis hierher in eine TFDMemTable gepostet. Die ist
-- eine Kopie aus dem zentralen Datenmodul, dessen Tabellen auf
-- EnableInsert/Update/Delete = False stehen - die Eingabe blieb im
-- Arbeitsspeicher und war beim naechsten Auffrischen weg.
--
-- Je Tabelle eine Funktion, nicht eine generische mit dynamischem SQL:
-- nur so steht in funktion_tabelle, welche Funktion welche Tabelle
-- anfasst. Genau dafuer gibt es das Register.
--
-- Alle nach demselben Muster: p_id = 0 heisst "neu", sonst aendern.
-- Rueckgabe ist die ID, damit der Aufrufer den Satz wiederfindet.

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_person_typ_speichern(
    p_id         integer,
    p_bezeichnung      varchar)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id, p_bezeichnung)
      FROM funktion WHERE name = 'fn_person_typ_speichern';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung eingeben.';
    END IF;

    IF COALESCE(p_id, 0) = 0 THEN
        INSERT INTO person_typ (bezeichnung)
        VALUES (btrim(p_bezeichnung))
        RETURNING typ_id INTO v_id;
    ELSE
        UPDATE person_typ
           SET bezeichnung        = btrim(p_bezeichnung)
         WHERE typ_id = p_id
        RETURNING typ_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_rolle_typ_speichern(
    p_id         integer,
    p_mandant_id integer,
    p_rollen_bezeichnung varchar)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id, p_mandant_id, p_rollen_bezeichnung)
      FROM funktion WHERE name = 'fn_rolle_typ_speichern';

    IF btrim(COALESCE(p_rollen_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung eingeben.';
    END IF;

    IF COALESCE(p_id, 0) = 0 THEN
        INSERT INTO rolle_typ (mandant_id, rollen_bezeichnung)
        VALUES (p_mandant_id, btrim(p_rollen_bezeichnung))
        RETURNING rolle_id INTO v_id;
    ELSE
        UPDATE rolle_typ
           SET rollen_bezeichnung = btrim(p_rollen_bezeichnung)
         WHERE rolle_id = p_id
        RETURNING rolle_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_adressentyp_speichern(
    p_id         integer,
    p_mandant_id integer,
    p_bezeichnung      varchar)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id, p_mandant_id, p_bezeichnung)
      FROM funktion WHERE name = 'fn_adressentyp_speichern';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung eingeben.';
    END IF;

    IF COALESCE(p_id, 0) = 0 THEN
        INSERT INTO adressentyp (mandant_id, bezeichnung)
        VALUES (p_mandant_id, btrim(p_bezeichnung))
        RETURNING adressentyp_id INTO v_id;
    ELSE
        UPDATE adressentyp
           SET bezeichnung        = btrim(p_bezeichnung)
         WHERE adressentyp_id = p_id
        RETURNING adressentyp_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_emailtyp_speichern(
    p_id         integer,
    p_mandant_id integer,
    p_bezeichnung      varchar)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id, p_mandant_id, p_bezeichnung)
      FROM funktion WHERE name = 'fn_emailtyp_speichern';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung eingeben.';
    END IF;

    IF COALESCE(p_id, 0) = 0 THEN
        INSERT INTO emailtyp (mandant_id, bezeichnung)
        VALUES (p_mandant_id, btrim(p_bezeichnung))
        RETURNING emailtyp_id INTO v_id;
    ELSE
        UPDATE emailtyp
           SET bezeichnung        = btrim(p_bezeichnung)
         WHERE emailtyp_id = p_id
        RETURNING emailtyp_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_telefonnummertyp_speichern(
    p_id         integer,
    p_mandant_id integer,
    p_bezeichnung      varchar)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id, p_mandant_id, p_bezeichnung)
      FROM funktion WHERE name = 'fn_telefonnummertyp_speichern';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung eingeben.';
    END IF;

    IF COALESCE(p_id, 0) = 0 THEN
        INSERT INTO telefonnummertyp (mandant_id, bezeichnung)
        VALUES (p_mandant_id, btrim(p_bezeichnung))
        RETURNING telefonnummertyp_id INTO v_id;
    ELSE
        UPDATE telefonnummertyp
           SET bezeichnung        = btrim(p_bezeichnung)
         WHERE telefonnummertyp_id = p_id
        RETURNING telefonnummertyp_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_leadquelle_typ_speichern(
    p_id         integer,
    p_mandant_id integer,
    p_bezeichnung      varchar)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id, p_mandant_id, p_bezeichnung)
      FROM funktion WHERE name = 'fn_leadquelle_typ_speichern';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung eingeben.';
    END IF;

    IF COALESCE(p_id, 0) = 0 THEN
        INSERT INTO leadquelle_typ (mandant_id, bezeichnung)
        VALUES (p_mandant_id, btrim(p_bezeichnung))
        RETURNING leadquelle_id INTO v_id;
    ELSE
        UPDATE leadquelle_typ
           SET bezeichnung        = btrim(p_bezeichnung)
         WHERE leadquelle_id = p_id
        RETURNING leadquelle_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_kompetenz_typ_speichern(
    p_id         integer,
    p_mandant_id integer,
    p_bezeichnung      varchar,
    p_beschreibung     text,
    p_gueltigkeit_monate integer,
    p_quelle           varchar,
    p_aktiv            boolean)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id, p_mandant_id, p_bezeichnung, p_beschreibung, p_gueltigkeit_monate, p_quelle, p_aktiv)
      FROM funktion WHERE name = 'fn_kompetenz_typ_speichern';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung eingeben.';
    END IF;

    IF COALESCE(p_id, 0) = 0 THEN
        INSERT INTO kompetenz_typ (mandant_id, bezeichnung, beschreibung, gueltigkeit_monate, quelle, aktiv)
        VALUES (p_mandant_id, btrim(p_bezeichnung), p_beschreibung, p_gueltigkeit_monate, p_quelle, COALESCE(p_aktiv, true))
        RETURNING kompetenz_id INTO v_id;
    ELSE
        UPDATE kompetenz_typ
           SET bezeichnung        = btrim(p_bezeichnung),
               beschreibung       = p_beschreibung,
               gueltigkeit_monate = p_gueltigkeit_monate,
               quelle             = p_quelle,
               aktiv              = COALESCE(p_aktiv, true)
         WHERE kompetenz_id = p_id
        RETURNING kompetenz_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_rechnungstyp_speichern(
    p_id         integer,
    p_mandant_id integer,
    p_bezeichnung      varchar,
    p_reihenfolge      integer,
    p_richtung         varchar,
    p_aktiv            boolean,
    p_erloes_konto_id  integer,
    p_aufwand_konto_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_id, p_mandant_id, p_bezeichnung, p_reihenfolge, p_richtung, p_aktiv, p_erloes_konto_id, p_aufwand_konto_id)
      FROM funktion WHERE name = 'fn_rechnungstyp_speichern';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung eingeben.';
    END IF;

    IF COALESCE(p_id, 0) = 0 THEN
        INSERT INTO rechnungstyp (mandant_id, bezeichnung, reihenfolge, richtung, aktiv, erloes_konto_id, aufwand_konto_id)
        VALUES (p_mandant_id, btrim(p_bezeichnung), p_reihenfolge, p_richtung, COALESCE(p_aktiv, true), p_erloes_konto_id, p_aufwand_konto_id)
        RETURNING rechnungstyp_id INTO v_id;
    ELSE
        UPDATE rechnungstyp
           SET bezeichnung        = btrim(p_bezeichnung),
               reihenfolge        = p_reihenfolge,
               richtung           = p_richtung,
               aktiv              = COALESCE(p_aktiv, true),
               erloes_konto_id    = p_erloes_konto_id,
               aufwand_konto_id   = p_aufwand_konto_id
         WHERE rechnungstyp_id = p_id
        RETURNING rechnungstyp_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Diesen Eintrag gibt es nicht mehr.';
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- Register nachziehen
-- ---------------------------------------------------------------------------
INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public'
   AND p.proname IN ('fn_person_typ_speichern', 'fn_rolle_typ_speichern', 'fn_adressentyp_speichern', 'fn_emailtyp_speichern', 'fn_telefonnummertyp_speichern', 'fn_leadquelle_typ_speichern', 'fn_kompetenz_typ_speichern', 'fn_rechnungstyp_speichern')
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, 'direkt'
  FROM (VALUES
    ('fn_person_typ_speichern', 'person_typ', 'INSERT'),
    ('fn_person_typ_speichern', 'person_typ', 'UPDATE'),
    ('fn_rolle_typ_speichern', 'rolle_typ', 'INSERT'),
    ('fn_rolle_typ_speichern', 'rolle_typ', 'UPDATE'),
    ('fn_adressentyp_speichern', 'adressentyp', 'INSERT'),
    ('fn_adressentyp_speichern', 'adressentyp', 'UPDATE'),
    ('fn_emailtyp_speichern', 'emailtyp', 'INSERT'),
    ('fn_emailtyp_speichern', 'emailtyp', 'UPDATE'),
    ('fn_telefonnummertyp_speichern', 'telefonnummertyp', 'INSERT'),
    ('fn_telefonnummertyp_speichern', 'telefonnummertyp', 'UPDATE'),
    ('fn_leadquelle_typ_speichern', 'leadquelle_typ', 'INSERT'),
    ('fn_leadquelle_typ_speichern', 'leadquelle_typ', 'UPDATE'),
    ('fn_kompetenz_typ_speichern', 'kompetenz_typ', 'INSERT'),
    ('fn_kompetenz_typ_speichern', 'kompetenz_typ', 'UPDATE'),
    ('fn_rechnungstyp_speichern', 'rechnungstyp', 'INSERT'),
    ('fn_rechnungstyp_speichern', 'rechnungstyp', 'UPDATE'),
    ('fn_person_typ_speichern', 'funktion_aufruf', 'INSERT'),
    ('fn_rolle_typ_speichern', 'funktion_aufruf', 'INSERT'),
    ('fn_adressentyp_speichern', 'funktion_aufruf', 'INSERT'),
    ('fn_emailtyp_speichern', 'funktion_aufruf', 'INSERT'),
    ('fn_telefonnummertyp_speichern', 'funktion_aufruf', 'INSERT'),
    ('fn_leadquelle_typ_speichern', 'funktion_aufruf', 'INSERT'),
    ('fn_kompetenz_typ_speichern', 'funktion_aufruf', 'INSERT'),
    ('fn_rechnungstyp_speichern', 'funktion_aufruf', 'INSERT')
  ) AS t(fname, tabelle, wirkung)
  JOIN funktion f ON f.name = t.fname
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle AND ft.wirkung = t.wirkung);
