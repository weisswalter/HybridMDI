-- ============================================================================
-- Dokumente fuers Web: Darstellungsform waehlbar — Stand 03.08.2026
--
-- WALTERS VORGABE: Zwischen Reintext, PDF und HTML muss gewaehlt werden
-- koennen, und es muss erkennbar sein, welche Dokumente fuers Web bestimmt
-- sind.
--
-- SPEICHER IST SCHON DA — die Tabelle `dokument` hat alle drei Formen:
--   pdf_blob     bytea   -> das PDF selbst
--   html + css   text    -> in PostgreSQL ist `text` das Gegenstueck zu
--                           nvarchar(max); eine Laengenangabe gibt es nicht
--                           und ist auch nicht noetig
--   ocr_text /
--   inhalt_text  text    -> Reintext
--
-- WAS GEFEHLT HAT, sind zwei Angaben:
--   fuer_web         Ist dieses Dokument ueberhaupt fuer die Website gedacht?
--                    Default false — ein eingescannter Vertrag hat im Netz
--                    nichts verloren, und das darf nicht von Achtsamkeit
--                    abhaengen.
--   web_darstellung  In welcher Form? Ein Dokument kann alle drei Formen
--                    gefuellt haben; ohne diese Angabe muesste die Website
--                    raten.
-- ============================================================================

ALTER TABLE dokument ADD COLUMN IF NOT EXISTS fuer_web boolean NOT NULL DEFAULT false;
ALTER TABLE dokument ADD COLUMN IF NOT EXISTS web_darstellung varchar(10);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conname = 'dokument_web_darstellung_check') THEN
        ALTER TABLE dokument ADD CONSTRAINT dokument_web_darstellung_check
            CHECK (web_darstellung IS NULL
                   OR web_darstellung IN ('text', 'html', 'pdf'));
    END IF;
END;
$$;

COMMENT ON COLUMN dokument.fuer_web IS
    'Ausdruecklich fuer die Website freigegeben. Default false.';
COMMENT ON COLUMN dokument.web_darstellung IS
    'text | html | pdf — in welcher Form die Website es zeigt. NULL = '
    'automatisch: html vor text vor pdf, je nachdem was gefuellt ist.';

-- Was ist ueberhaupt gefuellt? Hilft beim Pflegen und beim Setzen der
-- Darstellung.
CREATE OR REPLACE FUNCTION fn_dokument_formen(p_dokument_id integer)
RETURNS TABLE (hat_html boolean, hat_text boolean, hat_pdf boolean)
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(d.html, '') <> '',
           COALESCE(NULLIF(d.ocr_text, ''), d.inhalt_text) IS NOT NULL,
           d.pdf_blob IS NOT NULL
      FROM dokument d WHERE d.dokument_id = p_dokument_id;
$$;

-- Ueberblick fuer die Pflege: welche Dokumente stehen im Web, in welcher
-- Form, und passt die gewaehlte Form zu dem, was tatsaechlich gefuellt ist?
CREATE OR REPLACE VIEW v_web_dokumente AS
SELECT d.dokument_id,
       d.titel,
       d.sprache,
       d.fuer_web,
       COALESCE(d.web_darstellung,
                CASE WHEN COALESCE(d.html, '') <> ''             THEN 'html'
                     WHEN COALESCE(NULLIF(d.ocr_text, ''),
                                   d.inhalt_text) IS NOT NULL     THEN 'text'
                     WHEN d.pdf_blob IS NOT NULL                  THEN 'pdf'
                END) AS darstellung,
       COALESCE(d.html, '') <> ''                          AS hat_html,
       COALESCE(NULLIF(d.ocr_text, ''), d.inhalt_text) IS NOT NULL AS hat_text,
       d.pdf_blob IS NOT NULL                              AS hat_pdf,
       -- Warnt vor der haeufigsten Panne: Form gewaehlt, Inhalt fehlt
       CASE
         WHEN d.web_darstellung = 'html' AND COALESCE(d.html, '') = ''  THEN 'HTML gewaehlt, aber leer'
         WHEN d.web_darstellung = 'pdf'  AND d.pdf_blob IS NULL         THEN 'PDF gewaehlt, aber keins hinterlegt'
         WHEN d.web_darstellung = 'text' AND COALESCE(NULLIF(d.ocr_text, ''), d.inhalt_text) IS NULL
                                                                        THEN 'Text gewaehlt, aber leer'
         ELSE NULL
       END AS hinweis,
       (SELECT string_agg(COALESCE(p.vorname || ' ', '') || p.nachname_firmenname, ', ')
          FROM person_dokument pd JOIN person p ON p.person_id = pd.person_id
         WHERE pd.dokument_id = d.dokument_id) AS verknuepfte_personen
  FROM dokument d
 WHERE d.fuer_web
    OR EXISTS (SELECT 1 FROM webinhalt w WHERE w.dokument_id = d.dokument_id)
    OR EXISTS (SELECT 1 FROM person_dokument pd WHERE pd.dokument_id = d.dokument_id);

COMMENT ON VIEW v_web_dokumente IS
    'Dokumente, die im Web landen koennen — mit gewaehlter Darstellung und '
    'Hinweis, wenn die gewaehlte Form gar nicht gefuellt ist.';

-- Die bereits verwendeten Bios ausdruecklich freigeben; sie stehen ohnehin
-- schon auf der Website.
UPDATE dokument SET fuer_web = true
 WHERE dokument_id IN (SELECT dokument_id FROM webinhalt)
    OR dokument_id IN (SELECT dokument_id FROM person_dokument);

SELECT dokument_id, left(titel, 32) AS titel, fuer_web, darstellung,
       hat_html, hat_text, hat_pdf, COALESCE(hinweis, '-') AS hinweis
  FROM v_web_dokumente ORDER BY dokument_id;
