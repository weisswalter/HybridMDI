-- ============================================================================
-- Shop: Hinweisband und Bestellsperre
--
-- Der Shop zeigt zurzeit erfundene Artikel mit KI-erzeugten Bildern. Solange
-- das so ist, muss auf jeder Shop-Seite stehen, dass er im Aufbau ist, und es
-- darf nichts bestellt werden koennen.
--
-- Beides gehoert NICHT in den Quelltext der Website: sonst braucht jede
-- Aenderung ein Deployment. Es sind zwei weitere Eintraege in
-- mandant_einstellung, pflegbar ueber den Reiter "Website" im
-- Einstellungsfenster - wie SHOP_AKTIV, SHOP_MWST und die uebrigen.
--
--   SHOP_HINWEIS      Text des Bandes. LEER = kein Band.
--   SHOP_BESTELLBAR   'false' = die Warenkorb- und Bestellknoepfe sind aus.
--                     Fehlt der Eintrag, gilt 'true' - ein bestehender Shop
--                     wird durch dieses Skript nicht stillgelegt.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Sicht erweitern
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_shop_einstellung AS
SELECT
    m.mandant_id,
    COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_AKTIV'), ''),
             'false') = 'true'                                    AS shop_aktiv,
    COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_WAEHRUNG'), ''),
             'EUR')                                               AS waehrung,
    COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_MWST'), ''),
             '0')::numeric(5,2)                                   AS mwst,
    COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_VERSAND'), ''),
             '0')::numeric(12,2)                                  AS versand,
    COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_VERSANDFREI'), ''),
             '0')::numeric(12,2)                                  AS versandfrei_ab,
    -- Neu: Hinweisband und Bestellsperre.
    COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_HINWEIS'), ''),
             '')                                                  AS hinweis,
    COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id, 'SHOP_BESTELLBAR'), ''),
             'true') = 'true'                                     AS bestellbar
  FROM mandant m;

-- ---------------------------------------------------------------------------
-- 2. Fuer TRT (Mandant 1) gleich setzen: Aufbau, nicht bestellbar
-- ---------------------------------------------------------------------------
SELECT fn_mandant_einstellung_setzen(1, 'SHOP_HINWEIS',
  'Dieser Shop befindet sich im Aufbau. Die gezeigten Artikel und Bilder ' ||
  'sind Beispiele - eine Bestellung ist derzeit nicht moeglich.',
  'Shop: Hinweisband (leer = keines)');

SELECT fn_mandant_einstellung_setzen(1, 'SHOP_BESTELLBAR', 'false',
  'Shop: Bestellen erlaubt');
