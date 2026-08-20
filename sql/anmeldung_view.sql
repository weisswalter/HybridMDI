-- person_id fehlte in der Uebersicht; das Fenster braucht sie, um die
-- E-Mail-Adressen der Person zum gewaehlten Konto zu zeigen.
-- Angehaengt statt eingeschoben: CREATE OR REPLACE darf Spalten nur hinten
-- ergaenzen, nicht umordnen.
CREATE OR REPLACE VIEW v_benutzer_uebersicht AS
 SELECT b.benutzer_id,
    b.anmeldename,
    b.aktiv,
    b.letzter_login,
    b.muss_passwort_aendern,
    b.gesperrt_bis IS NOT NULL AND b.gesperrt_bis > now() AS gesperrt,
    p.nachname_firmenname::text || COALESCE(', '::text || p.vorname::text, ''::text) AS person,
    fn_ist_global_admin(b.benutzer_id) AS global_admin,
    ( SELECT string_agg(((m.mandanten_name::text || ' ('::text) || bm.rolle::text) || ')'::text, ', '::text ORDER BY m.mandanten_name) AS string_agg
           FROM benutzer_mandant bm
             JOIN mandant m ON m.mandant_id = bm.mandant_id
          WHERE bm.benutzer_id = b.benutzer_id AND bm.aktiv) AS mandanten,
    b.person_id
   FROM benutzer b
     LEFT JOIN person p ON p.person_id = b.person_id;