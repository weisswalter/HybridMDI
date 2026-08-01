# -*- coding: utf-8 -*-
"""Vom Scan zum Datensatz: Bild aufbereiten, Text erkennen, einordnen.

Die Rueckgabe ist bewusst auf die Spalten der Tabelle 'dokument'
zugeschnitten (siehe DokumenteDm.pas):

    dokument_id, typ_id, titel, ocr_text, mime_type, quelle,
    dateigroesse_kb, sprache, scan_datum, created_at

Geliefert werden die Felder, die sich aus der Datei ableiten lassen. Die
Zuordnung von 'kategorie' auf die tatsaechliche typ_id macht die
aufrufende Seite -- dieses Modul kennt die Datenbank nicht und soll sie
auch nicht kennen.
"""

import json
import os
import re
from datetime import datetime

from .kategorisierung import Kategorisierer, UNBEKANNT
from . import ocr_backend as backends
from . import extraktion
from . import pdf_leser

try:
    import cv2
except ImportError:  # pragma: no cover
    cv2 = None

try:
    from . import bildvorbereitung
except ImportError:  # pragma: no cover
    bildvorbereitung = None


# Dateiendungen, die als Bild gelesen werden koennen
BILD_ENDUNGEN = ('.png', '.jpg', '.jpeg', '.tif', '.tiff', '.bmp')

MIME_NACH_ENDUNG = {
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.tif': 'image/tiff',
    '.tiff': 'image/tiff',
    '.bmp': 'image/bmp',
    '.pdf': 'application/pdf',
    '.txt': 'text/plain',
}


def mime_typ(pfad):
    endung = os.path.splitext(pfad)[1].lower()
    return MIME_NACH_ENDUNG.get(endung, 'application/octet-stream')


def titel_vorschlagen(pfad, text, max_laenge=120):
    """Erste brauchbare Textzeile als Titel, sonst der Dateiname.

    'Brauchbar' heisst: mindestens vier Zeichen und nicht nur Ziffern und
    Satzzeichen -- Kopfzeilen von Scans bestehen oft aus Strichcodes oder
    Seitenzahlen, die als Titel nichts taugen.
    """
    for zeile in (text or '').split('\n'):
        kandidat = zeile.strip()
        if len(kandidat) < 4:
            continue
        buchstaben = [c for c in kandidat if c.isalpha()]
        if len(buchstaben) < 3:
            continue
        return kandidat[:max_laenge]

    return os.path.splitext(os.path.basename(pfad))[0][:max_laenge]


def sprache_raten(text):
    """Grobe Unterscheidung Deutsch/Englisch ueber haeufige Funktionswoerter.

    Reicht fuer das Feld 'sprache'. Wenn die Zaehlung zu knapp ausfaellt,
    wird nichts behauptet und None geliefert.
    """
    if not text:
        return None

    # Zeilenumbrueche zu Leerzeichen und aussen auffuellen: die Suchmuster
    # haben ein fuehrendes Leerzeichen, damit "der" nicht in "anderer"
    # trifft. Ohne diese Normalisierung wird ein Wort am Zeilenanfang -- bei
    # Belegen der Normalfall, z.B. "RECHNUNG" -- nie gefunden.
    klein = ' ' + re.sub(r'\s+', ' ', text.lower()) + ' '

    deutsch = sum(klein.count(w) for w in
                  (' der ', ' die ', ' das ', ' und ', ' nicht ', ' mit ',
                   ' fuer ', ' für ', ' rechnung', ' betrag', ' zahlbar',
                   ' datum', ' total ', ' inkl'))
    englisch = sum(klein.count(w) for w in
                   (' the ', ' and ', ' with ', ' for ', ' not ',
                    ' invoice', ' amount', ' payable', ' date '))

    if deutsch == 0 and englisch == 0:
        return None
    if deutsch >= englisch * 2:
        return 'de'
    if englisch >= deutsch * 2:
        return 'en'
    return None


