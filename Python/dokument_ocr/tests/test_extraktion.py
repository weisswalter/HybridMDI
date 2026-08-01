# -*- coding: utf-8 -*-
"""Tests der Datenextraktion.

Die wichtigsten Faelle stammen aus echtem OCR-Text: zerrissene Zeilen,
Tippfehler im Schluesselwort, Betraege ohne Waehrung daneben.
"""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)))))

from dokument_ocr import extraktion as ex  # noqa: E402


# So hat EasyOCR den Testbeleg tatsaechlich gelesen (01.08.2026):
OCR_ECHT = """Muster AG, 9658 Wildhaus
RECHNUNG Nr. 2026-4711
Rechnungsdatum: 12.07.2026
Pos
Artikel
Menge
Preis
1
Metallplatte 5mm
10
124.00
Zahlbar bis 30 Tage netto
Total inkl:. MWST
CHF 1240.00"""


class TestZahlLesen(unittest.TestCase):

    def test_schweizer_hochkomma(self):
        self.assertEqual(ex._zahl_lesen("1'240.00"), 1240.0)

    def test_deutsches_format(self):
        self.assertEqual(ex._zahl_lesen('1.240,00'), 1240.0)

    def test_komma_als_dezimal(self):
        self.assertEqual(ex._zahl_lesen('124,50'), 124.5)

    def test_einfache_zahl(self):
        self.assertEqual(ex._zahl_lesen('124.00'), 124.0)

    def test_ganze_zahl(self):
        self.assertEqual(ex._zahl_lesen('124'), 124.0)

    def test_unsinn_liefert_none(self):
        self.assertIsNone(ex._zahl_lesen('abc'))


class TestBetrag(unittest.TestCase):

    def test_endbetrag_trotz_zerrissener_zeilen(self):
        """Der Kernfall: 'Total' und der Betrag stehen in getrennten Zeilen."""
        b = ex.betrag_finden(OCR_ECHT)
        self.assertIsNotNone(b)
        self.assertEqual(b['wert'], 1240.0)
        self.assertEqual(b['waehrung'], 'CHF')

    def test_positionspreis_verliert_gegen_endbetrag(self):
        # 124.00 ist eine Position, 1240.00 der Endbetrag
        alle = ex.betraege_finden(OCR_ECHT)
        werte = [b['wert'] for b in alle[:1]]
        self.assertEqual(werte, [1240.0])

    def test_schweizer_schreibweise(self):
        b = ex.betrag_finden("Total inkl. MWST      CHF 1'240.00")
        self.assertEqual(b['wert'], 1240.0)

    def test_ohne_hinweis_wird_nichts_behauptet(self):
        # Nackte Zahlen ohne Kontext sind keine Betraege
        self.assertIsNone(ex.betrag_finden('Seite 1 von 3'))

    def test_menge_wird_nicht_als_betrag_genommen(self):
        b = ex.betrag_finden('Menge 10 Stk\nTotal CHF 89.00')
        self.assertEqual(b['wert'], 89.0)

    def test_mwst_satz_gewinnt_nicht(self):
        b = ex.betrag_finden('MWST-Satz 8.1%\nZu zahlen CHF 540.00')
        self.assertEqual(b['wert'], 540.0)

    def test_zahlungsfrist_ist_kein_betrag(self):
        """'30 Tage' steht neben Geldwoertern und sammelte fast so viele
        Punkte wie der Endbetrag -- in der Vorfuehrung aufgefallen."""
        alle = ex.betraege_finden(OCR_ECHT)
        punkte = {b['wert']: b['punkte'] for b in alle}
        self.assertIn(30.0, punkte, 'Testtext muss "30 Tage" enthalten')
        self.assertLess(punkte[30.0], punkte[1240.0] - 5,
                        'Zahlungsfrist liegt zu dicht am Endbetrag')

    def test_frist_allein_liefert_keinen_betrag(self):
        self.assertIsNone(ex.betrag_finden('Zahlbar bis 30 Tage netto'))

    def test_leerer_text(self):
        self.assertIsNone(ex.betrag_finden(''))
        self.assertEqual(ex.betraege_finden(None), [])

    def test_begruendung_wird_geliefert(self):
        b = ex.betrag_finden('Total CHF 100.00')
        self.assertIn('total', b['begruendung'])


