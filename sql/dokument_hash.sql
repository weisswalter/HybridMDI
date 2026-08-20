-- ============================================================================
-- Dokument-Integrität: SHA-256-Prüfwert — Stand 03.08.2026 (DQ-02)
--
-- WARUM PER TRIGGER, NICHT PER DELPHI-AUFRUF: Der Prüfwert entsteht automatisch,
-- sobald pdf_blob gesetzt oder geändert wird — kein Upload-Pfad (Delphi, Python
-- OCR, Mailanhang) muss dafür geändert werden. Das erfüllt "Hochgeladene
-- Dateien erhalten beim Upload einen Prüfwert" ohne einen einzigen bestehenden
-- Schreibpfad anzufassen.
--
-- GRENZE, ehrlich benannt: Nur `pdf_blob`-Dokumente sind so prüfbar. Dokumente,
-- die nur als `datei_pfad` auf der Platte liegen (grosse Scans, Audio/Video —
-- siehe Kommentar in sql/email_vorgang.sql), kann die Datenbank nicht hashen,
-- sie sieht die Datei nicht. Dafür bräuchte es einen Hash-Aufruf auf der
-- Delphi-Seite beim Speichern — nicht heute Nacht gebaut, siehe Morgenbericht.
-- ============================================================================

ALTER TABLE dokument ADD COLUMN IF NOT EXISTS sha256_hash bytea;
ALTER TABLE dokument ADD COLUMN IF NOT EXISTS hash_gesetzt_am timestamp;

COMMENT ON COLUMN dokument.sha256_hash IS
    'SHA-256 ueber pdf_blob, automatisch per Trigger gesetzt. NULL, wenn kein '
    'Blob vorliegt (datei_pfad-Dokumente) oder das Blob leer ist.';

CREATE OR REPLACE FUNCTION fn_dokument_hash_trigger()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.pdf_blob IS NULL THEN
        NEW.sha256_hash := NULL;
        NEW.hash_gesetzt_am := NULL;
    ELSIF (TG_OP = 'INSERT') OR (NEW.pdf_blob IS DISTINCT FROM OLD.pdf_blob) THEN
        NEW.sha256_hash := digest(NEW.pdf_blob, 'sha256');
        NEW.hash_gesetzt_am := now();
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_dokument_hash ON dokument;
CREATE TRIGGER tr_dokument_hash
    BEFORE INSERT OR UPDATE OF pdf_blob ON dokument
    FOR EACH ROW EXECUTE FUNCTION fn_dokument_hash_trigger();

-- Lesbare Hex-Darstellung für die Anzeige (Delphi zeigt sonst rohe Bytes)
CREATE OR REPLACE FUNCTION fn_dokument_hash_hex(p_dokument_id integer)
RETURNS varchar
LANGUAGE sql STABLE AS $$
    SELECT encode(sha256_hash, 'hex') FROM dokument WHERE dokument_id = p_dokument_id;
$$;

-- Wird beim ÖFFNEN eines Dokuments aufgerufen (Delphi: vor AnhangOeffnen o.ä.).
-- Rechnet den Hash über den AKTUELLEN Blob-Inhalt neu und vergleicht ihn mit
-- dem gespeicherten Wert — das ist die eigentliche Integritätsprüfung.
CREATE OR REPLACE FUNCTION fn_dokument_hash_pruefen(p_dokument_id integer)
RETURNS varchar
LANGUAGE plpgsql AS $$
DECLARE d dokument%ROWTYPE; v_aktuell bytea;
BEGIN
    SELECT * INTO d FROM dokument WHERE dokument_id = p_dokument_id;
    IF NOT FOUND THEN
        RETURN 'Dokument existiert nicht';
    END IF;
    IF d.pdf_blob IS NULL THEN
        RETURN 'kein Blob - nicht pruefbar (liegt als Datei vor)';
    END IF;
    IF d.sha256_hash IS NULL THEN
        RETURN 'kein Pruefwert hinterlegt';
    END IF;

    v_aktuell := digest(d.pdf_blob, 'sha256');
    IF v_aktuell = d.sha256_hash THEN
        RETURN 'unveraendert';
    ELSE
        RETURN 'ABWEICHUNG - Inhalt weicht vom gespeicherten Pruefwert ab';
    END IF;
END;
$$;

-- Stichprobe/Übersicht: alle Blob-Dokumente ohne Prüfwert (sollte nach dem
-- Trigger-Einbau nur betreffen, was schon VOR heute Nacht angelegt wurde).
CREATE OR REPLACE VIEW v_dokument_ohne_pruefwert AS
SELECT dokument_id, titel, mime_type, dateigroesse_kb, created_at
  FROM dokument
 WHERE pdf_blob IS NOT NULL AND sha256_hash IS NULL;

-- Bestehende Dokumente einmalig nachholen (Trigger wirkt nur auf künftige
-- INSERT/UPDATE). Idempotent — betrifft nur Sätze ohne Hash.
CREATE OR REPLACE FUNCTION fn_dokument_hash_nachholen()
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_anzahl integer;
BEGIN
    UPDATE dokument SET sha256_hash = digest(pdf_blob, 'sha256'),
           hash_gesetzt_am = now()
     WHERE pdf_blob IS NOT NULL AND sha256_hash IS NULL;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;
