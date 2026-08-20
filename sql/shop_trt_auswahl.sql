-- Auswahl der Artikel, die auf der TRT-Seite stehen sollen (Mandant 1).
--
-- ACHTUNG PREISE: die Betraege unten sind von mir gesetzt, nicht von TRT.
-- Sie stehen mit dem Vermerk "Platzhalter" in artikel_preis.bemerkung und
-- muessen vor dem Livegang durch echte ersetzt werden.

BEGIN;

-- Erst alles abschalten, damit die Auswahl unten die ganze Wahrheit ist -
-- unter anderem die zwei, die ich zum Ausprobieren freigeschaltet hatte.
UPDATE artikel SET im_shop = false WHERE mandant_id = 1;

UPDATE artikel SET im_shop = true
 WHERE mandant_id = 1
   AND artikel_nr IN ('TRT-100', 'TRT-120', 'TRT-121', 'TRT-130',
                      'TRT-200', 'TRT-210');

-- Ausfuehrlichere Texte: im Artikelstamm reicht ein Stichwort, auf einer
-- Verkaufsseite nicht.
UPDATE artikel SET beschreibung = t.text
  FROM (VALUES
    ('TRT-100', 'Kompletter Emissionsmessplatz als anschlussfertige Oberbaugruppe. ' ||
                'Messschrank, Analysatoren, Gasaufbereitung und Steuerrechner sind ' ||
                'aufeinander abgestimmt und werkseitig geprueft. Auf Wunsch ' ||
                'erweitern wir die Bestueckung nach Ihrer Messaufgabe.'),
    ('TRT-120', 'Stickoxid-Analysator nach dem Chemilumineszenz-Verfahren. ' ||
                'Fuer Dauermessungen an Motorpruefstaenden und Abgasanlagen. ' ||
                'Wird kalibriert und mit Pruefprotokoll geliefert.'),
    ('TRT-121', 'Analysator fuer Kohlenmonoxid und Kohlendioxid, nichtdispersiv ' ||
                'infrarot. Zwei Messbereiche in einem Geraet, mit Pruefprotokoll.'),
    ('TRT-130', 'Beheizte Probenahmesonde, ein Meter, fuer Abgase bis 180 Grad. ' ||
                'Verhindert Kondensat schon an der Entnahmestelle.'),
    ('TRT-200', 'Kalibriergas-Set aus drei Pruefgasflaschen fuer die regelmaessige ' ||
                'Kontrolle der Analysatoren. Mit Herstellerzertifikat.'),
    ('TRT-210', 'Filtersatz als Verbrauchsmaterial fuer Gasaufbereitung und ' ||
                'Probenahme. Wir empfehlen den Wechsel nach je 500 Betriebsstunden.')
  ) AS t(nr, text)
 WHERE artikel.mandant_id = 1 AND artikel.artikel_nr = t.nr;

-- Kategorien zuordnen (mehrere je Artikel waeren moeglich, hier reicht eine).
DELETE FROM artikel_kategorie
 WHERE artikel_id IN (SELECT artikel_id FROM artikel WHERE mandant_id = 1);

INSERT INTO artikel_kategorie (artikel_id, kategorie_id)
SELECT a.artikel_id, k.kategorie_id
  FROM (VALUES
    ('TRT-100', 'Fertigprodukt'),
    ('TRT-120', 'Handelsware'),
    ('TRT-121', 'Handelsware'),
    ('TRT-130', 'Handelsware'),
    ('TRT-200', 'Verbrauch'),
    ('TRT-210', 'Verbrauch')
  ) AS z(nr, kat)
  JOIN artikel a   ON a.mandant_id = 1 AND a.artikel_nr = z.nr
  JOIN kategorie k ON k.mandant_id = 1 AND k.bereich = 'ARTIKEL'
                  AND k.bezeichnung = z.kat;

-- Preise. Die alten Platzhalter von 49.90 fliegen raus.
DELETE FROM artikel_preis
 WHERE mandant_id = 1
   AND (bemerkung LIKE 'Platzhalter%' OR preis = 49.90);

INSERT INTO artikel_preis (mandant_id, artikel_id, gueltig_von, preis,
                           waehrung, mwst_satz, bemerkung)
SELECT 1, a.artikel_id, CURRENT_DATE, p.preis, 'EUR', 19.00,
       'Platzhalter aus der Shop-Einrichtung - bitte durch echten Preis ersetzen'
  FROM (VALUES
    ('TRT-100', 48500.00),
    ('TRT-120', 12900.00),
    ('TRT-121', 11400.00),
    ('TRT-130',  2450.00),
    ('TRT-200',   890.00),
    ('TRT-210',   145.00)
  ) AS p(nr, preis)
  JOIN artikel a ON a.mandant_id = 1 AND a.artikel_nr = p.nr;

COMMIT;

SELECT artikel_nr, artikelname, preis, kategorie
  FROM v_shop_artikel WHERE mandant_id = 1 ORDER BY artikel_nr;
