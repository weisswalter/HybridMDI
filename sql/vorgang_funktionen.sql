-- Teil 3 zu vorgang_ticket.sql: die Schreibwege.
-- Geschrieben wird am Vorgang ausschliesslich hierueber.

-- ---------------------------------------------------------------------------
-- Anlegen: Nummer ziehen, Startzustand setzen, Verlauf eroeffnen.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_vorgang_anlegen(
    p_mandant_id    integer,
    p_typ_id        integer,
    p_bezeichnung   varchar,
    p_beschreibung  text    DEFAULT NULL,
    p_person_id     integer DEFAULT NULL,
    p_bearbeiter_id integer DEFAULT NULL,
    p_faellig_am    date    DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_code    varchar;
    v_start   integer;
    v_nr      varchar;
    v_neu     integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_mandant_id, p_typ_id, p_bezeichnung,
             p_beschreibung, p_person_id, p_bearbeiter_id, p_faellig_am)
      FROM funktion WHERE name = 'fn_vorgang_anlegen';

    IF btrim(COALESCE(p_bezeichnung, '')) = '' THEN
        RAISE EXCEPTION 'Bitte eine Bezeichnung fuer den Vorgang eingeben.';
    END IF;

    SELECT t.code INTO v_code
      FROM vorgang_typ t
     WHERE t.typ_id = p_typ_id AND t.mandant_id = p_mandant_id AND t.aktiv;
    IF v_code IS NULL THEN
        RAISE EXCEPTION 'Diesen Vorgangstyp gibt es fuer den Mandanten nicht (oder er ist stillgelegt).';
    END IF;

    SELECT z.zustand_id INTO v_start
      FROM vorgang_zustand z
     WHERE z.mandant_id = p_mandant_id AND z.ist_start AND z.aktiv
     ORDER BY z.reihenfolge
     LIMIT 1;
    IF v_start IS NULL THEN
        RAISE EXCEPTION 'Fuer diesen Mandanten ist kein Startzustand hinterlegt.';
    END IF;

    v_nr := fn_nummer_ziehen(p_mandant_id, 'VORGANG_' || v_code, CURRENT_DATE);

    INSERT INTO vorgang (mandant_id, vorgang_nr, bezeichnung, beschreibung,
                         person_id, typ_id, zustand_id, bearbeiter_id,
                         faellig_am, eroeffnet_am)
    VALUES (p_mandant_id, v_nr, btrim(p_bezeichnung), p_beschreibung,
            p_person_id, p_typ_id, v_start, p_bearbeiter_id,
            p_faellig_am, CURRENT_DATE)
    RETURNING vorgang_id INTO v_neu;

    INSERT INTO vorgang_verlauf (vorgang_id, von_zustand_id, nach_zustand_id,
                                 bemerkung)
    VALUES (v_neu, NULL, v_start, 'Vorgang eroeffnet');

    RETURN v_neu;
END;
$$;

-- ---------------------------------------------------------------------------
-- Eine Stufe weiter. Erlaubt ist nur, was in vorgang_uebergang steht.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_vorgang_weiter(
    p_vorgang_id  integer,
    p_zustand_id  integer,
    p_benutzer_id integer DEFAULT NULL,
    p_bemerkung   text    DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_typ      integer;
    v_alt      integer;
    v_alt_zu   boolean;
    v_neu_zu   boolean;
    v_moeglich text;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_vorgang_id, p_zustand_id,
                                          p_benutzer_id, p_bemerkung)
      FROM funktion WHERE name = 'fn_vorgang_weiter';

    SELECT v.typ_id, v.zustand_id, z.ist_abschluss
      INTO v_typ, v_alt, v_alt_zu
      FROM vorgang v
      LEFT JOIN vorgang_zustand z ON z.zustand_id = v.zustand_id
     WHERE v.vorgang_id = p_vorgang_id;
    IF v_typ IS NULL THEN
        RAISE EXCEPTION 'Diesen Vorgang gibt es nicht.';
    END IF;

    IF COALESCE(v_alt_zu, false) THEN
        RAISE EXCEPTION
          'Der Vorgang ist abgeschlossen. Fuer eine Fortsetzung einen neuen Vorgang anlegen, der auf diesen verweist.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM vorgang_uebergang u
                    WHERE u.typ_id = v_typ
                      AND u.von_zustand_id = v_alt
                      AND u.nach_zustand_id = p_zustand_id) THEN
        SELECT string_agg(z.bezeichnung, ', ' ORDER BY z.reihenfolge)
          INTO v_moeglich
          FROM vorgang_uebergang u
          JOIN vorgang_zustand z ON z.zustand_id = u.nach_zustand_id
         WHERE u.typ_id = v_typ AND u.von_zustand_id = v_alt;
        RAISE EXCEPTION 'Dieser Schritt ist fuer diesen Vorgangstyp nicht vorgesehen. Moeglich waere: %',
                        COALESCE(v_moeglich, '(nichts)');
    END IF;

    SELECT z.ist_abschluss INTO v_neu_zu
      FROM vorgang_zustand z WHERE z.zustand_id = p_zustand_id;

    UPDATE vorgang
       SET zustand_id     = p_zustand_id,
           geschlossen_am = CASE WHEN COALESCE(v_neu_zu, false)
                                 THEN CURRENT_DATE ELSE NULL END
     WHERE vorgang_id = p_vorgang_id;

    INSERT INTO vorgang_verlauf (vorgang_id, von_zustand_id, nach_zustand_id,
                                 benutzer_id, bemerkung)
    VALUES (p_vorgang_id, v_alt, p_zustand_id, p_benutzer_id, p_bemerkung);
