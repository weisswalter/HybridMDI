-- ============================================================================
-- Navigationsleiste aus der Datenbank — Stand 03.08.2026
--
-- ZWECK: Die Menüeinträge links sind heute fest in NavMenu.razor verdrahtet.
-- Damit die Website wiederverkaufsfähig wird, muss jeder Mandant selbst
-- entscheiden, welche Einträge er zeigt — und eigene hinzufügen können, ohne
-- dass jemand die Anwendung neu übersetzt.
--
-- Nur die Navigation. Was auf den Seiten selbst passiert, bleibt vorerst
-- unverändert.
-- ============================================================================

CREATE TABLE IF NOT EXISTS navigation (
    nav_id       serial PRIMARY KEY,
    mandant_id   integer NOT NULL REFERENCES mandant(mandant_id),
    bezeichnung  varchar(100) NOT NULL,
    -- Wohin der Eintrag führt. Relativ ("/team") oder absolut
    -- ("https://..."), damit auch auf Fremdseiten verlinkt werden kann.
    route        varchar(200) NOT NULL,
    aktiv        boolean NOT NULL DEFAULT true,
    reihenfolge  integer NOT NULL DEFAULT 100,
    -- Optionales Symbol (die Vorlage nutzt Bootstrap-Icons)
    icon_css     varchar(100),
    -- Externe Ziele sollen in einem neuen Fenster aufgehen
    neues_fenster boolean NOT NULL DEFAULT false,
    bemerkung    text,
    UNIQUE (mandant_id, bezeichnung)
);

CREATE INDEX IF NOT EXISTS ix_navigation_mandant
    ON navigation (mandant_id, aktiv, reihenfolge);

COMMENT ON TABLE navigation IS
    'Menueeintraege der Website je Mandant. aktiv=false blendet aus, ohne '
    'den Eintrag zu verlieren.';

-- Erstbelegung mit dem, was heute fest im Menue steht. Idempotent.
CREATE OR REPLACE FUNCTION fn_navigation_standard(p_mandant_id integer)
RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE v_z record; v_anzahl integer := 0;
BEGIN
    FOR v_z IN
        SELECT * FROM (VALUES
        ('Home',      '/',           10, 'bi bi-house-door-fill-nav-menu'),
        ('Wetter',    '/weather',    20, 'bi bi-list-nested-nav-menu'),
        ('Team',      '/team',       30, NULL),
        ('Kontakt',   '/contact',    40, NULL),
        ('Impressum', '/impressum',  50, NULL)
        ) AS t(bez, route, rf, icon)
    LOOP
        INSERT INTO navigation (mandant_id, bezeichnung, route, reihenfolge,
                                icon_css)
        SELECT p_mandant_id, v_z.bez, v_z.route, v_z.rf, v_z.icon
        WHERE NOT EXISTS (SELECT 1 FROM navigation n
                           WHERE n.mandant_id = p_mandant_id
                             AND n.bezeichnung = v_z.bez);
        IF FOUND THEN v_anzahl := v_anzahl + 1; END IF;
    END LOOP;
    RETURN v_anzahl;
END;
$$;

SELECT fn_navigation_standard(1) AS neu_angelegt;

SELECT bezeichnung, route, aktiv, reihenfolge FROM navigation
 WHERE mandant_id = 1 ORDER BY reihenfolge;
