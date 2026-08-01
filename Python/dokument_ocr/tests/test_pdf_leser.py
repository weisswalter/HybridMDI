# -*- coding: utf-8 -*-
"""Tests des PDF-Lesers.

Die Test-PDFs werden von Hand zusammengesetzt. Das PDF-Format ist an der
Oberflaeche Text, ein minimales Dokument laesst sich damit ohne weitere
Bibliothek erzeugen -- und der Test bleibt unabhaengig davon, ob gerade
reportlab oder aehnliches installiert ist.
"""

import os
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)))))

from dokument_ocr import pdf_leser  # noqa: E402


def pdf_mit_text(pfad, zeilen):
    """Minimales einseitiges PDF mit echtem, auslesbarem Text."""
    inhalt_zeilen = []
    y = 700
    for z in zeilen:
        sicher = z.replace('\\', r'\\').replace('(', r'\(').replace(')', r'\)')
        inhalt_zeilen.append('BT /F1 12 Tf 70 %d Td (%s) Tj ET' % (y, sicher))
        y -= 20
    inhalt = '\n'.join(inhalt_zeilen).encode('latin-1')

    objekte = [
        b'<< /Type /Catalog /Pages 2 0 R >>',
        b'<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
        b'<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
        b'/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
        b'<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
        b'<< /Length ' + str(len(inhalt)).encode() + b' >>\nstream\n'
        + inhalt + b'\nendstream',
    ]

    daten = bytearray(b'%PDF-1.4\n')
    versaetze = []
    for i, obj in enumerate(objekte, start=1):
        versaetze.append(len(daten))
        daten += b'%d 0 obj\n' % i + obj + b'\nendobj\n'

    xref_start = len(daten)
    daten += b'xref\n0 %d\n' % (len(objekte) + 1)
    daten += b'0000000000 65535 f \n'
    for v in versaetze:
        daten += b'%010d 00000 n \n' % v
    daten += (b'trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n'
              % (len(objekte) + 1, xref_start))

    with open(pfad, 'wb') as f:
        f.write(bytes(daten))
    return pfad


def pdf_ohne_text(pfad):
    """PDF mit leerer Seite -- steht hier fuer einen reinen Scan."""
    return pdf_mit_text(pfad, [])


class TestPdfLeser(unittest.TestCase):

    def setUp(self):
        self.ordner = tempfile.mkdtemp(prefix='pdftest_')

    def tearDown(self):
        shutil.rmtree(self.ordner, ignore_errors=True)

    def test_ist_pdf(self):
        self.assertTrue(pdf_leser.ist_pdf('a.pdf'))
        self.assertTrue(pdf_leser.ist_pdf('A.PDF'))
        self.assertFalse(pdf_leser.ist_pdf('a.png'))

    def test_pypdf_ist_vorhanden(self):
        self.assertTrue(pdf_leser.pypdf_verfuegbar(),
                        'pypdf fehlt: pip install pypdf')

    def test_text_wird_ausgelesen(self):
        pfad = pdf_mit_text(os.path.join(self.ordner, 'r.pdf'), [
            'Muster AG, 9658 Wildhaus',
            'RECHNUNG Nr. 2026-4711',
            'Total inkl. MWST CHF 1240.00',
        ])
        text, seiten = pdf_leser.text_lesen(pfad)
        self.assertEqual(seiten, 1)
        self.assertIn('RECHNUNG', text)
        self.assertIn('1240.00', text)

    def test_durchsuchbares_pdf_wird_erkannt(self):
        pfad = pdf_mit_text(os.path.join(self.ordner, 'r.pdf'), [
            'Muster AG, 9658 Wildhaus',
            'RECHNUNG Nr. 2026-4711',
            'Rechnungsdatum 12.07.2026',
            'Total inkl. MWST CHF 1240.00',
        ])
        self.assertTrue(pdf_leser.ist_durchsuchbar(pfad))

    def test_scan_pdf_wird_als_nicht_durchsuchbar_erkannt(self):
        pfad = pdf_ohne_text(os.path.join(self.ordner, 'scan.pdf'))
        self.assertFalse(pdf_leser.ist_durchsuchbar(pfad))

    def test_auswertung_durchsuchbar(self):
        pfad = pdf_mit_text(os.path.join(self.ordner, 'r.pdf'), [
            'Muster AG, 9658 Wildhaus',
            'RECHNUNG Nr. 2026-4711',
            'Rechnungsdatum 12.07.2026',
            'Total inkl. MWST CHF 1240.00',
        ])
        a = pdf_leser.pdf_auswerten(pfad)
        self.assertTrue(a['ist_pdf'])
        self.assertTrue(a['durchsuchbar'])
        self.assertEqual(a['seiten'], 1)
        self.assertIn('keine Erkennung', a['hinweis'])

    def test_auswertung_scan_nennt_den_grund(self):
        pfad = pdf_ohne_text(os.path.join(self.ordner, 'scan.pdf'))
        a = pdf_leser.pdf_auswerten(pfad)
        self.assertFalse(a['durchsuchbar'])
        self.assertIn('Scan', a['hinweis'])

    def test_auswertung_bei_nicht_pdf(self):
        a = pdf_leser.pdf_auswerten('bild.png')
        self.assertFalse(a['ist_pdf'])

    def test_kaputte_datei_wirft_nicht(self):
        pfad = os.path.join(self.ordner, 'kaputt.pdf')
        with open(pfad, 'wb') as f:
            f.write(b'das ist kein PDF')
        self.assertFalse(pdf_leser.ist_durchsuchbar(pfad))
        a = pdf_leser.pdf_auswerten(pfad)
        self.assertFalse(a['durchsuchbar'])


class TestPipelineMitPdf(unittest.TestCase):
    """Ein durchsuchbares PDF muss ganz ohne OCR durchlaufen."""

    def setUp(self):
        self.ordner = tempfile.mkdtemp(prefix='pdfpipe_')

    def tearDown(self):
        shutil.rmtree(self.ordner, ignore_errors=True)

    def test_pdf_ohne_ocr_backend(self):
        from dokument_ocr import DokumentPipeline

        pfad = pdf_mit_text(os.path.join(self.ordner, 'r.pdf'), [
            'Muster AG, 9658 Wildhaus',
            'RECHNUNG Nr. 2026-4711',
            'Rechnungsdatum: 12.07.2026',
            'Zahlbar bis 30 Tage netto',
            'Total inkl. MWST CHF 1240.00',
        ])

        # Absichtlich ohne Backend: bei eingebettetem Text darf keins
        # gebraucht werden.
        e = DokumentPipeline(backend=None).verarbeiten(pfad)

        self.assertIsNone(e['fehler'])
        self.assertEqual(e['kategorie'], 'rechnung')
        self.assertEqual(e['mime_type'], 'application/pdf')
        self.assertEqual(e['aufbereitung'].get('pdf_quelle'),
                         'eingebetteter Text')
        self.assertEqual(e['betrag'], 1240.0)
        self.assertEqual(e['datum'], '2026-07-12')
        self.assertEqual(e['rechnungsnummer'], '2026-4711')

    def test_scan_pdf_meldet_verstaendlichen_fehler(self):
        from dokument_ocr import DokumentPipeline

        pfad = pdf_ohne_text(os.path.join(self.ordner, 'scan.pdf'))
        e = DokumentPipeline(backend=None).verarbeiten(pfad)

        self.assertIsNotNone(e['fehler'])
        self.assertIn('Scan', e['fehler'])


if __name__ == '__main__':
    unittest.main(verbosity=2)
