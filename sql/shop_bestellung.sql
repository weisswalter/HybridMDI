-- Eine Bestellung aus dem Webshop wird ein ganz normaler Beleg.
--
-- Kein shop_order, kein shop_order_item: das Bestellwesen gibt es schon
-- (beleg, beleg_position, belegart 'Bestellung', rechnungstyp 'Bestellung').
-- Eine Weblbestellung landet damit im Modul Kundenbestellung, bekommt beim
-- Visieren ihre Belegnummer aus dem Nummernkreis und laeuft durch dieselbe
-- Sperre wie jeder andere Beleg. Ein zweites Bestellwesen daneben haette
-- bedeutet: zwei Stellen pflegen, zwei Wahrheiten.
--
-- beleg.person_id ist NOT NULL - ein Weblkunde muss also eine Person werden.
-- Wiedererkannt wird er an der E-Mail-Adresse innerhalb des Mandanten;
-- nur wenn es ihn dort noch nicht gibt, wird er angelegt.

DROP FUNCTION IF EXISTS fn_shop_bestellung_anlegen(integer, varchar, varchar, text, jsonb);

CREATE OR REPLACE FUNCTION fn_shop_bestellung_anlegen(
    p_mandant_id integer,
    -- text statt varchar: Npgsql schickt Zeichenketten als text, und
    -- Postgres findet die Signatur sonst nicht ("Funktion existiert nicht").
    p_name       text,
    p_email      text,
    p_adresse    text,
    -- [{"artikel_id": 31|null, "bezeichnung": "...", "menge": 2,
    --   "einzelpreis": 249.00}, ...]
    p_positionen jsonb)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_person      integer;
    v_email_id    integer;
    v_adresse_id  integer;
    v_rechnungstyp integer;
    v_beleg       integer;
    v_pos         jsonb;
    v_nr          integer := 0;
    v_artikel     integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_mandant_id, p_name, p_email,
                                          p_adresse, p_positionen)
      FROM funktion WHERE name = 'fn_shop_bestellung_anlegen';

    IF btrim(COALESCE(p_name, '')) = '' OR btrim(COALESCE(p_email, '')) = '' THEN
        RAISE EXCEPTION 'Bitte Name und E-Mail angeben.';
    END IF;
    IF p_positionen IS NULL OR jsonb_array_length(p_positionen) = 0 THEN
        RAISE EXCEPTION 'Die Bestellung enthaelt keine Positionen.';
    END IF;

    -- ---------------------------------------------------------------- Person
    SELECT pm.person_id INTO v_person
      FROM person_mandant pm
      JOIN person_email pe ON pe.person_id = pm.person_id
                          AND pe.mandant_id = pm.mandant_id
      JOIN emailadresse e  ON e.email_id = pe.email_id
     WHERE pm.mandant_id = p_mandant_id
       AND lower(e.email_adresse) = lower(btrim(p_email))
     LIMIT 1;

    IF v_person IS NULL THEN
        -- typ_id 1 = Mensch. Ob dahinter eine Firma steckt, weiss der Shop
        -- nicht; das kann im ERP nachgezogen werden.
        INSERT INTO person (typ_id, nachname_firmenname)
        VALUES (1, btrim(p_name))
        RETURNING person_id INTO v_person;

        INSERT INTO person_mandant (person_id, mandant_id, trt_blazor_user,
                                    ist_hauptperson, im_web_anzeigen)
        VALUES (v_person, p_mandant_id, false, false, false);

        SELECT email_id INTO v_email_id
          FROM emailadresse WHERE lower(email_adresse) = lower(btrim(p_email));
        IF v_email_id IS NULL THEN
            INSERT INTO emailadresse (email_adresse) VALUES (btrim(p_email))
            RETURNING email_id INTO v_email_id;
        END IF;

        INSERT INTO person_email (person_id, email_id, mandant_id)
        VALUES (v_person, v_email_id, p_mandant_id)
        ON CONFLICT DO NOTHING;

        -- Die Anschrift kommt aus einem einzigen Feld des Formulars. Sie
        -- unaufgeloest in strasse zu stellen ist ehrlicher, als sie zu raten.
        IF btrim(COALESCE(p_adresse, '')) <> '' THEN
            INSERT INTO adresse (strasse) VALUES (btrim(p_adresse))
            RETURNING adresse_id INTO v_adresse_id;
            INSERT INTO person_adresse (person_id, adresse_id, mandant_id)
            VALUES (v_person, v_adresse_id, p_mandant_id);
        END IF;
    END IF;

    -- ----------------------------------------------------------------- Beleg
    SELECT rechnungstyp_id INTO v_rechnungstyp
      FROM rechnungstyp
     WHERE mandant_id = p_mandant_id AND bezeichnung = 'Bestellung' AND aktiv
     LIMIT 1;
    IF v_rechnungstyp IS NULL THEN
        RAISE EXCEPTION 'Fuer Mandant % ist kein Rechnungstyp "Bestellung" hinterlegt.',
                        p_mandant_id;
    END IF;

    -- Ohne Belegnummer: die zieht erst das Visieren im ERP aus dem
    -- Nummernkreis. Eine abgebrochene Weblbestellung soll keine Luecke in
    -- die Nummernfolge reissen.
    INSERT INTO beleg (mandant_id, belegart, rechnungstyp_id, person_id,
                       beleg_datum, status, bemerkung, empfaenger_text)
    VALUES (p_mandant_id, 'Bestellung', v_rechnungstyp, v_person,
            CURRENT_DATE, 'offen', 'Bestellung aus dem Webshop',
            btrim(p_name) || CASE WHEN btrim(COALESCE(p_adresse, '')) = ''
                                  THEN '' ELSE ', ' || btrim(p_adresse) END
                          || ' <' || btrim(p_email) || '>')
    RETURNING beleg_id INTO v_beleg;

    -- ------------------------------------------------------------ Positionen
    FOR v_pos IN SELECT * FROM jsonb_array_elements(p_positionen)
    LOOP
        v_nr := v_nr + 1;
        v_artikel := NULLIF(v_pos->>'artikel_id', '')::integer;

        -- beleg_position laesst keine reine Textzeile zu: der Check verlangt
        -- entweder artikel_id oder leistung_id. Eine Bestellung ohne
        -- Artikelnummer waere also gar nicht erfassbar - besser hier mit
        -- klarer Meldung abweisen als am Check scheitern.
        IF v_artikel IS NULL THEN
            RAISE EXCEPTION
              'Position "%" hat keine Artikelnummer. Im Shop duerfen nur Artikel aus dem Artikelstamm stehen (artikel.im_shop).',
              COALESCE(v_pos->>'bezeichnung', '?');
        END IF;

        IF NOT EXISTS (SELECT 1 FROM artikel a
                        WHERE a.artikel_id = v_artikel
                          AND a.mandant_id = p_mandant_id) THEN
            RAISE EXCEPTION 'Artikel % gehoert nicht zu Mandant %.',
                            v_artikel, p_mandant_id;
        END IF;

        INSERT INTO beleg_position (mandant_id, beleg_id, position_nr,
                                    artikel_id, bezeichnung, menge, einzelpreis)
        VALUES (p_mandant_id, v_beleg, v_nr, v_artikel,
                left(COALESCE(v_pos->>'bezeichnung', ''), 200),
                COALESCE((v_pos->>'menge')::numeric, 0),
                (v_pos->>'einzelpreis')::numeric);
    END LOOP;

    RETURN v_beleg;
END;
$$;

-- ---------------------------------------------------------------------------
UPDATE funktion SET parameterliste = (SELECT pg_get_function_arguments(p.oid) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.proname='fn_shop_bestellung_anlegen') WHERE name = 'fn_shop_bestellung_anlegen';

INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public' AND p.proname = 'fn_shop_bestellung_anlegen'
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, t.ueber
  FROM (VALUES
    ('beleg',           'INSERT', 'direkt'),
    ('beleg_position',  'INSERT', 'direkt'),
    ('person',          'INSERT', 'direkt'),
    ('person_mandant',  'INSERT', 'direkt'),
    ('emailadresse',    'INSERT', 'direkt'),
    ('person_email',    'INSERT', 'direkt'),
    ('adresse',         'INSERT', 'direkt'),
    ('person_adresse',  'INSERT', 'direkt'),
    ('audit_log',       'INSERT', 'trigger'),
    ('funktion_aufruf', 'INSERT', 'direkt')
  ) AS t(tabelle, wirkung, ueber)
  JOIN funktion f ON f.name = 'fn_shop_bestellung_anlegen'
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle AND ft.wirkung = t.wirkung);
