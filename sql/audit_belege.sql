-- ============================================================================
-- Audit-Trigger auf die Geschaeftsdokumente — Stand 02.08.2026
--
-- ANLASS: Walters Frage — beim SQL Server war ein ueberschriebener Auftrag im
-- Monitoring sichtbar und liess sich rekonstruieren. Postgres bietet das
-- nicht von Haus aus: Die alten Zeilenversionen liegen zwar physisch noch da,
-- aber VACUUM raeumt sie weg, und es gibt keinen unterstuetzten Weg, sie zu
-- lesen. Das WAL kann die ganze Datenbank auf einen Zeitpunkt zurueckspielen,
-- aber nicht einen einzelnen Auftrag zeigen.
--
-- Der unterstuetzte Weg ist ein Aenderungsprotokoll — und das gibt es bereits
-- (audit_log mit alter_wert/neuer_wert als jsonb, append-only). Es lag nur
-- auf den falschen Tabellen: person, abwesenheit, einwilligung, lohn_periode,
-- kostengutsprache, benutzer_mandant, datenschutz_vorfall. Ausgerechnet auf
-- Belegen und Artikeln, wo zwei Leute denselben Datensatz bearbeiten und der
-- letzte gewinnt, lag er nicht.
--
-- ANLAGE UND KALKULATION sind bewusst dabei: dort stehen Werte, die in die
-- Kostenrechnung einfliessen, und eine stille Aenderung verschiebt spaeter
-- Zahlen, die schon jemand gesehen hat.
-- ============================================================================

-- rechnungstyp hat einen zusammengesetzten Schluessel (mandant_id,
-- rechnungstyp_id). Der Trigger nimmt eine Spalte als Zeilenkennung; hier
-- ist rechnungstyp_id die sprechende, der Mandant steht ohnehin im jsonb.
DO $$
DECLARE
    v_t record;
BEGIN
    FOR v_t IN
        SELECT * FROM (VALUES
            ('beleg',          'beleg_id'),
            ('beleg_position', 'position_id'),
            ('artikel',        'artikel_id'),
            ('kurs',           'kurs_id'),
            ('vorgang',        'vorgang_id'),
            ('anlage',         'anlage_id'),
            ('kalkulation',    'kalkulation_id'),
            ('rechnungstyp',   'rechnungstyp_id'),
            -- Anwesenheit: hier zaehlt "wer hat wen abgehakt" besonders.
            -- Aus diesen Zeilen werden spaeter Loehne und Foerderabrufe
            -- abgeleitet — eine stille Korrektur verschiebt Geld.
            -- Zusammengesetzte Schluessel: die Zeilenkennung ist person_id,
            -- der Rest steht ohnehin vollstaendig im jsonb.
            ('kurs_anwesenheit', 'person_id'),
            ('kurs_teilnehmer',  'person_id'),
            ('anwesenheit_tag',  'person_id'),
            ('anwesenheit_check','person_id')
        ) AS t(tabelle, pk)
    LOOP
        -- Idempotent: alten Trigger weg, neuen drauf.
        EXECUTE format('DROP TRIGGER IF EXISTS tr_audit_%s ON %I',
                       v_t.tabelle, v_t.tabelle);
        EXECUTE format(
            'CREATE TRIGGER tr_audit_%s AFTER INSERT OR UPDATE OR DELETE ' ||
            'ON %I FOR EACH ROW EXECUTE FUNCTION fn_audit_erfassen(%L)',
            v_t.tabelle, v_t.tabelle, v_t.pk);
        RAISE NOTICE 'Audit-Trigger auf % (Schluessel %)', v_t.tabelle, v_t.pk;
    END LOOP;
END;
$$;

-- Kontrolle: worauf liegt der Audit-Trigger jetzt?
SELECT tgrelid::regclass::text AS tabelle
  FROM pg_trigger
 WHERE NOT tgisinternal AND tgfoid::regproc::text ILIKE '%audit_erfassen%'
 ORDER BY 1;
