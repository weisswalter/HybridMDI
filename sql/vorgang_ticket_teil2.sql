-- Teil 2 zu vorgang_ticket.sql: Startbestand, Migration, Funktionen.
BEGIN;

-- ===========================================================================
-- 5. Startbestand je Mandant
-- ===========================================================================
INSERT INTO vorgang_zustand (mandant_id, code, bezeichnung, reihenfolge,
                             ist_start, ist_abschluss)
SELECT m.mandant_id, z.code, z.bezeichnung, z.reihenfolge, z.ist_start,
       z.ist_abschluss
  FROM mandant m
  CROSS JOIN (VALUES
      ('NEU',           'Neu',            10, true,  false),
      ('IN_ARBEIT',     'In Arbeit',      20, false, false),
      ('WARTEND',       'Wartend',        30, false, false),
      ('ABGESCHLOSSEN', 'Abgeschlossen',  90, false, true),
      ('ABGEBROCHEN',   'Abgebrochen',    99, false, true)
  ) AS z(code, bezeichnung, reihenfolge, ist_start, ist_abschluss)
 WHERE NOT EXISTS (SELECT 1 FROM vorgang_zustand v
                    WHERE v.mandant_id = m.mandant_id AND v.code = z.code);

INSERT INTO vorgang_typ (mandant_id, code, bezeichnung, praefix)
SELECT m.mandant_id, t.code, t.bezeichnung, t.praefix
  FROM mandant m
  CROSS JOIN (VALUES
      ('ANFRAGE',      'Allgemeine Anfrage',         'A'),
      ('BESCHAFFUNG',  'Beschaffung',                'B'),
      ('REKLAMATION',  'Reklamation',                'R'),
      ('SANKTION',     'Arbeitsrechtliche Sanktion', 'S'),
      ('UEBERWACHUNG', 'Ueberwachung',               'U')
  ) AS t(code, bezeichnung, praefix)
 WHERE NOT EXISTS (SELECT 1 FROM vorgang_typ v
                    WHERE v.mandant_id = m.mandant_id AND v.code = t.code);

-- Wege durch die Stufen. Fuer den Anfang bekommt jeder Typ denselben Weg;
-- unterschiedlich wird es, sobald jemand einen Uebergang streicht - ohne
-- Programmaenderung.
INSERT INTO vorgang_uebergang (typ_id, von_zustand_id, nach_zustand_id)
SELECT t.typ_id, zv.zustand_id, zn.zustand_id
  FROM vorgang_typ t
  CROSS JOIN (VALUES
      ('NEU',       'IN_ARBEIT'),
      ('NEU',       'ABGEBROCHEN'),
      ('IN_ARBEIT', 'WARTEND'),
      ('WARTEND',   'IN_ARBEIT'),
      ('IN_ARBEIT', 'ABGESCHLOSSEN'),
      ('IN_ARBEIT', 'ABGEBROCHEN'),
      ('WARTEND',   'ABGEBROCHEN')
  ) AS u(von, nach)
  JOIN vorgang_zustand zv ON zv.mandant_id = t.mandant_id AND zv.code = u.von
  JOIN vorgang_zustand zn ON zn.mandant_id = t.mandant_id AND zn.code = u.nach
 WHERE NOT EXISTS (SELECT 1 FROM vorgang_uebergang x
                    WHERE x.typ_id = t.typ_id
                      AND x.von_zustand_id = zv.zustand_id
                      AND x.nach_zustand_id = zn.zustand_id);

-- Nummernkreis je Mandant und Typ fuer das laufende Jahr.
INSERT INTO nummernkreis (mandant_id, schluessel, jahr, praefix, stellen, letzte_nr)
SELECT t.mandant_id, 'VORGANG_' || t.code,
       EXTRACT(year FROM CURRENT_DATE)::int, t.praefix || '-', 4, 0
  FROM vorgang_typ t
 WHERE NOT EXISTS (SELECT 1 FROM nummernkreis n
                    WHERE n.mandant_id = t.mandant_id
                      AND n.schluessel = 'VORGANG_' || t.code
                      AND n.jahr = EXTRACT(year FROM CURRENT_DATE)::int);

