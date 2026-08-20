-- 1. Die leeren Werte bei Mandant 1 wieder auf sinnvolle setzen.
SELECT fn_mandant_einstellung_setzen(1, 'SHOP_WAEHRUNG',   'EUR');
SELECT fn_mandant_einstellung_setzen(1, 'SHOP_MWST',       '19.0');
SELECT fn_mandant_einstellung_setzen(1, 'SHOP_VERSAND',    '0');
SELECT fn_mandant_einstellung_setzen(1, 'SHOP_VERSANDFREI','100');

-- 2. Die Sicht darf an einem leeren Wert nicht mehr zerbrechen. COALESCE
--    hilft nur gegen NULL, nicht gegen '' - deshalb NULLIF davor. Eine
--    Sicht, die beim Start geladen wird, darf keine Tretmine sein.
CREATE OR REPLACE VIEW v_shop_einstellung AS
SELECT m.mandant_id,
       COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id,'SHOP_AKTIV'),''),
                'false') = 'true' AS shop_aktiv,
       COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id,'SHOP_WAEHRUNG'),''),
                'EUR') AS waehrung,
       COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id,'SHOP_MWST'),''),
                '0')::numeric(5,2) AS mwst,
       COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id,'SHOP_VERSAND'),''),
                '0')::numeric(12,2) AS versand,
       COALESCE(NULLIF(fn_mandant_einstellung_lesen(m.mandant_id,'SHOP_VERSANDFREI'),''),
                '0')::numeric(12,2) AS versandfrei_ab
  FROM mandant m;

SELECT * FROM v_shop_einstellung ORDER BY mandant_id;