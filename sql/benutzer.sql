-- ============================================================================
-- Benutzer und Anmeldung — Stand 03.08.2026
--
-- WALTERS MODELL, wörtlich umgesetzt:
--   "das login beim ersten mandanten als rolle administrator schaltet alle
--    mandanten frei. dieser kann Personen Mandanten zuordnen. die
--    nachfolgenden mandanten haben keinen globalen administrator, höchstens
--    einen mandantenbezogenen. wenn jemand seine logindaten eintippt und er
--    gehört zu mandant 3 und ist kein globaler admin, dann kann er nur dinge
--    aus mandant 3 machen."
--
-- DARAUS FOLGT: Authentifizierung ist global (ein Anmeldename, ein Passwort),
-- Autorisierung haengt am Mandanten. Der globale Administrator ergibt sich
-- aus der Kombination "Rolle administrator IM STAMMMANDANTEN" — es braucht
-- also keine zweite Wahrheit in Form eines separaten ist_global-Flags.
--
-- WARUM `ist_stammmandant` STATT `MIN(mandant_id)`: Der "erste Mandant" ueber
-- die kleinste Nummer zu bestimmen ist fragil — wird Mandant 1 geloescht,
-- wandert die globale Administration stillschweigend zum naechsten. Ein
-- ausdrueckliches Kennzeichen mit partiellem Unique-Index laesst genau einen
-- Stammmandanten zu und macht die Absicht sichtbar.
--
-- PASSWOERTER: bcrypt ueber pgcrypto (`crypt` + `gen_salt('bf')`). Es wird
-- NIE ein Klartextpasswort gespeichert, und die Pruefung passiert in der
-- Datenbank — die Anwendung sieht den Hash nicht einmal.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ── 1. Der Stammmandant ────────────────────────────────────────────────────
ALTER TABLE mandant ADD COLUMN IF NOT EXISTS ist_stammmandant boolean
    NOT NULL DEFAULT false;

CREATE UNIQUE INDEX IF NOT EXISTS ux_mandant_stamm
    ON mandant (ist_stammmandant) WHERE ist_stammmandant;

COMMENT ON COLUMN mandant.ist_stammmandant IS
    'Genau EIN Mandant traegt dieses Kennzeichen. Wer dort Administrator ist, '
    'ist globaler Administrator und sieht alle Mandanten.';

-- Erstbelegung: der aelteste Mandant, aber nur falls noch keiner gesetzt ist.
UPDATE mandant SET ist_stammmandant = true
 WHERE mandant_id = (SELECT MIN(mandant_id) FROM mandant)
   AND NOT EXISTS (SELECT 1 FROM mandant WHERE ist_stammmandant);

-- ── 2. Benutzer ────────────────────────────────────────────────────────────
-- Getrennt von `person`, weil nicht jede Person ein Login hat: Klienten,
-- Lieferanten und Kontakte sind Personen ohne Zugang. `person_mandant` sagt
-- "gehoert zum Mandanten", `benutzer_mandant` sagt "darf dort arbeiten" —
-- zwei verschiedene Aussagen, die nicht in eine Tabelle gehoeren.
CREATE TABLE IF NOT EXISTS benutzer (
    benutzer_id     serial PRIMARY KEY,
    person_id       integer REFERENCES person(person_id),
    anmeldename     varchar(100) NOT NULL,
    passwort_hash   text NOT NULL,
    aktiv           boolean NOT NULL DEFAULT true,
    muss_passwort_aendern boolean NOT NULL DEFAULT false,
    letzter_login   timestamp,
    fehlversuche    integer NOT NULL DEFAULT 0,
    gesperrt_bis    timestamp,
    created_at      timestamp NOT NULL DEFAULT now(),
    -- Gross-/Kleinschreibung darf nicht zwei Konten erlauben
    CONSTRAINT benutzer_anmeldename_key UNIQUE (anmeldename)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_benutzer_name_ci
    ON benutzer (lower(anmeldename));

COMMENT ON TABLE benutzer IS
    'Wer sich anmelden kann. Teilmenge der Personen - Klienten haben kein '
    'Login. Passwort als bcrypt-Hash, nie im Klartext.';

-- ── 3. Zuordnung Benutzer -> Mandant mit Rolle ─────────────────────────────
CREATE TABLE IF NOT EXISTS benutzer_mandant (
    benutzer_id integer NOT NULL REFERENCES benutzer(benutzer_id) ON DELETE CASCADE,
    mandant_id  integer NOT NULL REFERENCES mandant(mandant_id),
    -- Bewusst nur zwei Rollen: was nicht durchgesetzt wird, soll auch nicht
    -- vorgegaukelt werden. Weitere (z.B. 'leser') lassen sich spaeter
    -- ergaenzen, sobald es Stellen gibt, die sie auswerten.
    rolle       varchar(20) NOT NULL DEFAULT 'benutzer'
                  CHECK (rolle IN ('administrator', 'benutzer')),
    aktiv       boolean NOT NULL DEFAULT true,
    zugeordnet_am timestamp NOT NULL DEFAULT now(),
    PRIMARY KEY (benutzer_id, mandant_id)
);

-- Aenderungen an Zugaengen gehoeren protokolliert (Muster aus sql/audit_log.sql)
DROP TRIGGER IF EXISTS tr_audit_benutzer_mandant ON benutzer_mandant;
CREATE TRIGGER tr_audit_benutzer_mandant
    AFTER INSERT OR UPDATE OR DELETE ON benutzer_mandant
    FOR EACH ROW EXECUTE FUNCTION fn_audit_erfassen('benutzer_id');

-- ── 4. Ist dieser Benutzer globaler Administrator? ─────────────────────────
-- Genau Walters Regel: Rolle administrator IM Stammmandanten.
CREATE OR REPLACE FUNCTION fn_ist_global_admin(p_benutzer_id integer)
RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1 FROM benutzer_mandant bm
          JOIN mandant m ON m.mandant_id = bm.mandant_id
         WHERE bm.benutzer_id = p_benutzer_id
           AND bm.rolle = 'administrator'
           AND bm.aktiv
           AND m.ist_stammmandant);
