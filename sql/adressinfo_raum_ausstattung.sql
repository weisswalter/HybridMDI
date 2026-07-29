-- ============================================================================
-- Heisenberg: adressinfo, raum, ausstattung (m:n via raum_ausstattung)
-- PostgreSQL DDL
--
-- Motivation: eine Adresse kann mehrere Eingaenge/Stockwerke haben, ueber die
-- unterschiedliche Raeume erreichbar sind (adressinfo). Jeder Raum hat feste
-- Masse und kann mehrere Ausstattungsmerkmale gleichzeitig haben (Klima,
-- Beamer, kuehlraum-/roentgenraumtauglich, ...) -> m:n-Bruecke wie bei
-- person_adresse, NICHT eine einfache FK (ein Raum kann mehrere Merkmale
-- gleichzeitig haben).
--
-- Multi-Tenant: adressinfo/raum/ausstattung sind KEINE mandantenbezogenen
-- Daten, sondern physische Fakten des Gebaeudes (analog zu adresse selbst,
-- die auch keine mandant_id traegt). lager (das auf raum verweist) bleibt
-- mandantengebunden.
-- ============================================================================

BEGIN;

-- ── adressinfo: zusaetzliche Eingangs-/Stockwerksinfo zu einer Adresse ─────
CREATE TABLE IF NOT EXISTS adressinfo (
    adressinfo_id serial PRIMARY KEY,
    adresse_id    integer NOT NULL REFERENCES adresse(adresse_id),
    beschreibung  text NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_adressinfo_adresse ON adressinfo (adresse_id);

-- ── ausstattung: Merkmals-Lookup (Klima, Beamer, kuehlraumtauglich, ...) ───
CREATE TABLE IF NOT EXISTS ausstattung (
    ausstattungs_id serial PRIMARY KEY,
    bezeichnung     varchar(100) NOT NULL UNIQUE
);

-- ── raum: adresse_id Pflicht, adressinfo_id optional (nur bei mehreren
--    Eingaengen/Stockwerken noetig) ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS raum (
    raum_id       serial PRIMARY KEY,
    adresse_id    integer NOT NULL REFERENCES adresse(adresse_id),
    adressinfo_id integer REFERENCES adressinfo(adressinfo_id),
    bezeichnung   varchar(100),
    laenge        numeric(6,2),   -- Meter
    breite        numeric(6,2),
    hoehe         numeric(6,2),
    beschreibung  text
);
CREATE INDEX IF NOT EXISTS ix_raum_adresse ON raum (adresse_id);
CREATE INDEX IF NOT EXISTS ix_raum_adressinfo ON raum (adressinfo_id);

-- ── raum_ausstattung: m:n-Bruecke — ein Raum kann mehrere Merkmale
--    gleichzeitig haben ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS raum_ausstattung (
    raum_id         integer NOT NULL REFERENCES raum(raum_id),
    ausstattungs_id integer NOT NULL REFERENCES ausstattung(ausstattungs_id),
    PRIMARY KEY (raum_id, ausstattungs_id)
);

-- ── lager.raum_id jetzt als echter FK (Tabelle existierte vorher noch nicht) ─
ALTER TABLE lager
    ADD CONSTRAINT lager_raum_id_fkey
    FOREIGN KEY (raum_id) REFERENCES raum(raum_id);

COMMIT;
