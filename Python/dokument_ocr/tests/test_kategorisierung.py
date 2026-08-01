# -*- coding: utf-8 -*-
"""Tests der Kategorisierung. Laufen ohne EasyOCR und ohne OpenCV.

Aufruf aus Python\\:
    python -m unittest discover -s dokument_ocr\\tests -v
"""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)))))

from dokument_ocr.kategorisierung import (  # noqa: E402
    Kategorisierer, text_normalisieren, UNBEKANNT)


class TestNormalisierung(unittest.TestCase):

    def test_umlaute_werden_vereinheitlicht(self):
        self.assertIn('gruessen', text_normalisieren('Grüßen'))
        self.assertIn('faellig', text_normalisieren('Fällig'))

    def test_trennstrich_am_zeilenende_wird_zusammengezogen(self):
        # Genau so liefert OCR getrennte Woerter aus dem Blocksatz
        self.assertIn('rechnung', text_normalisieren('Rech-\nnung'))

    def test_zeilenumbrueche_werden_zu_leerzeichen(self):
        ergebnis = text_normalisieren('Zeile eins\nZeile zwei')
        self.assertNotIn('\n', ergebnis)
        self.assertIn('zeile eins zeile zwei', ergebnis)

    def test_leerer_text_bricht_nicht(self):
        self.assertEqual(text_normalisieren(''), '')
        self.assertEqual(text_normalisieren(None), '')


class TestKategorien(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.k = Kategorisierer()

    def test_regelwerk_wird_geladen(self):
        self.assertGreater(len(self.k.kategorien), 5)
        self.assertIn('rechnung', self.k.schluessel_liste())

    def test_rechnung(self):
        text = """
        Muster AG
        RECHNUNG Nr. 2026-4711
        Rechnungsdatum: 12.07.2026
        Zahlbar bis 30 Tage netto
        Total inkl. MWST  CHF 1'240.00
        """
        e = self.k.kategorisieren(text)
        self.assertEqual(e.schluessel, 'rechnung')
        self.assertTrue(e.sicher)

    def test_schweizer_qr_rechnung_schlaegt_normale_rechnung(self):
        # Beide Kategorien greifen; die spezifischere muss gewinnen.
        text = """
        Empfangsschein                Zahlteil
        Konto / Zahlbar an
        CH44 3199 9123 0008 8901 2
        Referenz 21 00000 00003 13947 14300 09017
        Waehrung CHF   Betrag 199.95
        Annahmestelle
        """
        e = self.k.kategorisieren(text)
        self.assertEqual(e.schluessel, 'qr_rechnung')
        self.assertTrue(e.sicher)

    def test_mahnung_gewinnt_gegen_rechnung(self):
        text = """
        2. Mahnung
        Trotz unserer Rechnung vom 12.05.2026 konnten wir bisher
        keinen Zahlungseingang feststellen. Mahngebuehr CHF 20.00.
        """
        e = self.k.kategorisieren(text)
        self.assertEqual(e.schluessel, 'mahnung')

    def test_lieferschein(self):
        text = """
        LIEFERSCHEIN 88231
        Lieferadresse: Werkstatt Wildhaus
        Lieferdatum 03.06.2026
        Pos  Artikel            Menge
        """
        self.assertEqual(self.k.kategorisieren(text).schluessel, 'lieferschein')

    def test_angebot(self):
        text = """
        Offerte 2026-114
        Gueltig bis 31.08.2026, unverbindlich
        Wir danken fuer Ihre Anfrage.
        """
        self.assertEqual(self.k.kategorisieren(text).schluessel, 'angebot')

    def test_lohnabrechnung(self):
        text = """
        Lohnabrechnung Juli 2026
        Bruttolohn       6'500.00
        AHV/IV/EO         -344.50
        ALV                -71.50
        Pensionskasse BVG -420.00
        Nettolohn        5'664.00
        """
        e = self.k.kategorisieren(text)
        self.assertEqual(e.schluessel, 'lohnabrechnung')

    def test_kursunterlage_arbeitsagogik(self):
        text = """
        Grundkurs Metallbearbeitung
        Lernziele der Module
        Unterkurs: Digitale Grundkompetenzen
        Teilnehmerliste siehe Anhang
        """
        e = self.k.kategorisieren(text)
        self.assertEqual(e.schluessel, 'kursunterlage')

    def test_unbekannt_bei_belanglosem_text(self):
        e = self.k.kategorisieren('Notizzettel Milch Brot Butter')
        self.assertEqual(e.schluessel, UNBEKANNT)
        self.assertFalse(e.sicher)

    def test_leerer_text_ist_unbekannt(self):
        e = self.k.kategorisieren('')
        self.assertEqual(e.schluessel, UNBEKANNT)
        self.assertFalse(e.sicher)

    def test_begruendung_nennt_die_fundstelle(self):
        e = self.k.kategorisieren('Rechnung Nr. 5, MWST 8.1%, zahlbar bis Ende Monat')
        self.assertTrue(e.sicher)
        self.assertIn('rechnung', e.begruendung().lower())

    def test_umlaute_im_dokument_stoeren_nicht(self):
        # OCR liefert mal "für", mal "fuer" - beides muss greifen
        mit = self.k.kategorisieren('Rechnung für Möbel, Betrag fällig, MWST')
        ohne = self.k.kategorisieren('Rechnung fuer Moebel, Betrag faellig, MWST')
        self.assertEqual(mit.schluessel, 'rechnung')
        self.assertEqual(ohne.schluessel, 'rechnung')

    def test_ergebnis_als_dict_ist_vollstaendig(self):
        d = self.k.kategorisieren('Rechnung Nr 1 MWST zahlbar bis').als_dict()
        for feld in ('schluessel', 'bezeichnung', 'punkte', 'sicher',
                     'begruendung', 'alle_punkte'):
            self.assertIn(feld, d)


if __name__ == '__main__':
    unittest.main(verbosity=2)
