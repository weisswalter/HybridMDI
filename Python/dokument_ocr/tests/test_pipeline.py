# -*- coding: utf-8 -*-
"""Tests des Gesamtlaufs.

Benutzt das TestBackend, damit die Tests ohne EasyOCR laufen. Geprueft wird
alles ausser der Texterkennung selbst: Titelvorschlag, Spracherkennung,
Fehlerbehandlung und das Format der Rueckgabe.
"""

import json
import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)))))

from dokument_ocr import ocr_backend  # noqa: E402
from dokument_ocr.pipeline import (  # noqa: E402
    DokumentPipeline, titel_vorschlagen, sprache_raten, mime_typ, als_json)


RECHNUNG = """Muster AG, Wildhaus
RECHNUNG Nr. 2026-4711
Rechnungsdatum 12.07.2026
Zahlbar bis 30 Tage netto
Total inkl. MWST CHF 1240.00
"""


class TestHilfsfunktionen(unittest.TestCase):

    def test_titel_nimmt_erste_sinnvolle_zeile(self):
        self.assertEqual(
            titel_vorschlagen('x.png', 'Muster AG\nRechnung'), 'Muster AG')

    def test_titel_ueberspringt_ziffernzeilen(self):
        # Kopfzeilen von Scans sind oft Strichcodes oder Seitenzahlen
        titel = titel_vorschlagen('x.png', '4711\n---\nRechnung Nr 5')
        self.assertEqual(titel, 'Rechnung Nr 5')

    def test_titel_faellt_auf_dateinamen_zurueck(self):
        self.assertEqual(titel_vorschlagen('/pfad/beleg_12.png', ''),
                         'beleg_12')

    def test_titel_wird_gekuerzt(self):
        lang = 'A' * 400
        self.assertEqual(len(titel_vorschlagen('x.png', lang)), 120)

    def test_sprache_deutsch(self):
        self.assertEqual(sprache_raten(RECHNUNG), 'de')

    def test_sprache_englisch(self):
        self.assertEqual(
            sprache_raten('This is the invoice for the amount and the goods'),
            'en')

    def test_sprache_unklar_behauptet_nichts(self):
        self.assertIsNone(sprache_raten(''))
        self.assertIsNone(sprache_raten('4711 88231 0.00'))

    def test_mime_typ(self):
        self.assertEqual(mime_typ('a.png'), 'image/png')
        self.assertEqual(mime_typ('a.PDF'), 'application/pdf')
        self.assertEqual(mime_typ('a.xyz'), 'application/octet-stream')


class TestPipeline(unittest.TestCase):

    def setUp(self):
        self.ordner = tempfile.mkdtemp(prefix='ocrtest_')
        self.datei = os.path.join(self.ordner, 'beleg.png')
        with open(self.datei, 'wb') as f:
            f.write(b'\x89PNG\r\n\x1a\n' + b'0' * 2000)   # Attrappe

    def tearDown(self):
        shutil.rmtree(self.ordner, ignore_errors=True)

    def test_gesamtlauf_liefert_alle_felder(self):
        p = DokumentPipeline(backend=ocr_backend.TestBackend(RECHNUNG))
        e = p.verarbeiten(self.datei)

        for feld in ('datei', 'titel', 'ocr_text', 'mime_type',
                     'dateigroesse_kb', 'sprache', 'scan_datum',
                     'kategorie', 'kategorie_sicher', 'kategorie_begruendung',
                     'ocr_zuversicht', 'fehler'):
            self.assertIn(feld, e)

        self.assertEqual(e['kategorie'], 'rechnung')
        self.assertTrue(e['kategorie_sicher'])
        self.assertEqual(e['sprache'], 'de')
        self.assertEqual(e['mime_type'], 'image/png')
        self.assertIsNone(e['fehler'])
        self.assertGreater(e['dateigroesse_kb'], 0)

    def test_unlesbares_dokument_bricht_den_lauf_nicht_ab(self):
        # Ohne Backend muss verarbeiten() den Fehler melden, nicht werfen --
        # sonst reisst ein kaputter Scan einen ganzen Stapel mit.
        p = DokumentPipeline(backend=None)
        e = p.verarbeiten(self.datei)
        self.assertIsNotNone(e['fehler'])
        self.assertEqual(e['kategorie'], 'unbekannt')
        self.assertEqual(e['ocr_text'], '')

    def test_ordner_verarbeiten(self):
        for name in ('a.png', 'b.png', 'egal.docx'):
            with open(os.path.join(self.ordner, name), 'wb') as f:
                f.write(b'x' * 100)

        p = DokumentPipeline(backend=ocr_backend.TestBackend(RECHNUNG))
        ergebnisse = p.ordner_verarbeiten(self.ordner)

        namen = sorted(os.path.basename(e['datei']) for e in ergebnisse)
        self.assertIn('a.png', namen)
        self.assertNotIn('egal.docx', namen, 'Nur Bilddateien verarbeiten')

    def test_json_ausgabe_ist_gueltig_und_behaelt_umlaute(self):
        p = DokumentPipeline(backend=ocr_backend.TestBackend(
            'Rechnung für Möbel, MWST, zahlbar bis Ende Monat'))
        text = als_json(p.verarbeiten(self.datei))
        wieder = json.loads(text)
        self.assertEqual(wieder['kategorie'], 'rechnung')
        self.assertIn('ö', wieder['ocr_text'])


class TestBackends(unittest.TestCase):

    def test_testbackend_zerlegt_in_bloecke(self):
        e = ocr_backend.TestBackend('eins\nzwei\n\ndrei').erkennen()
        self.assertEqual(len(e.bloecke), 3, 'Leerzeilen zaehlen nicht')
        self.assertAlmostEqual(e.zuversicht, 0.9, places=5)

    def test_zuversicht_ohne_bloecke_ist_null(self):
        self.assertEqual(ocr_backend.OcrErgebnis('').zuversicht, 0.0)

    def test_textdatei_backend(self):
        ordner = tempfile.mkdtemp(prefix='ocrtxt_')
        try:
            pfad = os.path.join(ordner, 'text.txt')
            with open(pfad, 'w', encoding='utf-8') as f:
                f.write(RECHNUNG)
            b = ocr_backend.TextDateiBackend(pfad)
            self.assertTrue(b.verfuegbar())
            self.assertIn('RECHNUNG', b.erkennen().text)
        finally:
            shutil.rmtree(ordner, ignore_errors=True)

    def test_easyocr_backend_meldet_fehlende_installation_verstaendlich(self):
        b = ocr_backend.EasyOcrBackend()
        if b.verfuegbar():
            self.skipTest('EasyOCR ist installiert')
        with self.assertRaises(RuntimeError) as ctx:
            b.erkennen(None)
        self.assertIn('pip install easyocr', str(ctx.exception))


if __name__ == '__main__':
    unittest.main(verbosity=2)
