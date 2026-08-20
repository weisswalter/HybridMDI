-- ============================================================================
-- Indexe auf Fremdschluesselspalten — Stand 02.08.2026
--
-- ANLASS: Walters Hinweis, dass Joins am Index vorbei SQL sehr langsam
-- machen. Die Nachpruefung ergab 183 Fremdschluesselspalten ohne fuehrenden
-- Index. Postgres legt auf Fremdschluessel naemlich KEINEN Index an — nur
-- auf Primaer- und Unique-Schluessel. Das muss man von Hand machen.
--
-- ZWEITER GRUND, DER OFT VERGESSEN WIRD: Beim Loeschen einer Elternzeile
-- prueft Postgres jede Kindtabelle auf verweisende Zeilen. Ohne Index ist
-- das ein voller Durchlauf — je Loeschung, je Kindtabelle.
--
-- BEWUSST NICHT ALLE 183: Auf einer Typ-Tabelle mit fuenf Zeilen liest der
-- Planer ohnehin durch, und das ist richtig so — ein Index waere dort nur
-- Ballast beim Schreiben. Aufgenommen sind die Tabellen, die im Betrieb
-- mitwachsen: Personen und ihre Bruecken, Belege, Kurse, Anwesenheit,
-- Buchhaltung, Lager.
--
-- Bei der aktuellen Datenmenge (rund 1000 Zeilen ueber alle Tabellen) aendert
-- das MESSBAR NICHTS. Es ist Vorsorge fuer den Zeitpunkt, an dem echte Daten
-- drin sind — dann ist es zu spaet, es zu bemerken.
-- ============================================================================

DO $$
DECLARE
    v_r    record;
    v_name text;
    v_zahl integer := 0;
BEGIN
    FOR v_r IN
        SELECT DISTINCT
               c.conrelid::regclass::text AS tabelle,
               a.attname                  AS spalte
          FROM pg_constraint c
          JOIN LATERAL unnest(c.conkey) k(attnum) ON true
          JOIN pg_attribute a ON a.attrelid = c.conrelid
                             AND a.attnum   = k.attnum
         WHERE c.contype = 'f'
           AND c.connamespace = 'public'::regnamespace
           -- noch kein Index, der mit dieser Spalte beginnt
           AND NOT EXISTS (SELECT 1 FROM pg_index i
                            WHERE i.indrelid = c.conrelid
                              AND i.indkey[0] = k.attnum)
           -- nur die mitwachsenden Tabellen
           AND (   c.conrelid::regclass::text LIKE 'person%'
                OR c.conrelid::regclass::text LIKE 'beleg%'
                OR c.conrelid::regclass::text LIKE 'kurs%'
                OR c.conrelid::regclass::text LIKE 'anwesenheit%'
                OR c.conrelid::regclass::text LIKE 'artikel%'
                OR c.conrelid::regclass::text LIKE 'buchung%'
                OR c.conrelid::regclass::text LIKE 'lohn%'
                OR c.conrelid::regclass::text LIKE 'kalkulation%'
                OR c.conrelid::regclass::text LIKE 'dokument%'
                OR c.conrelid::regclass::text LIKE 'email%'
                OR c.conrelid::regclass::text LIKE 'vorgang%'
                OR c.conrelid::regclass::text IN
                   ('abwesenheit', 'anlage', 'budget', 'einwilligung',
                    'klient', 'leistung', 'kostengutsprache', 'regal_fach',
                    'lager', 'termin_ausstattung', 'raum_ausstattung'))
         ORDER BY 1, 2
    LOOP
        v_name := 'ix_' || v_r.tabelle || '_' || v_r.spalte;
        -- Indexnamen sind auf 63 Zeichen begrenzt
        v_name := left(v_name, 63);
        EXECUTE format('CREATE INDEX IF NOT EXISTS %I ON %I (%I)',
                       v_name, v_r.tabelle, v_r.spalte);
        v_zahl := v_zahl + 1;
    END LOOP;
    RAISE NOTICE 'Indexe angelegt oder bereits vorhanden: %', v_zahl;
END;
$$;

-- Was bleibt bewusst offen?
SELECT count(*) AS fk_ohne_index_verbleibend
  FROM (SELECT c.conrelid, k.attnum
          FROM pg_constraint c
          JOIN LATERAL unnest(c.conkey) k(attnum) ON true
         WHERE c.contype = 'f'
           AND c.connamespace = 'public'::regnamespace
           AND NOT EXISTS (SELECT 1 FROM pg_index i
                            WHERE i.indrelid = c.conrelid
                              AND i.indkey[0] = k.attnum)) t;
