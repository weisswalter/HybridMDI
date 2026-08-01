-- ============================================================================
-- Varianten als Baum mit zwei Bezugsarten (Entwurf 01.08.2026)
--
-- NICHT AUSGEFUEHRT. Erst lesen, dann entscheiden -- siehe "Folgen fuer den
-- Bestand" ganz unten.
--
-- Walters Vorgabe:
--   Merkmale und Ausspraegungen haengen nicht mehr am einzelnen Artikel,
--   sondern werden in den Einstellungen gepflegt. Zwei Zuordnungsarten:
--
--     50 --child-->       Deutsch      50 ist eine Auspraegung von "Deutsch"
--     50 --aequivalenz--> L            50 und L bezeichnen dasselbe
--
-- Zielbild:
--
--   Groesse
--   ├── Deutsch      → 46  48  50
--   ├── Englisch     → L   XL  XXL
--   └── Untersetzt   → 25  27  29  31
--   Farbe            → Rot Gruen Gelb
--   Kragenform       → rund  V-Ausschnitt
--
--   quer dazu:  46 = L,  48 = XL,  50 = XXL
-- ============================================================================


-- ── 1. Die Knoten: Merkmale UND Auspraegungen in einer Tabelle ──────────────
--
-- Bewusst eine Tabelle statt "merkmal" + "auspraegung": Walters Beispiel hat
-- drei Ebenen (Groesse > Deutsch > 50). Bei getrennten Tabellen braeuchte
-- jede weitere Ebene eine weitere Tabelle. So ist die Tiefe beliebig.
--
-- Was ein Knoten IST, ergibt sich aus seiner Lage: hat er Kinder, ist er eine
-- Gruppe; hat er keine, ist er eine Auspraegung.
CREATE TABLE IF NOT EXISTS variante (
    variante_id  serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    name         varchar(100) NOT NULL,      -- 'Groesse', 'Deutsch', '50', 'Rot'
    kurzzeichen  varchar(20),                -- fuer Etiketten/Barcode
    beschreibung text,
    sortierung   integer NOT NULL DEFAULT 0, -- 46 vor 48 vor 50
    aktiv        boolean NOT NULL DEFAULT true,
    created_at   timestamp NOT NULL DEFAULT now()
);

-- Absichtlich KEIN UNIQUE(mandant_id, name): derselbe Name darf an
-- verschiedenen Stellen im Baum stehen ("rund" als Kragenform und
-- spaeter vielleicht als Knopfform). Eindeutig ist erst der Pfad --
-- dafuer sorgt der Index weiter unten.
CREATE INDEX IF NOT EXISTS ix_variante_mandant ON variante (mandant_id);


-- ── 2. Die Kanten: child ODER aequivalenz ───────────────────────────────────
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'variante_bezug') THEN
        CREATE TYPE variante_bezug AS ENUM ('child', 'aequivalenz');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS variante_variante (
    mandant_id integer NOT NULL REFERENCES mandant(mandant_id),
    von_id     integer NOT NULL REFERENCES variante(variante_id) ON DELETE CASCADE,
    nach_id    integer NOT NULL REFERENCES variante(variante_id) ON DELETE CASCADE,
    bezug      variante_bezug NOT NULL,
    PRIMARY KEY (von_id, nach_id, bezug),
    CHECK (von_id <> nach_id)          -- nichts zeigt auf sich selbst
);

-- Ein Knoten hat hoechstens EINEN Elternknoten. Ohne das waere es kein Baum
-- mehr, sondern ein Netz -- und "wo gehoert 50 hin" haette mehrere Antworten.
CREATE UNIQUE INDEX IF NOT EXISTS ux_variante_ein_elternteil
    ON variante_variante (von_id) WHERE bezug = 'child';

-- Aequivalenz ist SYMMETRISCH: 50=L ist dieselbe Aussage wie L=50. Ohne
-- Absicherung stuenden beide Zeilen in der Tabelle und koennten sich
-- widersprechen. LEAST/GREATEST macht die Richtung fuer den Index egal --
-- eintragen darf man sie also so herum, wie es beim Erfassen passt, aber
-- nur einmal.
CREATE UNIQUE INDEX IF NOT EXISTS ux_variante_aequivalenz
    ON variante_variante (LEAST(von_id, nach_id), GREATEST(von_id, nach_id))
    WHERE bezug = 'aequivalenz';

