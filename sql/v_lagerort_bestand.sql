-- ============================================================================
-- v_lagerort_bestand — Sicht statt fn_lagerort_bestand(artikel_id)
-- Stand 09.08.2026
--
-- WARUM: LadeBestandBaum laeuft in tblArtikelAfterScroll, also einmal pro
-- Pfeiltastendruck eine Fahrt zum Server. Als Sicht wandert der Bestand
-- einmal ins zentrale Datenmodul, danach filtert das Modul im Speicher.
--
-- WARUM DAS KREUZPRODUKT: die Funktion hatte den Artikel in der JOIN-
-- Bedingung, nicht im WHERE -- deshalb erscheinen auch LEERE Faecher, sonst
-- koennte man nirgends einlagern. Ohne CROSS JOIN wuerde ein Filter auf
-- artikel_id im Speicher genau diese leeren Faecher wegwerfen.
--
-- mandant_id kommt aus artikel, NICHT aus artikel_fach: artikel_id ist
-- Primaerschluessel von artikel und damit schon eindeutig einem Mandanten
-- zugeordnet. Die Spalte in artikel_fach ist eine Dopplung (Walter,
-- 09.08.2026 -- soll spaeter weg).
--
-- Mengengeruest heute: 36 Artikel x 9 Faecher = 324 Zeilen.
-- ============================================================================

CREATE OR REPLACE VIEW v_lagerort_bestand AS
SELECT
    a.artikel_id,
    a.mandant_id,
    ad.adresse_id,
    ad.strasse,
    ad.hausnummer,
    ad.plz,
    ad.ort,
    ai.adressinfo_id,
    ai.beschreibung        AS gebaeude_beschreibung,
    r.raum_id,
    r.bezeichnung          AS raum_bezeichnung,
    rg.regal_id,
    rg.bezeichnung         AS regal_bezeichnung,
    rf.fach_id,
    rf.bezeichnung         AS fach_bezeichnung,
    rf.kapazitaet          AS fach_kapazitaet,
    af.artikel_fach_id,
    af.bestand,
    af.variante_id,
    af.einheit_id,
    e.name                 AS einheit_name
FROM artikel a
CROSS JOIN adresse ad
JOIN raum r             ON r.adresse_id = ad.adresse_id
LEFT JOIN adressinfo ai ON ai.adressinfo_id = r.adressinfo_id
JOIN regal rg           ON rg.raum_id = r.raum_id
JOIN regal_fach rf      ON rf.regal_id = rg.regal_id
-- Nur ueber artikel_id verbinden: der Mandant steckt schon darin.
LEFT JOIN artikel_fach af ON af.fach_id = rf.fach_id
                         AND af.artikel_id = a.artikel_id
LEFT JOIN einheit e       ON e.einheit_id = af.einheit_id
-- Wie in der Funktion: nur Adressen, die als Lager eingetragen sind.
WHERE ad.adresse_id IN (SELECT l.adresse_id FROM lager l
                         WHERE l.adresse_id IS NOT NULL);

COMMENT ON VIEW v_lagerort_bestand IS
    'Alle Faecher je Artikel, mit Bestand wo vorhanden und NULL wo leer. '
    'Ersetzt fn_lagerort_bestand; gefiltert wird im Modul auf der Kopie.';
