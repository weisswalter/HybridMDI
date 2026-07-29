-- ============================================================================
-- Mehrzweckraeume und mobiles Inventar - Stand 29.07.2026
--
-- WALTERS VORGABE: "vielzweckraeume die unter Umstaenden mit mobilem Inventar
-- ausgestattet werden koennen sollten auch waehlbar sein, Raeume sollten ein
-- entsprechendes Flag auch erhalten".
--
-- ZENTRALE ENTSCHEIDUNG: Mobiles Inventar ist eine RESSOURCE mit eigener
-- Belegung, kein blosses Merkmal am Raum. Ein Beamer kann nicht in zwei
-- Raeumen gleichzeitig stehen - ohne eigene Buchung wuerde die Planung genau
-- das zulassen. Deshalb `ausstattung.anzahl_mobil` (wieviele bewegliche
-- Stueck es gibt) plus `termin_ausstattung` (wer sie wann belegt).
--
-- Ein Raum kommt damit auf zwei Wegen in Frage:
--   1. er hat die geforderte Ausstattung FEST (raum_ausstattung)
--   2. er ist Mehrzweckraum UND ein bewegliches Stueck ist im Zeitfenster frei
-- ============================================================================

-- ── Flags ──────────────────────────────────────────────────────────────────
ALTER TABLE raum ADD COLUMN IF NOT EXISTS ist_mehrzweck boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN raum.ist_mehrzweck IS
  'Raum laesst sich mit mobilem Inventar nachruesten. Ohne dieses Flag zaehlt nur die feste Ausstattung.';

ALTER TABLE ausstattung ADD COLUMN IF NOT EXISTS ist_mobil boolean NOT NULL DEFAULT false;
-- Wieviele bewegliche Stueck es insgesamt gibt. 0 = nur fest verbaut.
ALTER TABLE ausstattung ADD COLUMN IF NOT EXISTS anzahl_mobil integer NOT NULL DEFAULT 0;
COMMENT ON COLUMN ausstattung.anzahl_mobil IS
  'Anzahl beweglicher Stuecke insgesamt. Die Verfuegbarkeit ergibt sich daraus abzueglich der im Zeitfenster belegten.';

-- ── Belegung des mobilen Inventars ─────────────────────────────────────────
-- Haengt am TERMIN, nicht am Kurs: dasselbe Curriculum kann in einer Runde
-- den Beamer brauchen und in der naechsten nicht.
CREATE TABLE IF NOT EXISTS termin_ausstattung (
    termin_id       integer NOT NULL REFERENCES kurs_termin(termin_id) ON DELETE CASCADE,
    ausstattungs_id integer NOT NULL REFERENCES ausstattung(ausstattungs_id),
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    menge           integer NOT NULL DEFAULT 1 CHECK (menge > 0),
    PRIMARY KEY (termin_id, ausstattungs_id)
);

CREATE INDEX IF NOT EXISTS ix_termin_ausstattung_st
    ON termin_ausstattung (ausstattungs_id);

-- ── Wieviele Stueck sind im Zeitfenster noch frei? ─────────────────────────
-- Zaehlt die Belegungen ueberlappender Termine ab. Ausgefallene Termine
-- blockieren nichts.
CREATE OR REPLACE FUNCTION fn_ausstattung_frei(
    p_ausstattungs_id integer, p_von timestamptz, p_bis timestamptz,
    p_ausser_termin integer DEFAULT NULL)
RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT GREATEST(0, a.anzahl_mobil - COALESCE((
             SELECT SUM(ta.menge)
               FROM termin_ausstattung ta
               JOIN kurs_termin t ON t.termin_id = ta.termin_id
              WHERE ta.ausstattungs_id = p_ausstattungs_id
                AND t.status <> 'ausgefallen'
                AND t.zeitraum && tstzrange(p_von, p_bis)
                AND (p_ausser_termin IS NULL OR t.termin_id <> p_ausser_termin)
           ), 0))::integer
      FROM ausstattung a
     WHERE a.ausstattungs_id = p_ausstattungs_id;
