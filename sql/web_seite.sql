-- ============================================================================
--  web_seite — jede Seite der Website ist ein Datensatz
--  Stand 03.08.2026
--
--  VORGABE (Walter): "Ich will in den Razordateien nichts haben, was ich nicht
--  managen kann." Also steht hier ALLES: Adresse, Titel, Menue und Inhalt.
--
--  DREI INHALTSFELDER, EINE AUSWAHL — genau wie gefordert:
--     darstellung = 'text' -> text_inhalt   wird als Reintext gezeigt
--     darstellung = 'html' -> html_inhalt   wird als HTML gezeigt (+ css_inhalt)
--     darstellung = 'pdf'  -> pdf_inhalt    wird als PDF eingebettet
--  Alle drei duerfen gleichzeitig gefuellt sein; `darstellung` entscheidet,
--  was der Besucher sieht. So kann man umschalten, ohne etwas zu verlieren.
--
--  WARUM EINE EIGENE TABELLE und nicht weiter `dokument`: `dokument` ist die
--  Ablage fuer eingescannte Unterlagen, Vertraege, Zeugnisse. Eine Webseite
--  ist etwas anderes — sie hat eine Adresse, eine Reihenfolge im Menue und
--  einen Titel. Beides in einer Tabelle zu fuehren hiess, bei jedem Zugriff
--  aufzupassen, dass kein Vertrag ins Netz rutscht.
-- ============================================================================

CREATE TABLE IF NOT EXISTS web_seite (
    seite_id     serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),

    -- Adresse in der Website, ohne fuehrenden Schraegstrich: 'team/wolfgang'.
    -- Leer = Startseite.
    slug         varchar(200) NOT NULL,
    sprache      varchar(5)   NOT NULL DEFAULT 'de',

    titel        varchar(200) NOT NULL,
    untertitel   varchar(300),

    -- Was der Besucher zu sehen bekommt
    darstellung  varchar(10)  NOT NULL DEFAULT 'html'
                 CHECK (darstellung IN ('text', 'html', 'pdf')),
    text_inhalt  text,
    html_inhalt  text,
    css_inhalt   text,
    pdf_inhalt   bytea,
    pdf_dateiname varchar(200),

    -- Menue
    im_menue     boolean NOT NULL DEFAULT false,
    menue_text   varchar(100),
    reihenfolge  integer NOT NULL DEFAULT 100,

    -- Sichtbarkeit. Default false: eine neu angelegte Seite steht nicht
    -- sofort im Netz.
    aktiv        boolean NOT NULL DEFAULT false,

    -- Optionale Verknuepfung zu einer Person (Teamseiten)
    person_id    integer REFERENCES person(person_id),

    bemerkung    varchar(300),
    geaendert_am timestamp NOT NULL DEFAULT now(),

    UNIQUE (mandant_id, slug, sprache)
);

CREATE INDEX IF NOT EXISTS ix_web_seite_menue
    ON web_seite (mandant_id, aktiv, im_menue, reihenfolge);

COMMENT ON TABLE web_seite IS
    'Eine Zeile = eine Seite der Website. Inhalt als Reintext, HTML oder PDF; '
    '`darstellung` waehlt aus.';
COMMENT ON COLUMN web_seite.slug IS
    'Adresse ohne fuehrenden Schraegstrich. Leer = Startseite.';
COMMENT ON COLUMN web_seite.darstellung IS
    'text | html | pdf — welches der drei Inhaltsfelder gezeigt wird.';

CREATE OR REPLACE FUNCTION fn_web_seite_geaendert() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    NEW.geaendert_am := now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tr_web_seite_geaendert ON web_seite;
CREATE TRIGGER tr_web_seite_geaendert BEFORE UPDATE ON web_seite
    FOR EACH ROW EXECUTE FUNCTION fn_web_seite_geaendert();

-- Was ist gefuellt, und passt die Auswahl dazu? Fuer die Pflegemaske.
CREATE OR REPLACE VIEW v_web_seite AS
SELECT s.seite_id, s.mandant_id, s.slug, s.sprache, s.titel, s.untertitel,
       s.darstellung, s.aktiv, s.im_menue, s.reihenfolge,
       COALESCE(s.text_inhalt, '') <> '' AS hat_text,
       COALESCE(s.html_inhalt, '') <> '' AS hat_html,
       s.pdf_inhalt IS NOT NULL          AS hat_pdf,
       length(COALESCE(s.text_inhalt, '')) AS zeichen_text,
       length(COALESCE(s.html_inhalt, '')) AS zeichen_html,
       COALESCE(length(s.pdf_inhalt), 0)   AS bytes_pdf,
       CASE
         WHEN s.darstellung = 'text' AND COALESCE(s.text_inhalt, '') = '' THEN 'Text gewaehlt, aber leer'
         WHEN s.darstellung = 'html' AND COALESCE(s.html_inhalt, '') = '' THEN 'HTML gewaehlt, aber leer'
         WHEN s.darstellung = 'pdf'  AND s.pdf_inhalt IS NULL             THEN 'PDF gewaehlt, aber keins hinterlegt'
       END AS hinweis,
       s.geaendert_am
  FROM web_seite s;

COMMENT ON VIEW v_web_seite IS
    'Seiten mit Fuellstand je Form und Hinweis, wenn die gewaehlte Form leer ist.';