-- Geschwister muessen unterschiedlich heissen. Das geht NICHT als Index:
-- der Name steht in variante, der Elternknoten hier -- und PostgreSQL
-- erlaubt in einem Index-Ausdruck keine Unterabfrage auf eine andere
-- Tabelle. Also per Trigger, siehe unten.


-- ── 3. Zyklenschutz ─────────────────────────────────────────────────────────
--
-- Ohne diese Pruefung liesse sich "Groesse" zum Kind von "50" machen. Die
-- rekursiven Abfragen weiter unten wuerden dann endlos laufen. Der PRIMARY
-- KEY faengt das NICHT ab -- er verbietet nur die direkte Wiederholung.
CREATE OR REPLACE FUNCTION variante_zyklus_pruefen() RETURNS trigger AS $$
BEGIN
    IF NEW.bezug <> 'child' THEN
        RETURN NEW;
    END IF;

    -- Ist der neue Elternknoten bereits ein Nachfahre des Kindes?
    IF EXISTS (
        WITH RECURSIVE nachfahren AS (
            SELECT von_id FROM variante_variante
             WHERE nach_id = NEW.von_id AND bezug = 'child'
            UNION
            SELECT vv.von_id FROM variante_variante vv
              JOIN nachfahren n ON vv.nach_id = n.von_id
             WHERE vv.bezug = 'child'
        )
        SELECT 1 FROM nachfahren WHERE von_id = NEW.nach_id
    ) THEN
        -- Namen statt IDs: die Meldung landet in der Oberflaeche, und mit
        -- "3 kann nicht unter 1" kann dort niemand etwas anfangen.
        RAISE EXCEPTION
            'Zyklus: "%" kann nicht unter "%" haengen -- der Knoten liegt '
            'bereits darueber im Baum',
            (SELECT name FROM variante WHERE variante_id = NEW.von_id),
            (SELECT name FROM variante WHERE variante_id = NEW.nach_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_variante_zyklus ON variante_variante;
CREATE TRIGGER trg_variante_zyklus
    BEFORE INSERT OR UPDATE ON variante_variante
    FOR EACH ROW EXECUTE FUNCTION variante_zyklus_pruefen();


-- Geschwister mit gleichem Namen verhindern (siehe Hinweis oben).
CREATE OR REPLACE FUNCTION variante_name_pruefen() RETURNS trigger AS $$
DECLARE
    v_name text;
BEGIN
    IF NEW.bezug <> 'child' THEN
        RETURN NEW;
    END IF;

    SELECT lower(name) INTO v_name FROM variante WHERE variante_id = NEW.von_id;

    IF EXISTS (
        SELECT 1
          FROM variante_variante vv
          JOIN variante v ON v.variante_id = vv.von_id
         WHERE vv.nach_id = NEW.nach_id
           AND vv.bezug   = 'child'
           AND vv.von_id <> NEW.von_id
           AND lower(v.name) = v_name
    ) THEN
        RAISE EXCEPTION 'Unter diesem Knoten gibt es "%" bereits', v_name;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_variante_name ON variante_variante;
CREATE TRIGGER trg_variante_name
    BEFORE INSERT OR UPDATE ON variante_variante
    FOR EACH ROW EXECUTE FUNCTION variante_name_pruefen();


-- ── 4. Der Baum als Abfrage ─────────────────────────────────────────────────
-- Liefert jeden Knoten mit Pfad und Ebene -- direkt fuer den Treeview.
CREATE OR REPLACE VIEW v_variante_baum AS
WITH RECURSIVE baum AS (
    -- Wurzeln: alles ohne Elternknoten
    SELECT v.variante_id, v.mandant_id, v.name, v.sortierung, v.aktiv,
           NULL::integer AS eltern_id,
           0 AS ebene,
           v.name::text AS pfad,
           ARRAY[v.sortierung, v.variante_id] AS sortpfad
      FROM variante v
     WHERE NOT EXISTS (SELECT 1 FROM variante_variante vv
                        WHERE vv.von_id = v.variante_id AND vv.bezug = 'child')
    UNION ALL
    SELECT v.variante_id, v.mandant_id, v.name, v.sortierung, v.aktiv,
           b.variante_id,
           b.ebene + 1,
           b.pfad || ' > ' || v.name,
           b.sortpfad || v.sortierung || v.variante_id
      FROM variante v
      JOIN variante_variante vv ON vv.von_id = v.variante_id AND vv.bezug = 'child'
      JOIN baum b ON b.variante_id = vv.nach_id
)
SELECT * FROM baum;


-- ── 5. Aequivalenzen, transitiv ─────────────────────────────────────────────
--
-- Wichtig: Gleichheit ist uebertragbar. Steht 46=L und L=25 in der Tabelle,
-- dann ist auch 46=25 -- ohne dass jemand diese Zeile erfasst hat. Die
-- Funktion loest das auf, damit die Anwendung nicht selbst rechnen muss.
CREATE OR REPLACE FUNCTION fn_variante_gleichwertig(p_variante_id integer)
RETURNS TABLE (variante_id integer, name varchar) AS $$
    WITH RECURSIVE gleich AS (
        SELECT p_variante_id AS id
        UNION
        SELECT CASE WHEN vv.von_id = g.id THEN vv.nach_id ELSE vv.von_id END
          FROM variante_variante vv
          JOIN gleich g ON (vv.von_id = g.id OR vv.nach_id = g.id)
         WHERE vv.bezug = 'aequivalenz'
    )
    SELECT v.variante_id, v.name
      FROM gleich g
      JOIN variante v ON v.variante_id = g.id
     WHERE g.id <> p_variante_id;
$$ LANGUAGE sql STABLE;


-- ── 6. Anbindung an den Artikel ─────────────────────────────────────────────
--
-- artikel_variante BLEIBT wie sie ist -- daran haengen Bestand
-- (artikel_fach), Zulauf (artikel_zugang) und Barcodes. Sie beschreibt
-- weiterhin EINE konkrete, lagerfaehige Ausfuehrung eines Artikels.
--
-- Neu ist nur, woraus sich diese Ausfuehrung zusammensetzt: statt des
-- Freitexts 'Groesse L' nun Verweise auf die Auspraegungen im Baum. Ein
-- Shirt in L + Rot + V-Ausschnitt hat drei Zeilen.
CREATE TABLE IF NOT EXISTS artikel_variante_wert (
    artikel_variante_id integer NOT NULL
        REFERENCES artikel_variante(variante_id) ON DELETE CASCADE,
    variante_id         integer NOT NULL
        REFERENCES variante(variante_id),
    PRIMARY KEY (artikel_variante_id, variante_id)
);

CREATE INDEX IF NOT EXISTS ix_artikel_variante_wert_variante
    ON artikel_variante_wert (variante_id);

-- Welche Merkmalsbaeume ein Artikel ueberhaupt anbietet. Ohne das muesste
-- man raten, ob ein Artikel Groessen hat -- und der Treeview auf dem
-- Tabsheet wuesste nicht, was er anzeigen soll.
CREATE TABLE IF NOT EXISTS artikel_variante_typ (
    artikel_id  integer NOT NULL REFERENCES artikel(artikel_id) ON DELETE CASCADE,
    variante_id integer NOT NULL REFERENCES variante(variante_id),
    pflicht     boolean NOT NULL DEFAULT true,
    PRIMARY KEY (artikel_id, variante_id)
);


-- ── 7. Beispieldaten (Walters Fall) ─────────────────────────────────────────
-- Am 01.08.2026 gegen TRTHeisenberg gelaufen (in einer Transaktion mit
-- ROLLBACK, die Datenbank blieb unveraendert). mandant_id anpassen.
--
-- INSERT INTO variante (mandant_id, name, sortierung) VALUES
--  (1,'Groesse',10),(1,'Deutsch',10),(1,'Englisch',20),(1,'Untersetzt',30),
--  (1,'46',10),(1,'48',20),(1,'50',30),
--  (1,'L',10),(1,'XL',20),(1,'XXL',30),
--  (1,'25',10),(1,'27',20),(1,'29',30),(1,'31',40),
--  (1,'Farbe',20),(1,'Rot',10),(1,'Gruen',20),(1,'Gelb',30),
--  (1,'Kragenform',30),(1,'rund',10),(1,'V-Ausschnitt',20);
--
-- -- Hierarchie
-- INSERT INTO variante_variante (mandant_id, von_id, nach_id, bezug)
-- SELECT 1, k.variante_id, e.variante_id, 'child'
-- FROM (VALUES
--  ('Deutsch','Groesse'),('Englisch','Groesse'),('Untersetzt','Groesse'),
--  ('46','Deutsch'),('48','Deutsch'),('50','Deutsch'),
--  ('L','Englisch'),('XL','Englisch'),('XXL','Englisch'),
--  ('25','Untersetzt'),('27','Untersetzt'),('29','Untersetzt'),('31','Untersetzt'),
--  ('Rot','Farbe'),('Gruen','Farbe'),('Gelb','Farbe'),
--  ('rund','Kragenform'),('V-Ausschnitt','Kragenform')
-- ) AS x(kind,eltern)
-- JOIN variante k ON k.name=x.kind  AND k.mandant_id=1
-- JOIN variante e ON e.name=x.eltern AND e.mandant_id=1;
--
-- -- Entsprechungen. Nur EINE Richtung eintragen, die Abfrage findet beide.
-- INSERT INTO variante_variante (mandant_id, von_id, nach_id, bezug)
-- SELECT 1, a.variante_id, b.variante_id, 'aequivalenz'
-- FROM (VALUES ('46','L'),('48','XL'),('50','XXL'),('50','25')) AS x(a,b)
-- JOIN variante a ON a.name=x.a AND a.mandant_id=1
-- JOIN variante b ON b.name=x.b AND b.mandant_id=1;
--
-- Baum ansehen:
--   SELECT repeat('    ', ebene) || name, ebene
--     FROM v_variante_baum WHERE mandant_id=1 ORDER BY sortpfad;
--
-- Was ist gleichwertig zu XXL?  -> 50 und 25, obwohl nur 50->XXL erfasst ist
--   SELECT * FROM fn_variante_gleichwertig(
--     (SELECT variante_id FROM variante WHERE name='XXL' AND mandant_id=1));


-- ============================================================================
-- FOLGEN FUER DEN BESTAND -- vor dem Ausfuehren klaeren
-- ============================================================================
--
-- 1. artikel_variante.bezeichnung bleibt zunaechst bestehen. Vorhandene
--    Eintraege ('Groesse L') muessen von Hand oder per Skript auf die neuen
--    Verweise umgestellt werden. Solange beides existiert, ist die
--    bezeichnung die Anzeige und artikel_variante_wert die Wahrheit.
--
-- 2. Die Aequivalenz sagt NICHT, dass zwei Bestaende zusammenfallen. Liegen
--    20 Stueck unter "48" und 5 unter "XL" im Regal, sind das nach wie vor
--    zwei Bestandszeilen in artikel_fach -- physisch aber derselbe Pullover.
--    Es braucht eine Festlegung, WELCHE Bezeichnung den Bestand fuehrt.
--    Ohne diese Regel entsteht genau die Doppelfuehrung, die die Aequivalenz
--    eigentlich verhindern soll. Vorschlag: je Merkmalsbaum einen Knoten als
--    "fuehrend" markieren (Spalte in variante oder eigene Tabelle), und beim
--    Buchen immer dorthin aufloesen.
--
-- 3. Zwei Artikel duerfen nicht dieselbe Merkmalskombination doppelt haben.
--    Das laesst sich nicht mit einem einfachen UNIQUE erschlagen (die
--    Kombination steht in mehreren Zeilen). Entweder ein Trigger oder eine
--    berechnete Signatur-Spalte auf artikel_variante.