END;
$$;

-- ---------------------------------------------------------------------------
-- Fortsetzung: neuer Vorgang, verknuepft mit dem alten. Ersetzt das
-- Wiedereroeffnen, das es bewusst nicht gibt.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_vorgang_nachfolger(
    p_alt_id       integer,
    p_bezeichnung  varchar,
    p_beschreibung text    DEFAULT NULL,
    p_typ_id       integer DEFAULT NULL,
    p_bezug        varchar DEFAULT 'nachfolger')
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_alt vorgang%ROWTYPE;
    v_neu integer;
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_alt_id, p_bezeichnung,
                                          p_beschreibung, p_typ_id, p_bezug)
      FROM funktion WHERE name = 'fn_vorgang_nachfolger';

    SELECT * INTO v_alt FROM vorgang WHERE vorgang_id = p_alt_id;
    IF v_alt.vorgang_id IS NULL THEN
        RAISE EXCEPTION 'Den Vorgang, auf den verwiesen werden soll, gibt es nicht.';
    END IF;

    v_neu := fn_vorgang_anlegen(v_alt.mandant_id,
                                COALESCE(p_typ_id, v_alt.typ_id),
                                p_bezeichnung, p_beschreibung,
                                v_alt.person_id, v_alt.bearbeiter_id, NULL);

    INSERT INTO vorgang_vorgang (von_id, nach_id, bezug)
    VALUES (p_alt_id, v_neu, p_bezug);

    RETURN v_neu;
END;
$$;

-- ---------------------------------------------------------------------------
-- Register nachziehen
-- ---------------------------------------------------------------------------
INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public'
   AND p.proname IN ('fn_vorgang_anlegen', 'fn_vorgang_weiter',
                     'fn_vorgang_nachfolger', 'fn_nummer_ziehen')
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, t.ueber
  FROM (VALUES
    ('fn_nummer_ziehen',      'nummernkreis',      'UPDATE', 'direkt'),
    ('fn_nummer_ziehen',      'funktion_aufruf',   'INSERT', 'direkt'),
    ('fn_vorgang_anlegen',    'vorgang',           'INSERT', 'direkt'),
    ('fn_vorgang_anlegen',    'vorgang_verlauf',   'INSERT', 'direkt'),
    ('fn_vorgang_anlegen',    'nummernkreis',      'UPDATE', 'kaskade'),
    ('fn_vorgang_anlegen',    'audit_log',         'INSERT', 'trigger'),
    ('fn_vorgang_anlegen',    'funktion_aufruf',   'INSERT', 'direkt'),
    ('fn_vorgang_weiter',     'vorgang',           'UPDATE', 'direkt'),
    ('fn_vorgang_weiter',     'vorgang_verlauf',   'INSERT', 'direkt'),
    ('fn_vorgang_weiter',     'audit_log',         'INSERT', 'trigger'),
    ('fn_vorgang_weiter',     'funktion_aufruf',   'INSERT', 'direkt'),
    ('fn_vorgang_nachfolger', 'vorgang',           'INSERT', 'kaskade'),
    ('fn_vorgang_nachfolger', 'vorgang_vorgang',   'INSERT', 'direkt'),
    ('fn_vorgang_nachfolger', 'funktion_aufruf',   'INSERT', 'direkt')
  ) AS t(fname, tabelle, wirkung, ueber)
  JOIN funktion f ON f.name = t.fname
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle
                      AND ft.wirkung = t.wirkung);
