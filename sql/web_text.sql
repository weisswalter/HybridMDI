-- ============================================================================
-- Texte und Bilder der Website aus der Datenbank — Stand 03.08.2026
--
-- ZIEL (Walter): Jeder Text und jedes Logo muss ohne Programmierer aenderbar
-- sein, damit dieselbe Website fuer einen anderen Kunden aufbereitet werden
-- kann. Der Aufbau der Seiten bleibt, nur die Inhalte kommen von hier.
--
-- SCHLUESSEL statt Seiten-IDs: `home.hero.titel` sagt beim Lesen, wo der Text
-- steht. Fehlt ein Schluessel, benutzt die Website den im Quelltext
-- hinterlegten Ersatztext — sie bleibt also auch mit leerer Tabelle
-- vollstaendig, und man kann Seite fuer Seite umstellen.
--
-- SPRACHE ist Teil des Schluessels, nicht eine eigene Tabelle: Mehrsprachig
-- heisst hier nur eine weitere Zeile.
-- ============================================================================

CREATE TABLE IF NOT EXISTS web_text (
    mandant_id  integer      NOT NULL REFERENCES mandant(mandant_id),
    schluessel  varchar(100) NOT NULL,
    sprache     varchar(5)   NOT NULL DEFAULT 'de',
    wert        text         NOT NULL,
    -- Wofuer ist das? Steht in der Pflegemaske als Hilfe.
    bemerkung   varchar(200),
    geaendert_am timestamp   NOT NULL DEFAULT now(),
    PRIMARY KEY (mandant_id, schluessel, sprache)
);

COMMENT ON TABLE web_text IS
    'Textbausteine der Website je Mandant und Sprache. Fehlender Schluessel '
    '= der Ersatztext aus dem Quelltext greift.';

CREATE OR REPLACE FUNCTION fn_web_text_geaendert() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.geaendert_am := now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_web_text_geaendert ON web_text;
CREATE TRIGGER tr_web_text_geaendert BEFORE UPDATE ON web_text
    FOR EACH ROW EXECUTE FUNCTION fn_web_text_geaendert();

-- ============================================================================
-- Bilder: Logos, Hintergruende, alles was heute unter wwwroot/images liegt.
-- Als Bytes in der Datenbank, damit ein neuer Kunde sein Logo einspielen
-- kann, ohne an Dateien im Web-Verzeichnis zu muessen.
-- ============================================================================

CREATE TABLE IF NOT EXISTS web_bild (
    mandant_id   integer      NOT NULL REFERENCES mandant(mandant_id),
    schluessel   varchar(100) NOT NULL,
    mime_type    varchar(100) NOT NULL DEFAULT 'image/png',
    daten        bytea        NOT NULL,
    bezeichnung  varchar(200),
    geaendert_am timestamp    NOT NULL DEFAULT now(),
    PRIMARY KEY (mandant_id, schluessel)
);

COMMENT ON TABLE web_bild IS
    'Bilder der Website je Mandant (Logo, Hintergruende). Ausgeliefert ueber '
    '/bild/<schluessel>.';

-- ============================================================================
-- Erstbelegung mit dem, was heute fest im Quelltext steht. Idempotent:
-- vorhandene Werte werden NICHT ueberschrieben, sonst waere jede Pflege
-- beim naechsten Einspielen wieder weg.
-- ============================================================================
INSERT INTO web_text (mandant_id, schluessel, sprache, wert, bemerkung)
SELECT 1, s.schluessel, 'de', s.wert, s.bemerkung
  FROM (VALUES
    ('nav.marke',            'TRT-Engineering',
     'Schriftzug oben links in der Navigationsleiste'),
    ('home.hero.titel',      'TRT Engineering',
     'Grosse Ueberschrift auf der Startseite'),
    ('home.hero.untertitel', 'Ihr Partner für Projektmanagement, Beratung und Softwareentwicklungen',
     'Zeile unter der Ueberschrift der Startseite'),
    ('home.leistungen.titel','Unsere Leistungen',
     'Ueberschrift ueber den Leistungskacheln'),
    ('team.hero.titel',      'Unser Team',
     'Ueberschrift der Teamuebersicht'),
    ('team.hero.untertitel', 'Die Menschen hinter TRT Engineering GmbH',
     'Zeile unter der Ueberschrift der Teamuebersicht'),
    ('team.mehr',            'Weitere anzeigen',
     'Schaltflaeche unter den Teamkacheln'),
    ('cta.frage',            'Interesse an einer Zusammenarbeit?',
     'Text im Kontaktstreifen am Seitenende'),
    ('cta.knopf',            'Kontakt aufnehmen →',
     'Beschriftung der Schaltflaeche im Kontaktstreifen')
  ) AS s(schluessel, wert, bemerkung)
 WHERE NOT EXISTS (SELECT 1 FROM web_text t
                    WHERE t.mandant_id = 1 AND t.schluessel = s.schluessel
                      AND t.sprache = 'de');

SELECT schluessel, left(wert, 45) AS wert FROM web_text
 WHERE mandant_id = 1 ORDER BY schluessel;