$$;

-- ── Welche Raeume kommen fuer einen Kurs im Zeitfenster in Frage? ──────────
-- Liefert ALLE Raeume mit Begruendung, nicht nur die passenden: der Anwender
-- soll sehen, WARUM ein Raum ausscheidet. Das ist der Unterschied zwischen
-- einer brauchbaren Auswahl und einer leeren Liste.
CREATE OR REPLACE FUNCTION fn_raum_auswahl(
    p_kurs_id integer, p_von timestamptz, p_bis timestamptz,
    p_ausser_termin integer DEFAULT NULL)
RETURNS TABLE (
    raum_id         integer,
    bezeichnung     varchar(200),
    max_personen    integer,
    ist_mehrzweck   boolean,
    belegt          boolean,
    fehlend_fest    text,     -- geforderte Ausstattung, die fest fehlt
    mobil_moeglich  boolean,  -- laesst sich das Fehlende mobil ausgleichen?
    geeignet        boolean,
    begruendung     varchar(300)
)
LANGUAGE sql STABLE AS $$
WITH gefordert AS (
    SELECT ka.ausstattungs_id, a.bezeichnung, ka.zwingend,
           a.ist_mobil, a.anzahl_mobil
      FROM kurs_ausstattung ka
      JOIN ausstattung a ON a.ausstattungs_id = ka.ausstattungs_id
     WHERE ka.kurs_id = p_kurs_id
), je_raum AS (
    SELECT r.raum_id,
           CAST(COALESCE(r.bezeichnung, 'Raum ' || r.raum_id) AS varchar(200)) AS bezeichnung,
           r.max_personen,
           r.ist_mehrzweck,
           -- Ist der Raum im Zeitfenster schon belegt?
           EXISTS (SELECT 1 FROM kurs_termin t
                    WHERE t.raum_id = r.raum_id
                      AND t.status <> 'ausgefallen'
                      AND t.zeitraum && tstzrange(p_von, p_bis)
                      AND (p_ausser_termin IS NULL OR t.termin_id <> p_ausser_termin)) AS belegt,
           -- zwingend gefordert, aber nicht fest vorhanden
           ARRAY(SELECT g.bezeichnung FROM gefordert g
                  WHERE g.zwingend
                    AND NOT EXISTS (SELECT 1 FROM raum_ausstattung ra
                                     WHERE ra.raum_id = r.raum_id
                                       AND ra.ausstattungs_id = g.ausstattungs_id)) AS fehlt,
           -- davon: was liesse sich mobil ausgleichen (Stueck im Fenster frei)?
           ARRAY(SELECT g.bezeichnung FROM gefordert g
                  WHERE g.zwingend
                    AND NOT EXISTS (SELECT 1 FROM raum_ausstattung ra
                                     WHERE ra.raum_id = r.raum_id
                                       AND ra.ausstattungs_id = g.ausstattungs_id)
                    AND g.ist_mobil
                    AND fn_ausstattung_frei(g.ausstattungs_id, p_von, p_bis, p_ausser_termin) > 0
                ) AS mobil_deckbar
      FROM raum r
)
SELECT j.raum_id, j.bezeichnung, j.max_personen, j.ist_mehrzweck, j.belegt,
       array_to_string(j.fehlt, ', ') AS fehlend_fest,
       (cardinality(j.fehlt) > 0
        AND j.ist_mehrzweck
        AND cardinality(j.fehlt) = cardinality(j.mobil_deckbar)) AS mobil_moeglich,
       (NOT j.belegt
        AND (cardinality(j.fehlt) = 0
             OR (j.ist_mehrzweck
                 AND cardinality(j.fehlt) = cardinality(j.mobil_deckbar)))) AS geeignet,
       CAST(CASE
         WHEN j.belegt THEN 'belegt'
         WHEN cardinality(j.fehlt) = 0 THEN 'fest ausgestattet'
         WHEN NOT j.ist_mehrzweck THEN 'fehlt: ' || array_to_string(j.fehlt, ', ')
         WHEN cardinality(j.fehlt) = cardinality(j.mobil_deckbar)
              THEN 'mobil ausruestbar: ' || array_to_string(j.mobil_deckbar, ', ')
         ELSE 'mobil nicht deckbar: ' ||
              array_to_string(ARRAY(SELECT unnest(j.fehlt)
                                    EXCEPT SELECT unnest(j.mobil_deckbar)), ', ')
       END AS varchar(300)) AS begruendung
  FROM je_raum j
 ORDER BY 8 DESC, j.bezeichnung;
