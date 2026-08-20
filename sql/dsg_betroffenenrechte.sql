-- ============================================================================
-- Betroffenenrechte und Vorfallsmeldung — Stand 03.08.2026 (DS-04, DS-07)
-- ============================================================================

-- ── DS-04: Auskunftsexport ──────────────────────────────────────────────────
-- KATALOGGETRIEBEN statt Handliste: 43 Spalten in ~30 Tabellen verweisen
-- heute auf person(person_id) — eine von Hand gepflegte Liste wäre entweder
-- unvollständig oder morgen schon veraltet. Die Funktion fragt bei jedem
-- Aufruf den aktuellen Schema-Katalog ab und erfasst deshalb automatisch auch
-- Tabellen, die erst nach heute Nacht dazukommen.
CREATE OR REPLACE FUNCTION fn_person_auskunft_json(p_person_id integer)
RETURNS jsonb
LANGUAGE plpgsql AS $$
DECLARE
    v_ergebnis jsonb := '{}'::jsonb;
    v_teil jsonb;
    r record;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM person WHERE person_id = p_person_id) THEN
        RAISE EXCEPTION 'Person % gibt es nicht.', p_person_id;
    END IF;

    SELECT to_jsonb(p) INTO v_teil FROM person p WHERE person_id = p_person_id;
    v_ergebnis := jsonb_set(v_ergebnis, '{person}', v_teil);

    FOR r IN
        SELECT tc.table_name, kcu.column_name
          FROM information_schema.table_constraints tc
          JOIN information_schema.key_column_usage kcu
            ON kcu.constraint_name = tc.constraint_name
           AND kcu.table_schema = tc.table_schema
          JOIN information_schema.constraint_column_usage ccu
            ON ccu.constraint_name = tc.constraint_name
           AND ccu.table_schema = tc.table_schema
         WHERE tc.constraint_type = 'FOREIGN KEY'
           AND tc.table_schema = 'public'
           AND ccu.table_name = 'person' AND ccu.column_name = 'person_id'
           AND tc.table_name <> 'person'
         ORDER BY tc.table_name, kcu.column_name
    LOOP
        EXECUTE format('SELECT jsonb_agg(to_jsonb(t)) FROM %I t WHERE %I = $1',
                        r.table_name, r.column_name)
          INTO v_teil USING p_person_id;

        IF v_teil IS NOT NULL THEN
            -- Schlüssel "tabelle__spalte" macht sichtbar, UEBER WELCHE Spalte
            -- der Bezug lief — wichtig, weil manche Tabellen (z.B. lohn_periode)
            -- zwei verschiedene Personenbezüge haben (Empfänger UND wer
            -- freigegeben hat) und das nicht vermischt werden darf.
            v_ergebnis := jsonb_set(v_ergebnis,
                ARRAY[r.table_name || '__' || r.column_name], v_teil, true);
        END IF;
    END LOOP;

    RETURN v_ergebnis;
END;
$$;

COMMENT ON FUNCTION fn_person_auskunft_json IS
    'Vollstaendige Auskunft als JSON (DS-04). PDF-Aufbereitung ist nicht '
    'gebaut - dafuer fehlt eine PDF-Bibliothek auf der Delphi-Seite, siehe '
    'Morgenbericht. JSON laesst sich in der Zwischenzeit direkt uebergeben '
    'oder mit einem Skript in ein lesbares Dokument giessen.';

-- ── DS-04: Anonymisierung ───────────────────────────────────────────────────
ALTER TABLE person ADD COLUMN IF NOT EXISTS anonymisiert boolean NOT NULL DEFAULT false;
ALTER TABLE person ADD COLUMN IF NOT EXISTS anonymisiert_am timestamp;

CREATE TABLE IF NOT EXISTS anonymisierung_protokoll (
    protokoll_id  serial PRIMARY KEY,
    person_id     integer NOT NULL REFERENCES person(person_id),
    grund         text NOT NULL,
    durchgefuehrt_am timestamp NOT NULL DEFAULT clock_timestamp(),
    durchgefuehrt_von varchar(100) NOT NULL DEFAULT current_user
);

-- SCHUTZSCHRANKE, keine Rechtsberatung: eine Person mit noch OFFENEM Vorgang
-- wird nicht anonymisiert, ohne dass das ausdrücklich erzwungen wird — sonst
-- verliert eine laufende Akte mitten in der Bearbeitung ihre Grundlage.
-- Was rechtlich WIRKLICH zur Aufbewahrung verpflichtet (Lohnbelege,
-- Buchungen), wird hier NICHT geprüft — das bräuchte Fristen, die ich nicht
-- kenne. Diese Funktion ersetzt keine rechtliche Prüfung im Einzelfall.
--
-- NUR die person_* BRÜCKENTABELLEN werden gelöscht, NICHT die dahinter
-- liegenden emailadresse/adresse/telefonnummer selbst — die sind poolfähig
-- und können mehreren Personen gleichzeitig gehören (siehe
-- project_heisenberg_db_schema); sie zu löschen würde fremde Datensätze
-- treffen, die nichts mit dieser Anonymisierung zu tun haben.
CREATE OR REPLACE FUNCTION fn_person_anonymisieren(
    p_person_id integer, p_grund text, p_erzwingen boolean DEFAULT false)