class DokumentPipeline(object):
    """Fuehrt Aufbereitung, Erkennung und Einordnung zusammen."""

    def __init__(self, backend=None, kategorisierer=None, aufbereiten=True):
        # Kein Standard-Backend erzwingen: wer nur kategorisieren will,
        # soll das Modul ohne installiertes EasyOCR benutzen koennen.
        self.backend = backend
        self.kategorisierer = kategorisierer or Kategorisierer()
        self.aufbereiten = aufbereiten

    # -- Einzelschritte ---------------------------------------------------

    def bild_laden(self, pfad):
        if cv2 is None:
            raise RuntimeError('OpenCV fehlt: pip install opencv-python')
        bild = cv2.imread(pfad)
        if bild is None:
            raise IOError('Bild konnte nicht gelesen werden: %s' % pfad)
        return bild

    def text_erkennen(self, pfad):
        """Liefert (OcrErgebnis, protokoll)."""
        protokoll = {}

        # PDFs zuerst: steckt der Text schon drin, ist jede Erkennung
        # ueberfluessig -- und das Ergebnis obendrein fehlerfrei.
        if pdf_leser.ist_pdf(pfad):
            if not pdf_leser.pypdf_verfuegbar():
                raise RuntimeError(
                    'PDF erkannt, aber pypdf fehlt: pip install pypdf')
            text, seiten = pdf_leser.text_lesen(pfad)
            protokoll['pdf_seiten'] = seiten
            if text.strip():
                protokoll['pdf_quelle'] = 'eingebetteter Text'
                return backends.OcrErgebnis(text, [(text, 1.0)]), protokoll
            # Kein Text drin -> Scan. Rendern braucht Poppler, das wird
            # hier bewusst nicht vorausgesetzt.
            protokoll['pdf_quelle'] = 'kein Text eingebettet (Scan)'
            raise RuntimeError(
                'PDF enthaelt keinen Text (vermutlich ein Scan). Zum '
                'Erkennen muessen die Seiten gerendert werden -- dafuer '
                'fehlt pdf2image + Poppler.')

        if self.backend is None:
            raise RuntimeError(
                'Kein OCR-Backend gesetzt. Fuer den Normalbetrieb:\n'
                '    from dokument_ocr import ocr_backend\n'
                '    pipeline.backend = ocr_backend.standard_backend()')

        # Backends, die gar kein Bild brauchen (z.B. Textdatei)
        if isinstance(self.backend, (backends.TextDateiBackend,
                                     backends.TestBackend)):
            return self.backend.erkennen(None), protokoll

        bild = self.bild_laden(pfad)
        if self.aufbereiten and bildvorbereitung is not None:
            bild, protokoll = bildvorbereitung.aufbereiten(bild)

        return self.backend.erkennen(bild), protokoll

    # -- Gesamtlauf -------------------------------------------------------

    def verarbeiten(self, pfad):
        """Ein Dokument komplett auswerten. Liefert ein dict."""
        ocr = None
        protokoll = {}
        fehler = None

        try:
            ocr, protokoll = self.text_erkennen(pfad)
            text = ocr.text
        except Exception as e:
            # Ein unlesbares Dokument darf einen Stapellauf nicht abbrechen.
            fehler = '%s: %s' % (type(e).__name__, e)
            text = ''

        ergebnis = self.kategorisierer.kategorisieren(text)

        groesse_kb = None
        if os.path.exists(pfad):
            groesse_kb = int(round(os.path.getsize(pfad) / 1024.0))

        auswertung = {
            'datei': pfad,
            'titel': titel_vorschlagen(pfad, text),
            'ocr_text': text,
            'mime_type': mime_typ(pfad),
            'dateigroesse_kb': groesse_kb,
            'sprache': sprache_raten(text),
            'scan_datum': datetime.now().isoformat(timespec='seconds'),
            'kategorie': ergebnis.schluessel,
            'kategorie_bezeichnung': ergebnis.bezeichnung,
            'kategorie_sicher': ergebnis.sicher,
            'kategorie_punkte': ergebnis.punkte,
            'kategorie_begruendung': ergebnis.begruendung(),
            'ocr_zuversicht': round(ocr.zuversicht, 3) if ocr else 0.0,
            'aufbereitung': protokoll,
            'fehler': fehler,
        }

        # Betrag, Datum, Rechnungsnummer, IBAN, QR-Referenz. Fehlende Werte
        # sind None -- es wird nichts geraten, was nicht im Text steht.
        auswertung.update(extraktion.daten_ziehen(text))
        return auswertung

    def ordner_verarbeiten(self, ordner, endungen=BILD_ENDUNGEN):
        """Alle passenden Dateien eines Ordners. Liefert eine Liste."""
        ergebnisse = []
        for name in sorted(os.listdir(ordner)):
            if not name.lower().endswith(tuple(endungen)):
                continue
            ergebnisse.append(self.verarbeiten(os.path.join(ordner, name)))
        return ergebnisse


def als_json(ergebnis, einrueckung=2):
    """JSON-Text -- das Austauschformat Richtung Delphi."""
    return json.dumps(ergebnis, ensure_ascii=False, indent=einrueckung,
                      default=str)


def nur_text_kategorisieren(text, regelwerk_pfad=None):
    """Abkuerzung fuer bereits vorliegenden Text, ganz ohne OCR."""
    k = Kategorisierer(regelwerk_pfad)
    return k.kategorisieren(text)