class TestDatum(unittest.TestCase):

    def test_belegdatum(self):
        d = ex.datum_finden(OCR_ECHT)
        self.assertIsNotNone(d)
        self.assertEqual(d.isoformat(), '2026-07-12')

    def test_zweistelliges_jahr(self):
        self.assertEqual(ex.datum_finden('Datum 12.07.26').isoformat(),
                         '2026-07-12')

    def test_iso_format(self):
        self.assertEqual(ex.datum_finden('Datum 2026-07-12').isoformat(),
                         '2026-07-12')

    def test_bindestrich_format(self):
        self.assertEqual(ex.datum_finden('Datum 12-07-2026').isoformat(),
                         '2026-07-12')

    def test_unsinniges_datum_wird_verworfen(self):
        self.assertIsNone(ex.datum_finden('Artikel 45.99.2026'))

    def test_ohne_datum(self):
        self.assertIsNone(ex.datum_finden('Kein Datum hier'))

    def test_rechnungsdatum_schlaegt_andere(self):
        text = 'Lieferdatum 01.01.2026\nRechnungsdatum: 15.03.2026'
        self.assertEqual(ex.datum_finden(text).isoformat(), '2026-03-15')


class TestNummern(unittest.TestCase):

    def test_rechnungsnummer(self):
        self.assertEqual(ex.rechnungsnummer_finden(OCR_ECHT), '2026-4711')

    def test_rechnungsnummer_ohne_ziffern_wird_verworfen(self):
        self.assertIsNone(
            ex.rechnungsnummer_finden('Die Rechnung wurde versendet'))

    def test_iban_mit_leerzeichen(self):
        self.assertEqual(
            ex.iban_finden('Konto CH44 3199 9123 0008 8901 2'),
            'CH4431999123000889012')

    def test_iban_liechtenstein(self):
        self.assertEqual(
            ex.iban_finden('IBAN LI21 0881 0000 2324 013A A'),
            'LI21088100002324013AA')

    def test_keine_iban(self):
        self.assertIsNone(ex.iban_finden('Nur Text ohne Kontonummer'))

    def test_qr_referenz(self):
        r = ex.qr_referenz_finden('Referenz 21 00000 00003 13947 14300 09017')
        self.assertEqual(r, '210000000003139471430009017')
        self.assertEqual(len(r), 27)

    def test_zu_kurze_referenz_wird_verworfen(self):
        self.assertIsNone(ex.qr_referenz_finden('Referenz 21 00000'))


class TestGesamtauswertung(unittest.TestCase):

    def test_alle_felder_aus_echtem_ocr_text(self):
        d = ex.daten_ziehen(OCR_ECHT)
        self.assertEqual(d['betrag'], 1240.0)
        self.assertEqual(d['betrag_waehrung'], 'CHF')
        self.assertEqual(d['datum'], '2026-07-12')
        self.assertEqual(d['rechnungsnummer'], '2026-4711')
        self.assertIsNone(d['iban'])

    def test_qr_rechnung(self):
        text = """Empfangsschein          Zahlteil
        Konto / Zahlbar an
        CH44 3199 9123 0008 8901 2
        Referenz 21 00000 00003 13947 14300 09017
        Waehrung CHF   Betrag 199.95"""
        d = ex.daten_ziehen(text)
        self.assertEqual(d['iban'], 'CH4431999123000889012')
        self.assertEqual(d['qr_referenz'], '210000000003139471430009017')
        self.assertEqual(d['betrag'], 199.95)

    def test_leerer_text_liefert_lauter_none(self):
        d = ex.daten_ziehen('')
        for feld in ('betrag', 'datum', 'rechnungsnummer', 'iban',
                     'qr_referenz'):
            self.assertIsNone(d[feld], '%s haette None sein muessen' % feld)


if __name__ == '__main__':
    unittest.main(verbosity=2)
