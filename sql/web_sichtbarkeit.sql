-- ============================================================================
-- Steuerung, wer auf der Website erscheint — Stand 03.08.2026
--
-- ANLASS: Sebastian und Walter durften nicht mehr im Web stehen. Vorher hat
-- die Website ALLE Personen des Mandanten mit typ_id=1 angezeigt — wer in
-- Heisenberg angelegt wurde, stand ungefragt im Internet. Das ist die
-- falsche Voreinstellung.
--
-- DEFAULT IST BEWUSST `false`: Nicht anzeigen ist der sichere Zustand. Wer
-- ins Web soll, wird ausdrücklich freigeschaltet — nicht umgekehrt. Sonst
-- landet die nächste angelegte Person wieder ungewollt auf der Seite.
--
-- Das Flag hängt an `person_mandant`, nicht an `person`: Dieselbe Person kann
-- für einen Mandanten sichtbar sein und für einen anderen nicht.
-- ============================================================================

ALTER TABLE person_mandant ADD COLUMN IF NOT EXISTS im_web_anzeigen boolean
    NOT NULL DEFAULT false;

COMMENT ON COLUMN person_mandant.im_web_anzeigen IS
    'Steuert, ob die Person auf der oeffentlichen Website erscheint. '
    'Default false - Sichtbarkeit muss ausdruecklich erteilt werden.';

-- Wolfgang und Juergen bleiben sichtbar (beide haben eine eigene
-- Detailseite auf der Website). Alle anderen bleiben auf false.
UPDATE person_mandant pm
   SET im_web_anzeigen = true
  FROM person p
 WHERE p.person_id = pm.person_id
   AND pm.mandant_id = 1
   AND p.nachname_firmenname = 'Thiel' AND p.vorname = 'Wolfgang';

UPDATE person_mandant pm
   SET im_web_anzeigen = true
  FROM person p
 WHERE p.person_id = pm.person_id
   AND pm.mandant_id = 1
   AND p.nachname_firmenname = 'Rischkau' AND p.vorname = 'Jürgen';

-- Zweiter Riegel: auch die hinterlegten Seiteninhalte der beiden abschalten.
-- Die Detailseiten sind zwar schon ohne Route (auskommentiertes @page), aber
-- ein Schalter allein ist bei diesem Thema zu wenig.
UPDATE webinhalt SET sichtbar = false
 WHERE mandant_id = 1
   AND seite IN ('Team-Sebastian', 'Team-Walter');

-- Kontrolle: wer steht jetzt im Web?
SELECT p.person_id, COALESCE(p.vorname, '') AS vorname, p.nachname_firmenname,
       pm.im_web_anzeigen
  FROM person_mandant pm
  JOIN person p ON p.person_id = pm.person_id
 WHERE pm.mandant_id = 1 AND p.typ_id = 1
 ORDER BY p.person_id;
