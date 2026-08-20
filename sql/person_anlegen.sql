-- ============================================================================
-- Person anlegen — Stamm und Bruecken in einem Zug — Stand 02.08.2026
--
-- ANLASS: Zweimal ist das Anlegen einer Person mit NULL-Fremdschluesseln in
-- person_mandant bzw. person_adresse abgestuerzt. Die Ursache war jedes Mal
-- dieselbe Bauart: Die Anwendung schreibt erst den Stammsatz, holt sich die
-- neue ID, und schreibt danach die Bruecken. Zwischen diesen Schritten kann
-- alles Moegliche dazwischenkommen — und dann steht ein Stammsatz ohne
-- Mandantenzuordnung in der Datenbank.
--
-- Diese Funktion macht den Fehler strukturell unmoeglich: Entweder es
-- entsteht die Person MIT ihrer Mandantenzuordnung (und der Adresse, wenn
-- eine angegeben ist), oder es entsteht gar nichts.
--
-- WARUM FUNKTION UND NICHT PROCEDURE: Eine PostgreSQL-Funktion kann nicht
-- committen — sie laeuft in der Transaktion des Aufrufers. Sie ist dafuer
-- von sich aus atomar: Fliegt irgendwo eine Ausnahme, ist alles zurueck-
-- genommen, was sie angefasst hat. Genau das gewuenschte Verhalten, ohne ein
-- einziges COMMIT im Code. Eine PROCEDURE mit CALL braeuchte man erst, wenn
-- ein Aufruf mehrere unabhaengige Commits erzeugen soll.
-- ============================================================================

-- Damit die Wiederverwendung unten auch bei gleichzeitigen Anlagen haelt:
-- ohne diesen Index koennten zwei parallele Aufrufe beide "nicht gefunden"
-- feststellen und je eine Zeile anlegen. Beim Anlegen war die Tabelle
-- dublettenfrei (geprueft, 7 Zeilen).
CREATE UNIQUE INDEX IF NOT EXISTS ux_adresse_eindeutig ON adresse (
    lower(TRIM(COALESCE(strasse, ''))),
    lower(TRIM(COALESCE(hausnummer, ''))),
    TRIM(COALESCE(plz, '')),
    lower(TRIM(COALESCE(ort, ''))),
    COALESCE(land_id, -1)
);

CREATE OR REPLACE FUNCTION fn_person_anlegen(
    p_mandant_id           integer,
    p_typ_id               integer,
    p_nachname_firmenname  varchar,
    p_vorname              varchar     DEFAULT NULL,
    p_titel                varchar     DEFAULT NULL,
    p_geburtsdatum         date        DEFAULT NULL,
    p_beschreibung         text        DEFAULT NULL,
    p_ist_hauptperson      boolean     DEFAULT false,
    p_im_web_anzeigen      boolean     DEFAULT false,
    -- Adresse: alles oder nichts. Ist p_strasse und p_ort leer, wird keine
    -- Adresse angelegt und keine Bruecke geschrieben.
    p_strasse              varchar     DEFAULT NULL,
    p_hausnummer           varchar     DEFAULT NULL,
    p_plz                  varchar     DEFAULT NULL,
    p_ort                  varchar     DEFAULT NULL,
    p_land_id              integer     DEFAULT NULL,
    p_adressentyp_id       integer     DEFAULT NULL
)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_person_id  integer;
    v_adresse_id integer;
    v_hat_adresse boolean;