RETURNS void
LANGUAGE plpgsql AS $$
DECLARE v_offene_vorgaenge integer;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM person WHERE person_id = p_person_id) THEN
        RAISE EXCEPTION 'Person % gibt es nicht.', p_person_id;
    END IF;
    IF COALESCE(p_grund, '') = '' THEN
        RAISE EXCEPTION 'Ohne Begruendung wird nicht anonymisiert - das '
            'Protokoll braucht einen nachvollziehbaren Grund.';
    END IF;

    SELECT count(*) INTO v_offene_vorgaenge FROM vorgang
     WHERE person_id = p_person_id AND status IN ('offen', 'wartend');
    IF v_offene_vorgaenge > 0 AND NOT p_erzwingen THEN
        RAISE EXCEPTION '% offene(r) Vorgang/Vorgaenge fuer diese Person - '
            'bitte zuerst abschliessen oder p_erzwingen=true setzen, wenn '
            'die Anonymisierung trotzdem gewuenscht ist.', v_offene_vorgaenge;
    END IF;

    INSERT INTO anonymisierung_protokoll (person_id, grund)
    VALUES (p_person_id, p_grund);

    UPDATE person
       SET vorname = NULL, nachname_firmenname = '[anonymisiert]',
           beschreibung = NULL, photo = NULL, geburtsdatum = NULL,
           titel = NULL, anonymisiert = true, anonymisiert_am = clock_timestamp()
     WHERE person_id = p_person_id;

    DELETE FROM person_email WHERE person_id = p_person_id;
    DELETE FROM person_adresse WHERE person_id = p_person_id;
    DELETE FROM person_telefonnummer WHERE person_id = p_person_id;
END;
$$;

-- ── DS-07: Meldepflicht bei Datenschutzverletzungen ────────────────────────
CREATE TABLE IF NOT EXISTS datenschutz_vorfall (
    vorfall_id      serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    titel           varchar(200) NOT NULL,
    beschreibung    text NOT NULL,
    schweregrad     varchar(10) NOT NULL
                      CHECK (schweregrad IN ('gering','mittel','hoch','kritisch')),
    betroffene_anzahl integer,
    betroffene_datenkategorien text,
    entdeckt_am     timestamp NOT NULL DEFAULT clock_timestamp(),
    gemeldet_am     timestamp,
    meldepflichtig  boolean,
    massnahmen      text,
    status          varchar(20) NOT NULL DEFAULT 'offen'
                      CHECK (status IN ('offen','in_bearbeitung','gemeldet','abgeschlossen')),
    gemeldet_von_person_id integer REFERENCES person(person_id),
    created_at      timestamp NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS tr_audit_datenschutz_vorfall ON datenschutz_vorfall;
CREATE TRIGGER tr_audit_datenschutz_vorfall
    AFTER INSERT OR UPDATE OR DELETE ON datenschutz_vorfall
    FOR EACH ROW EXECUTE FUNCTION fn_audit_erfassen('vorfall_id');

-- Berichtstext als VORLAGE — das tatsächliche EDÖB-Meldeformat ändert sich
-- und ist eine Rechtsfrage; das hier ist ein strukturierter Entwurf, der die
-- Pflichtangaben sammelt, keine geprüfte Meldung.
CREATE OR REPLACE FUNCTION fn_vorfall_bericht(p_vorfall_id integer)
RETURNS text
LANGUAGE plpgsql AS $$
DECLARE v datenschutz_vorfall%ROWTYPE; v_mandant varchar;
BEGIN
    SELECT * INTO v FROM datenschutz_vorfall WHERE vorfall_id = p_vorfall_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Vorfall % gibt es nicht.', p_vorfall_id;
    END IF;
    SELECT mandanten_name INTO v_mandant FROM mandant WHERE mandant_id = v.mandant_id;

    RETURN
        '=== ENTWURF - Meldung Datenschutzverletzung (Vorlage, nicht rechtlich geprueft) ===' || E'\n\n' ||
        'Verantwortliche Stelle: ' || COALESCE(v_mandant, '?') || E'\n' ||
        'Titel: ' || v.titel || E'\n' ||
        'Schweregrad: ' || v.schweregrad || E'\n' ||
        'Entdeckt am: ' || to_char(v.entdeckt_am, 'DD.MM.YYYY HH24:MI') || E'\n' ||
        'Anzahl betroffener Personen: ' || COALESCE(v.betroffene_anzahl::text, 'unbekannt') || E'\n' ||
        'Betroffene Datenkategorien: ' || COALESCE(v.betroffene_datenkategorien, '-') || E'\n\n' ||
        'Beschreibung des Vorfalls:' || E'\n' || v.beschreibung || E'\n\n' ||
        'Ergriffene/geplante Massnahmen:' || E'\n' || COALESCE(v.massnahmen, '(noch keine erfasst)') || E'\n\n' ||
        '--- Vor Einreichung beim EDOEB: Format und Pflichtfelder gegen die ' ||
        'aktuellen Vorgaben des EDOEB pruefen (diese Vorlage erhebt keinen ' ||
        'Anspruch auf Vollstaendigkeit). ---';
END;
$$;
