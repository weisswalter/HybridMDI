-- ============================================================================
-- Heisenberg: Zyklus-Schutz fuer artikel_artikel (Stueckliste)
-- PostgreSQL DDL
--
-- artikel_artikel.CHECK (artikel_id <> unter_artikel_id) faengt nur die
-- direkte Selbstreferenz ab. Mehrstufige Zyklen (A -> B -> C -> A) kann ein
-- CHECK-Constraint prinzipiell nicht erkennen (sieht nur die aktuelle Zeile).
-- Dieser Trigger schliesst die Luecke serverseitig, unabhaengig davon, ob
-- ein Client (z.B. VirtualStringTree-Check vor dem Speichern) das schon
-- verhindert hat.
--
-- Kosten: laeuft nur bei INSERT/UPDATE auf artikel_artikel (Stuecklisten-
-- Pflege ist kein Hochfrequenz-Schreibpfad wie Bestandsbuchungen) und
-- durchsucht nur den tatsaechlichen Unterbaum von NEW.unter_artikel_id,
-- nicht die ganze Tabelle. Bei sehr grossen/tiefen Stuecklisten (viele
-- tausend Teile, mehrstufig verschachtelt, wie z.B. bei einem Kunden mit
-- komplexen elektromechanischen Baugruppen) ggf. spaeter erneut bewerten.
-- ============================================================================

CREATE OR REPLACE FUNCTION artikel_artikel_check_zyklus()
RETURNS trigger AS $$
BEGIN
    IF EXISTS (
        WITH RECURSIVE unterbaum AS (
            SELECT unter_artikel_id AS artikel_id
            FROM artikel_artikel
            WHERE artikel_id = NEW.unter_artikel_id
            UNION
            SELECT aa.unter_artikel_id
            FROM artikel_artikel aa
            JOIN unterbaum u ON aa.artikel_id = u.artikel_id
        )
        SELECT 1 FROM unterbaum WHERE artikel_id = NEW.artikel_id
    ) THEN
        RAISE EXCEPTION
          'Zyklus in Stueckliste: Artikel % waere ueber % in seiner eigenen Unterstruktur enthalten',
          NEW.artikel_id, NEW.unter_artikel_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_artikel_artikel_check_zyklus ON artikel_artikel;

CREATE TRIGGER trg_artikel_artikel_check_zyklus
BEFORE INSERT OR UPDATE ON artikel_artikel
FOR EACH ROW
EXECUTE FUNCTION artikel_artikel_check_zyklus();
