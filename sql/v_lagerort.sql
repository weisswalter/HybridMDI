-- ============================================================================
-- v_lagerort — Ortshierarchie, vom Fach aus nach oben, eine Zeile je Fach
-- Stand 09.08.2026
--
-- Harter Join vom Fach zurueck zum Standort (Walters Vorgabe): im Baum steht
-- nur, was bis zum Fach durchgebaut ist. Eine angefangene Kette - Ort ohne
-- Raum, Raum ohne Regal, Regal ohne Fach - erscheint nicht. Wer im Baum einen
-- Ort, Raum oder ein Regal anlegt, muss deshalb VORHER den Hinweis bekommen,
-- dass der Eintrag verfaellt, wenn er nicht bis zum Fach durchkommt.
--
-- KORREKTUR eines Denkfehlers vom selben Tag: die erste Fassung hiess
-- v_lagerort_bestand und hatte einen CROSS JOIN auf artikel. Damit wurde eine
-- Struktur, die mit dem Artikel nichts zu tun hat, je Artikel wiederholt -
-- aus 9 Faechern wurden 324 Zeilen, 36-mal dasselbe Regal.
-- Adresse -> Raum -> Regal -> Fach besteht unabhaengig vom Artikel. Nur die
-- Verknuepfung Artikel<->Fach traegt eine artikel_id, und die steht in
-- artikel_fach, einer Tabelle, die das zentrale Datenmodul ohnehin fuehrt.
-- Der Baum setzt beides im Speicher zusammen.
-- ============================================================================

DROP VIEW IF EXISTS v_lagerort_bestand;

CREATE OR REPLACE VIEW v_lagerort AS
SELECT
    rf.fach_id,
    rf.mandant_id,                       -- die Mandantentrennung sitzt am Fach
    rf.bezeichnung        AS fach_bezeichnung,
    rf.kapazitaet         AS fach_kapazitaet,
    rf.einheit_id         AS fach_einheit_id,
    ef.name               AS fach_einheit_name,
    rg.regal_id,
    rg.bezeichnung        AS regal_bezeichnung,
    r.raum_id,
    r.bezeichnung         AS raum_bezeichnung,
    ai.adressinfo_id,
    ai.beschreibung       AS gebaeude_beschreibung,
    ad.adresse_id,
    ad.strasse,
    ad.hausnummer,
    ad.plz,
    ad.ort
FROM regal_fach rf
JOIN regal rg           ON rg.regal_id   = rf.regal_id
JOIN raum r             ON r.raum_id     = rg.raum_id
JOIN adresse ad         ON ad.adresse_id = r.adresse_id
LEFT JOIN adressinfo ai ON ai.adressinfo_id = r.adressinfo_id
LEFT JOIN einheit ef    ON ef.einheit_id = rf.einheit_id
-- Wie bisher in fn_lagerort_bestand: nur Adressen, die als Lager gefuehrt sind.
WHERE ad.adresse_id IN (SELECT l.adresse_id FROM lager l
                         WHERE l.adresse_id IS NOT NULL);

COMMENT ON VIEW v_lagerort IS
    'Ortshierarchie Adresse->Raum->Regal->Fach, flach, eine Zeile je Fach. '
    'Ohne Artikel - der haengt ueber artikel_fach am Fach.';
