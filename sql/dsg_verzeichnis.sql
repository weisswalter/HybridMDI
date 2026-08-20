-- ============================================================================
-- Verzeichnis der Bearbeitungstätigkeiten (VBT) — Stand 03.08.2026 (DS-06)
--
-- Das VBT ist im Schweizer DSG die Dokumentationspflicht: WELCHE Daten
-- WOFÜR WARUM verarbeitet werden und WER sie bekommt. Es ist ein Katalog,
-- kein Mechanismus, der irgendetwas erzwingt — deshalb technisch der
-- ungefährlichste der DSG-Punkte.
--
-- WICHTIG, unmissverständlich: Die unten eingefügten Einträge sind ein
-- ERSTER ENTWURF aus meiner Kenntnis des Schemas, KEINE geprüfte Rechtsauskunft.
-- `rechtlich_geprueft = false` markiert das ausdrücklich. Rechtsgrundlagen,
-- Aufbewahrungsfristen und Empfängerkreise gehören vor dem ersten Einsatz von
-- jemandem geprüft, der das schweizerische DSG tatsächlich anwenden darf.
-- ============================================================================

CREATE TABLE IF NOT EXISTS verarbeitungstaetigkeit (
    taetigkeit_id     serial PRIMARY KEY,
    mandant_id        integer NOT NULL REFERENCES mandant(mandant_id),
    bezeichnung       varchar(200) NOT NULL,
    zweck             text NOT NULL,
    rechtsgrundlage   text,
    datenkategorien   text,       -- z.B. "Personendaten, Gesundheitsdaten"
    personengruppen   text,       -- Klienten, Mitarbeitende, Foerderstellen...
    empfaenger        text,       -- wer bekommt die Daten, intern/extern
    aufbewahrungsfrist text,      -- als Text, weil je nach Datenart sehr unterschiedlich
    technische_massnahmen text,
    verantwortlich_person_id integer REFERENCES person(person_id),
    rechtlich_geprueft boolean NOT NULL DEFAULT false,
    aktiv             boolean NOT NULL DEFAULT true,
    erstellt_am       timestamp NOT NULL DEFAULT now(),
    geaendert_am      timestamp,
    UNIQUE (mandant_id, bezeichnung)
);

COMMENT ON TABLE verarbeitungstaetigkeit IS
    'Verzeichnis der Bearbeitungstaetigkeiten (DSG). Seed-Eintraege sind '
    'ENTWURF (rechtlich_geprueft=false) - vor Gebrauch rechtlich pruefen.';

CREATE OR REPLACE VIEW v_vbt AS
SELECT taetigkeit_id, mandant_id, bezeichnung, zweck, rechtsgrundlage,
       datenkategorien, personengruppen, empfaenger, aufbewahrungsfrist,
       technische_massnahmen, rechtlich_geprueft,
       CASE WHEN rechtlich_geprueft THEN 'geprueft' ELSE 'ENTWURF - ungeprueft' END
         AS pruefstatus
  FROM verarbeitungstaetigkeit
 WHERE aktiv
 ORDER BY mandant_id, bezeichnung;

