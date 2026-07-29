-- ============================================================================
-- Heisenberg: fn_lagerort_bestand — Hierarchie Adresse -> Gebaeude/Eingang
-- (adressinfo) -> Raum -> Regal -> Fach -> Bestand des jeweiligen Artikels,
-- fuer den Bestand-Baum (VirtualStringTree) im ArtikelStamm-Modul.
--
-- artikel_id ist bewusst die FUEHRENDE Spalte (Walters Vorgabe), damit die
-- FireDAC-Seite sauber je Artikel durchscrollen kann (analog zum bestehenden
-- IndexFieldNames='artikel_id'-Muster bei tblArtikelFach).
--
-- Eine normale VIEW kann keinen Parameter (den Artikel) entgegennehmen -> als
-- Stored Function gebaut (RETURNS TABLE), passt zum Projektmuster
-- "FDTable/Views/Stored Procedures statt FDQuery-Inline-SQL".
--
-- WICHTIG: liefert ALLE Faecher unter allen Lager-Adressen zurueck (nicht nur
-- die, wo der Artikel schon liegt) -- LEFT JOIN auf artikel_fach, gefiltert
-- auf p_artikel_id. So zeigt der Baum sowohl den vorhandenen Bestand
-- (bestand/artikel_fach_id gefuellt) als auch leere, waehlbare Faecher
-- (bestand/artikel_fach_id NULL) fuer den "an anderem Ort ablegen"-Dialog in
-- einem Rutsch.
--
-- Nur Adressen, die auch tatsaechlich als Lager genutzt werden (per lager-
-- Tabelle markiert), werden angezeigt.
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_lagerort_bestand(p_artikel_id integer)
RETURNS TABLE (
    artikel_id           integer,
    adresse_id           integer,
    strasse              varchar(150),
    hausnummer           varchar(20),
    plz                  varchar(20),
    ort                  varchar(100),
    adressinfo_id        integer,
    gebaeude_beschreibung text,
    raum_id              integer,
    raum_bezeichnung     varchar(100),
    regal_id             integer,
    regal_bezeichnung    varchar(100),
    fach_id              integer,
    fach_bezeichnung     varchar(100),
    fach_kapazitaet      numeric(12,3),
    artikel_fach_id      integer,
    bestand              numeric(12,3),
    variante_id          integer,
    einheit_id           integer,
    einheit_name         varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p_artikel_id                AS artikel_id,
        a.adresse_id,
        a.strasse,
        a.hausnummer,
        a.plz,
        a.ort,
        ai.adressinfo_id,
        ai.beschreibung             AS gebaeude_beschreibung,
        r.raum_id,
        r.bezeichnung               AS raum_bezeichnung,
        rg.regal_id,
        rg.bezeichnung              AS regal_bezeichnung,
        rf.fach_id,
        rf.bezeichnung              AS fach_bezeichnung,
        rf.kapazitaet               AS fach_kapazitaet,
        af.artikel_fach_id,
        af.bestand,
        af.variante_id,
        af.einheit_id,
        e.name                      AS einheit_name
    FROM adresse a
    JOIN raum r        ON r.adresse_id = a.adresse_id
    LEFT JOIN adressinfo ai ON ai.adressinfo_id = r.adressinfo_id
    JOIN regal rg      ON rg.raum_id = r.raum_id
    JOIN regal_fach rf ON rf.regal_id = rg.regal_id
    LEFT JOIN artikel_fach af
           ON af.fach_id = rf.fach_id
          AND af.artikel_id = p_artikel_id
    LEFT JOIN einheit e
           ON e.mandant_id = af.mandant_id
          AND e.einheit_id = af.einheit_id
    WHERE a.adresse_id IN (SELECT l.adresse_id FROM lager l WHERE l.adresse_id IS NOT NULL)
    ORDER BY a.adresse_id, ai.adressinfo_id, r.raum_id, rg.regal_id, rf.fach_id;
END;
$$ LANGUAGE plpgsql STABLE;
