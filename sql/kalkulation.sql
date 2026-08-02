-- ============================================================================
-- Kalkulation (Zuschlagskalkulation) — Stand 02.08.2026
--
-- Das ist die dritte Stufe: WOFÜR sind die Kosten angefallen. Sie zieht
-- zusammen, was in den Punkten 1 bis 3 aufgebaut wurde, und beantwortet die
-- Frage, die im Kalkulationskonzept ganz oben steht: Was kostet uns das
-- wirklich, und was muss es kosten?
--
-- DAS RECHENSCHEMA — es bildet die Liste des Konzepts der Reihe nach ab:
--
--     Materialeinzelkosten                    ← Stückliste, EK-Preise
--   + Materialgemeinkosten     (% auf MEK)    ← Overhead, Prio 1
--   = Materialkosten
--     Fertigungslöhne                         ← Personalkosten, Prio 1
--   + Fertigungsgemeinkosten   (% auf FL)
--   + Maschinenkosten                         ← Abschreibungen, Prio 1
--   = Fertigungskosten
--   + Sondereinzelkosten                      ← Entwicklung, Lizenzen
--   = HERSTELLKOSTEN
--   + Verwaltungsgemeinkosten  (% auf HK)
--   + Vertriebsgemeinkosten    (% auf HK)
--   = SELBSTKOSTEN
--   + kalkulatorisches Wagnis   (%)           ← Risikofaktoren, Prio 3
--   + kalkulatorischer Zins     (%)           ← Finanzierungskosten, Prio 2
--   = Selbstkosten einschliesslich Wagnis
--   + Gewinn                    (%)           ← Gewinnmarge, Prio 1
--   = Barverkaufspreis
--   + Skonto                   (im Hundert)
--   = Zielverkaufspreis
--   + Rabatt                   (im Hundert)
--   = ANGEBOTSPREIS (netto)
--
-- WARUM DIE SÄTZE IN DER KALKULATION MITGESPEICHERT WERDEN: Wie beim
-- Lohnbeleg friert eine abgeschlossene Kalkulation ihre Grundlagen ein. Ein
-- Angebot, das vor drei Monaten hinausging, muss nachvollziehbar bleiben,
-- auch wenn die Zuschlagssätze inzwischen andere sind.
-- ============================================================================

