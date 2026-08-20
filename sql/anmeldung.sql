-- Anmeldung: Benutzer je Person, E-Mail als Ersatz fuer den Anmeldenamen,
-- und eine Anmeldepflicht, die man wirklich schalten kann.
--
-- Ausgangslage:
--   * benutzer.person_id gibt es schon, fn_benutzer_anlegen nimmt sie
--     entgegen - jede Person kann also ein Konto bekommen.
--   * fn_benutzer_anmelden kannte nur den Anmeldenamen.
--   * fn_anmeldung_erforderlich hiess bisher schlicht "es gibt mindestens
--     ein aktives Konto". Abschalten ging damit nur, indem man alle Konten
--     deaktiviert, und einschalten erst, nachdem eines existiert.

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Ein Platz fuer Schalter, die den ganzen Betrieb betreffen.
--    Nicht an den Mandanten gehaengt: ein Konto gilt ueber Mandanten hinweg
--    (die Zuordnung steht in benutzer_mandant), also gilt auch die Frage
--    "muss man sich anmelden" fuer die Anwendung als Ganzes.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS systemeinstellung (
    schluessel  varchar(50) PRIMARY KEY,
    wert        text,
    bezeichnung varchar(200),
    geaendert_am timestamp NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION fn_einstellung_lesen(p_schluessel varchar)
RETURNS text
LANGUAGE sql
STABLE
AS $$
    SELECT wert FROM systemeinstellung WHERE schluessel = p_schluessel;
$$;

CREATE OR REPLACE FUNCTION fn_einstellung_setzen(
    p_schluessel  varchar,
    p_wert        text,
    p_bezeichnung varchar DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_schluessel, p_wert, p_bezeichnung)
      FROM funktion WHERE name = 'fn_einstellung_setzen';

    INSERT INTO systemeinstellung (schluessel, wert, bezeichnung)
    VALUES (p_schluessel, p_wert, p_bezeichnung)
    ON CONFLICT (schluessel) DO UPDATE
       SET wert = EXCLUDED.wert,
           bezeichnung = COALESCE(EXCLUDED.bezeichnung, systemeinstellung.bezeichnung),
           geaendert_am = now();
END;
$$;

-- ---------------------------------------------------------------------------
-- 2. Anmeldepflicht als ausdruecklicher Schalter.
--    Ohne Eintrag bleibt es beim bisherigen Verhalten - eine bestehende
--    Installation aendert sich durch dieses Skript also nicht.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_anmeldung_erforderlich()
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
    SELECT CASE fn_einstellung_lesen('ANMELDEPFLICHT')
             WHEN 'true'  THEN true
             WHEN 'false' THEN false
             ELSE EXISTS (SELECT 1 FROM benutzer WHERE aktiv)
           END;
$$;

CREATE OR REPLACE FUNCTION fn_anmeldepflicht_setzen(p_an boolean)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_an)
      FROM funktion WHERE name = 'fn_anmeldepflicht_setzen';

    -- Einschalten ohne ein einziges Konto wuerde die Anwendung aussperren.
    IF p_an AND NOT EXISTS (SELECT 1 FROM benutzer WHERE aktiv) THEN
        RAISE EXCEPTION
          'Es gibt noch kein aktives Benutzerkonto. Erst ein Konto anlegen, sonst kommt niemand mehr herein.';
    END IF;

    PERFORM fn_einstellung_setzen('ANMELDEPFLICHT',
        CASE WHEN p_an THEN 'true' ELSE 'false' END,
        'Muss man sich beim Start anmelden?');
END;
$$;

-- ---------------------------------------------------------------------------
-- 3. E-Mail als Ersatz fuer den Anmeldenamen
-- ---------------------------------------------------------------------------
ALTER TABLE person_email
    ADD COLUMN IF NOT EXISTS ist_anmeldename boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN person_email.ist_anmeldename IS
  'true = mit dieser Adresse kann man sich statt mit dem Anmeldenamen anmelden.';

