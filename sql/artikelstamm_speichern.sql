-- ============================================================================
-- Artikelstamm: Stammsatz und Bestand schreiben
--
-- Warum es diese Datei gibt: nach der Umstellung auf das zentrale Datenmodul
-- sind tblArtikel und tblArtikelFach TFDMemTable — Speicherkopien. Die
-- Buttonleiste rief darauf Append/Edit/Post, und SetBestand ebenso. Beides
-- landete im Arbeitsspeicher und war beim naechsten Auffrischen weg, ohne
-- Fehlermeldung. Es gab weder fn_artikel_speichern noch fn_artikel_fach_*.
-- Damit war der Artikelstamm faktisch nur lesbar.
--
-- Gleiches Muster wie fn_artikel_foto_speichern: 0/NULL als Schluessel heisst
-- anlegen, NULL bei einem Feld heisst "unveraendert lassen".
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Artikel anlegen oder aendern
--
--    Die drei Felder, die das Artikelstammfenster NICHT anzeigt
--    (erloes_konto_id, aufwand_konto_id, im_shop), duerfen beim Aendern nicht
--    verlorengehen: sonst schaltet ein Speichern im Stammfenster jeden
--    Shop-Artikel wieder aus. NULL heisst deshalb "so lassen".
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_artikel_speichern(
    p_mandant_id       integer,
    p_artikel_id       integer DEFAULT NULL,
    p_artikel_nr       text    DEFAULT NULL,
    p_artikelname      text    DEFAULT NULL,
    p_serien_nr        text    DEFAULT NULL,
    p_modul_nr         text    DEFAULT NULL,
    p_beschreibung     text    DEFAULT NULL,
    p_erloes_konto_id  integer DEFAULT NULL,
    p_aufwand_konto_id integer DEFAULT NULL,
    p_im_shop          boolean DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id,
           jsonb_build_array(p_mandant_id, p_artikel_id, p_artikel_nr,
                             p_artikelname, p_serien_nr, p_modul_nr,
                             p_beschreibung, p_erloes_konto_id,
                             p_aufwand_konto_id, p_im_shop)
      FROM funktion WHERE name = 'fn_artikel_speichern';

    IF COALESCE(p_mandant_id, 0) <= 0 THEN
        RAISE EXCEPTION 'Mandant fehlt.';
    END IF;
    IF btrim(COALESCE(p_artikel_nr, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Artikelnummer angeben.';
    END IF;
    IF btrim(COALESCE(p_artikelname, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung angeben.';
    END IF;
    -- Die Eindeutigkeit steckt auch im Index; hier abgefangen, damit der
    -- Anwender einen lesbaren Satz sieht statt einer Constraint-Meldung.
    IF EXISTS (SELECT 1 FROM artikel
                WHERE mandant_id = p_mandant_id
                  AND artikel_nr = btrim(p_artikel_nr)
                  AND artikel_id IS DISTINCT FROM NULLIF(p_artikel_id, 0)) THEN
        RAISE EXCEPTION 'Die Artikelnummer "%" gibt es bei diesem Mandanten schon.',
                        btrim(p_artikel_nr);
    END IF;

    IF COALESCE(p_artikel_id, 0) = 0 THEN
        INSERT INTO artikel (mandant_id, artikel_nr, artikelname, serien_nr,
                             modul_nr, beschreibung, erloes_konto_id,
                             aufwand_konto_id, im_shop, created_at, updated_at)
        VALUES (p_mandant_id, btrim(p_artikel_nr), btrim(p_artikelname),
                p_serien_nr, p_modul_nr, p_beschreibung, p_erloes_konto_id,
                p_aufwand_konto_id, COALESCE(p_im_shop, false), now(), now())
        RETURNING artikel_id INTO v_id;
    ELSE
        UPDATE artikel
           SET artikel_nr       = btrim(p_artikel_nr),
               artikelname      = btrim(p_artikelname),
               serien_nr        = p_serien_nr,
               modul_nr         = p_modul_nr,
               beschreibung     = p_beschreibung,
               -- Nicht im Fenster sichtbar: nur aendern, wenn etwas mitkommt.
               erloes_konto_id  = COALESCE(p_erloes_konto_id, erloes_konto_id),
               aufwand_konto_id = COALESCE(p_aufwand_konto_id, aufwand_konto_id),
               im_shop          = COALESCE(p_im_shop, im_shop),
               updated_at       = now()
         WHERE artikel_id = p_artikel_id AND mandant_id = p_mandant_id
        RETURNING artikel_id INTO v_id;

        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Artikel % gibt es fuer Mandant % nicht.',
                            p_artikel_id, p_mandant_id;
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- 2. Bestand eines Artikels in einem Fach setzen
--
--    Der Schluessel ist fachlich (artikel_id, fach_id, variante_id) — genau
--    das, was die beiden partiellen UNIQUE-Indizes erzwingen. Der Aufrufer
--    (Bestand-Baum) kennt nur Fach und Menge, keine artikel_fach_id.
--
--    p_bestand ist double precision, NICHT numeric: FireDAC schickt ein
--    Delphi-Double als float8, und Postgres wandelt das bei der
--    Funktionsauswahl nicht nach numeric um ("Funktion existiert nicht").
--    Umgewandelt wird deshalb erst beim Schreiben. Gleiches Muster wie
--    p_menge in fn_stueckliste_hinzufuegen.
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_artikel_fach_speichern(integer, integer, integer,
                                                  numeric, integer, integer);

CREATE OR REPLACE FUNCTION fn_artikel_fach_speichern(
    p_mandant_id  integer,
    p_artikel_id  integer,
    p_fach_id     integer,
    p_bestand     double precision,
    p_variante_id integer DEFAULT NULL,
    p_einheit_id  integer DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id,
           jsonb_build_array(p_mandant_id, p_artikel_id, p_fach_id, p_bestand,
                             p_variante_id, p_einheit_id)
      FROM funktion WHERE name = 'fn_artikel_fach_speichern';

    IF COALESCE(p_mandant_id, 0) <= 0 THEN
        RAISE EXCEPTION 'Mandant fehlt.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM artikel
                    WHERE artikel_id = p_artikel_id
                      AND mandant_id = p_mandant_id) THEN
        RAISE EXCEPTION 'Artikel % gehoert nicht zu Mandant %.',
                        p_artikel_id, p_mandant_id;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM regal_fach WHERE fach_id = p_fach_id) THEN
        RAISE EXCEPTION 'Das Fach % gibt es nicht.', p_fach_id;
    END IF;
    IF p_bestand IS NULL OR p_bestand < 0 THEN
        RAISE EXCEPTION 'Der Bestand darf nicht kleiner als null sein.';
    END IF;

    SELECT artikel_fach_id INTO v_id
      FROM artikel_fach
     WHERE artikel_id = p_artikel_id
       AND fach_id    = p_fach_id
       AND variante_id IS NOT DISTINCT FROM p_variante_id;

    IF v_id IS NULL THEN
        INSERT INTO artikel_fach (mandant_id, artikel_id, fach_id,
                                  variante_id, bestand, einheit_id)
        VALUES (p_mandant_id, p_artikel_id, p_fach_id, p_variante_id,
                p_bestand::numeric, p_einheit_id)
        RETURNING artikel_fach_id INTO v_id;
    ELSE
        UPDATE artikel_fach
           SET bestand    = p_bestand::numeric,
               einheit_id = COALESCE(p_einheit_id, einheit_id)
         WHERE artikel_fach_id = v_id;
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
   AND p.proname IN ('fn_artikel_speichern', 'fn_artikel_fach_speichern')
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, t.ueber
  FROM (VALUES
    ('fn_artikel_speichern',      'artikel',         'INSERT', 'direkt'),
    ('fn_artikel_speichern',      'artikel',         'UPDATE', 'direkt'),
    ('fn_artikel_speichern',      'funktion_aufruf', 'INSERT', 'direkt'),
    ('fn_artikel_fach_speichern', 'artikel_fach',    'INSERT', 'direkt'),
    ('fn_artikel_fach_speichern', 'artikel_fach',    'UPDATE', 'direkt'),
    ('fn_artikel_fach_speichern', 'artikel',         'SELECT', 'direkt'),
    ('fn_artikel_fach_speichern', 'regal_fach',      'SELECT', 'direkt'),
    ('fn_artikel_fach_speichern', 'funktion_aufruf', 'INSERT', 'direkt')
  ) AS t(fname, tabelle, wirkung, ueber)
  JOIN funktion f ON f.name = t.fname
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle
                      AND ft.wirkung = t.wirkung);
