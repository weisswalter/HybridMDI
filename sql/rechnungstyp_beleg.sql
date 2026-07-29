-- ============================================================================
-- Rechnungstyp (Beleg-Typ-Lookup) + generischer Beleg/Beleg-Position fuer die
-- 3 Transaktionsmodule:
--   1) Kunde bestellt bei Hauptperson       (vorgangsart 'Bestellung')
--   2) Hauptperson bestellt bei Lieferant   (vorgangsart 'Lieferung')
--   3) Lehrer reserviert/entnimmt aus Lager (vorgangsart 'Entnahme')
-- Stand 27.07.2026 -- schliesst an project_heisenberg_rechnungslauf an
-- (Angebot -> Kostenvoranschlag -> Bestellung -> Versand -> Lieferschein ->
-- Rechnung, plus Gutschrift/Retoure/Mahnung/Zahlungseingang/Storno) sowie an
-- die Lager-Entnahme/Rueckgabe-Anforderung.
--
-- Konventionen wie bei artikel.sql: alles mandantenbezogen, Typ-Tabellen nach
-- adressentyp-Muster (PK (mandant_id, xyz_id serial)).
-- ============================================================================

-- ── Rechnungstyp: Lookup der Belegarten/Stufen, je Mandant pflegbar (ueber
--    ein eigenes JvRibbon-Stammdatenmodul, RechnungstypDm/Frm) ──────────────
CREATE TABLE IF NOT EXISTS rechnungstyp (
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    rechnungstyp_id serial,
    bezeichnung     varchar(100) NOT NULL,
    -- Reihenfolge in der Angebot->Rechnung-Kette (fuer Sortierung/kuenftige
    -- Statemaschine); NULL bei Typen ausserhalb der linearen Kette.
    reihenfolge     integer,
    -- 'eingehend' = Wareneingang (Lieferschein/Retoure/Rueckgabe),
    -- 'ausgehend' = Warenausgang (Versand/Entnahme), NULL sonst.
    richtung        varchar(20) CHECK (richtung IN ('eingehend', 'ausgehend')),
    aktiv           boolean NOT NULL DEFAULT true,
    PRIMARY KEY (mandant_id, rechnungstyp_id),
    UNIQUE (mandant_id, bezeichnung)
);

INSERT INTO rechnungstyp (mandant_id, bezeichnung, reihenfolge, richtung)
SELECT m.mandant_id, v.bezeichnung, v.reihenfolge, v.richtung
FROM mandant m
CROSS JOIN (VALUES
    ('Angebot',             10, NULL),
    ('Kostenvoranschlag',   20, NULL),
    ('Bestellung',          30, NULL),
    ('Auftragsbestätigung', 35, NULL),
    ('Lieferschein',        40, 'eingehend'),
    ('Versand',             45, 'ausgehend'),
    ('Rechnung',            50, NULL),
    ('Gutschrift',          60, NULL),
    ('Retoure',             65, 'eingehend'),
    ('Mahnung',             70, NULL),
    ('Zahlungseingang',     80, NULL),
    ('Storno',              90, NULL),
    -- Zusaetzlich fuer Modul 3 (Lager-Entnahme/Rueckgabe) -- ausserhalb der
    -- Angebot->Rechnung-Kette, deshalb reihenfolge NULL.
    ('Entnahme',            NULL, 'ausgehend'),
    ('Rückgabe',            NULL, 'eingehend')
) AS v(bezeichnung, reihenfolge, richtung)
ON CONFLICT (mandant_id, bezeichnung) DO NOTHING;

-- ── Rollen-Erweiterung: Lieferant/Lehrer analog ist_kunde/ist_mitarbeiter ───
ALTER TABLE person_beziehung ADD COLUMN IF NOT EXISTS ist_lieferant boolean NOT NULL DEFAULT false;
ALTER TABLE person_beziehung ADD COLUMN IF NOT EXISTS ist_lehrer    boolean NOT NULL DEFAULT false;

-- ── Leistung: wie Artikel, aber Dienstleistung mit Bezug zur Ressource Mensch
CREATE TABLE IF NOT EXISTS leistung (
    leistung_id   serial PRIMARY KEY,
    mandant_id    integer NOT NULL REFERENCES mandant(mandant_id),
    leistung_nr   varchar(50) NOT NULL,
    bezeichnung   varchar(200) NOT NULL,
    beschreibung  text,
    -- Die Person (Ressource Mensch), die die Leistung erbringt (z.B. Kursleiter/Coach).
    person_id     integer REFERENCES person(person_id),
    einheit_id    integer,          -- z.B. Stunde
    standardpreis numeric(12,2),
    UNIQUE (mandant_id, leistung_nr),
    FOREIGN KEY (mandant_id, einheit_id) REFERENCES einheit(mandant_id, einheit_id)
);