$$;

-- Welche Mandanten darf dieser Benutzer? Globaler Administrator bekommt ALLE
-- (auch die, denen er nie ausdruecklich zugeordnet wurde) — das ist der Kern
-- von "schaltet alle mandanten frei".
CREATE OR REPLACE FUNCTION fn_benutzer_mandanten(p_benutzer_id integer)
RETURNS TABLE (mandant_id integer, mandanten_name varchar, rolle varchar,
               ist_stammmandant boolean)
LANGUAGE sql STABLE AS $$
    SELECT m.mandant_id, m.mandanten_name,
           CASE WHEN fn_ist_global_admin(p_benutzer_id) THEN 'administrator'
                ELSE bm.rolle END::varchar,
           m.ist_stammmandant
      FROM mandant m
      LEFT JOIN benutzer_mandant bm
             ON bm.mandant_id = m.mandant_id
            AND bm.benutzer_id = p_benutzer_id
            AND bm.aktiv
     WHERE fn_ist_global_admin(p_benutzer_id) OR bm.benutzer_id IS NOT NULL
     ORDER BY m.ist_stammmandant DESC, m.mandanten_name;
$$;

-- Die Pruefprimitive fuer jeden Modulzugriff: darf dieser Benutzer in diesem
-- Mandanten arbeiten?
CREATE OR REPLACE FUNCTION fn_benutzer_darf_mandant(
    p_benutzer_id integer, p_mandant_id integer)
RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT fn_ist_global_admin(p_benutzer_id)
        OR EXISTS (SELECT 1 FROM benutzer_mandant
                    WHERE benutzer_id = p_benutzer_id
                      AND mandant_id = p_mandant_id AND aktiv);
$$;

-- Ist er im gegebenen Mandanten Administrator (global ODER mandantenbezogen)?
CREATE OR REPLACE FUNCTION fn_benutzer_ist_admin(
    p_benutzer_id integer, p_mandant_id integer)
RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT fn_ist_global_admin(p_benutzer_id)
        OR EXISTS (SELECT 1 FROM benutzer_mandant
                    WHERE benutzer_id = p_benutzer_id
                      AND mandant_id = p_mandant_id
                      AND rolle = 'administrator' AND aktiv);
$$;