-- Eine als Anmeldung markierte Adresse darf nicht zu zwei Personen fuehren,
-- sonst waere nicht entscheidbar, wer sich da anmeldet.
CREATE UNIQUE INDEX IF NOT EXISTS ux_person_email_anmeldung
    ON person_email(email_id) WHERE ist_anmeldename;

CREATE OR REPLACE FUNCTION fn_email_anmeldename_setzen(
    p_person_id  integer,
    p_email_id   integer,
    p_mandant_id integer,
    p_ja         boolean)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_person_id, p_email_id,
                                          p_mandant_id, p_ja)
      FROM funktion WHERE name = 'fn_email_anmeldename_setzen';

    IF p_ja AND EXISTS (SELECT 1 FROM person_email pe
                         WHERE pe.email_id = p_email_id
                           AND pe.ist_anmeldename
                           AND pe.person_id <> p_person_id) THEN
        RAISE EXCEPTION
          'Diese Adresse ist bereits die Anmeldung einer anderen Person.';
    END IF;

    UPDATE person_email
       SET ist_anmeldename = p_ja
     WHERE person_id = p_person_id
       AND email_id = p_email_id
       AND mandant_id = p_mandant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diese Zuordnung von Person und E-Mail gibt es nicht.';
    END IF;
END;
$$;

COMMIT;

-- ---------------------------------------------------------------------------
-- 4. Anmelden mit Anmeldename ODER markierter E-Mail.
--    Rueckgabe unveraendert - BenutzerDm liest genau diese Spalten.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_benutzer_anmelden(
    p_anmeldename character varying,
    p_passwort    text)
RETURNS TABLE(benutzer_id integer, person_id integer, anzeigename character varying,
              ist_global_admin boolean, muss_passwort_aendern boolean, meldung text)
LANGUAGE plpgsql
AS $$
DECLARE
    b        benutzer%ROWTYPE;
    v_name   varchar;
    v_kennung varchar := lower(btrim(p_anmeldename));
    v_anzahl integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_anmeldename,
             (CASE WHEN p_passwort IS NULL THEN NULL ELSE '<geheim>' END))
      FROM funktion WHERE name = 'fn_benutzer_anmelden';

    -- Erst der Anmeldename.
    SELECT * INTO b FROM benutzer WHERE lower(anmeldename) = v_kennung;

    -- Dann die als Anmeldung markierte E-Mail. Der eindeutige Index sorgt
    -- dafuer, dass eine Adresse nur zu einer Person gehoert; mehrere Konten
    -- an derselben Person waeren aber trotzdem nicht entscheidbar.
    IF NOT FOUND THEN
        SELECT count(*) INTO v_anzahl
          FROM benutzer bu
         WHERE bu.aktiv
           AND bu.person_id IN (SELECT pe.person_id
                                  FROM person_email pe
                                  JOIN emailadresse e ON e.email_id = pe.email_id
                                 WHERE pe.ist_anmeldename
                                   AND lower(e.email_adresse) = v_kennung);

        IF v_anzahl > 1 THEN
            RETURN QUERY SELECT NULL::integer, NULL::integer, NULL::varchar, false, false,
                'Zu dieser Adresse gehoeren mehrere Konten. Bitte den Anmeldenamen verwenden.'::text;
            RETURN;
        END IF;

        SELECT bu.* INTO b
          FROM benutzer bu
         WHERE bu.aktiv
           AND bu.person_id IN (SELECT pe.person_id
                                  FROM person_email pe
                                  JOIN emailadresse e ON e.email_id = pe.email_id
                                 WHERE pe.ist_anmeldename
                                   AND lower(e.email_adresse) = v_kennung);
    END IF;

    IF b.benutzer_id IS NULL THEN
        RETURN QUERY SELECT NULL::integer, NULL::integer, NULL::varchar, false, false,
            'Anmeldename oder Passwort stimmt nicht.'::text;
        RETURN;
    END IF;

    IF NOT b.aktiv THEN
        RETURN QUERY SELECT NULL::integer, NULL::integer, NULL::varchar, false, false,
            'Dieses Konto ist deaktiviert.'::text;
        RETURN;
    END IF;

    IF b.gesperrt_bis IS NOT NULL AND b.gesperrt_bis > clock_timestamp() THEN
        RETURN QUERY SELECT NULL::integer, NULL::integer, NULL::varchar, false, false,
            ('Zu viele Fehlversuche. Wieder moeglich ab '
             || to_char(b.gesperrt_bis, 'HH24:MI') || ' Uhr.')::text;
        RETURN;
    END IF;

    IF b.passwort_hash <> crypt(p_passwort, b.passwort_hash) THEN
        UPDATE benutzer
           SET fehlversuche = fehlversuche + 1,
               gesperrt_bis = CASE WHEN fehlversuche + 1 >= 5
                                   THEN clock_timestamp() + interval '15 minutes'
                                   ELSE NULL END
         WHERE benutzer.benutzer_id = b.benutzer_id;
        RETURN QUERY SELECT NULL::integer, NULL::integer, NULL::varchar, false, false,
            'Anmeldename oder Passwort stimmt nicht.'::text;
        RETURN;
    END IF;

    UPDATE benutzer SET letzter_login = clock_timestamp(), fehlversuche = 0,
                        gesperrt_bis = NULL
     WHERE benutzer.benutzer_id = b.benutzer_id;

    SELECT COALESCE(p.nachname_firmenname || COALESCE(', ' || p.vorname, ''),
                    b.anmeldename)
      INTO v_name
      FROM benutzer bb LEFT JOIN person p ON p.person_id = bb.person_id
     WHERE bb.benutzer_id = b.benutzer_id;

    RETURN QUERY SELECT b.benutzer_id, b.person_id, v_name,
        fn_ist_global_admin(b.benutzer_id), b.muss_passwort_aendern,
        'OK'::text;
