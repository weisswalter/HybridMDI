-- ============================================================================
-- Mehr Testdaten fuer die Durchfuehrung (Mandant 3 / BMW).
--
-- Ziel: eine Wochenplanung, die im Gantt etwas hergibt - mehrere
-- Durchfuehrungen parallel, verteilt auf Raeume und Lehrer, mit den Faellen,
-- die in der Praxis weh tun: Doppelbelegung, Randzeiten, Ausfaelle,
-- knappes mobiles Inventar.
--
-- Idempotent ueber die Bezeichnungen.
-- ============================================================================

BEGIN;

-- ── Weitere Durchfuehrungen ────────────────────────────────────────────────
INSERT INTO kurs_durchfuehrung (kurs_id, mandant_id, semester_id, bezeichnung,
                                leiter_person_id, raum_id, status)
SELECT k.kurs_id, 3,
       (SELECT semester_id FROM semester WHERE mandant_id = 3 LIMIT 1),
       v.bez,
       (SELECT person_id FROM person WHERE nachname_firmenname = v.leiter),
       (SELECT raum_id FROM raum WHERE bezeichnung = v.raum),
       'geplant'
  FROM (SELECT kurs_id, row_number() OVER (ORDER BY kurs_id) AS rn
          FROM kurs WHERE mandant_id = 3) k
  JOIN (VALUES
    (2, 'Werkstattgruppe Mo/Mi', 'Egli',     'Werkstatt'),
    (3, 'B' || chr(252) || 'rogruppe Di/Do', 'Berger',   'Schulungsraum 2'),
    (4, 'Bewerbungstraining',    'Caduff',   'Mehrzweckraum A'),
    (5, 'Abendkurs',             'Dietrich', 'Besprechung')
  ) AS v(rn, bez, leiter, raum) ON v.rn = k.rn
 WHERE NOT EXISTS (SELECT 1 FROM kurs_durchfuehrung d
                    WHERE d.mandant_id = 3 AND d.bezeichnung = v.bez);

-- ── Termine ueber eine ganze Woche ─────────────────────────────────────────
-- Der Wochenanfang ist der Montag der laufenden Woche, damit die Daten
-- unabhaengig vom Ausfuehrungstag immer "diese Woche" ergeben.
INSERT INTO kurs_termin (durchfuehrung_id, mandant_id, zeitraum, raum_id,
                         leiter_person_id, thema, status)
SELECT d.durchfuehrung_id, 3,
       tstzrange(w.montag + v.tag + v.von, w.montag + v.tag + v.bis),
       d.raum_id, d.leiter_person_id, v.thema, v.status
  FROM kurs_durchfuehrung d
  CROSS JOIN (SELECT date_trunc('week', CURRENT_DATE)::date AS montag) w
  JOIN (VALUES
    -- Werkstattgruppe: Montag und Mittwoch ganztags
    ('Werkstattgruppe Mo/Mi', 0, TIME '08:00', TIME '11:30', 'Werkstatt Vormittag', 'geplant'),
    ('Werkstattgruppe Mo/Mi', 0, TIME '13:00', TIME '16:00', 'Werkstatt Nachmittag','geplant'),
    ('Werkstattgruppe Mo/Mi', 2, TIME '08:00', TIME '11:30', 'Werkstatt Vormittag', 'geplant'),
    ('Werkstattgruppe Mo/Mi', 2, TIME '16:00', TIME '18:00', 'Werkstatt Sp'||chr(228)||'tschicht','stattgefunden'),
    -- Buerogruppe: Dienstag und Donnerstag
    ('B' || chr(252) || 'rogruppe Di/Do', 1, TIME '09:00', TIME '12:00', 'EDV',      'geplant'),
    ('B' || chr(252) || 'rogruppe Di/Do', 3, TIME '09:00', TIME '12:00', 'EDV',      'geplant'),
    ('B' || chr(252) || 'rogruppe Di/Do', 3, TIME '14:00', TIME '15:30', 'Korrespondenz','ausgefallen'),
    -- Bewerbungstraining: Mittwoch, braucht den Beamer
    ('Bewerbungstraining', 2, TIME '09:00', TIME '12:00', 'Unterlagen',       'geplant'),
    ('Bewerbungstraining', 4, TIME '10:00', TIME '11:30', 'Vorstellungsgespr' || chr(228) || 'ch', 'geplant'),
    -- Abendkurs: Dienstag spaet, laeuft ueber Mitternacht
    ('Abendkurs', 1, TIME '18:00', TIME '21:00', 'Abendeinheit',  'geplant'),
    ('Abendkurs', 4, TIME '22:00', TIME '23:59', 'Nachtblock',    'geplant')
  ) AS v(bez, tag, von, bis, thema, status) ON v.bez = d.bezeichnung
 WHERE d.mandant_id = 3
   AND NOT EXISTS (SELECT 1 FROM kurs_termin t
                    WHERE t.durchfuehrung_id = d.durchfuehrung_id
                      AND t.thema = v.thema
                      AND lower(t.zeitraum) = w.montag + v.tag + v.von);

