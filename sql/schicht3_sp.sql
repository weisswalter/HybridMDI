-- ===========================================================================
-- Schicht 3: Schreib-Funktionen fuer die restlichen Module.
--
-- Gleiches Muster wie sql/lager_views_und_sp.sql:
--   fn_<tabelle>_speichern(p_id, ...) -> INSERT bei p_id NULL/0, sonst UPDATE,
--   Rueckgabe ist immer die ID des geschriebenen Satzes.
--   fn_<tabelle>_loeschen(...)        -> Rueckgabe ist die Zahl der Zeilen.
--
-- Eine FUNCTION ist in PostgreSQL automatisch atomar (Transaktion des
-- Aufrufers, Exception rollt zurueck) - deshalb kein BEGIN/COMMIT.
-- ===========================================================================

-- --------------------------------------------------------------------------
-- MandantDm
-- --------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_mandant_speichern(
    p_mandant_id       integer,
    p_mandanten_name   varchar,
    p_ist_stammmandant boolean DEFAULT false)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    IF COALESCE(TRIM(p_mandanten_name), '') = '' THEN
        RAISE EXCEPTION 'Der Mandant braucht einen Namen.';
    END IF;

    IF COALESCE(p_mandant_id, 0) = 0 THEN
        INSERT INTO mandant (mandanten_name, ist_stammmandant)
        VALUES (TRIM(p_mandanten_name), COALESCE(p_ist_stammmandant, false))
        RETURNING mandant_id INTO v_id;
    ELSE
        UPDATE mandant
           SET mandanten_name   = TRIM(p_mandanten_name),
               ist_stammmandant = COALESCE(p_ist_stammmandant, ist_stammmandant)
         WHERE mandant_id = p_mandant_id
        RETURNING mandant_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Mandant % gibt es nicht.', p_mandant_id;
        END IF;
    END IF;
    RETURN v_id;
END;
$$;