-- ── Beleg: generischer Kopf fuer alle 3 Module ──────────────────────────────
-- vorgangsart wird VOM MODUL vorgegeben (Delphi-Konstante je Modul, kein
-- Anwenderfeld) -- der CHECK sichert das nur gegen Fehlbedienung ausserhalb
-- der GUI ab (z.B. direkte SQL-Eingriffe).
CREATE TABLE IF NOT EXISTS beleg (
    beleg_id            serial PRIMARY KEY,
    mandant_id          integer NOT NULL REFERENCES mandant(mandant_id),
    vorgangsart         varchar(20) NOT NULL
                          CHECK (vorgangsart IN ('Bestellung', 'Lieferung', 'Entnahme')),
    rechnungstyp_id     integer NOT NULL,
    -- Gegenpartei: Kunde (Modul 1), Lieferant (Modul 2) oder Lehrer (Modul 3).
    -- Die Hauptperson selbst wird nicht zusaetzlich gespeichert -- sie ergibt
    -- sich aus person_mandant.ist_hauptperson des Mandanten (siehe
    -- project_heisenberg_db_schema).
    person_id           integer NOT NULL REFERENCES person(person_id),
    beleg_nr            varchar(50),
    beleg_datum         date NOT NULL DEFAULT CURRENT_DATE,
    status              varchar(20) NOT NULL DEFAULT 'offen'
                          CHECK (status IN ('offen', 'teilweise', 'abgeschlossen', 'storniert')),
    -- Fuer Split/Kette: eine Teillieferung/Teilrechnung referenziert ihren
    -- Vorgaenger-Beleg (Baumstruktur statt linearem Pfad, siehe
    -- project_heisenberg_rechnungslauf).
    vorgaenger_beleg_id integer REFERENCES beleg(beleg_id),
    bemerkung           text,
    created_at          timestamp NOT NULL DEFAULT now(),
    FOREIGN KEY (mandant_id, rechnungstyp_id) REFERENCES rechnungstyp(mandant_id, rechnungstyp_id)
);
CREATE INDEX IF NOT EXISTS ix_beleg_mandant     ON beleg (mandant_id, vorgangsart);
CREATE INDEX IF NOT EXISTS ix_beleg_person      ON beleg (person_id);
CREATE INDEX IF NOT EXISTS ix_beleg_vorgaenger  ON beleg (vorgaenger_beleg_id);

-- ── Beleg-Position: Zeile bezieht sich auf GENAU EINEN Artikel ODER EINE
--    Leistung (Ressource Mensch) -- deckt "Artikel koennen auch Leistungen
--    sein" ab, ohne ein separates viertes Modul zu brauchen.
CREATE TABLE IF NOT EXISTS beleg_position (
    position_id        serial PRIMARY KEY,
    mandant_id         integer NOT NULL REFERENCES mandant(mandant_id),
    beleg_id           integer NOT NULL REFERENCES beleg(beleg_id),
    position_nr        integer NOT NULL,
    artikel_id         integer REFERENCES artikel(artikel_id),
    leistung_id        integer REFERENCES leistung(leistung_id),
    menge              numeric(12,3) NOT NULL,
    einheit_id         integer,
    einzelpreis        numeric(12,2),
    -- Wieviel von dieser Position bereits erledigt ist (geliefert/verrechnet) --
    -- fuer den Split-Fall (Teillieferung/Teilrechnung).
    menge_erledigt     numeric(12,3) NOT NULL DEFAULT 0,
    -- Modul 3 (Lehrer entnimmt): true, wenn der Artikel nach Benutzung wieder
    -- zurueckgestellt wird (Reservierung/Rueckgabe statt endgueltigem Verbrauch).
    rueckgabe_erwartet boolean NOT NULL DEFAULT false,
    rueckgegeben_am    timestamp,
    FOREIGN KEY (mandant_id, einheit_id) REFERENCES einheit(mandant_id, einheit_id),
    CHECK ((artikel_id IS NOT NULL AND leistung_id IS NULL)
        OR (artikel_id IS NULL AND leistung_id IS NOT NULL))
);
CREATE INDEX IF NOT EXISTS ix_beleg_position_beleg ON beleg_position (beleg_id);

-- Buchung von Bestand (Wareneingang/-ausgang/Entnahme/Rueckgabe) in
-- artikel_fach passiert weiterhin im Delphi-Modul (wie bei artikel_zugang),
-- nicht in der DB.
