-- ===========================================================================
-- Lager-Modul: Lookup-Views und Schreib-Funktionen
--
-- Muster fuer den Umbau aller Module:
--   * Lesen  -> die Module holen ihre MemTables aus dem zentralen Datenmodul.
--               Was einen JOIN oder eine zusammengesetzte Anzeige braucht,
--               wird hier als VIEW abgelegt und dort wie eine Tabelle gefuehrt.
--   * Schreiben -> ausschliesslich ueber die fn_*_speichern/fn_*_loeschen
--               unten. Kein TFDQuery, kein TFDTable, kein ApplyUpdates aus
--               einem Modul heraus.
--
-- Zur Transaktion: eine PostgreSQL-FUNCTION laeuft immer in der Transaktion
-- ihres Aufrufers und ist atomar - eine Exception rollt alles zurueck, was
-- die Funktion angefasst hat. Ein explizites BEGIN/COMMIT/ROLLBACK ist in
-- einer FUNCTION nicht erlaubt und hier auch nicht noetig. Nur eine
-- PROCEDURE koennte Transaktionen selbst steuern; das brauchen wir nicht.
--
-- CAST(... AS varchar(n)) in den Views ist Absicht: PostgreSQL liefert sonst
-- "text", FireDAC macht daraus ein WideMemo und die Combo zeigt "(WIDEMEMO)".
-- ===========================================================================

-- --------------------------------------------------------------------------
-- 1) Lookup-Views (ersetzen die bisherigen Inline-FDQuery im Modul)
-- --------------------------------------------------------------------------

CREATE OR REPLACE VIEW v_adresse_anzeige AS
SELECT a.adresse_id,
       CAST(COALESCE(a.strasse, '') || ' ' || COALESCE(a.hausnummer, '') ||
            ', ' || COALESCE(a.plz, '') || ' ' || COALESCE(a.ort, '')
            AS varchar(300)) AS anzeige
  FROM adresse a;

CREATE OR REPLACE VIEW v_adressinfo_anzeige AS
SELECT ai.adressinfo_id,
       ai.adresse_id,
       CAST(COALESCE(a.strasse, '') || ' ' || COALESCE(a.hausnummer, '') ||
            ', ' || COALESCE(a.ort, '') || ' — ' || ai.beschreibung
            AS varchar(400)) AS anzeige
  FROM adressinfo ai
  JOIN adresse a ON a.adresse_id = ai.adresse_id;

CREATE OR REPLACE VIEW v_raum_anzeige AS
SELECT r.raum_id,
       r.adresse_id,
       CAST(COALESCE(r.bezeichnung, 'Raum ' || r.raum_id) || ' (' ||
            COALESCE(a.strasse, '') || ' ' || COALESCE(a.hausnummer, '') ||
            ', ' || COALESCE(a.ort, '') || ')' AS varchar(400)) AS anzeige
  FROM raum r
  JOIN adresse a ON a.adresse_id = r.adresse_id;

CREATE OR REPLACE VIEW v_regal_anzeige AS
SELECT rg.regal_id,
       rg.raum_id,
       CAST(COALESCE(rg.bezeichnung, 'Regal ' || rg.regal_id) || ' (' ||
            COALESCE(r.bezeichnung, 'Raum ' || r.raum_id) || ')'
            AS varchar(400)) AS anzeige
  FROM regal rg
  JOIN raum r ON r.raum_id = rg.raum_id;