CREATE TABLE IF NOT EXISTS kalkulation (
    kalkulation_id  serial PRIMARY KEY,
    mandant_id      integer NOT NULL REFERENCES mandant(mandant_id),
    nummer          varchar(50),
    bezeichnung     varchar(200) NOT NULL,

    -- Wofür kalkuliert wird. Alle drei optional — eine Kalkulation kann auch
    -- freistehend sein (Vorkalkulation für eine Idee).
    artikel_id      integer REFERENCES artikel(artikel_id),
    durchfuehrung_id integer REFERENCES kurs_durchfuehrung(durchfuehrung_id),
    beleg_id        integer REFERENCES beleg(beleg_id),

    datum           date NOT NULL DEFAULT CURRENT_DATE,
    -- Bestimmt, welche Zuschlagssätze gezogen werden
    jahr            smallint NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),
    waehrung        char(3) NOT NULL DEFAULT 'CHF',
    -- Losgrösse. Fixkosten je Stück sinken mit der Menge — genau das macht
    -- die Skalierbarkeit sichtbar (Prio 2).
    menge           numeric(12,3) NOT NULL DEFAULT 1 CHECK (menge > 0),

    -- ── Eingefrorene Sätze ────────────────────────────────────────────────
    mgk_prozent     numeric(8,3) NOT NULL DEFAULT 0,
    fgk_prozent     numeric(8,3) NOT NULL DEFAULT 0,
    vwgk_prozent    numeric(8,3) NOT NULL DEFAULT 0,
    vtgk_prozent    numeric(8,3) NOT NULL DEFAULT 0,
    wagnis_prozent  numeric(8,3) NOT NULL DEFAULT 0,
    zins_prozent    numeric(8,3) NOT NULL DEFAULT 0,
    marge_prozent   numeric(8,3) NOT NULL DEFAULT 0,
    skonto_prozent  numeric(8,3) NOT NULL DEFAULT 0
                      CHECK (skonto_prozent >= 0 AND skonto_prozent < 100),
    rabatt_prozent  numeric(8,3) NOT NULL DEFAULT 0
                      CHECK (rabatt_prozent >= 0 AND rabatt_prozent < 100),
    mwst_satz       numeric(5,2) NOT NULL DEFAULT 0,

    -- ── Ergebnis ──────────────────────────────────────────────────────────
    materialeinzelkosten   numeric(14,2) NOT NULL DEFAULT 0,
    materialgemeinkosten   numeric(14,2) NOT NULL DEFAULT 0,
    materialkosten         numeric(14,2) NOT NULL DEFAULT 0,
    fertigungsloehne       numeric(14,2) NOT NULL DEFAULT 0,
    fertigungsgemeinkosten numeric(14,2) NOT NULL DEFAULT 0,
    maschinenkosten        numeric(14,2) NOT NULL DEFAULT 0,
    fertigungskosten       numeric(14,2) NOT NULL DEFAULT 0,
    sondereinzelkosten     numeric(14,2) NOT NULL DEFAULT 0,
    herstellkosten         numeric(14,2) NOT NULL DEFAULT 0,
    verwaltungskosten      numeric(14,2) NOT NULL DEFAULT 0,
    vertriebskosten        numeric(14,2) NOT NULL DEFAULT 0,
    selbstkosten           numeric(14,2) NOT NULL DEFAULT 0,
    wagnis_betrag          numeric(14,2) NOT NULL DEFAULT 0,
    zins_betrag            numeric(14,2) NOT NULL DEFAULT 0,
    selbstkosten_gesamt    numeric(14,2) NOT NULL DEFAULT 0,
    gewinn_betrag          numeric(14,2) NOT NULL DEFAULT 0,
    barverkaufspreis       numeric(14,2) NOT NULL DEFAULT 0,
    zielverkaufspreis      numeric(14,2) NOT NULL DEFAULT 0,
    angebotspreis          numeric(14,2) NOT NULL DEFAULT 0,
    preis_pro_einheit      numeric(14,4) NOT NULL DEFAULT 0,
    -- Was von jedem Franken Umsatz nach den variablen Kosten übrig bleibt
    deckungsbeitrag        numeric(14,2) NOT NULL DEFAULT 0,

    status          varchar(20) NOT NULL DEFAULT 'entwurf'
                      CHECK (status IN ('entwurf', 'freigegeben', 'archiviert')),
    berechnet_am    timestamp,
    bemerkung       text,
    created_at      timestamp NOT NULL DEFAULT now(),
    UNIQUE (mandant_id, nummer)
);

CREATE INDEX IF NOT EXISTS ix_kalkulation_mandant
    ON kalkulation (mandant_id, jahr, datum DESC);

CREATE TABLE IF NOT EXISTS kalkulation_position (
    position_id     serial PRIMARY KEY,
    kalkulation_id  integer NOT NULL
                      REFERENCES kalkulation(kalkulation_id) ON DELETE CASCADE,
    reihenfolge     smallint NOT NULL DEFAULT 0,

    -- Bestimmt, in welchen Block der Rechnung die Position fliesst
    art             varchar(20) NOT NULL
                      CHECK (art IN ('material', 'lohn', 'maschine',
                                     'fremd', 'sonder')),
    bezeichnung     varchar(200) NOT NULL,

    -- Woher der Wert stammt — für die Nachvollziehbarkeit und damit ein
    -- erneutes Befüllen weiss, was es ersetzen darf.
    artikel_id      integer REFERENCES artikel(artikel_id),
    person_id       integer REFERENCES person(person_id),
    anlage_id       integer REFERENCES anlage(anlage_id),
    kostenart_id    integer REFERENCES kostenart(kostenart_id),

    menge           numeric(14,4) NOT NULL DEFAULT 1,
    einheit         varchar(30),
    satz            numeric(14,4) NOT NULL DEFAULT 0,
    betrag          numeric(14,2) NOT NULL DEFAULT 0,
    bemerkung       text
);