END;
$$;

-- ---------------------------------------------------------------------------
-- 5. Was das Fenster braucht: Personen mit ihrem Konto, und die Adressen
--    einer Person samt Markierung.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_person_konto AS
SELECT p.person_id,
       pm.mandant_id,
       COALESCE(p.nachname_firmenname || COALESCE(', ' || p.vorname, ''), '')
           AS anzeigename,
       b.benutzer_id,
       b.anmeldename,
       COALESCE(b.aktiv, false) AS konto_aktiv,
       b.letzter_login,
       (SELECT count(*) FROM person_email pe
         WHERE pe.person_id = p.person_id AND pe.ist_anmeldename)::integer
           AS anmelde_adressen
  FROM person p
  JOIN person_mandant pm ON pm.person_id = p.person_id
  LEFT JOIN benutzer b ON b.person_id = p.person_id;

CREATE OR REPLACE VIEW v_person_email_anmeldung AS
SELECT pe.person_id, pe.mandant_id, pe.email_id, e.email_adresse,
       pe.ist_anmeldename
  FROM person_email pe
  JOIN emailadresse e ON e.email_id = pe.email_id;

-- ---------------------------------------------------------------------------
-- Register nachziehen
-- ---------------------------------------------------------------------------
INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public'
   AND p.proname IN ('fn_einstellung_lesen', 'fn_einstellung_setzen',
                     'fn_anmeldepflicht_setzen', 'fn_email_anmeldename_setzen')
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, t.ueber
  FROM (VALUES
    ('fn_einstellung_setzen',       'systemeinstellung', 'INSERT', 'direkt'),
    ('fn_einstellung_setzen',       'systemeinstellung', 'UPDATE', 'direkt'),
    ('fn_einstellung_setzen',       'funktion_aufruf',   'INSERT', 'direkt'),
    ('fn_anmeldepflicht_setzen',    'systemeinstellung', 'UPDATE', 'kaskade'),
    ('fn_anmeldepflicht_setzen',    'funktion_aufruf',   'INSERT', 'direkt'),
    ('fn_email_anmeldename_setzen', 'person_email',      'UPDATE', 'direkt'),
    ('fn_email_anmeldename_setzen', 'funktion_aufruf',   'INSERT', 'direkt')
  ) AS t(fname, tabelle, wirkung, ueber)
  JOIN funktion f ON f.name = t.fname
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle AND ft.wirkung = t.wirkung);