-- --------------------------------------------------------------------------
-- 2) Schreiben: lager
--    p_lager_id NULL oder 0 -> INSERT, sonst UPDATE. Rueckgabe ist immer die
--    ID des geschriebenen Satzes, damit das Modul sie sofort weiterverwenden
--    kann (bei INSERT die neu vergebene).
-- --------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_lager_speichern(
    p_lager_id      integer,
    p_mandant_id    integer,
    p_adresse_id    integer DEFAULT NULL,
    p_raum_id       integer DEFAULT NULL,
    p_regal_id      integer DEFAULT NULL,
    p_barcode       varchar DEFAULT NULL,
    p_beschreibung  text    DEFAULT NULL,
    p_qrcode        bytea   DEFAULT NULL,
    p_photo         bytea   DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    IF p_mandant_id IS NULL OR p_mandant_id <= 0 THEN
        RAISE EXCEPTION 'Mandant fehlt.';
    END IF;

    IF COALESCE(p_lager_id, 0) = 0 THEN
        INSERT INTO lager (mandant_id, adresse_id, raum_id, regal_id,
                           barcode, beschreibung, qrcode, photo)
        VALUES (p_mandant_id, p_adresse_id, p_raum_id, p_regal_id,
                p_barcode, p_beschreibung, p_qrcode, p_photo)
        RETURNING lager_id INTO v_id;
    ELSE
        UPDATE lager
           SET adresse_id   = p_adresse_id,
               raum_id      = p_raum_id,
               regal_id     = p_regal_id,
               barcode      = p_barcode,
               beschreibung = p_beschreibung,
               -- Blobs nur ueberschreiben, wenn wirklich etwas mitkommt:
               -- sonst wuerde ein Speichern ohne Bildauswahl das Bild loeschen.
               qrcode       = COALESCE(p_qrcode, qrcode),
               photo        = COALESCE(p_photo, photo)
         WHERE lager_id = p_lager_id AND mandant_id = p_mandant_id
        RETURNING lager_id INTO v_id;

        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Lagerplatz % gibt es fuer Mandant % nicht.',
                            p_lager_id, p_mandant_id;
        END IF;
    END IF;

    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_lager_loeschen(
    p_lager_id integer, p_mandant_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_anzahl integer;
BEGIN
    DELETE FROM lager
     WHERE lager_id = p_lager_id AND mandant_id = p_mandant_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- --------------------------------------------------------------------------
-- 3) Schreiben: adressinfo (pool-weit, kein mandant_id)
-- --------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_adressinfo_speichern(
    p_adressinfo_id integer,
    p_adresse_id    integer,
    p_beschreibung  text)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    IF COALESCE(p_beschreibung, '') = '' THEN
        RAISE EXCEPTION 'Beschreibung fehlt.';
    END IF;

    IF COALESCE(p_adressinfo_id, 0) = 0 THEN
        INSERT INTO adressinfo (adresse_id, beschreibung)
        VALUES (p_adresse_id, p_beschreibung)
        RETURNING adressinfo_id INTO v_id;
    ELSE
        UPDATE adressinfo
           SET adresse_id = p_adresse_id, beschreibung = p_beschreibung
         WHERE adressinfo_id = p_adressinfo_id
        RETURNING adressinfo_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Adressinfo % gibt es nicht.', p_adressinfo_id;
        END IF;
    END IF;
    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_adressinfo_loeschen(p_adressinfo_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    DELETE FROM adressinfo WHERE adressinfo_id = p_adressinfo_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- --------------------------------------------------------------------------
-- 4) Schreiben: raum (pool-weit)
-- --------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_raum_speichern(
    p_raum_id        integer,
    p_adresse_id     integer,
    p_adressinfo_id  integer DEFAULT NULL,
    p_bezeichnung    varchar DEFAULT NULL,
    p_laenge         numeric DEFAULT NULL,
    p_breite         numeric DEFAULT NULL,
    p_hoehe          numeric DEFAULT NULL,
    p_beschreibung   text    DEFAULT NULL,
    p_max_personen   integer DEFAULT NULL,
    p_ist_mehrzweck  boolean DEFAULT false)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    IF p_adresse_id IS NULL THEN
        RAISE EXCEPTION 'Ein Raum braucht eine Adresse.';
    END IF;

    IF COALESCE(p_raum_id, 0) = 0 THEN
        INSERT INTO raum (adresse_id, adressinfo_id, bezeichnung, laenge,
                          breite, hoehe, beschreibung, max_personen,
                          ist_mehrzweck)
        VALUES (p_adresse_id, p_adressinfo_id, p_bezeichnung, p_laenge,
                p_breite, p_hoehe, p_beschreibung, p_max_personen,
                COALESCE(p_ist_mehrzweck, false))
        RETURNING raum_id INTO v_id;
    ELSE
        UPDATE raum
           SET adresse_id    = p_adresse_id,
               adressinfo_id = p_adressinfo_id,
               bezeichnung   = p_bezeichnung,
               laenge        = p_laenge,
               breite        = p_breite,
               hoehe         = p_hoehe,
               beschreibung  = p_beschreibung,
               max_personen  = p_max_personen,
               ist_mehrzweck = COALESCE(p_ist_mehrzweck, false)
         WHERE raum_id = p_raum_id
        RETURNING raum_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Raum % gibt es nicht.', p_raum_id;
        END IF;
    END IF;
    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_raum_loeschen(p_raum_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    DELETE FROM raum WHERE raum_id = p_raum_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- --------------------------------------------------------------------------
-- 5) Schreiben: ausstattung (pool-weit)
-- --------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_ausstattung_speichern(
    p_ausstattungs_id integer,
    p_bezeichnung     varchar,
    p_ist_mobil       boolean DEFAULT false,
    p_anzahl_mobil    integer DEFAULT 0)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    IF COALESCE(p_bezeichnung, '') = '' THEN
        RAISE EXCEPTION 'Bezeichnung fehlt.';
    END IF;

    IF COALESCE(p_ausstattungs_id, 0) = 0 THEN
        INSERT INTO ausstattung (bezeichnung, ist_mobil, anzahl_mobil)
        VALUES (p_bezeichnung, COALESCE(p_ist_mobil, false),
                COALESCE(p_anzahl_mobil, 0))
        RETURNING ausstattungs_id INTO v_id;
    ELSE
        UPDATE ausstattung
           SET bezeichnung  = p_bezeichnung,
               ist_mobil    = COALESCE(p_ist_mobil, false),
               anzahl_mobil = COALESCE(p_anzahl_mobil, 0)
         WHERE ausstattungs_id = p_ausstattungs_id
        RETURNING ausstattungs_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Ausstattung % gibt es nicht.', p_ausstattungs_id;
        END IF;
    END IF;
    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_ausstattung_loeschen(p_ausstattungs_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    DELETE FROM ausstattung WHERE ausstattungs_id = p_ausstattungs_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- --------------------------------------------------------------------------
-- 6) Schreiben: raum_ausstattung (m:n, kein eigener Schluessel)
--    "setzen" statt "speichern": die Zuordnung gibt es entweder oder nicht,
--    ein UPDATE waere sinnlos. ON CONFLICT haelt den doppelten Klick ab.
-- --------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_raum_ausstattung_setzen(
    p_raum_id integer, p_ausstattungs_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    INSERT INTO raum_ausstattung (raum_id, ausstattungs_id)
    VALUES (p_raum_id, p_ausstattungs_id)
    ON CONFLICT DO NOTHING;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

CREATE OR REPLACE FUNCTION fn_raum_ausstattung_loeschen(
    p_raum_id integer, p_ausstattungs_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    DELETE FROM raum_ausstattung
     WHERE raum_id = p_raum_id AND ausstattungs_id = p_ausstattungs_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- --------------------------------------------------------------------------
-- 7) Schreiben: regal (pool-weit)
-- --------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_regal_speichern(
    p_regal_id     integer,
    p_raum_id      integer,
    p_bezeichnung  varchar DEFAULT NULL,
    p_beschreibung text    DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    IF p_raum_id IS NULL THEN
        RAISE EXCEPTION 'Ein Regal braucht einen Raum.';
    END IF;

    IF COALESCE(p_regal_id, 0) = 0 THEN
        INSERT INTO regal (raum_id, bezeichnung, beschreibung)
        VALUES (p_raum_id, p_bezeichnung, p_beschreibung)
        RETURNING regal_id INTO v_id;
    ELSE
        UPDATE regal
           SET raum_id = p_raum_id, bezeichnung = p_bezeichnung,
               beschreibung = p_beschreibung
         WHERE regal_id = p_regal_id
        RETURNING regal_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Regal % gibt es nicht.', p_regal_id;
        END IF;
    END IF;
    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_regal_loeschen(p_regal_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    DELETE FROM regal WHERE regal_id = p_regal_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- --------------------------------------------------------------------------
-- 8) Schreiben: regal_fach (mandantenbezogen)
-- --------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_regal_fach_speichern(
    p_fach_id      integer,
    p_mandant_id   integer,
    p_regal_id     integer,
    p_bezeichnung  varchar,
    p_beschreibung text    DEFAULT NULL,
    p_kapazitaet   numeric DEFAULT NULL,
    p_einheit_id   integer DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
BEGIN
    IF p_mandant_id IS NULL OR p_mandant_id <= 0 THEN
        RAISE EXCEPTION 'Mandant fehlt.';
    END IF;
    IF COALESCE(p_bezeichnung, '') = '' THEN
        RAISE EXCEPTION 'Bezeichnung fehlt.';
    END IF;

    IF COALESCE(p_fach_id, 0) = 0 THEN
        INSERT INTO regal_fach (mandant_id, regal_id, bezeichnung,
                                beschreibung, kapazitaet, einheit_id)
        VALUES (p_mandant_id, p_regal_id, p_bezeichnung,
                p_beschreibung, p_kapazitaet, p_einheit_id)
        RETURNING fach_id INTO v_id;
    ELSE
        UPDATE regal_fach
           SET regal_id     = p_regal_id,
               bezeichnung  = p_bezeichnung,
               beschreibung = p_beschreibung,
               kapazitaet   = p_kapazitaet,
               einheit_id   = p_einheit_id
         WHERE fach_id = p_fach_id AND mandant_id = p_mandant_id
        RETURNING fach_id INTO v_id;
        IF v_id IS NULL THEN
            RAISE EXCEPTION 'Fach % gibt es fuer Mandant % nicht.',
                            p_fach_id, p_mandant_id;
        END IF;
    END IF;
    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_regal_fach_loeschen(
    p_fach_id integer, p_mandant_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE v_anzahl integer;
BEGIN
    DELETE FROM regal_fach
     WHERE fach_id = p_fach_id AND mandant_id = p_mandant_id;
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;
