-- Einstellungen je Mandant.
--
-- systemeinstellung gibt es schon, die gilt aber fuer den ganzen Betrieb
-- (Anmeldepflicht etwa: Konten gelten ueber Mandanten hinweg). Was eine
-- einzelne Website betrifft, gehoert an den Mandanten - die DynamicWebsite
-- soll ja mehrfach verkauft werden, jeder Kunde mit eigener Datenbankzeile.
--
-- Warum ueberhaupt in der Datenbank: der Sinn der dynamischen Website ist,
-- dass Inhalte und Verhalten dort geregelt werden und nicht in einer Datei
-- auf dem Server. Eine Seite anlegen ist ein INSERT in navbarweb; den Shop
-- ein- oder auszuschalten soll genauso wenig ein Deployment brauchen.

BEGIN;

CREATE TABLE IF NOT EXISTS mandant_einstellung (
    mandant_id   integer     NOT NULL REFERENCES mandant(mandant_id),
    schluessel   varchar(50) NOT NULL,
    wert         text,
    bezeichnung  varchar(200),
    geaendert_am timestamp   NOT NULL DEFAULT now(),
    PRIMARY KEY (mandant_id, schluessel)
);

CREATE OR REPLACE FUNCTION fn_mandant_einstellung_lesen(
    p_mandant_id integer,
    p_schluessel varchar)
RETURNS text
LANGUAGE sql
STABLE
AS $$
    SELECT wert FROM mandant_einstellung
     WHERE mandant_id = p_mandant_id AND schluessel = p_schluessel;
$$;

CREATE OR REPLACE FUNCTION fn_mandant_einstellung_setzen(
    p_mandant_id  integer,
    p_schluessel  varchar,
    p_wert        text,
    p_bezeichnung varchar DEFAULT NULL)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_mandant_id, p_schluessel, p_wert,
                                          p_bezeichnung)
      FROM funktion WHERE name = 'fn_mandant_einstellung_setzen';

    INSERT INTO mandant_einstellung (mandant_id, schluessel, wert, bezeichnung)
    VALUES (p_mandant_id, p_schluessel, p_wert, p_bezeichnung)
    ON CONFLICT (mandant_id, schluessel) DO UPDATE
       SET wert = EXCLUDED.wert,
           bezeichnung = COALESCE(EXCLUDED.bezeichnung,
                                  mandant_einstellung.bezeichnung),
           geaendert_am = now();
END;
$$;

-- Startbestand je Mandant. SHOP_AKTIV bewusst auf false: nach dem Einspielen
-- ist kein Shop sichtbar, bis ihn jemand einschaltet.
INSERT INTO mandant_einstellung (mandant_id, schluessel, wert, bezeichnung)
SELECT m.mandant_id, e.schluessel, e.wert, e.bezeichnung
  FROM mandant m
  CROSS JOIN (VALUES
      ('SHOP_AKTIV',      'false', 'Shop auf der Website anzeigen'),
      ('SHOP_WAEHRUNG',   'EUR',   'Waehrung im Shop'),
      ('SHOP_MWST',       '19.0',  'Mehrwertsteuersatz in Prozent'),
      ('SHOP_VERSAND',    '0',     'Versandkosten'),
      ('SHOP_VERSANDFREI','100',   'Ab diesem Warenwert kein Versand')
  ) AS e(schluessel, wert, bezeichnung)
 WHERE NOT EXISTS (SELECT 1 FROM mandant_einstellung x
                    WHERE x.mandant_id = m.mandant_id
                      AND x.schluessel = e.schluessel);

-- Mandant 1 ist TRT: Schweizer Voreinstellungen waeren dort falsch.
UPDATE mandant_einstellung SET wert = 'CHF'
 WHERE schluessel = 'SHOP_WAEHRUNG' AND mandant_id <> 1;
UPDATE mandant_einstellung SET wert = '8.1'
 WHERE schluessel = 'SHOP_MWST' AND mandant_id <> 1;

COMMIT;

-- ---------------------------------------------------------------------------
-- Alles, was die Website je Mandant braucht, in einer Zeile.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_shop_einstellung AS
SELECT m.mandant_id,
       COALESCE(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_AKTIV'), 'false')
           = 'true' AS shop_aktiv,
       COALESCE(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_WAEHRUNG'), 'EUR')
           AS waehrung,
       COALESCE(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_MWST'), '0')::numeric(5,2)
           AS mwst,
       COALESCE(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_VERSAND'), '0')::numeric(12,2)
           AS versand,
       COALESCE(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_VERSANDFREI'), '0')::numeric(12,2)
           AS versandfrei_ab
  FROM mandant m;

-- ---------------------------------------------------------------------------
INSERT INTO funktion (name, parameterliste)
SELECT p.proname, pg_get_function_arguments(p.oid)
  FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
 WHERE n.nspname = 'public'
   AND p.proname IN ('fn_mandant_einstellung_lesen', 'fn_mandant_einstellung_setzen')
   AND NOT EXISTS (SELECT 1 FROM funktion f WHERE f.name = p.proname);

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, t.tabelle, t.wirkung, 'direkt'
  FROM (VALUES
    ('fn_mandant_einstellung_setzen', 'mandant_einstellung', 'INSERT'),
    ('fn_mandant_einstellung_setzen', 'mandant_einstellung', 'UPDATE'),
    ('fn_mandant_einstellung_setzen', 'funktion_aufruf',     'INSERT')
  ) AS t(fname, tabelle, wirkung)
  JOIN funktion f ON f.name = t.fname
 WHERE NOT EXISTS (SELECT 1 FROM funktion_tabelle ft
                    WHERE ft.funktion_id = f.funktion_id
                      AND ft.tabelle = t.tabelle AND ft.wirkung = t.wirkung);
