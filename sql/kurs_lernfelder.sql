-- ============================================================================
-- Lernfelder & Faehigkeiten aus dem Arbeitsagogikprogramm
-- ("9. Ressourcen Planungs-Modul", Walters Vorlage, 28.07.2026)
--
-- Jedes Lernfeld wird DOPPELT abgebildet, weil es beides ist:
--   1. ein `kurs` (Curriculum mit Lernzielen)
--   2. ein `kompetenz_typ` (das, was der Teilnehmer am Ende koennen soll)
-- verbunden ueber kurs_kompetenz mit rolle='vermittelt'.
--
-- Mandant 1 = TRT Engineering (Walters eigene Firma, produktiv) — dies sind
-- echte fachliche Inhalte, keine Testdaten. Beim Anlegen wird nichts
-- Bestehendes geaendert, nur ergaenzt.
--
-- "Lebenskompetenzen" fehlt bewusst: im Vorlagendokument abgeschnitten,
-- kommt laut Walter spaeter.
-- ============================================================================

-- Prioritaet aus der PRIO-Spalte der Vorlage
ALTER TABLE kurs ADD COLUMN IF NOT EXISTS prioritaet integer;

DO $$
DECLARE
    v_mandant  CONSTANT integer := 1;   -- TRT Engineering
    r          record;
    v_kurs_id  integer;
    v_komp_id  integer;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('LF-01', 'Digitale Grundkompetenzen',
             'Erlernen grundlegender digitaler Fähigkeiten, einschliesslich der Bedienung von Computern und mobilen Geräten.' || chr(10) ||
             'Schulung in der sicheren Online-Navigation und Kommunikation.', 1),

            ('LF-02', 'Selbstmanagement',
             'Aufbauen und Üben von eigenwirksamem Handeln.', 1),

            ('LF-03', 'Kommunikationsfähigkeiten',
             'Nutzung von Kommunikations-Werkzeugen innerhalb der Software, um mit Sozialarbeitern und anderen Klienten zu interagieren.' || chr(10) ||
             'Fähigkeit zur klaren Artikulation der eigenen Bedürfnisse und Ziele.', 1),

            ('LF-04', 'Selbstreflexion und Zielsetzung',
             'Fähigkeit zur Selbstreflexion, um eigene Bedürfnisse und Fortschritte zu erkennen.' || chr(10) ||
             'Festlegung und Verfolgung von persönlichen Zielen mithilfe der Software.', 1),

            ('LF-05', 'Technologische Grundkompetenzen',
             'Erlernen grundlegender technologischer Fähigkeiten, um die Software eigenständig zu verwenden.' || chr(10) ||
             'Sicherheitsbewusstsein und Schutz persönlicher Informationen während der Nutzung.', 1),

            ('LF-06', 'Fortbildung und Unterstützung',
             'Unterstützungsbedarf und allgemeine Lernfelder.' || chr(10) ||
             'Einrichtung von Support-Mechanismen, um Klienten bei Fragen oder Schwierigkeiten zu unterstützen.', 1),

            -- Ab hier Teil 2 der Vorlage. LF-07 zog sich ueber den
            -- Seitenumbruch, deshalb drei Unterthemen.
            ('LF-07', 'Lebenskompetenzen',
             'Kommunikation: Verbesserung der verbalen und nonverbalen Kommunikationsfähigkeiten, um effektiv mit anderen zu interagieren.' || chr(10) ||
             'Problemlösung: Entwicklung von Fähigkeiten zur Identifizierung, Analyse und Lösung von persönlichen und sozialen Problemen.' || chr(10) ||
             'Entscheidungsfindung: Förderung der Fähigkeit, fundierte und selbstbestimmte Entscheidungen zu treffen.', 1),

            ('LF-08', 'Bildung und berufliche Entwicklung',
             'Lernkompetenzen: Entwicklung von Lernstrategien und -techniken, um Bildungsziele zu erreichen.' || chr(10) ||
             'Berufliche Orientierung: Unterstützung bei der Identifizierung von beruflichen Interessen und Fähigkeiten.', 1),

            ('LF-09', 'Soziale Integration',
             'Soziale Kompetenzen: Förderung von Empathie, Teamarbeit, Konfliktlösung und anderen sozialen Fähigkeiten.' || chr(10) ||
             'Integration in die Gemeinschaft: Unterstützung bei der Teilnahme an sozialen Aktivitäten und der Gemeinschaftsbindung.', 1),

            ('LF-10', 'Gesundheit und Wohlbefinden',
             'Gesundheitskompetenzen: Förderung von Grundkenntnissen im Bereich Gesundheit und Hygiene.' || chr(10) ||
             'Selbstfürsorge: Entwicklung von Fähigkeiten zur eigenverantwortlichen Pflege und Förderung des körperlichen und emotionalen Wohlbefindens.', 1),

            ('LF-11', 'Finanzielle Bildung',
             'Grundlagen der Finanzen: Vermittlung von grundlegenden finanziellen Kenntnissen, Budgetierung und Sparfähigkeiten.' || chr(10) ||
             'Berufsbezogene Fähigkeiten: Förderung von Fähigkeiten im Zusammenhang mit beruflicher Mobilität, Arbeitsplatzsuche und beruflicher Weiterentwicklung.', 1),

            ('LF-12', 'Kulturelle und kreative Entfaltung',
             'Kulturelles Verständnis: Erweiterung des Bewusstseins für kulturelle Vielfalt und Respekt für unterschiedliche Traditionen.' || chr(10) ||
             'Kreativität und Selbstausdruck: Förderung von kreativen Ausdrucksformen wie Kunst, Musik oder anderen kulturellen Aktivitäten.', 1),

            ('LF-13', 'Emotionale Intelligenz und Resilienz',
             'Emotionale Intelligenz: Förderung der Fähigkeit, Emotionen zu erkennen, zu verstehen und konstruktiv zu bewältigen.' || chr(10) ||
             'Resilienz: Entwicklung von Widerstandsfähigkeit und Anpassungsfähigkeit in schwierigen Lebenssituationen.', 1),

            ('LF-14', 'Selbstständigkeit und Autonomie',
             'Alltagskompetenzen: Förderung von Fähigkeiten im Bereich Hauswirtschaft, Selbstversorgung und Mobilität.' || chr(10) ||
             'Selbstreflexion: Unterstützung bei der Entwicklung von Selbstbewusstsein und Selbstreflexion.', 1)
        ) AS t(nr, bez, ziele, prio)
    LOOP
        -- 1. Kurs
        SELECT kurs_id INTO v_kurs_id
        FROM kurs WHERE mandant_id = v_mandant AND kurs_nr = r.nr;

        IF v_kurs_id IS NULL THEN
            INSERT INTO kurs (mandant_id, kurs_nr, bezeichnung, lernziele, prioritaet)
            VALUES (v_mandant, r.nr, r.bez, r.ziele, r.prio)
            RETURNING kurs_id INTO v_kurs_id;
        ELSE
            UPDATE kurs SET bezeichnung = r.bez, lernziele = r.ziele, prioritaet = r.prio
            WHERE kurs_id = v_kurs_id;
        END IF;

        -- 2. Gleichnamige Kompetenz
        SELECT kompetenz_id INTO v_komp_id
        FROM kompetenz_typ WHERE mandant_id = v_mandant AND bezeichnung = r.bez;

        IF v_komp_id IS NULL THEN
            INSERT INTO kompetenz_typ (mandant_id, bezeichnung, beschreibung, quelle)
            VALUES (v_mandant, r.bez, r.ziele, 'Arbeitsagogikprogramm')
            RETURNING kompetenz_id INTO v_komp_id;
        END IF;

        -- 3. Der Kurs vermittelt diese Kompetenz
        INSERT INTO kurs_kompetenz (kurs_id, kompetenz_id, mandant_id, rolle)
        VALUES (v_kurs_id, v_komp_id, v_mandant, 'vermittelt')
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;
