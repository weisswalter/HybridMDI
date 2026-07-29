-- ============================================================================
-- Artikel-Modul: Artikel, Varianten, Stueckliste, Regalfaecher, Barcodes,
-- Bestand je Fach + Zulauf/Wareneingang (noch nicht eingelagert).
-- Stand 19.07.2026 — passt zum Ist-Schema (regal/raum/lager existieren).
--
-- ALLES MANDANTENBEZOGEN (Walters Vorgabe 19.07.2026):
--   - Lookup-Tabellen (einheit, zugang_status) nach dem adressentyp-Muster:
--     PK (mandant_id, xyz_id serial), Seeds je vorhandenem Mandanten.
--   - Alle uebrigen Tabellen tragen mandant_id NOT NULL; FKs auf die
--     Lookups laufen zusammengesetzt ueber (mandant_id, xyz_id), damit kein
--     Typ mandantenuebergreifend "ausgeliehen" werden kann.
--   - regal bleibt pool-weit (physisches Inventar), aber die FAECHER sind
--     mandantenbezogen — so koennen sich mehrere Mandanten dasselbe
--     physische Regal mit eigenen Faechern aufteilen.
--   - Seriennummer aenderbar im Stamm, modul_nr bleibt (fachliche Vorgabe).
-- ============================================================================

-- ── Einheiten (Stueck, kg, Liter, ...) — je Mandant anpassbar ───────────────
CREATE TABLE IF NOT EXISTS einheit (
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    einheit_id   serial,
    name         varchar(50) NOT NULL,
    beschreibung text,
    PRIMARY KEY (mandant_id, einheit_id),
    UNIQUE (mandant_id, name)
);

INSERT INTO einheit (mandant_id, name, beschreibung)
SELECT m.mandant_id, v.name, v.beschreibung
FROM mandant m
CROSS JOIN (VALUES
    ('Stück',  'Stückzahl'),
    ('kg',     'Kilogramm'),
    ('g',      'Gramm'),
    ('Liter',  'Liter'),
    ('m',      'Meter'),
    ('m²',     'Quadratmeter')
) AS v(name, beschreibung)
ON CONFLICT (mandant_id, name) DO NOTHING;

-- ── Artikel-Stamm ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS artikel (
    artikel_id   serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    artikel_nr   varchar(50) NOT NULL,
    serien_nr    varchar(100),          -- aenderbar (aktuelle Serie/Charge)
    modul_nr     varchar(100),          -- bleibt konstant
    artikelname  varchar(200) NOT NULL,
    beschreibung text,
    created_at   timestamp NOT NULL DEFAULT now(),
    updated_at   timestamp,
    UNIQUE (mandant_id, artikel_nr)
);

-- ── Varianten (Groesse/Farbe usw. unter EINER Artikelnummer) ────────────────
CREATE TABLE IF NOT EXISTS artikel_variante (
    variante_id  serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    artikel_id   integer NOT NULL REFERENCES artikel(artikel_id),
    bezeichnung  varchar(100) NOT NULL,  -- z.B. 'Größe L', 'blau'
    serien_nr    varchar(100),           -- optional je Variante
    beschreibung text,
    UNIQUE (artikel_id, bezeichnung)
);

-- ── Stueckliste: Artikel besteht aus Unterartikeln ──────────────────────────
CREATE TABLE IF NOT EXISTS artikel_artikel (
    mandant_id       integer NOT NULL REFERENCES mandant(mandant_id),
    artikel_id       integer NOT NULL REFERENCES artikel(artikel_id),
    unter_artikel_id integer NOT NULL REFERENCES artikel(artikel_id),
    menge            numeric(12,3) NOT NULL DEFAULT 1,
    einheit_id       integer,
    position         integer,            -- Sortierung in der Stueckliste
    PRIMARY KEY (artikel_id, unter_artikel_id),
    FOREIGN KEY (mandant_id, einheit_id) REFERENCES einheit(mandant_id, einheit_id),
    CHECK (artikel_id <> unter_artikel_id)  -- Zyklen ueber mehrere Ebenen prueft die Logik
);

