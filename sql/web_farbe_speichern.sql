-- ============================================================================
--  fn_web_farbe_speichern — Schreibweg fuer web_farbe, Stand 21.08.2026
--
--  web_farbe hat keinen Autoinc-Schluessel wie die uebrigen Typ-Tabellen,
--  sondern den Primaerschluessel (mandant_id, schluessel) - deshalb kein
--  Fall in EinstellungenDm.ReiterInfo/TypSpeichern, sondern ein eigener Weg
--  wie beim Website-Reiter (WebWertSetzen).
--
--  Die Website (CmsService.GetFarbenCssAsync) laesst nur Werte durch, die
--  auf ^#[0-9a-fA-F]{3,8}$ passen - alles andere wird beim Rendern der CSS
--  stillschweigend uebersprungen. Damit ein falscher Wert nicht erst dort,
--  sondern schon beim Speichern auffaellt, prueft die Funktion dieselbe
--  Form.
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_web_farbe_speichern(
    p_mandant_id integer,
    p_schluessel varchar,
    p_wert varchar,
    p_bemerkung varchar DEFAULT NULL
) RETURNS void AS $$
BEGIN
    INSERT INTO funktion_aufruf (funktion_id, parameter)
    SELECT funktion_id, jsonb_build_array(p_mandant_id, p_schluessel, p_wert,
                                           p_bemerkung)
      FROM funktion WHERE name = 'fn_web_farbe_speichern';

    IF btrim(COALESCE(p_schluessel, '')) = '' THEN
        RAISE EXCEPTION 'Kein Schluessel angegeben.';
    END IF;

    IF p_wert !~ '^#[0-9a-fA-F]{3,8}$' THEN
        RAISE EXCEPTION
            'Farbwert "%" ist kein gueltiger Hex-Code (z. B. #4FE3E7).', p_wert;
    END IF;

    INSERT INTO web_farbe (mandant_id, schluessel, wert, bemerkung)
    VALUES (p_mandant_id, btrim(p_schluessel), p_wert, p_bemerkung)
    ON CONFLICT (mandant_id, schluessel) DO UPDATE
       SET wert      = EXCLUDED.wert,
           bemerkung = COALESCE(EXCLUDED.bemerkung, web_farbe.bemerkung);
END;
$$ LANGUAGE plpgsql;

-- Katalogeintrag, wie bei jeder anderen _speichern-Funktion.
INSERT INTO funktion (name, parameterliste)
VALUES ('fn_web_farbe_speichern',
        'p_mandant_id integer, p_schluessel varchar, p_wert varchar, p_bemerkung varchar')
ON CONFLICT (name) DO UPDATE SET parameterliste = EXCLUDED.parameterliste;

INSERT INTO funktion_tabelle (funktion_id, tabelle, wirkung, ueber)
SELECT f.funktion_id, v.tabelle, v.wirkung, 'direkt'
  FROM funktion f
  CROSS JOIN (VALUES ('funktion_aufruf', 'INSERT'),
                      ('web_farbe', 'INSERT'),
                      ('web_farbe', 'UPDATE')) AS v(tabelle, wirkung)
 WHERE f.name = 'fn_web_farbe_speichern'
ON CONFLICT (funktion_id, tabelle, wirkung) DO NOTHING;