BEGIN
    -- ── Eingangspruefungen ───────────────────────────────────────────────
    -- Lieber hier mit klarem Text scheitern als spaeter mit einer
    -- Fremdschluesselverletzung, die niemand liest.
    IF p_mandant_id IS NULL THEN
        RAISE EXCEPTION 'Mandant fehlt — eine Person ohne Mandant ist nicht vorgesehen.'
            USING ERRCODE = '23502';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM mandant WHERE mandant_id = p_mandant_id) THEN
        RAISE EXCEPTION 'Mandant % existiert nicht.', p_mandant_id
            USING ERRCODE = '23503';
    END IF;

    IF p_typ_id IS NULL THEN
        RAISE EXCEPTION 'Personentyp fehlt.' USING ERRCODE = '23502';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM person_typ WHERE typ_id = p_typ_id) THEN
        RAISE EXCEPTION 'Personentyp % existiert nicht.', p_typ_id
            USING ERRCODE = '23503';
    END IF;

    IF COALESCE(TRIM(p_nachname_firmenname), '') = '' THEN
        RAISE EXCEPTION 'Nachname bzw. Firmenname fehlt.'
            USING ERRCODE = '23502';
    END IF;

    -- Adresse nur, wenn ueberhaupt etwas Brauchbares dasteht.
    v_hat_adresse := COALESCE(TRIM(p_strasse), '') <> ''
                  OR COALESCE(TRIM(p_ort), '')    <> '';

    -- Der Adressentyp haengt am zusammengesetzten Schluessel
    -- (mandant_id, adressentyp_id). Ein Typ eines fremden Mandanten wuerde
    -- erst beim INSERT auffliegen — hier faellt es frueher und lesbarer auf.
    IF v_hat_adresse AND p_adressentyp_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM adressentyp
                        WHERE mandant_id = p_mandant_id
                          AND adressentyp_id = p_adressentyp_id) THEN
            RAISE EXCEPTION
                'Adressentyp % gehoert nicht zu Mandant %.',
                p_adressentyp_id, p_mandant_id USING ERRCODE = '23503';
        END IF;
    END IF;

    -- ── Stammsatz ────────────────────────────────────────────────────────
    INSERT INTO person (typ_id, vorname, nachname_firmenname, titel,
                        geburtsdatum, beschreibung)
    VALUES (p_typ_id, NULLIF(TRIM(p_vorname), ''),
            TRIM(p_nachname_firmenname), NULLIF(TRIM(p_titel), ''),
            p_geburtsdatum, NULLIF(TRIM(p_beschreibung), ''))
    RETURNING person_id INTO v_person_id;

    -- ── Mandantenzuordnung, nicht verhandelbar ───────────────────────────
    INSERT INTO person_mandant (person_id, mandant_id, ist_hauptperson,
                                im_web_anzeigen)
    VALUES (v_person_id, p_mandant_id, COALESCE(p_ist_hauptperson, false),
            COALESCE(p_im_web_anzeigen, false));

    -- ── Adresse, wenn angegeben ──────────────────────────────────────────
    IF v_hat_adresse THEN
        -- Eine bestehende Adresse wird WIEDERVERWENDET, nicht kopiert.
        -- Wenn fuenf Leute im selben Haus wohnen und die Stadt benennt die
        -- Strasse um, darf die Aenderung genau einmal noetig sein. Genau
        -- dafuer gibt es die Bruecke person_adresse — waeren Adressen
        -- personengebunden, saesse adresse_id direkt auf person.
        SELECT a.adresse_id INTO v_adresse_id
          FROM adresse a
         WHERE lower(TRIM(COALESCE(a.strasse, '')))
                 = lower(TRIM(COALESCE(p_strasse, '')))
           AND lower(TRIM(COALESCE(a.hausnummer, '')))
                 = lower(TRIM(COALESCE(p_hausnummer, '')))
           AND TRIM(COALESCE(a.plz, '')) = TRIM(COALESCE(p_plz, ''))
           AND lower(TRIM(COALESCE(a.ort, '')))
                 = lower(TRIM(COALESCE(p_ort, '')))
           AND a.land_id IS NOT DISTINCT FROM p_land_id
         LIMIT 1;

        IF v_adresse_id IS NULL THEN
            INSERT INTO adresse (strasse, hausnummer, plz, ort, land_id)
            VALUES (NULLIF(TRIM(p_strasse), ''),
                    NULLIF(TRIM(p_hausnummer), ''),
                    NULLIF(TRIM(p_plz), ''), NULLIF(TRIM(p_ort), ''),
                    p_land_id)
            RETURNING adresse_id INTO v_adresse_id;
        END IF;

        INSERT INTO person_adresse (person_id, adresse_id, mandant_id,
                                    adressentyp_id)
        VALUES (v_person_id, v_adresse_id, p_mandant_id, p_adressentyp_id);
    END IF;

    RETURN v_person_id;
END;
$$;

COMMENT ON FUNCTION fn_person_anlegen IS
    'Legt Person, Mandantenzuordnung und optional Adresse in einem Zug an. '
    'Entweder alles oder nichts — verhindert Stammsaetze ohne Bruecke.';

-- ============================================================================
-- Person einem weiteren Mandanten zuordnen. Dieselbe Falle: die Bruecke
-- entsteht sonst von Hand und kann danebengehen.
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_person_mandant_zuordnen(
    p_person_id       integer,
    p_mandant_id      integer,
    p_ist_hauptperson boolean DEFAULT false
)
RETURNS boolean
LANGUAGE plpgsql AS $$
BEGIN
    IF p_person_id IS NULL OR p_mandant_id IS NULL THEN
        RAISE EXCEPTION 'Person und Mandant muessen beide angegeben sein.'
            USING ERRCODE = '23502';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM person WHERE person_id = p_person_id) THEN
        RAISE EXCEPTION 'Person % existiert nicht.', p_person_id
            USING ERRCODE = '23503';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM mandant WHERE mandant_id = p_mandant_id) THEN
        RAISE EXCEPTION 'Mandant % existiert nicht.', p_mandant_id
            USING ERRCODE = '23503';
    END IF;

    INSERT INTO person_mandant (person_id, mandant_id, ist_hauptperson)
    VALUES (p_person_id, p_mandant_id, COALESCE(p_ist_hauptperson, false))
    ON CONFLICT (person_id, mandant_id) DO NOTHING;

    -- true = neu angelegt, false = war schon zugeordnet
    RETURN FOUND;
END;
$$;