$$;

-- ── Dasselbe fuer Lehrer: Kompetenz und freie Zeit ─────────────────────────
CREATE OR REPLACE FUNCTION fn_lehrer_auswahl(
    p_mandant_id integer, p_kurs_id integer,
    p_von timestamptz, p_bis timestamptz, p_ausser_termin integer DEFAULT NULL)
RETURNS TABLE (
    person_id       integer,
    name            varchar(300),
    anstellungsart  varchar(20),
    belegt          boolean,
    fehlend         text,
    geeignet        boolean,
    begruendung     varchar(300)
)
LANGUAGE sql STABLE AS $$
WITH gefordert AS (
    SELECT kk.kompetenz_id, kt.bezeichnung
      FROM kurs_kompetenz kk
      JOIN kompetenz_typ kt ON kt.mandant_id = kk.mandant_id
                           AND kt.kompetenz_id = kk.kompetenz_id
     WHERE kk.kurs_id = p_kurs_id AND kk.rolle = 'lehrer'
), je_lehrer AS (
    SELECT p.person_id,
           CAST(p.nachname_firmenname ||
                CASE WHEN COALESCE(p.vorname,'') <> '' THEN ', ' || p.vorname
                     ELSE '' END AS varchar(300)) AS name,
           CAST(CASE WHEN pb.ist_mitarbeiter THEN 'Lohnmitarbeiter'
                     ELSE 'Honorarlehrer' END AS varchar(20)) AS anstellungsart,
           EXISTS (SELECT 1 FROM kurs_termin t
                    WHERE t.leiter_person_id = p.person_id
                      AND t.status <> 'ausgefallen'
                      AND t.zeitraum && tstzrange(p_von, p_bis)
                      AND (p_ausser_termin IS NULL OR t.termin_id <> p_ausser_termin)) AS belegt,
           -- geforderte Kompetenz ohne GUELTIGEN Nachweis
           ARRAY(SELECT g.bezeichnung FROM gefordert g
                  WHERE NOT EXISTS (
                    SELECT 1 FROM person_kompetenz pk
                     WHERE pk.person_id = p.person_id
                       AND pk.mandant_id = p_mandant_id
                       AND pk.kompetenz_id = g.kompetenz_id
                       AND (pk.gueltig_bis IS NULL OR pk.gueltig_bis >= CURRENT_DATE))) AS fehlt
      FROM person_beziehung pb
      JOIN person p ON p.person_id = pb.quell_person_id
     WHERE pb.mandant_id = p_mandant_id AND pb.ist_lehrer
)
SELECT l.person_id, l.name, l.anstellungsart, l.belegt,
       array_to_string(l.fehlt, ', ') AS fehlend,
       (NOT l.belegt AND cardinality(l.fehlt) = 0) AS geeignet,
       CAST(CASE
         WHEN l.belegt AND cardinality(l.fehlt) > 0
              THEN 'belegt, ausserdem fehlt: ' || array_to_string(l.fehlt, ', ')
         WHEN l.belegt THEN 'belegt'
         WHEN cardinality(l.fehlt) > 0
              THEN 'Kompetenz fehlt oder abgelaufen: ' || array_to_string(l.fehlt, ', ')
         ELSE 'frei und qualifiziert'
       END AS varchar(300)) AS begruendung
  FROM je_lehrer l
 ORDER BY 6 DESC, l.name;
$$;
