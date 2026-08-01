# -*- coding: utf-8 -*-
"""PDF-Text lesen.

Bei PDFs gibt es zwei Sorten, und sie brauchen unterschiedliche Behandlung:

  * **Durchsuchbare PDFs** -- der Text steht als Text darin, etwa weil sie
    aus Word oder einem ERP kommen. Hier braucht es keine Texterkennung,
    nur Auslesen. Das ist schnell, fehlerfrei und der Normalfall bei
    zugesandten Rechnungen.
  * **Gescannte PDFs** -- nur Bilder. Hier fuehrt kein Weg an OCR vorbei,
    und dafuer muessen die Seiten erst gerendert werden.

Dieses Modul kuemmert sich um den ersten Fall und erkennt zuverlaessig,
wann der zweite vorliegt. Das Rendern gescannter Seiten braucht zusaetzlich
Poppler als Systeminstallation und bleibt deshalb bewusst aussen vor --
`ist_durchsuchbar()` sagt vorher, woran man ist.

Benoetigt pypdf. Fehlt es, melden die Funktionen das verstaendlich, statt
beim Import zu scheitern.
"""

import os


# Ab wie vielen Zeichen je Seite gilt ein PDF als durchsuchbar. Scans
# liefern durch Metadaten gelegentlich ein paar Zeichen, aber nie so viele.
MINDEST_ZEICHEN_JE_SEITE = 40


def pypdf_verfuegbar():
    try:
        import pypdf  # noqa: F401
        return True
    except ImportError:
        try:
            import PyPDF2  # noqa: F401
            return True
        except ImportError:
            return False


def _leser_klasse():
    """pypdf bevorzugt, PyPDF2 als Rueckfallebene fuer aeltere Umgebungen."""
    try:
        from pypdf import PdfReader
        return PdfReader
    except ImportError:
        pass
    try:
        from PyPDF2 import PdfReader
        return PdfReader
    except ImportError:
        raise RuntimeError(
            'pypdf ist nicht installiert. Installation:\n'
            '    pip install pypdf\n'
            'Klein und ohne weitere Abhaengigkeiten.')


def ist_pdf(pfad):
    return os.path.splitext(pfad)[1].lower() == '.pdf'


def text_lesen(pfad, max_seiten=None):
    """Text aus einem durchsuchbaren PDF. Liefert (text, seitenzahl).

    Bei einem reinen Scan kommt praktisch leerer Text zurueck -- das ist
    kein Fehler, sondern die Auskunft, dass OCR noetig ist.
    """
    PdfReader = _leser_klasse()
    leser = PdfReader(pfad)

    seiten = leser.pages
    anzahl = len(seiten)
    if max_seiten:
        seiten = seiten[:max_seiten]

    teile = []
    for seite in seiten:
        try:
            teile.append(seite.extract_text() or '')
        except Exception:
            # Eine kaputte Seite darf das ganze Dokument nicht verlieren
            teile.append('')

    return '\n'.join(teile), anzahl


def ist_durchsuchbar(pfad, proben_seiten=3):
    """True, wenn genug echter Text drinsteht -- dann braucht es kein OCR."""
    try:
        text, anzahl = text_lesen(pfad, max_seiten=proben_seiten)
    except Exception:
        return False

    if anzahl == 0:
        return False

    geprueft = min(anzahl, proben_seiten)
    zeichen = len(text.strip())
    return zeichen >= MINDEST_ZEICHEN_JE_SEITE * geprueft


def pdf_auswerten(pfad):
    """Kurzauskunft ueber ein PDF, ohne den ganzen Text zu liefern."""
    ergebnis = {
        'ist_pdf': ist_pdf(pfad),
        'pypdf_da': pypdf_verfuegbar(),
        'seiten': None,
        'durchsuchbar': False,
        'hinweis': None,
    }

    if not ergebnis['ist_pdf']:
        ergebnis['hinweis'] = 'Keine PDF-Datei.'
        return ergebnis

    if not ergebnis['pypdf_da']:
        ergebnis['hinweis'] = 'pypdf fehlt: pip install pypdf'
        return ergebnis

    try:
        text, anzahl = text_lesen(pfad, max_seiten=3)
        ergebnis['seiten'] = anzahl
        geprueft = min(anzahl, 3)
        ergebnis['durchsuchbar'] = (
            anzahl > 0 and
            len(text.strip()) >= MINDEST_ZEICHEN_JE_SEITE * geprueft)
        if ergebnis['durchsuchbar']:
            ergebnis['hinweis'] = 'Text direkt lesbar, keine Erkennung noetig.'
        else:
            ergebnis['hinweis'] = (
                'Kein eingebetteter Text -- vermutlich ein Scan. Zum Erkennen '
                'muessen die Seiten gerendert werden (pdf2image + Poppler).')
    except Exception as e:
        ergebnis['hinweis'] = 'PDF nicht lesbar: %s' % e

    return ergebnis
