-- ============================================================================
-- Kontenrahmen — Stand 02.08.2026
--
-- ZWECK: Das Fundament, an dem später alles hängt. Kostenarten bekommen ein
-- Konto, Anlagen bekommen ein Aktiv- und ein Aufwandkonto, Löhne und Belege
-- lassen sich zuordnen. Solange kein Buchhaltungsmodul läuft, wird hier nichts
-- gebucht — aber die Zuordnung ist da, und der Schritt zur doppelten
-- Buchführung ist dann eine Ergänzung statt eines Umbaus.
--
-- MANDANTENBEZOGEN, wie einheit und adressentyp: Jeder Mandant führt seinen
-- eigenen Rahmen. Ein Agogikbetrieb braucht andere Konten als ein
-- Ingenieurbüro, und beide sollen die Nummern anpassen können.
--
-- Der Seed folgt dem KONTENRAHMEN KMU (Schweiz), weil die Zielgruppe dort
-- sitzt. Er ist bewusst kompakt gehalten — die üblichen Konten eines kleinen
-- Betriebs, nicht der vollständige Rahmen. Fehlendes trägt man nach.
-- ============================================================================

CREATE TABLE IF NOT EXISTS konto (
    konto_id        serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    nummer          varchar(20) NOT NULL,
    bezeichnung     varchar(200) NOT NULL,

    -- Bestimmt, auf welcher Seite eine Mehrung steht, und ob das Konto in die
    -- Bilanz oder die Erfolgsrechnung gehört.
    typ             varchar(10) NOT NULL
                      CHECK (typ IN ('aktiv', 'passiv', 'aufwand', 'ertrag')),

    -- Gliederungsbaum: 1 → 10 → 1000. Sammelkonten tragen keine Buchungen,
    -- sie fassen nur zusammen (Titelzeilen in Bilanz und Erfolgsrechnung).
    parent_id       integer REFERENCES konto(konto_id),
    ist_sammelkonto boolean NOT NULL DEFAULT false,

    -- Vorbelegung für die Belegerfassung. Der tatsächliche Satz kommt später
    -- aus der Buchung; hier steht nur, was üblich ist.
    mwst_satz       numeric(5,2),

    aktiv           boolean NOT NULL DEFAULT true,
    bemerkung       text,
    UNIQUE (mandant_id, nummer)
);

CREATE INDEX IF NOT EXISTS ix_konto_mandant ON konto (mandant_id, nummer);

COMMENT ON TABLE konto IS
    'Kontenrahmen je Mandant. Sammelkonten gliedern nur, auf ihnen wird nicht '
    'gebucht.';