CREATE INDEX IF NOT EXISTS ix_kalkulation_position
    ON kalkulation_position (kalkulation_id, reihenfolge);

-- ── Neue Kalkulation mit den Sätzen des Jahres ─────────────────────────────
-- Holt die Zuschlagssätze aus zuschlagssatz und friert sie ein. Fehlt ein
-- Satz, bleibt er auf 0 — dann rechnet die Kalkulation ohne diesen Block,
-- statt zu scheitern. Das ist gewollt: Ein Betrieb ohne ermittelte Sätze soll
-- trotzdem seine Einzelkosten kalkulieren können.
CREATE OR REPLACE FUNCTION fn_kalkulation_neu(
    p_mandant_id integer, p_bezeichnung varchar, p_jahr integer DEFAULT NULL,
    p_menge numeric DEFAULT 1, p_artikel_id integer DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    v_jahr integer := COALESCE(p_jahr, EXTRACT(YEAR FROM CURRENT_DATE)::integer);
    v_id integer;
BEGIN
    INSERT INTO kalkulation (mandant_id, bezeichnung, jahr, menge, artikel_id,
        mgk_prozent, fgk_prozent, vwgk_prozent, vtgk_prozent)
    VALUES (p_mandant_id, p_bezeichnung, v_jahr, p_menge, p_artikel_id,
        COALESCE((SELECT prozent FROM zuschlagssatz WHERE mandant_id = p_mandant_id
                   AND jahr = v_jahr AND bereich = 'material'), 0),
        COALESCE((SELECT prozent FROM zuschlagssatz WHERE mandant_id = p_mandant_id
                   AND jahr = v_jahr AND bereich = 'fertigung'), 0),
        COALESCE((SELECT prozent FROM zuschlagssatz WHERE mandant_id = p_mandant_id
                   AND jahr = v_jahr AND bereich = 'verwaltung'), 0),
        COALESCE((SELECT prozent FROM zuschlagssatz WHERE mandant_id = p_mandant_id
                   AND jahr = v_jahr AND bereich = 'vertrieb'), 0))
    RETURNING kalkulation_id INTO v_id;
    RETURN v_id;
END;
$$;

-- ── Material aus der Stückliste übernehmen ─────────────────────────────────
-- Zieht artikel_artikel (Stückliste) und bewertet mit dem EK-Preis aus
-- artikel_preis. Gibt es keinen EK-Preis, wird der VK genommen und das in der
-- Bemerkung vermerkt — lieber ein gekennzeichneter Näherungswert als eine
-- Position, die stillschweigend mit null in die Kalkulation geht.
CREATE OR REPLACE FUNCTION fn_kalkulation_material(
    p_kalkulation_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
    k kalkulation%ROWTYPE;
    v_anzahl integer := 0;
    v_rf smallint;
BEGIN
    SELECT * INTO k FROM kalkulation WHERE kalkulation_id = p_kalkulation_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Kalkulation % gibt es nicht.', p_kalkulation_id;
    END IF;
    IF k.artikel_id IS NULL THEN
        RAISE EXCEPTION 'Diese Kalkulation haengt an keinem Artikel - '
            'Material bitte von Hand erfassen.';
    END IF;

    DELETE FROM kalkulation_position
     WHERE kalkulation_id = p_kalkulation_id AND art = 'material'
       AND artikel_id IS NOT NULL;

    SELECT COALESCE(MAX(reihenfolge), 0) INTO v_rf
      FROM kalkulation_position WHERE kalkulation_id = p_kalkulation_id;

    INSERT INTO kalkulation_position (kalkulation_id, reihenfolge, art,
        bezeichnung, artikel_id, kostenart_id, menge, einheit, satz, betrag,
        bemerkung)
    SELECT p_kalkulation_id,
           v_rf + ROW_NUMBER() OVER (ORDER BY aa.position, ua.artikelname),
           'material',
           ua.artikelname,
           ua.artikel_id,
           (SELECT kostenart_id FROM kostenart
             WHERE mandant_id = k.mandant_id AND nummer = 'K100'),
           aa.menge * k.menge,
           e.name,
           COALESCE(p.preis, 0),
           ROUND(aa.menge * k.menge * COALESCE(p.preis, 0), 2),
           CASE WHEN p.preis IS NULL THEN 'ACHTUNG: kein Preis hinterlegt'
                WHEN p.preis_art = 'VK' THEN 'Naeherung: VK-Preis, kein EK hinterlegt'
                ELSE NULL END
      FROM artikel_artikel aa
      JOIN artikel ua ON ua.artikel_id = aa.unter_artikel_id
      LEFT JOIN einheit e ON e.mandant_id = aa.mandant_id
                         AND e.einheit_id = aa.einheit_id
      LEFT JOIN LATERAL (
            SELECT ap.preis, ap.preis_art
              FROM artikel_preis ap
             WHERE ap.artikel_id = ua.artikel_id
               AND ap.gueltig_von <= k.datum
               AND (ap.gueltig_bis IS NULL OR ap.gueltig_bis >= k.datum)
             -- EK zuerst; nur wenn keiner da ist, der VK
             ORDER BY CASE WHEN ap.preis_art = 'EK' THEN 0 ELSE 1 END
             LIMIT 1) p ON true
     WHERE aa.artikel_id = k.artikel_id;

    GET DIAGNOSTICS v_anzahl = ROW_COUNT;
    RETURN v_anzahl;
END;
$$;

-- ── Maschinenstunden übernehmen ────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_kalkulation_maschine(
    p_kalkulation_id integer, p_anlage_id integer, p_stunden numeric)
RETURNS numeric
LANGUAGE plpgsql AS $$
DECLARE
    k kalkulation%ROWTYPE;
    v_satz numeric;
    v_bez varchar(200);
    v_rf smallint;
BEGIN
    SELECT * INTO k FROM kalkulation WHERE kalkulation_id = p_kalkulation_id;
    SELECT bezeichnung INTO v_bez FROM anlage WHERE anlage_id = p_anlage_id;

    v_satz := fn_maschinenstundensatz(p_anlage_id, k.jahr);
    IF v_satz IS NULL THEN
        RAISE EXCEPTION 'Fuer die Anlage % gibt es im Jahr % keinen '
            'Stundensatz - fehlen die Betriebsstunden oder der '
            'Abschreibungsplan?', v_bez, k.jahr;
    END IF;

    SELECT COALESCE(MAX(reihenfolge), 0) + 1 INTO v_rf
      FROM kalkulation_position WHERE kalkulation_id = p_kalkulation_id;

    INSERT INTO kalkulation_position (kalkulation_id, reihenfolge, art,
        bezeichnung, anlage_id, kostenart_id, menge, einheit, satz, betrag)
    VALUES (p_kalkulation_id, v_rf, 'maschine', v_bez, p_anlage_id,
        (SELECT kostenart_id FROM kostenart
          WHERE mandant_id = k.mandant_id AND nummer = 'K800'),
        p_stunden, 'Stunde', v_satz, ROUND(p_stunden * v_satz, 2));

    RETURN ROUND(p_stunden * v_satz, 2);
END;
$$;

-- ── Fertigungslohn übernehmen ──────────────────────────────────────────────
-- Nimmt den Stundensatz aus der gültigen Lohnvereinbarung. Bei Festgehalt
-- wird er aus den Monatsstunden abgeleitet — dieselbe Rechnung wie im
-- Lohnlauf, damit Kalkulation und Abrechnung nicht auseinanderlaufen.
--
-- Der Zuschlag für Sozialleistungen (nebenkosten_prozent) wird
-- MITGERECHNET: Das Konzept verlangt Personalkosten "einschliesslich
-- Sozialleistungen".
CREATE OR REPLACE FUNCTION fn_kalkulation_lohn(
    p_kalkulation_id integer, p_person_id integer, p_stunden numeric)
RETURNS numeric
LANGUAGE plpgsql AS $$
DECLARE
    k kalkulation%ROWTYPE;
    l person_lohn%ROWTYPE;
    v_satz numeric; v_monatsstunden numeric; v_name varchar(200); v_rf smallint;
BEGIN
    SELECT * INTO k FROM kalkulation WHERE kalkulation_id = p_kalkulation_id;

    SELECT * INTO l FROM person_lohn
     WHERE mandant_id = k.mandant_id AND person_id = p_person_id
       AND gueltig_ab <= k.datum
       AND (gueltig_bis IS NULL OR gueltig_bis >= k.datum)
     ORDER BY CASE lohnart WHEN 'stundenlohn' THEN 0 WHEN 'festgehalt' THEN 1
                           ELSE 2 END
     LIMIT 1;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Fuer diese Person gibt es zum % keine gueltige '
            'Lohnvereinbarung.', k.datum;
    END IF;

    IF l.lohnart = 'festgehalt' THEN
        v_monatsstunden := l.monatsstunden;
        IF COALESCE(v_monatsstunden, 0) <= 0 THEN
            SELECT 173.0 * COALESCE(MAX(pensum_prozent), 100) / 100.0
              INTO v_monatsstunden
              FROM person_arbeitszeit
             WHERE mandant_id = k.mandant_id AND person_id = p_person_id;
        END IF;
        v_satz := CASE WHEN COALESCE(v_monatsstunden, 0) > 0
                       THEN l.betrag / v_monatsstunden ELSE 0 END;
    ELSIF l.lohnart = 'honorar' AND l.bezug = 'lektion' THEN
        -- Honorar je Lektion auf eine volle Stunde umrechnen
        v_satz := l.betrag * 60.0 / GREATEST(l.lektion_minuten, 1);
    ELSE
        v_satz := l.betrag;
    END IF;

    -- Arbeitgeberanteil aufschlagen
    v_satz := ROUND(v_satz * (1 + COALESCE(l.nebenkosten_prozent, 0) / 100.0), 4);

    SELECT nachname_firmenname || ', ' || COALESCE(vorname, '') INTO v_name
      FROM person WHERE person_id = p_person_id;
    SELECT COALESCE(MAX(reihenfolge), 0) + 1 INTO v_rf
      FROM kalkulation_position WHERE kalkulation_id = p_kalkulation_id;

    INSERT INTO kalkulation_position (kalkulation_id, reihenfolge, art,
        bezeichnung, person_id, kostenart_id, menge, einheit, satz, betrag,
        bemerkung)
    VALUES (p_kalkulation_id, v_rf, 'lohn', v_name, p_person_id,
        (SELECT kostenart_id FROM kostenart
          WHERE mandant_id = k.mandant_id AND nummer = 'K200'),
        p_stunden, 'Stunde', v_satz, ROUND(p_stunden * v_satz, 2),
        'inkl. ' || COALESCE(l.nebenkosten_prozent, 0) || ' % Sozialleistungen');

    RETURN ROUND(p_stunden * v_satz, 2);
END;
$$;

-- ── Die Rechnung ───────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fn_kalkulation_rechnen(p_kalkulation_id integer)
RETURNS numeric
LANGUAGE plpgsql AS $$
DECLARE
    k kalkulation%ROWTYPE;
    v_mek numeric(14,2); v_mgk numeric(14,2); v_mat numeric(14,2);
    v_fl numeric(14,2);  v_fgk numeric(14,2); v_masch numeric(14,2);
    v_fert numeric(14,2); v_sonder numeric(14,2); v_hk numeric(14,2);
    v_vwgk numeric(14,2); v_vtgk numeric(14,2); v_sk numeric(14,2);
    v_wagnis numeric(14,2); v_zins numeric(14,2); v_skg numeric(14,2);
    v_gewinn numeric(14,2); v_bar numeric(14,2); v_ziel numeric(14,2);
    v_angebot numeric(14,2); v_variabel numeric(14,2);
BEGIN
    SELECT * INTO k FROM kalkulation WHERE kalkulation_id = p_kalkulation_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Kalkulation % gibt es nicht.', p_kalkulation_id;
    END IF;
    IF k.status <> 'entwurf' THEN
        RAISE EXCEPTION 'Diese Kalkulation ist % und wird nicht neu '
            'gerechnet.', k.status;
    END IF;

    SELECT COALESCE(SUM(betrag) FILTER (WHERE art = 'material'), 0),
           COALESCE(SUM(betrag) FILTER (WHERE art = 'lohn'), 0),
           COALESCE(SUM(betrag) FILTER (WHERE art = 'maschine'), 0),
           COALESCE(SUM(betrag) FILTER (WHERE art IN ('fremd', 'sonder')), 0)
      INTO v_mek, v_fl, v_masch, v_sonder
      FROM kalkulation_position WHERE kalkulation_id = p_kalkulation_id;

    v_mgk  := ROUND(v_mek * k.mgk_prozent / 100.0, 2);
    v_mat  := v_mek + v_mgk;
    v_fgk  := ROUND(v_fl * k.fgk_prozent / 100.0, 2);
    v_fert := v_fl + v_fgk + v_masch;
    v_hk   := v_mat + v_fert + v_sonder;
    v_vwgk := ROUND(v_hk * k.vwgk_prozent / 100.0, 2);
    v_vtgk := ROUND(v_hk * k.vtgk_prozent / 100.0, 2);
    v_sk   := v_hk + v_vwgk + v_vtgk;

    v_wagnis := ROUND(v_sk * k.wagnis_prozent / 100.0, 2);
    v_zins   := ROUND(v_sk * k.zins_prozent / 100.0, 2);
    v_skg    := v_sk + v_wagnis + v_zins;

    v_gewinn := ROUND(v_skg * k.marge_prozent / 100.0, 2);
    v_bar    := v_skg + v_gewinn;

    -- Skonto und Rabatt werden IM Hundert gerechnet, nicht AUF Hundert.
    -- Wer 2 % Skonto gewähren will, darf nicht 2 % aufschlagen (× 1.02),
    -- sondern muss durch 0.98 teilen — sonst bleibt nach Abzug weniger übrig
    -- als kalkuliert. Der Unterschied wächst mit dem Satz.
    v_ziel    := ROUND(v_bar / (1 - k.skonto_prozent / 100.0), 2);
    v_angebot := ROUND(v_ziel / (1 - k.rabatt_prozent / 100.0), 2);

    -- Deckungsbeitrag: Erlös minus die Kosten, die mit der Menge mitgehen.
    -- Sagt, was ein Zusatzauftrag zur Deckung der Fixkosten beiträgt.
    SELECT COALESCE(SUM(
             p.betrag * CASE ka.verhalten
                          WHEN 'variabel' THEN 1
                          WHEN 'gemischt' THEN ka.variabler_anteil_prozent / 100.0
                          ELSE 0 END), 0)
      INTO v_variabel
      FROM kalkulation_position p
      LEFT JOIN kostenart ka ON ka.kostenart_id = p.kostenart_id
     WHERE p.kalkulation_id = p_kalkulation_id;

    UPDATE kalkulation SET
        materialeinzelkosten = v_mek, materialgemeinkosten = v_mgk,
        materialkosten = v_mat,
        fertigungsloehne = v_fl, fertigungsgemeinkosten = v_fgk,
        maschinenkosten = v_masch, fertigungskosten = v_fert,
        sondereinzelkosten = v_sonder, herstellkosten = v_hk,
        verwaltungskosten = v_vwgk, vertriebskosten = v_vtgk,
        selbstkosten = v_sk,
        wagnis_betrag = v_wagnis, zins_betrag = v_zins,
        selbstkosten_gesamt = v_skg,
        gewinn_betrag = v_gewinn, barverkaufspreis = v_bar,
        zielverkaufspreis = v_ziel, angebotspreis = v_angebot,
        preis_pro_einheit = ROUND(v_angebot / k.menge, 4),
        deckungsbeitrag = v_angebot - v_variabel,
        berechnet_am = now()
     WHERE kalkulation_id = p_kalkulation_id;

    RETURN v_angebot;
END;
$$;

-- ── Die Kalkulation als lesbare Aufstellung ────────────────────────────────
-- Gibt das Schema Zeile für Zeile aus — so, wie es auf einem Angebotsblatt
-- stehen würde.
CREATE OR REPLACE FUNCTION fn_kalkulation_blatt(p_kalkulation_id integer)
RETURNS TABLE (zeile smallint, bezeichnung text, prozent numeric, betrag numeric)
LANGUAGE sql STABLE AS $$
    -- CROSS JOIN LATERAL, nicht ein blosses FROM: Ein VALUES-Block darf nur
    -- auf Tabellen verweisen, die VOR ihm stehen. LATERAL macht k sichtbar.
    SELECT t.* FROM kalkulation k
    CROSS JOIN LATERAL (VALUES
      (1::smallint,  'Materialeinzelkosten'::text,  NULL::numeric, k.materialeinzelkosten),
      (2,  '+ Materialgemeinkosten',       k.mgk_prozent,  k.materialgemeinkosten),
      (3,  '= Materialkosten',             NULL,           k.materialkosten),
      (4,  'Fertigungsloehne',             NULL,           k.fertigungsloehne),
      (5,  '+ Fertigungsgemeinkosten',     k.fgk_prozent,  k.fertigungsgemeinkosten),
      (6,  '+ Maschinenkosten',            NULL,           k.maschinenkosten),
      (7,  '= Fertigungskosten',           NULL,           k.fertigungskosten),
      (8,  '+ Sondereinzelkosten',         NULL,           k.sondereinzelkosten),
      (9,  '= HERSTELLKOSTEN',             NULL,           k.herstellkosten),
      (10, '+ Verwaltungsgemeinkosten',    k.vwgk_prozent, k.verwaltungskosten),
      (11, '+ Vertriebsgemeinkosten',      k.vtgk_prozent, k.vertriebskosten),
      (12, '= SELBSTKOSTEN',               NULL,           k.selbstkosten),
      (13, '+ Kalk. Wagnis',               k.wagnis_prozent, k.wagnis_betrag),
      (14, '+ Kalk. Zins',                 k.zins_prozent, k.zins_betrag),
      (15, '= Selbstkosten inkl. Wagnis',  NULL,           k.selbstkosten_gesamt),
      (16, '+ Gewinn',                     k.marge_prozent, k.gewinn_betrag),
      (17, '= Barverkaufspreis',           NULL,           k.barverkaufspreis),
      (18, '+ Skonto',                     k.skonto_prozent, k.zielverkaufspreis - k.barverkaufspreis),
      (19, '+ Rabatt',                     k.rabatt_prozent, k.angebotspreis - k.zielverkaufspreis),
      (20, '= ANGEBOTSPREIS (netto)',      NULL,           k.angebotspreis),
      (21, 'Preis je Einheit',             NULL,           k.preis_pro_einheit),
      (22, 'Deckungsbeitrag',              NULL,           k.deckungsbeitrag)
    ) AS t(zeile, bezeichnung, prozent, betrag)
    WHERE k.kalkulation_id = p_kalkulation_id
    ORDER BY t.zeile;
$$;