-- ===========================================================================
-- 6. Den vorhandenen Vorgang mitziehen, dann status abloesen
-- ===========================================================================
-- In einen DO-Block gefasst und an das Vorhandensein der Spalte geknuepft:
-- beim zweiten Lauf gibt es status nicht mehr, und ein Skript, das nur beim
-- ersten Mal durchlaeuft, ist auf einem Kundenserver wertlos.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
              WHERE table_name = 'vorgang' AND column_name = 'status') THEN
    EXECUTE $sql$
      UPDATE vorgang v
         SET zustand_id = z.zustand_id
        FROM vorgang_zustand z
       WHERE z.mandant_id = v.mandant_id
         AND z.code = CASE v.status
                        WHEN 'offen'         THEN 'NEU'
                        WHEN 'wartend'       THEN 'WARTEND'
                        WHEN 'abgeschlossen' THEN 'ABGESCHLOSSEN'
                        WHEN 'abgebrochen'   THEN 'ABGEBROCHEN'
                      END
         AND v.zustand_id IS NULL
    $sql$;
  END IF;
END $$;

-- Was danach noch ohne Zustand dasteht (neu angelegt ohne Migration),
-- bekommt den Startzustand seines Mandanten.
UPDATE vorgang v
   SET zustand_id = z.zustand_id
  FROM vorgang_zustand z
 WHERE z.mandant_id = v.mandant_id AND z.ist_start
   AND v.zustand_id IS NULL;

-- Der eine Altsatz ist eine Beschaffung ("Beschaffung Schrauben M8"); alles
-- andere bekommt den neutralen Typ.
UPDATE vorgang v
   SET typ_id = t.typ_id
  FROM vorgang_typ t
 WHERE t.mandant_id = v.mandant_id
   AND t.code = CASE WHEN v.bezeichnung ILIKE '%beschaff%' THEN 'BESCHAFFUNG'
                     ELSE 'ANFRAGE' END
   AND v.typ_id IS NULL;

-- Erster Eintrag im Verlauf, damit auch Altsaetze eine Vorgeschichte haben.
INSERT INTO vorgang_verlauf (vorgang_id, von_zustand_id, nach_zustand_id,
                             zeitpunkt, bemerkung)
SELECT v.vorgang_id, NULL, v.zustand_id, v.created_at,
       'Uebernommen aus dem alten status-Feld'
  FROM vorgang v
 WHERE NOT EXISTS (SELECT 1 FROM vorgang_verlauf x WHERE x.vorgang_id = v.vorgang_id);

-- Die Sicht las status - jetzt liest sie den Zustand.
CREATE OR REPLACE VIEW v_vorgang_ohne_zweck AS
 SELECT v.vorgang_id, v.mandant_id, v.vorgang_nr, v.bezeichnung, v.person_id,
        v.eroeffnet_am
   FROM vorgang v
   LEFT JOIN vorgang_zustand z ON z.zustand_id = v.zustand_id
  WHERE v.verwendungszweck_id IS NULL
    AND COALESCE(z.code, '') <> 'ABGEBROCHEN';

ALTER TABLE vorgang DROP CONSTRAINT IF EXISTS vorgang_status_check;
ALTER TABLE vorgang DROP COLUMN IF EXISTS status;
ALTER TABLE vorgang ALTER COLUMN typ_id     SET NOT NULL;
ALTER TABLE vorgang ALTER COLUMN zustand_id SET NOT NULL;
ALTER TABLE vorgang ALTER COLUMN vorgang_nr SET NOT NULL;

-- ===========================================================================
-- 7. Der Satz wird eingefroren, sobald er in einem Abschlusszustand steht.
--    Zweites Schloss neben "kein Uebergang aus dem Abschluss".
-- ===========================================================================
CREATE OR REPLACE FUNCTION fn_vorgang_schutz()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_zu boolean;
BEGIN
    SELECT z.ist_abschluss INTO v_zu
      FROM vorgang_zustand z WHERE z.zustand_id = OLD.zustand_id;

    IF COALESCE(v_zu, false) THEN
        RAISE EXCEPTION
          'Vorgang % ist abgeschlossen und kann nicht mehr geaendert werden. Fuer eine Fortsetzung einen neuen Vorgang anlegen (fn_vorgang_nachfolger).',
          OLD.vorgang_nr;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_vorgang_schutz ON vorgang;
CREATE TRIGGER tr_vorgang_schutz
    BEFORE UPDATE OR DELETE ON vorgang
    FOR EACH ROW EXECUTE FUNCTION fn_vorgang_schutz();

COMMIT;
