-- ============================================================================
-- Belegpflicht: Dokumente zu Kosten — Stand 02.08.2026
--
-- Walters Vorgabe: "alle Kosten koennen auch ein Dokument verlangen".
--
-- WARUM ZUERST: Ohne Beleg ist eine Kostenposition weder pruefbar noch
-- steuerlich haltbar, und fuer die Buchhaltung gilt ohnehin "keine Buchung
-- ohne Beleg". Wer das nachruestet, muss Altsaetze nachbelegen — jeder Tag
-- macht es teurer.
--
-- DEM BESTEHENDEN MUSTER FOLGEN: `dokument` wird im Projekt ueber EXPLIZITE
-- Bruecken angebunden (person_dokument, mandant_dokument, vorgang_dokument).
-- Eine generische Zuordnungstabelle (entitaet, entitaet_id) waere kuerzer,
-- verloere aber die Fremdschluessel — und damit genau die Sicherheit, die im
-- restlichen Schema konsequent durchgehalten ist.
--
-- PFLICHT IST KEIN CONSTRAINT: Ein NOT NULL auf das Dokument wuerde die
-- Erfassung blockieren — man hat den Beleg selten in dem Moment zur Hand, in
-- dem man die Kosten erfasst. Stattdessen eine ARBEITSLISTE der offenen
-- Belege, die man abarbeitet.
-- ============================================================================

-- ── 1. Steuerung an der Kostenart ──────────────────────────────────────────
-- Jeder Mandant entscheidet selbst, wo er streng ist. Bei kalkulatorischen
-- Kostenarten ist ein Beleg per Definition unmoeglich — sie haben kein
-- Gegenstueck in der Wirklichkeit.
ALTER TABLE kostenart ADD COLUMN IF NOT EXISTS beleg_pflicht boolean
    NOT NULL DEFAULT false;

ALTER TABLE kostenart DROP CONSTRAINT IF EXISTS kostenart_kalk_ohne_beleg;
ALTER TABLE kostenart ADD CONSTRAINT kostenart_kalk_ohne_beleg
    CHECK (NOT (kalkulatorisch AND beleg_pflicht));

COMMENT ON COLUMN kostenart.beleg_pflicht IS
    'Verlangt diese Kostenart einen Beleg? Geprueft ueber v_beleg_fehlt, '
    'nicht als Constraint - sonst blockiert es die Erfassung.';

-- Sinnvolle Vorbelegung: alles, was echtes Geld kostet, braucht einen Beleg.
-- Kalkulatorisches nie.
UPDATE kostenart SET beleg_pflicht = true
 WHERE NOT kalkulatorisch AND NOT beleg_pflicht
   AND nummer IN ('K100','K110','K120','K300','K310','K320','K330','K340',
                  'K350','K360','K370','K380');

-- ── 2. Bruecken ────────────────────────────────────────────────────────────
-- `art` unterscheidet, WOFUER das Dokument steht: eine Anlage hat einen
-- Kaufbeleg, spaeter Wartungsprotokolle und am Ende einen Verkaufsbeleg.
CREATE TABLE IF NOT EXISTS anlage_dokument (
    anlage_id   integer NOT NULL REFERENCES anlage(anlage_id) ON DELETE CASCADE,
    dokument_id integer NOT NULL REFERENCES dokument(dokument_id),
    art         varchar(30) NOT NULL DEFAULT 'kaufbeleg'
                  CHECK (art IN ('kaufbeleg', 'wartung', 'garantie',
                                 'verkauf', 'sonstiges')),
    bemerkung   text,
    PRIMARY KEY (anlage_id, dokument_id)
);

CREATE TABLE IF NOT EXISTS kostenwert_dokument (
    wert_id     integer NOT NULL
                  REFERENCES kostenstelle_wert(wert_id) ON DELETE CASCADE,
    dokument_id integer NOT NULL REFERENCES dokument(dokument_id),
    PRIMARY KEY (wert_id, dokument_id)
);

CREATE TABLE IF NOT EXISTS lohn_dokument (
    periode_id  integer NOT NULL
                  REFERENCES lohn_periode(periode_id) ON DELETE CASCADE,
    dokument_id integer NOT NULL REFERENCES dokument(dokument_id),
    art         varchar(30) NOT NULL DEFAULT 'abrechnung'
                  CHECK (art IN ('abrechnung', 'ausweis', 'bescheinigung',
                                 'sonstiges')),
    PRIMARY KEY (periode_id, dokument_id)
);

CREATE TABLE IF NOT EXISTS kalkulation_dokument (
    kalkulation_id integer NOT NULL
                     REFERENCES kalkulation(kalkulation_id) ON DELETE CASCADE,
    dokument_id    integer NOT NULL REFERENCES dokument(dokument_id),
    art            varchar(30) NOT NULL DEFAULT 'angebot'
                     CHECK (art IN ('angebot', 'anfrage', 'nachweis',
                                    'sonstiges')),
    PRIMARY KEY (kalkulation_id, dokument_id)
);