-- ── Regalfaecher (mandantenbezogen — Mandanten teilen sich physische Regale) ─
CREATE TABLE IF NOT EXISTS regal_fach (
    fach_id      serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    regal_id     integer NOT NULL REFERENCES regal(regal_id),
    bezeichnung  varchar(100) NOT NULL,  -- z.B. 'A3'
    beschreibung text,
    kapazitaet   numeric(12,3),
    einheit_id   integer,
    FOREIGN KEY (mandant_id, einheit_id) REFERENCES einheit(mandant_id, einheit_id),
    UNIQUE (mandant_id, regal_id, bezeichnung)
);

-- ── Barcodes/QR-Codes (mehrere je Artikel moeglich: EAN, interner Code...) ──
CREATE TABLE IF NOT EXISTS artikel_barcode (
    barcode_id   serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    artikel_id   integer NOT NULL REFERENCES artikel(artikel_id),
    variante_id  integer REFERENCES artikel_variante(variante_id),  -- optional
    barcode      varchar(100),
    qrcode       bytea,                  -- wie lager.qrcode
    beschreibung text
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_artikel_barcode
    ON artikel_barcode (mandant_id, barcode) WHERE barcode IS NOT NULL;

-- ── Bestand je Fach ─────────────────────────────────────────────────────────
-- variante_id nullable: Artikel ohne Varianten lagern direkt. Zwei partielle
-- Unique-Indexe statt PK, weil NULL in einem PK nicht erlaubt ist.
CREATE TABLE IF NOT EXISTS artikel_fach (
    artikel_fach_id serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    artikel_id      integer NOT NULL REFERENCES artikel(artikel_id),
    fach_id         integer NOT NULL REFERENCES regal_fach(fach_id),
    variante_id     integer REFERENCES artikel_variante(variante_id),
    bestand         numeric(12,3) NOT NULL DEFAULT 0,
    einheit_id      integer,
    FOREIGN KEY (mandant_id, einheit_id) REFERENCES einheit(mandant_id, einheit_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_artikel_fach_ohne_variante
    ON artikel_fach (artikel_id, fach_id) WHERE variante_id IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS ux_artikel_fach_mit_variante
    ON artikel_fach (artikel_id, fach_id, variante_id) WHERE variante_id IS NOT NULL;

-- ── Zulauf/Wareneingang: bestellt oder eingegangen, aber noch kein Fach ─────
CREATE TABLE IF NOT EXISTS zugang_status (
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    status_id    serial,
    bezeichnung  varchar(50) NOT NULL,
    PRIMARY KEY (mandant_id, status_id),
    UNIQUE (mandant_id, bezeichnung)
);

INSERT INTO zugang_status (mandant_id, bezeichnung)
SELECT m.mandant_id, v.bezeichnung
FROM mandant m
CROSS JOIN (VALUES
    ('Bestellt'),
    ('Im Zulauf'),
    ('Eingegangen')          -- angekommen, aber noch nicht eingelagert
) AS v(bezeichnung)
ON CONFLICT (mandant_id, bezeichnung) DO NOTHING;

CREATE TABLE IF NOT EXISTS artikel_zugang (
    zugang_id      serial PRIMARY KEY,
    mandant_id     integer NOT NULL REFERENCES mandant(mandant_id),
    artikel_id     integer NOT NULL REFERENCES artikel(artikel_id),
    variante_id    integer REFERENCES artikel_variante(variante_id),
    menge          numeric(12,3) NOT NULL,
    einheit_id     integer,
    status_id      integer NOT NULL,
    erwartet_am    date,                -- geplantes Lieferdatum
    eingegangen_am timestamp,           -- gesetzt bei Status 'Eingegangen'
    beschreibung   text,
    created_at     timestamp NOT NULL DEFAULT now(),
    FOREIGN KEY (mandant_id, einheit_id) REFERENCES einheit(mandant_id, einheit_id),
    FOREIGN KEY (mandant_id, status_id)  REFERENCES zugang_status(mandant_id, status_id)
);
CREATE INDEX IF NOT EXISTS ix_artikel_zugang_status ON artikel_zugang (mandant_id, status_id);

-- Beim Einlagern: menge dem artikel_fach-Bestand zuschlagen und den
-- artikel_zugang-Satz loeschen oder auf einen (spaeter ergaenzbaren)
-- Status 'Eingelagert' setzen — Logik im Delphi-Modul, nicht in der DB.
