-- ============================================================================
-- Bruecke zwischen der Texterkennung und dokument.typ_id
--
-- Das Python-Paket dokument_ocr liefert einen Kategorie-SCHLUESSEL
-- ('rechnung', 'qr_rechnung', 'mahnung' ...). Die Anwendung braucht eine
-- typ_id aus dokument_typ. Statt die Zuordnung im Delphi-Code festzunageln
-- bekommt dokument_typ eine eigene Spalte -- so laesst sie sich pflegen,
-- ohne etwas neu zu uebersetzen.
--
-- Die vorhandene Spalte "kategorie" wird NICHT benutzt: sie beschreibt die
-- Herkunft (Person, Web, Medien, E-Mail), nicht die Dokumentart. Beides zu
-- vermischen wuerde eine der beiden Bedeutungen kaputt machen.
-- ============================================================================

ALTER TABLE dokument_typ
    ADD COLUMN IF NOT EXISTS ocr_schluessel varchar(50);

COMMENT ON COLUMN dokument_typ.ocr_schluessel IS
    'Schluessel aus dokument_ocr/kategorien.json. Leer = wird von der '
    'Texterkennung nicht automatisch vergeben.';

-- Ein Schluessel darf nur einmal vergeben sein, sonst waere die Zuordnung
-- mehrdeutig. Teilindex, damit beliebig viele Typen ohne Schluessel bleiben.
CREATE UNIQUE INDEX IF NOT EXISTS ux_dokument_typ_ocr
    ON dokument_typ (ocr_schluessel) WHERE ocr_schluessel IS NOT NULL;


-- ── Vorhandene Typen zuordnen ───────────────────────────────────────────────
UPDATE dokument_typ SET ocr_schluessel = 'vertrag'
 WHERE lower(bezeichnung) = 'vertrag' AND ocr_schluessel IS NULL;


-- ── Fehlende Dokumentarten anlegen ──────────────────────────────────────────
-- Nur, was die Texterkennung auch erkennen kann. "Beleg" als Oberbegriff,
-- weil Rechnung/Mahnung/Lieferschein fachlich zusammengehoeren.
INSERT INTO dokument_typ (bezeichnung, kategorie, ocr_schluessel)
SELECT x.bezeichnung, x.kategorie, x.schluessel
  FROM (VALUES
        ('Rechnung',        'Beleg',    'rechnung'),
        ('QR-Rechnung',     'Beleg',    'qr_rechnung'),
        ('Mahnung',         'Beleg',    'mahnung'),
        ('Lieferschein',    'Beleg',    'lieferschein'),
        ('Angebot',         'Beleg',    'angebot'),
        ('Bestellung',      'Beleg',    'bestellung'),
        ('Lohnabrechnung',  'Person',   'lohnabrechnung'),
        ('Zeugnis',         'Person',   'zeugnis'),
        ('Kursunterlage',   'Kurs',     'kursunterlage'),
        ('Korrespondenz',   'Freitext', 'korrespondenz')
       ) AS x(bezeichnung, kategorie, schluessel)
 WHERE NOT EXISTS (SELECT 1 FROM dokument_typ d
                    WHERE d.ocr_schluessel = x.schluessel);


-- ── Nachschlagen aus der Anwendung ──────────────────────────────────────────
-- Liefert die typ_id zu einem Kategorie-Schluessel, oder NULL wenn der
-- Schluessel nicht gepflegt ist. NULL ist ausdruecklich erlaubt: ein nicht
-- zugeordnetes Dokument soll gespeichert werden koennen, nur eben ohne Typ.
CREATE OR REPLACE FUNCTION fn_dokument_typ_zu_ocr(p_schluessel varchar)
RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT typ_id FROM dokument_typ
     WHERE ocr_schluessel = p_schluessel
     LIMIT 1;
$$;
