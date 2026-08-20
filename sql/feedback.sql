-- ============================================================================
-- Feedback & kontinuierliche Verbesserung — Stand 03.08.2026 (QM-02)
-- ============================================================================

CREATE TABLE IF NOT EXISTS feedback (
    feedback_id   serial PRIMARY KEY,
    mandant_id    integer NOT NULL REFERENCES mandant(mandant_id),
    -- Optional: Sozialarbeiter mit Login hinterlassen eine Person, ein
    -- Klient ohne eigenes Konto kann trotzdem Feedback geben (dann NULL).
    person_id     integer REFERENCES person(person_id),
    kategorie     varchar(10) NOT NULL
                    CHECK (kategorie IN ('lob', 'kritik', 'vorschlag')),
    -- Aus welchem Formular heraus (Delphi uebergibt den Modulnamen) — sagt,
    -- WORAUF sich das Feedback bezieht, ohne dass der Anwender es eintippen muss.
    modul         varchar(100),
    text_inhalt   text NOT NULL CHECK (length(trim(text_inhalt)) > 0),
    status        varchar(20) NOT NULL DEFAULT 'neu'
                    CHECK (status IN ('neu', 'gesehen', 'bearbeitet', 'abgelehnt')),
    antwort       text,
    bearbeitet_von_person_id integer REFERENCES person(person_id),
    bearbeitet_am timestamp,
    erstellt_am   timestamp NOT NULL DEFAULT clock_timestamp()
);

CREATE INDEX IF NOT EXISTS ix_feedback_status
    ON feedback (mandant_id, status, erstellt_am DESC);

COMMENT ON TABLE feedback IS
    'QM-02: Lob/Kritik/Verbesserungsvorschlag aus der Anwendung heraus. '
    'Auswertung ueber v_feedback_uebersicht.';

CREATE OR REPLACE VIEW v_feedback_uebersicht AS
SELECT f.feedback_id, f.mandant_id, f.kategorie, f.modul, f.text_inhalt,
       f.status, f.erstellt_am,
       p.nachname_firmenname AS von_person,
       f.antwort, f.bearbeitet_am
  FROM feedback f
  LEFT JOIN person p ON p.person_id = f.person_id
 ORDER BY f.status = 'neu' DESC, f.erstellt_am DESC;

-- Kleine Kennzahl fuer eine kuenftige Admin-Ansicht: wie viel liegt noch an.
CREATE OR REPLACE FUNCTION fn_feedback_offen(p_mandant_id integer)
RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT count(*)::integer FROM feedback
     WHERE mandant_id = p_mandant_id AND status = 'neu';
$$;
