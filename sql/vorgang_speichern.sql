CREATE OR REPLACE FUNCTION fn_vorgang_speichern(
    p_vorgang_id    integer,
    p_bezeichnung   varchar,
    p_beschreibung  text    DEFAULT NULL,
    p_person_id     integer DEFAULT NULL,
    p_bearbeiter_id integer DEFAULT NULL,
    p_faellig_am    date    DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_vorgang_id, p_bezeichnung,
             p_beschreibung, p_person_id, p_bearbeiter_id, p_faellig_am)
      FROM funktion WHERE name = 'fn_vorgang_speichern';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung fuer den Vorgang eingeben.';
    END IF;

    -- Nummer, Typ und Zustand aendert diese Funktion bewusst nicht: die
    -- Nummer ist vergeben, der Zustand laeuft ueber fn_vorgang_weiter.
    -- Ist der Vorgang abgeschlossen, laesst der Trigger den UPDATE nicht zu.
    UPDATE vorgang
       SET bezeichnung   = btrim(p_bezeichnung),
           beschreibung  = p_beschreibung,
           person_id     = p_person_id,
           bearbeiter_id = p_bearbeiter_id,
           faellig_am    = p_faellig_am
     WHERE vorgang_id = p_vorgang_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Diesen Vorgang gibt es nicht.';
    END IF;
END;
$$;

INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname='public' AND p.proname='fn_vorgang_speichern'
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, t.ueber
  FROM (VALUES ('vorgang','UPDATE','direkt'),
               ('audit_log','INSERT','trigger'),
               ('funktion_aufruf','INSERT','direkt')) AS t(tabelle,wirkung,ueber)
  JOIN funktion f ON f.name = 'fn_vorgang_speichern'
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id=f.funktion_id AND ft.tabelle=t.tabelle
                      AND ft.wirkung=t.wirkung);