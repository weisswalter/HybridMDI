-- ============================================================================
-- Artikelfotos speichern und loeschen
--
-- Warum es diese Datei gibt: btnFotoLadenClick hat das Bild bisher per
-- Append/Edit + LoadFromFile in tblArtikelFoto geschrieben. Das ist eine
-- Speicherkopie aus dem zentralen Datenmodul - der Post landete nie in der
-- Datenbank, ohne Fehlermeldung. artikel_foto war deshalb leer, und der
-- Webshop zeigte bei jedem Artikel "Kein Bild vorhanden".
--
-- Vorbild fuer den Umgang mit dem Blob ist fn_lager_speichern: das Bild wird
-- nur ueberschrieben, wenn wirklich eines mitkommt (COALESCE), und in
-- funktion_aufruf steht nicht das Bild selbst, sondern seine Groesse.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Foto anlegen oder aendern
--    p_foto_id 0/NULL  -> neuer Satz
--    p_foto    NULL    -> Bild bleibt, nur Beschreibung/Reihenfolge aendern
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_artikel_foto_speichern(
    p_mandant_id   integer,
    p_artikel_id   integer,
    p_foto_id      integer DEFAULT NULL,
    p_foto         bytea   DEFAULT NULL,
    p_beschreibung text    DEFAULT NULL,
    p_reihenfolge  integer DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id,
           jsonb_build_array(p_mandant_id, p_artikel_id, p_foto_id,
                             '<bytea ' || COALESCE(octet_length(p_foto), 0)::text
                                       || ' Bytes>',
                             p_beschreibung, p_reihenfolge)
      FROM funktion WHERE name = 'fn_artikel_foto_speichern';

    IF COALESCE(p_mandant_id, 0) <= 0 THEN
        RAISE EXCEPTION 'Mandant fehlt.';
    END IF;
    IF COALESCE(p_artikel_id, 0) <= 0 THEN
        RAISE EXCEPTION 'Ohne Artikel kein Foto.';
    END IF;
    -- Der Artikel muss dem Mandanten gehoeren. Sonst haenge das Foto an
    -- einem fremden Artikel - der Fremdschluessel allein merkt das nicht.
    IF NOT EXISTS (SELECT 1 FROM artikel
                    WHERE artikel_id = p_artikel_id
                      AND mandant_id = p_mandant_id) THEN
        RAISE EXCEPTION 'Artikel % gehoert nicht zu Mandant %.',
                        p_artikel_id, p_mandant_id;
    END IF;

    IF COALESCE(p_foto_id, 0) = 0 THEN
        INSERT INTO artikel_foto (mandant_id, artikel_id, foto,
                                  beschreibung, reihenfolge)
        VALUES (p_mandant_id, p_artikel_id, p_foto, p_beschreibung,
                COALESCE(p_reihenfolge,
                         (SELECT COALESCE(MAX(reihenfolge), 0) + 1
                            FROM artikel_foto
                           WHERE artikel_id = p_artikel_id)))
        RETURNING foto_id INTO v_id;
    ELSE
        UPDATE artikel_foto
           SET beschreibung = p_beschreibung,
               reihenfolge  = COALESCE(p_reihenfolge, reihenfolge),
               -- Nur ueberschreiben, wenn ein Bild mitkommt: sonst wuerde
               -- ein Speichern der Beschreibung das Foto loeschen.
               foto         = COALESCE(p_foto, foto)
         WHERE foto_id    = p_foto_id
           AND mandant_id = p_mandant_id
           -- Diese Zeile ist der Schutz: ein Foto gehoert genau einem
           -- Artikel, und nur dieser darf es aendern. Ohne sie konnte
           -- "Foto laden" bei falsch stehendem Satzzeiger das Bild eines
           -- FREMDEN Artikels ueberschreiben -- danach zeigten alle
           -- Artikel dasselbe Foto (gemeldet 19.08.2026).
           AND artikel_id = p_artikel_id
        RETURNING foto_id INTO v_id;

        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Foto % gehoert nicht zu Artikel %.',
                            p_foto_id, p_artikel_id;
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- 2. Foto loeschen
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_artikel_foto_loeschen(
    p_foto_id    integer,
    p_mandant_id integer)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_anzahl integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_foto_id, p_mandant_id)
      FROM funktion WHERE name = 'fn_artikel_foto_loeschen';

    DELETE FROM artikel_foto
     WHERE foto_id = p_foto_id AND mandant_id = p_mandant_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;

    IF v_anzahl = 0 THEN
        RAISE EXCEPTION 'Foto % gibt es fuer Mandant % nicht.',
                        p_foto_id, p_mandant_id;
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
   AND p.proname IN ('fn_artikel_foto_speichern', 'fn_artikel_foto_loeschen')
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, t.ueber
  FROM (VALUES
    ('fn_artikel_foto_speichern', 'artikel_foto',    'INSERT', 'direkt'),
    ('fn_artikel_foto_speichern', 'artikel_foto',    'UPDATE', 'direkt'),
    ('fn_artikel_foto_speichern', 'artikel',         'SELECT', 'direkt'),
    ('fn_artikel_foto_speichern', 'funktion_aufruf', 'INSERT', 'direkt'),
    ('fn_artikel_foto_loeschen',  'artikel_foto',    'DELETE', 'direkt'),
    ('fn_artikel_foto_loeschen',  'funktion_aufruf', 'INSERT', 'direkt')
  ) AS t(fname, tabelle, wirkung, ueber)
  JOIN funktion f ON f.name = t.fname
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle
                      AND ft.wirkung = t.wirkung);