-- ── Erstbefüllung aus dem tatsächlichen Schema ─────────────────────────────
-- Idempotent, wie die anderen Seed-Funktionen. Sechs Kerntätigkeiten, die
-- in JEDEM Mandanten mit Personendaten vorkommen — kein Anspruch auf
-- Vollständigkeit, ein Anfang zum Weiterpflegen.
CREATE OR REPLACE FUNCTION fn_vbt_standard(p_mandant_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_z record; v_anzahl integer := 0;
BEGIN
    FOR v_z IN
        SELECT * FROM (VALUES
        ('Personen- und Stammdatenverwaltung',
         'Verwaltung von Kontakt-, Adress- und Beziehungsdaten für Klienten, '
         'Mitarbeitende, Lehrer und Geschäftspartner',
         'Vertrag bzw. gesetzlicher Auftrag (ENTWURF - genaue Grundlage je '
         'Personengruppe pruefen)',
         'Personendaten, Kontaktdaten, Beziehungsdaten',
         'Klienten, Mitarbeitende, Lehrer, Kunden, Lieferanten',
         'intern; ENTWURF - externe Empfaenger je Fall pruefen',
         'ENTWURF - gesetzliche Aufbewahrungsfrist pruefen'),
        ('Lohnbuchhaltung',
         'Berechnung und Abrechnung von Loehnen, Honoraren und '
         'Sozialversicherungsbeitraegen',
         'Arbeitsvertrag, gesetzliche Pflicht (Sozialversicherung)',
         'Personendaten, Finanzdaten, Sozialversicherungsdaten',
         'Mitarbeitende, Honorarkraefte',
         'Sozialversicherungen, Steuerbehoerden',
         'ENTWURF - gesetzliche Aufbewahrungsfrist (Schweiz i.d.R. 10 Jahre, '
         'pruefen)'),
        ('Zeiterfassung und Anwesenheit',
         'Erfassung von Arbeits- und Anwesenheitszeiten',
         'Arbeitsvertrag',
         'Personendaten, Zeitdaten',
         'Mitarbeitende, Klienten (Kursbesuch)',
         'intern',
         'ENTWURF - pruefen'),
        ('Kostengutsprachen und Foerderabrechnung',
         'Abrechnung von Leistungen gegenueber staatlichen Foerderstellen',
         'Vertrag mit Foerderstelle, gesetzlicher Auftrag',
         'Personendaten, Falldaten, Finanzdaten',
         'Klienten',
         'IV-Stellen, Sozialaemter, Gemeinden',
         'ENTWURF - pruefen, vermutlich lang wegen Foerderrecht'),
        ('E-Mail-Kommunikation',
         'Geschaeftliche Korrespondenz inkl. Anhaenge',
         'Vertrag bzw. berechtigtes Interesse',
         'Personendaten, Kommunikationsinhalte, ggf. Anhaenge mit '
         'weiteren Kategorien',
         'Klienten, Mitarbeitende, Geschaeftspartner, Behoerden',
         'je nach Kommunikationspartner; bei Nutzung von Microsoft Graph '
         'zusaetzlich Microsoft als Auftragsverarbeiter (Serverstandort '
         'pruefen, siehe DS-05)',
         'ENTWURF - pruefen'),
        ('Dokumenten- und Belegablage',
         'Digitale Ablage von Belegen, Vertraegen und Korrespondenz, '
         'teils mit Texterkennung (OCR)',
         'gesetzliche Aufbewahrungspflicht, Vertrag',
         'Personendaten, je nach Dokument auch besondere Kategorien',
         'Klienten, Mitarbeitende, Geschaeftspartner',
         'intern',
         'ENTWURF - je nach Dokumentart unterschiedlich, gesetzliche '
         'Aufbewahrungsfristen pruefen')
        ) AS t(bez, zweck, grundlage, kategorien, gruppen, empf, frist)
    LOOP
        INSERT INTO verarbeitungstaetigkeit (mandant_id, bezeichnung, zweck,
            rechtsgrundlage, datenkategorien, personengruppen, empfaenger,
            aufbewahrungsfrist, rechtlich_geprueft)
        SELECT p_mandant_id, v_z.bez, v_z.zweck, v_z.grundlage, v_z.kategorien,
               v_z.gruppen, v_z.empf, v_z.frist, false
        WHERE NOT EXISTS (SELECT 1 FROM verarbeitungstaetigkeit v
                           WHERE v.mandant_id = p_mandant_id
                             AND v.bezeichnung = v_z.bez);
        IF FOUND THEN v_anzahl := v_anzahl + 1; END IF;
    END LOOP;
    RETURN v_anzahl;
END;
$$;