-- ── Kontenrahmen KMU anlegen ───────────────────────────────────────────────
-- Idempotent: vorhandene Konten bleiben unangetastet, nur Fehlendes kommt
-- dazu. So kann man den Aufruf gefahrlos wiederholen, auch wenn der Mandant
-- seinen Rahmen inzwischen angepasst hat.
CREATE OR REPLACE FUNCTION fn_kontenrahmen_kmu(p_mandant_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_zeile record;
    v_anzahl integer := 0;
BEGIN
    FOR v_zeile IN
        SELECT * FROM (VALUES
        -- nummer, bezeichnung, typ, sammelkonto, parent
        ('1',    'AKTIVEN',                              'aktiv',   true,  NULL),
        ('10',   'Umlaufvermoegen',                      'aktiv',   true,  '1'),
        ('1000', 'Kasse',                                'aktiv',   false, '10'),
        ('1020', 'Bank',                                 'aktiv',   false, '10'),
        ('1100', 'Forderungen aus Lieferungen und Leistungen', 'aktiv', false, '10'),
        ('1109', 'Delkredere (Wertberichtigung Forderungen)', 'aktiv', false, '10'),
        ('1170', 'Vorsteuer MWST',                       'aktiv',   false, '10'),
        ('1200', 'Vorraete Handelswaren',                'aktiv',   false, '10'),
        ('1210', 'Vorraete Rohstoffe / Material',        'aktiv',   false, '10'),
        ('1260', 'Fertige und unfertige Erzeugnisse',    'aktiv',   false, '10'),
        ('1300', 'Aktive Rechnungsabgrenzung',           'aktiv',   false, '10'),
        ('14',   'Anlagevermoegen',                      'aktiv',   true,  '1'),
        ('1500', 'Maschinen und Apparate',               'aktiv',   false, '14'),
        ('1509', 'Wertberichtigung Maschinen',           'aktiv',   false, '14'),
        ('1510', 'Mobiliar und Einrichtungen',           'aktiv',   false, '14'),
        ('1519', 'Wertberichtigung Mobiliar',            'aktiv',   false, '14'),
        ('1520', 'Bueromaschinen, Informatik',           'aktiv',   false, '14'),
        ('1529', 'Wertberichtigung Informatik',          'aktiv',   false, '14'),
        ('1530', 'Fahrzeuge',                            'aktiv',   false, '14'),
        ('1539', 'Wertberichtigung Fahrzeuge',           'aktiv',   false, '14'),
        ('1540', 'Werkzeuge und Geraete',                'aktiv',   false, '14'),
        ('1600', 'Immobilien',                           'aktiv',   false, '14'),
        ('1770', 'Software / Lizenzen',                  'aktiv',   false, '14'),

        ('2',    'PASSIVEN',                             'passiv',  true,  NULL),
        ('20',   'Kurzfristiges Fremdkapital',           'passiv',  true,  '2'),
        ('2000', 'Verbindlichkeiten aus Lieferungen und Leistungen', 'passiv', false, '20'),
        ('2100', 'Kurzfristige Bankverbindlichkeiten',   'passiv',  false, '20'),
        ('2200', 'Geschuldete MWST (Umsatzsteuer)',      'passiv',  false, '20'),
        ('2270', 'Geschuldete Sozialversicherungen',     'passiv',  false, '20'),
        ('2300', 'Passive Rechnungsabgrenzung',          'passiv',  false, '20'),
        ('24',   'Langfristiges Fremdkapital',           'passiv',  true,  '2'),
        ('2400', 'Darlehen',                             'passiv',  false, '24'),
        ('28',   'Eigenkapital',                         'passiv',  true,  '2'),
        ('2800', 'Eigenkapital / Aktienkapital',         'passiv',  false, '28'),
        ('2900', 'Reserven',                             'passiv',  false, '28'),
        ('2979', 'Jahresgewinn oder Jahresverlust',      'passiv',  false, '28'),

        ('3',    'BETRIEBSERTRAG',                       'ertrag',  true,  NULL),
        ('3000', 'Produktionserloese',                   'ertrag',  false, '3'),
        ('3200', 'Handelserloese',                       'ertrag',  false, '3'),
        ('3400', 'Dienstleistungserloese',               'ertrag',  false, '3'),
        ('3600', 'Uebrige Erloese',                      'ertrag',  false, '3'),
        ('3800', 'Erloesminderungen (Rabatte, Skonti)',  'ertrag',  false, '3'),
        ('3805', 'Verluste aus Forderungen',             'ertrag',  false, '3'),

        ('4',    'AUFWAND FUER MATERIAL UND DRITTLEISTUNGEN', 'aufwand', true, NULL),
        ('4000', 'Materialaufwand',                      'aufwand', false, '4'),
        ('4200', 'Handelswarenaufwand',                  'aufwand', false, '4'),
        ('4400', 'Aufwand fuer Drittleistungen',         'aufwand', false, '4'),
        ('4500', 'Energieaufwand zur Leistungserstellung','aufwand', false, '4'),
        ('4900', 'Einkaufsminderungen (Rabatte, Skonti)','aufwand', false, '4'),

        ('5',    'PERSONALAUFWAND',                      'aufwand', true,  NULL),
        ('5000', 'Lohnaufwand',                          'aufwand', false, '5'),
        ('5700', 'Sozialversicherungsaufwand',           'aufwand', false, '5'),
        ('5800', 'Uebriger Personalaufwand',             'aufwand', false, '5'),
        ('5810', 'Aus- und Weiterbildung',               'aufwand', false, '5'),
        ('5900', 'Leistungen Dritter (Honorare)',        'aufwand', false, '5'),

        ('6',    'UEBRIGER BETRIEBSAUFWAND',             'aufwand', true,  NULL),
        ('6000', 'Raumaufwand (Miete)',                  'aufwand', false, '6'),
        ('6100', 'Unterhalt, Reparaturen, Ersatz',       'aufwand', false, '6'),
        ('6105', 'Leasingaufwand',                       'aufwand', false, '6'),
        ('6200', 'Fahrzeug- und Transportaufwand',       'aufwand', false, '6'),
        ('6300', 'Sachversicherungen, Abgaben, Gebuehren','aufwand', false, '6'),
        ('6400', 'Energie- und Entsorgungsaufwand',      'aufwand', false, '6'),
        ('6500', 'Verwaltungsaufwand',                   'aufwand', false, '6'),
        ('6570', 'Informatikaufwand, Softwarelizenzen',  'aufwand', false, '6'),
        ('6600', 'Werbeaufwand',                         'aufwand', false, '6'),
        ('6700', 'Uebriger Betriebsaufwand',             'aufwand', false, '6'),
        ('6800', 'Abschreibungen',                       'aufwand', false, '6'),
        ('6900', 'Finanzaufwand (Zinsen)',               'aufwand', false, '6'),
        ('6950', 'Finanzertrag',                         'ertrag',  false, '6'),

        ('7',    'BETRIEBLICHER NEBENERFOLG',            'ertrag',  true,  NULL),
        ('7000', 'Ertrag Nebenbetrieb',                  'ertrag',  false, '7'),

        ('8',    'AUSSERORDENTLICHER ERFOLG',            'aufwand', true,  NULL),
        ('8000', 'Ausserordentlicher Aufwand',           'aufwand', false, '8'),
        ('8100', 'Ausserordentlicher Ertrag',            'ertrag',  false, '8'),
        ('8900', 'Direkte Steuern',                      'aufwand', false, '8')
        ) AS t(nummer, bez, typ, sammel, parent)
    LOOP
        INSERT INTO konto (mandant_id, nummer, bezeichnung, typ,
                           ist_sammelkonto, parent_id)
        SELECT p_mandant_id, v_zeile.nummer, v_zeile.bez, v_zeile.typ,
               v_zeile.sammel,
               (SELECT k.konto_id FROM konto k
                 WHERE k.mandant_id = p_mandant_id AND k.nummer = v_zeile.parent)
        WHERE NOT EXISTS (SELECT 1 FROM konto k
                           WHERE k.mandant_id = p_mandant_id
                             AND k.nummer = v_zeile.nummer);
        IF FOUND THEN
            v_anzahl := v_anzahl + 1;
        END IF;
    END LOOP;
    RETURN v_anzahl;
END;
$$;

-- Bequemer Zugriff aus den Folgemodulen: Konto über die Nummer finden.
-- Liefert NULL statt einer Ausnahme, damit ein fehlendes Konto nicht gleich
-- den ganzen Vorgang abbricht.
CREATE OR REPLACE FUNCTION fn_konto_id(p_mandant_id integer, p_nummer varchar)
RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT konto_id FROM konto
     WHERE mandant_id = p_mandant_id AND nummer = p_nummer;
$$;

-- Sicht mit eingerücktem Namen — für Auswahllisten, in denen der Baum
-- sichtbar sein soll, ohne dass die Oberfläche ihn selbst aufbauen muss.
CREATE OR REPLACE VIEW v_kontenrahmen AS
WITH RECURSIVE baum AS (
    SELECT konto_id, mandant_id, nummer, bezeichnung, typ, ist_sammelkonto,
           parent_id, aktiv, 0 AS ebene, nummer::text AS sortierung
      FROM konto WHERE parent_id IS NULL
    UNION ALL
    SELECT k.konto_id, k.mandant_id, k.nummer, k.bezeichnung, k.typ,
           k.ist_sammelkonto, k.parent_id, k.aktiv, b.ebene + 1,
           b.sortierung || '.' || k.nummer
      FROM konto k JOIN baum b ON b.konto_id = k.parent_id
)
SELECT konto_id, mandant_id, nummer, bezeichnung, typ, ist_sammelkonto,
       aktiv, ebene,
       repeat('   ', ebene) || nummer || ' ' || bezeichnung AS anzeige,
       sortierung
  FROM baum;