-- ── Teilnehmer auf die Durchfuehrungen verteilen ──────────────────────────
INSERT INTO kurs_teilnehmer (durchfuehrung_id, person_id, mandant_id)
SELECT d.durchfuehrung_id, p.person_id, 3
  FROM kurs_durchfuehrung d
  JOIN (VALUES
    ('Werkstattgruppe Mo/Mi', 'Fankhauser'),
    ('Werkstattgruppe Mo/Mi', 'Gerber'),
    ('B' || chr(252) || 'rogruppe Di/Do', 'Huber'),
    ('B' || chr(252) || 'rogruppe Di/Do', 'Fankhauser'),
    ('Bewerbungstraining', 'Gerber'),
    ('Bewerbungstraining', 'Huber'),
    ('Bewerbungstraining', 'Iten')
  ) AS v(bez, nn) ON v.bez = d.bezeichnung
  JOIN person p ON p.nachname_firmenname = v.nn
 WHERE d.mandant_id = 3
ON CONFLICT DO NOTHING;

-- ── Mobiles Inventar belegen: der EINE Beamer im Bewerbungstraining ───────
INSERT INTO termin_ausstattung (termin_id, ausstattungs_id, mandant_id, menge)
SELECT t.termin_id, a.ausstattungs_id, 3, 1
  FROM kurs_termin t
  JOIN kurs_durchfuehrung d ON d.durchfuehrung_id = t.durchfuehrung_id
  JOIN ausstattung a ON a.bezeichnung = 'Beamer'
 WHERE d.mandant_id = 3 AND d.bezeichnung = 'Bewerbungstraining'
ON CONFLICT DO NOTHING;

-- Laptopwagen (2 Stueck) an die EDV-Termine - einer bleibt frei
INSERT INTO termin_ausstattung (termin_id, ausstattungs_id, mandant_id, menge)
SELECT t.termin_id, a.ausstattungs_id, 3, 1
  FROM kurs_termin t
  JOIN kurs_durchfuehrung d ON d.durchfuehrung_id = t.durchfuehrung_id
  JOIN ausstattung a ON a.bezeichnung = 'Laptopwagen'
 WHERE d.mandant_id = 3 AND t.thema = 'EDV'
ON CONFLICT DO NOTHING;

COMMIT;

SELECT d.bezeichnung AS durchfuehrung,
       p.nachname_firmenname AS leiter,
       r.bezeichnung AS raum,
       (SELECT count(*) FROM kurs_termin t
         WHERE t.durchfuehrung_id = d.durchfuehrung_id) AS termine,
       (SELECT count(*) FROM kurs_teilnehmer tn
         WHERE tn.durchfuehrung_id = d.durchfuehrung_id) AS teilnehmer
  FROM kurs_durchfuehrung d
  LEFT JOIN person p ON p.person_id = d.leiter_person_id
  LEFT JOIN raum r   ON r.raum_id   = d.raum_id
 WHERE d.mandant_id = 3
 ORDER BY d.bezeichnung;