CREATE INDEX IF NOT EXISTS ix_anlage_dokument_dok
    ON anlage_dokument (dokument_id);
CREATE INDEX IF NOT EXISTS ix_kostenwert_dokument_dok
    ON kostenwert_dokument (dokument_id);

-- ── 3. Dokumentarten ergaenzen ─────────────────────────────────────────────
-- Global (mandant_id NULL), wie 'E-Mail-Anhang' aus dem Mailmodul.
INSERT INTO dokument_typ (mandant_id, bezeichnung, kategorie)
SELECT NULL, v.bez, v.kat
  FROM (VALUES
        ('Kaufbeleg',             'beleg'),
        ('Lieferantenrechnung',   'beleg'),
        ('Spesenbeleg',           'beleg'),
        ('Quittung',              'beleg'),
        ('Wartungsprotokoll',     'technik'),
        ('Garantieschein',        'technik'),
        ('Kostengutsprache',      'behoerde'),
        ('Bescheid',              'behoerde'),
        ('Leistungsvereinbarung', 'behoerde'),
        ('Lohnabrechnung',        'personal'),
        ('Lohnausweis',           'personal')
       ) AS v(bez, kat)
 WHERE NOT EXISTS (SELECT 1 FROM dokument_typ d
                    WHERE d.bezeichnung = v.bez AND d.mandant_id IS NULL);

-- ── 4. Die Arbeitsliste: was ohne Beleg dasteht ────────────────────────────
-- Bewusst eine Sicht ueber ALLE Bereiche mit einer Spalte `bereich`, statt
-- drei getrennter Listen: Wer Belege nachtraegt, will EINE Liste abarbeiten
-- und nicht drei Fenster oeffnen.
CREATE OR REPLACE VIEW v_beleg_fehlt AS
-- Kostenpositionen, deren Kostenart einen Beleg verlangt
SELECT 'Kostenposition'::text AS bereich,
       w.mandant_id,
       w.wert_id AS satz_id,
       w.jahr,
       ks.nummer || ' ' || ks.bezeichnung AS wo,
       ka.nummer || ' ' || ka.bezeichnung AS was,
       w.betrag,
       w.quelle
  FROM kostenstelle_wert w
  JOIN kostenart ka ON ka.kostenart_id = w.kostenart_id
  JOIN kostenstelle ks ON ks.kostenstelle_id = w.kostenstelle_id
 WHERE ka.beleg_pflicht
   -- Aus Umlage und Anlagenplan entstandene Werte sind ABGELEITET, sie
   -- koennen keinen eigenen Beleg haben. Der Beleg liegt beim Ursprung.
   AND w.quelle NOT IN ('umlage', 'anlage')
   AND NOT EXISTS (SELECT 1 FROM kostenwert_dokument kd
                    WHERE kd.wert_id = w.wert_id)
UNION ALL
-- Anlagen ohne Kaufbeleg
SELECT 'Anlage', a.mandant_id, a.anlage_id,
       EXTRACT(YEAR FROM a.anschaffung_datum)::smallint,
       COALESCE(a.inventar_nr, '(ohne Nummer)'),
       a.bezeichnung, a.anschaffung_wert, 'stammdaten'
  FROM anlage a
 WHERE a.anschaffung_wert > 0
   AND NOT EXISTS (SELECT 1 FROM anlage_dokument ad
                    WHERE ad.anlage_id = a.anlage_id AND ad.art = 'kaufbeleg');

COMMENT ON VIEW v_beleg_fehlt IS
    'Arbeitsliste: Kosten, die laut Kostenart einen Beleg verlangen, aber '
    'keinen haben. Abgeleitete Werte (Umlage, Anlagenplan) bleiben aussen '
    'vor - deren Beleg liegt beim Ursprung.';

-- Wie vollstaendig ist die Belegablage? Eine Zahl, die man verfolgen kann.
CREATE OR REPLACE FUNCTION fn_belegquote(p_mandant_id integer, p_jahr integer)
RETURNS numeric
LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN COUNT(*) = 0 THEN 100.0
                ELSE ROUND(100.0 * COUNT(*) FILTER (
                       WHERE EXISTS (SELECT 1 FROM kostenwert_dokument kd
                                      WHERE kd.wert_id = w.wert_id))
                     / COUNT(*), 1) END
      FROM kostenstelle_wert w
      JOIN kostenart ka ON ka.kostenart_id = w.kostenart_id
     WHERE w.mandant_id = p_mandant_id AND w.jahr = p_jahr
       AND ka.beleg_pflicht AND w.quelle NOT IN ('umlage', 'anlage');
$$;