-- --------------------------------------------------------------------------
-- DokumenteDm
--
-- pdf_blob/sha256_hash bleiben aussen vor: den Hash setzt der vorhandene
-- Trigger (fn_dokument_hash_trigger), das PDF kommt ueber den Scanner-Weg.
-- Blobs werden - wie bei fn_lager_speichern - nur ueberschrieben, wenn
-- wirklich etwas mitkommt.
-- --------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_dokument_speichern(
    p_dokument_id     integer,
    p_titel           varchar,
    p_typ_id          integer DEFAULT NULL,
    p_ocr_text        text    DEFAULT NULL,
    p_datei_pfad      varchar DEFAULT NULL,
    p_mime_type       varchar DEFAULT NULL,
    p_quelle          varchar DEFAULT NULL,
    p_dateigroesse_kb integer DEFAULT NULL,
    p_sprache         varchar DEFAULT NULL,
    p_scan_datum      timestamp DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    IF COALESCE(TRIM(p_titel), '') = '' THEN
        RAISE EXCEPTION 'Das Dokument braucht einen Titel.';
    END IF;

    IF COALESCE(p_dokument_id, 0) = 0 THEN
        INSERT INTO dokument (titel, typ_id, ocr_text, datei_pfad, mime_type,
                              quelle, dateigroesse_kb, sprache, scan_datum)
        VALUES (p_titel, p_typ_id, p_ocr_text, p_datei_pfad, p_mime_type,
                p_quelle, p_dateigroesse_kb, p_sprache,
                COALESCE(p_scan_datum, now()))
        RETURNING dokument_id INTO v_id;
    ELSE
        UPDATE dokument
           SET titel           = p_titel,
               typ_id          = p_typ_id,
               ocr_text        = p_ocr_text,
               datei_pfad      = p_datei_pfad,
               mime_type       = p_mime_type,
               quelle          = p_quelle,
               dateigroesse_kb = p_dateigroesse_kb,
               sprache         = p_sprache,
               scan_datum      = COALESCE(p_scan_datum, scan_datum)
         WHERE dokument_id = p_dokument_id
        RETURNING dokument_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Dokument % gibt es nicht.', p_dokument_id;
        END IF;
    END IF;
    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_dokument_loeschen(p_dokument_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    DELETE FROM dokument WHERE dokument_id = p_dokument_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- --------------------------------------------------------------------------
-- KursAnwesenheitDm
--
-- Die frueheren Inline-Queries hatten ihre Filter (Mandant, Zeitraum, Coach)
-- als WHERE-Parameter. Als View gibt es die Filter hier nicht mehr - das
-- Modul filtert auf seiner Kopie im Speicher. Deshalb muessen mandant_id
-- und datum als Spalten mitkommen.
-- --------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_kurs_termin_liste AS
SELECT t.termin_id,
       t.mandant_id,
       t.durchfuehrung_id,
       t.leiter_person_id,
       lower(t.zeitraum)::date AS datum,
       CAST(to_char(lower(t.zeitraum), 'DD.MM.YYYY HH24:MI') AS varchar(20)) AS beginn,
       CAST(k.bezeichnung AS varchar(200)) AS kurs,
       CAST(d.bezeichnung AS varchar(200)) AS durchfuehrung,
       CAST(COALESCE(t.thema, '') AS varchar(300)) AS thema,
       CAST(t.status AS varchar(30)) AS status,
       CAST(COALESCE(r.bezeichnung, '') AS varchar(200)) AS raum,
       CAST(COALESCE(p.nachname_firmenname, '') AS varchar(200)) AS leiter,
       (SELECT count(*) FROM kurs_teilnehmer kt
         WHERE kt.durchfuehrung_id = d.durchfuehrung_id
           AND kt.status IN ('angemeldet','bestaetigt'))::integer AS erwartet,
       (SELECT count(*) FROM kurs_anwesenheit ka
         WHERE ka.termin_id = t.termin_id)::integer AS erfasst
  FROM kurs_termin t
  JOIN kurs_durchfuehrung d ON d.durchfuehrung_id = t.durchfuehrung_id
  JOIN kurs k ON k.kurs_id = d.kurs_id
  LEFT JOIN raum r ON r.raum_id = t.raum_id
  LEFT JOIN person p ON p.person_id = t.leiter_person_id;

-- Nur wer wirklich Termine leitet - eine Liste aller Lehrer waere laenger
-- als noetig.
CREATE OR REPLACE VIEW v_kurs_coach AS
SELECT DISTINCT
       t.mandant_id,
       p.person_id,
       CAST(p.nachname_firmenname || COALESCE(', ' || p.vorname, '')
            AS varchar(300)) AS name
  FROM kurs_termin t
  JOIN person p ON p.person_id = t.leiter_person_id;

-- Legt fuer jeden angemeldeten/bestaetigten Teilnehmer eine Zeile an, ohne
-- vorhandene zu ueberschreiben. Rueckgabe: Zahl der neu angelegten Zeilen.
CREATE OR REPLACE FUNCTION fn_kurs_anwesenheit_liste_erzeugen(
    p_termin_id integer, p_coach_id integer DEFAULT 0)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    IF COALESCE(p_termin_id, 0) <= 0 THEN
        RAISE EXCEPTION 'Kein Termin gewaehlt.';
    END IF;

    INSERT INTO kurs_anwesenheit (termin_id, person_id, mandant_id,
                                  anwesend, erfasst_von_person_id)
    SELECT p_termin_id, kt.person_id, kt.mandant_id, false,
           NULLIF(p_coach_id, 0)
      FROM kurs_teilnehmer kt
      JOIN kurs_termin ter ON ter.durchfuehrung_id = kt.durchfuehrung_id
     WHERE ter.termin_id = p_termin_id
       AND kt.status IN ('angemeldet', 'bestaetigt')
    ON CONFLICT (termin_id, person_id) DO NOTHING;

    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- Der haeufige Fall: fast alle sind da.
CREATE OR REPLACE FUNCTION fn_kurs_anwesenheit_alle_da(
    p_termin_id integer, p_coach_id integer DEFAULT 0)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    UPDATE kurs_anwesenheit
       SET anwesend = true,
           fehlminuten = NULL,
           erfasst_von_person_id =
             COALESCE(NULLIF(p_coach_id, 0), erfasst_von_person_id)
     WHERE termin_id = p_termin_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- Einzelne Anwesenheit (das frueher direkte Post auf der MemTable).
CREATE OR REPLACE FUNCTION fn_kurs_anwesenheit_speichern(
    p_anwesenheit_id integer,
    p_anwesend       boolean,
    p_fehlminuten    integer DEFAULT NULL,
    p_bemerkung      text    DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_id integer;
BEGIN
    UPDATE kurs_anwesenheit
       SET anwesend    = COALESCE(p_anwesend, false),
           fehlminuten = p_fehlminuten,
           bemerkung   = p_bemerkung
     WHERE anwesenheit_id = p_anwesenheit_id
    RETURNING anwesenheit_id INTO v_id;
    IF v_id IS NULL THEN
        RAISE EXCEPTION 'Anwesenheitszeile % gibt es nicht.', p_anwesenheit_id;
    END IF;
    RETURN v_id;
END;
$$;

-- 'stattgefunden' ist der Status, den die Honorarabrechnung auswertet
-- (fn_honorar_einheiten zaehlt nur stattgefundene Termine). Ein
-- ausgefallener Termin wird bewusst nicht umgebucht -> Rueckgabe 0.
CREATE OR REPLACE FUNCTION fn_kurs_termin_abschliessen(p_termin_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    UPDATE kurs_termin
       SET status = 'stattgefunden'
     WHERE termin_id = p_termin_id AND status <> 'ausgefallen';
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- --------------------------------------------------------------------------
-- BenutzerDm
-- --------------------------------------------------------------------------

-- Personen-Auswahlliste mit fertigem Anzeigenamen (frueher Inline-SQL).
CREATE OR REPLACE VIEW v_person_auswahl AS
SELECT p.person_id,
       CAST(p.nachname_firmenname || COALESCE(', ' || p.vorname, '')
            AS varchar(300)) AS name
  FROM person p
 WHERE NOT p.anonymisiert;

-- Ersetzt die frueheren count(*)-Abfragen im Modul.
CREATE OR REPLACE FUNCTION fn_anmeldung_erforderlich()
RETURNS boolean
LANGUAGE sql
STABLE
AS $$ SELECT EXISTS (SELECT 1 FROM benutzer WHERE aktiv); $$;

CREATE OR REPLACE FUNCTION fn_gibt_es_globalen_admin()
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM benutzer_mandant bm
          JOIN mandant m ON m.mandant_id = bm.mandant_id
         WHERE bm.rolle = 'administrator' AND m.ist_stammmandant);
$$;

-- Entsperren/Aktivieren (frueher UPDATE benutzer ... im Modul).
CREATE OR REPLACE FUNCTION fn_benutzer_entsperren(p_benutzer_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    UPDATE benutzer
       SET aktiv = true, fehlversuche = 0, gesperrt_bis = NULL
     WHERE benutzer_id = p_benutzer_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

CREATE OR REPLACE FUNCTION fn_benutzer_mandant_setzen(
    p_benutzer_id integer, p_mandant_id integer, p_rolle varchar)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    INSERT INTO benutzer_mandant (benutzer_id, mandant_id, rolle)
    VALUES (p_benutzer_id, p_mandant_id, p_rolle)
    ON CONFLICT (benutzer_id, mandant_id)
    DO UPDATE SET rolle = EXCLUDED.rolle, aktiv = true;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

CREATE OR REPLACE FUNCTION fn_benutzer_mandant_loeschen(
    p_benutzer_id integer, p_mandant_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    DELETE FROM benutzer_mandant
     WHERE benutzer_id = p_benutzer_id AND mandant_id = p_mandant_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- --------------------------------------------------------------------------
-- Beleg-Module (KundenBestellungDm / LieferantenBestellungDm /
-- LagerEntnahmeDm) - die drei sind Kopien voneinander und teilen sich
-- deshalb dieselben Views und Funktionen.
--
-- Die Auswahllisten kommen als Views OHNE Mandantenfilter: gefiltert wird
-- im Modul auf der Kopie im Speicher.
-- --------------------------------------------------------------------------

-- Lehrer, die an der Hauptperson des Mandanten haengen (frueher Inline-SQL
-- mit doppeltem :m-Parameter).
CREATE OR REPLACE VIEW v_beleg_person_auswahl AS
SELECT pb.mandant_id,
       p.person_id,
       CAST(p.nachname_firmenname AS varchar(300)) AS nachname_firmenname
  FROM person_beziehung pb
  JOIN person p ON p.person_id = pb.quell_person_id
 WHERE pb.ist_lehrer = true
   AND pb.ziel_person_id = (SELECT pm.person_id
                              FROM person_mandant pm
                             WHERE pm.mandant_id = pb.mandant_id
                               AND pm.ist_hauptperson = true);

CREATE OR REPLACE VIEW v_rechnungstyp_auswahl AS
SELECT rt.mandant_id, rt.rechnungstyp_id,
       CAST(rt.bezeichnung AS varchar(200)) AS bezeichnung,
       rt.reihenfolge
  FROM rechnungstyp rt
 WHERE rt.aktiv = true;

CREATE OR REPLACE FUNCTION fn_hat_hauptperson(p_mandant_id integer)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
    SELECT EXISTS (SELECT 1 FROM person_mandant
                    WHERE mandant_id = p_mandant_id
                      AND ist_hauptperson = true);
$$;

CREATE OR REPLACE FUNCTION fn_rechnungstyp_id(
    p_mandant_id integer, p_bezeichnung varchar)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
    SELECT rechnungstyp_id FROM rechnungstyp
     WHERE mandant_id = p_mandant_id AND bezeichnung = p_bezeichnung
     LIMIT 1;
$$;

-- Naechste freie Positionsnummer eines Belegs.
CREATE OR REPLACE FUNCTION fn_naechste_position(p_beleg_id integer)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
    SELECT COALESCE(MAX(position_nr), 0) + 1
      FROM beleg_position WHERE beleg_id = p_beleg_id;
$$;