-- ── 5. Anlegen und Passwort ────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_benutzer_anlegen(
    p_anmeldename varchar, p_passwort text, p_person_id integer DEFAULT NULL,
    p_mandant_id integer DEFAULT NULL, p_rolle varchar DEFAULT 'benutzer')
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_id integer;
BEGIN
    IF COALESCE(trim(p_anmeldename), '') = '' THEN
        RAISE EXCEPTION 'Der Anmeldename darf nicht leer sein.';
    END IF;
    IF length(COALESCE(p_passwort, '')) < 8 THEN
        RAISE EXCEPTION 'Das Passwort muss mindestens 8 Zeichen haben.';
    END IF;

    INSERT INTO benutzer (person_id, anmeldename, passwort_hash)
    VALUES (p_person_id, trim(p_anmeldename), crypt(p_passwort, gen_salt('bf')))
    RETURNING benutzer_id INTO v_id;

    IF p_mandant_id IS NOT NULL THEN
        INSERT INTO benutzer_mandant (benutzer_id, mandant_id, rolle)
        VALUES (v_id, p_mandant_id, p_rolle);
    END IF;

    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_benutzer_passwort_setzen(
    p_benutzer_id integer, p_passwort text, p_muss_aendern boolean DEFAULT false)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
    IF length(COALESCE(p_passwort, '')) < 8 THEN
        RAISE EXCEPTION 'Das Passwort muss mindestens 8 Zeichen haben.';
    END IF;
    UPDATE benutzer
       SET passwort_hash = crypt(p_passwort, gen_salt('bf')),
           muss_passwort_aendern = p_muss_aendern,
           fehlversuche = 0, gesperrt_bis = NULL
     WHERE benutzer_id = p_benutzer_id;
END;
$$;

-- ── 6. Anmelden ────────────────────────────────────────────────────────────
-- Liefert IMMER eine Zeile — bei Misserfolg mit benutzer_id NULL und einer
-- Meldung. So muss die Delphi-Seite nicht zwischen "keine Zeile" und "Fehler"
-- unterscheiden.
--
-- Die Meldung sagt bei falschen Daten bewusst NICHT, ob der Name oder das
-- Passwort falsch war — sonst liesse sich damit herausfinden, welche
-- Anmeldenamen es gibt.
--
-- Nach 5 Fehlversuchen 15 Minuten Sperre. Ohne Bremse waere ein Passwort
-- durch reines Durchprobieren zu finden.
CREATE OR REPLACE FUNCTION fn_benutzer_anmelden(
    p_anmeldename varchar, p_passwort text)
RETURNS TABLE (benutzer_id integer, person_id integer, anzeigename varchar,
               ist_global_admin boolean, muss_passwort_aendern boolean,
               meldung text)
LANGUAGE plpgsql AS $$
DECLARE b benutzer%ROWTYPE; v_name varchar;
BEGIN
    SELECT * INTO b FROM benutzer WHERE lower(anmeldename) = lower(trim(p_anmeldename));

    IF NOT FOUND THEN
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

-- ── 7. Ersteinrichtung ─────────────────────────────────────────────────────
-- Legt den ersten globalen Administrator im Stammmandanten an. Verweigert
-- den Dienst, sobald es bereits einen gibt — der Weg fuer weitere Konten
-- fuehrt danach ausschliesslich ueber die Benutzerverwaltung, nicht ueber
-- einen zweiten Aufruf dieser Funktion.
CREATE OR REPLACE FUNCTION fn_ersten_admin_anlegen(
    p_anmeldename varchar, p_passwort text, p_person_id integer DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_stamm integer; v_id integer;
BEGIN
    IF EXISTS (SELECT 1 FROM benutzer_mandant bm
                 JOIN mandant m ON m.mandant_id = bm.mandant_id
                WHERE bm.rolle = 'administrator' AND m.ist_stammmandant) THEN
        RAISE EXCEPTION 'Es gibt bereits einen globalen Administrator - '
            'weitere Konten bitte ueber die Benutzerverwaltung anlegen.';
    END IF;

    SELECT mandant_id INTO v_stamm FROM mandant WHERE ist_stammmandant;
    IF v_stamm IS NULL THEN
        RAISE EXCEPTION 'Es ist kein Stammmandant gekennzeichnet.';
    END IF;

    v_id := fn_benutzer_anlegen(p_anmeldename, p_passwort, p_person_id,
                                v_stamm, 'administrator');
    RETURN v_id;
END;
$$;

-- ── 8. Übersicht für die Verwaltung ────────────────────────────────────────
CREATE OR REPLACE VIEW v_benutzer_uebersicht AS
SELECT b.benutzer_id, b.anmeldename, b.aktiv, b.letzter_login,
       b.muss_passwort_aendern,
       (b.gesperrt_bis IS NOT NULL AND b.gesperrt_bis > now()) AS gesperrt,
       p.nachname_firmenname || COALESCE(', ' || p.vorname, '') AS person,
       fn_ist_global_admin(b.benutzer_id) AS global_admin,
       (SELECT string_agg(m.mandanten_name || ' (' || bm.rolle || ')', ', '
                          ORDER BY m.mandanten_name)
          FROM benutzer_mandant bm JOIN mandant m ON m.mandant_id = bm.mandant_id
         WHERE bm.benutzer_id = b.benutzer_id AND bm.aktiv) AS mandanten
  FROM benutzer b
  LEFT JOIN person p ON p.person_id = b.person_id;
