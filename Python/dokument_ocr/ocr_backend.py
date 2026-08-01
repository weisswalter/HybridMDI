# -*- coding: utf-8 -*-
"""Austauschbare Texterkennung.

Warum eine Abstraktion statt EasyOCR direkt:

  * EasyOCR zieht PyTorch nach (rund 2 GB). Das soll nicht Voraussetzung
    dafuer sein, dass sich der Rest des Pakets ueberhaupt importieren oder
    testen laesst.
  * Die Wahl der Bibliothek ist eine Betriebsentscheidung, keine fachliche.
    Faellt sie spaeter anders aus, wird hier eine Klasse ergaenzt und sonst
    nichts geaendert.
  * Fuer Tests braucht es ein Backend, das feste Texte liefert, ohne dass
    irgendetwas installiert sein muss.

Der Import von EasyOCR passiert erst beim ersten Erkennen, nicht beim
Import dieses Moduls. Ein fehlendes EasyOCR faellt damit dort auf, wo es
gebraucht wird, mit einer Meldung, die sagt, was zu tun ist.

Beschlossen wurde EasyOCR (nicht Tesseract), weil es ohne Systeminstallation
auskommt und mit deutschen Umlauten in Scans besser zurechtkommt.
"""

import os


class OcrErgebnis(object):
    """Erkannter Text samt Gutepunkten.

    text      -- der gesamte erkannte Text
    bloecke   -- Liste aus (text, zuversicht) je erkanntem Abschnitt
    zuversicht-- Mittelwert ueber alle Bloecke, 0.0 bis 1.0
    """

    def __init__(self, text, bloecke=None):
        self.text = text
        self.bloecke = bloecke or []

    @property
    def zuversicht(self):
        if not self.bloecke:
            return 0.0
        werte = [z for _, z in self.bloecke if z is not None]
        if not werte:
            return 0.0
        return sum(werte) / float(len(werte))

    def __repr__(self):
        return 'OcrErgebnis(%d Zeichen, Zuversicht %.2f)' % (
            len(self.text), self.zuversicht)


class OcrBackend(object):
    """Schnittstelle, die jedes Backend erfuellen muss."""

    name = 'abstrakt'

    def verfuegbar(self):
        raise NotImplementedError

    def erkennen(self, bild):
        """bild ist ein NumPy-Array. Liefert OcrErgebnis."""
        raise NotImplementedError


class EasyOcrBackend(OcrBackend):
    """EasyOCR. Laedt erst beim ersten Aufruf.

    Das Sprachmodell wird einmalig heruntergeladen und danach zwischen-
    gespeichert; der erste Aufruf dauert deshalb deutlich laenger.
    """

    name = 'easyocr'

    def __init__(self, sprachen=('de', 'en'), gpu=False):
        self.sprachen = list(sprachen)
        self.gpu = gpu
        self._leser = None

    def verfuegbar(self):
        try:
            import easyocr  # noqa: F401
            return True
        except ImportError:
            return False

    def _leser_holen(self):
        if self._leser is None:
            try:
                import easyocr
            except ImportError:
                raise RuntimeError(
                    'EasyOCR ist nicht installiert. Installation:\n'
                    '    pip install easyocr\n'
                    'Achtung: zieht PyTorch nach (~2 GB).')
            # verbose=False ist hier NICHT Kosmetik: EasyOCR zeichnet seinen
            # Fortschrittsbalken mit dem Blockzeichen U+2588. Die Windows-
            # Konsole laeuft unter cp1252 und kann das nicht ausgeben -- der
            # Lauf stirbt dann mit UnicodeEncodeError, obwohl die Erkennung
            # selbst in Ordnung waere. Beim Einbetten in Delphi gibt es
            # ueberdies gar kein brauchbares stdout.
            self._leser = easyocr.Reader(self.sprachen, gpu=self.gpu,
                                         verbose=False)
        return self._leser

    def erkennen(self, bild):
        leser = self._leser_holen()
        # detail=1 liefert (Koordinaten, Text, Zuversicht) je Fund.
        roh = leser.readtext(bild, detail=1)

        bloecke = []
        teile = []
        for eintrag in roh:
            # EasyOCR liefert (koordinaten, text, zuversicht)
            if len(eintrag) >= 3:
                _, text, zuversicht = eintrag[0], eintrag[1], eintrag[2]
            else:  # pragma: no cover - defensiv
                text, zuversicht = eintrag[1], None
            teile.append(text)
            bloecke.append((text, zuversicht))

        return OcrErgebnis('\n'.join(teile), bloecke)


class TextDateiBackend(OcrBackend):
    """Liest den Text aus einer daneben liegenden .txt-Datei.

    Gedacht fuer zwei Faelle: bereits durchsuchbare PDFs, aus denen der Text
    anderswo extrahiert wurde, und die Weiterarbeit an der Kategorisierung,
    ohne jedes Mal die Erkennung laufen zu lassen.
    """

    name = 'textdatei'

    def __init__(self, pfad):
        self.pfad = pfad

    def verfuegbar(self):
        return os.path.exists(self.pfad)

    def erkennen(self, bild=None):
        import io
        with io.open(self.pfad, 'r', encoding='utf-8', errors='replace') as f:
            text = f.read()
        return OcrErgebnis(text, [(text, 1.0)])


class TestBackend(OcrBackend):
    """Liefert vorgegebenen Text. Nur fuer Tests."""

    name = 'test'

    def __init__(self, text='', zuversicht=0.9):
        self.text = text
        self.zuversicht = zuversicht

    def verfuegbar(self):
        return True

    def erkennen(self, bild=None):
        zeilen = [z for z in self.text.split('\n') if z.strip()]
        return OcrErgebnis(self.text, [(z, self.zuversicht) for z in zeilen])


def standard_backend(sprachen=('de', 'en')):
    """Das Backend fuer den Normalbetrieb."""
    return EasyOcrBackend(sprachen=sprachen)
