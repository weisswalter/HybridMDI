# -*- coding: utf-8 -*-
# ocr_caller.py
# Aufrufschicht der Texterkennung fuer Delphi -- nach dem Muster von
# mail_caller.py.
#
# Delphi ruft auf:
#   import ocr_caller
#   _result = ocr_caller.dokument_lesen('C:\\Scans\\beleg.png')
#   _result = ocr_caller.text_einordnen('Rechnung Nr. 4711 ...')
#
# Rueckgabe ist immer ein JSON-String. Das haelt die Delphi-Seite frei von
# Python-Objekten: dort wird nur geparst, wie beim Mailmodul auch.
#
# Dieses Modul enthaelt bewusst keine Fachlogik -- die steht in
# dokument_ocr\. Hier wird nur durchgereicht und jeder Fehler in eine
# JSON-Antwort verwandelt, damit die Delphi-Seite nie eine Python-Ausnahme
# sieht.

import json
import os
import sys

_here = os.path.dirname(os.path.abspath(__file__))
if _here not in sys.path:
    sys.path.insert(0, _here)

from dokument_ocr import DokumentPipeline, nur_text_kategorisieren  # noqa: E402
from dokument_ocr import ocr_backend  # noqa: E402


# Die Pipeline wird einmal aufgebaut und behalten. Das ist wichtig: EasyOCR
# laedt beim ersten Erkennen sein Sprachmodell, das dauert mehrere Sekunden.
# Bei jedem Aufruf neu zu bauen wuerde das jedes Mal kosten.
_pipeline = None


def _fehler_als_json(e):
    return json.dumps({
        'ok': False,
        'fehler': '%s: %s' % (type(e).__name__, e),
    }, ensure_ascii=False)


def pipeline_holen(sprachen=('de', 'en')):
    global _pipeline
    if _pipeline is None:
        _pipeline = DokumentPipeline(
            backend=ocr_backend.standard_backend(sprachen=sprachen))
    return _pipeline


def ocr_verfuegbar():
    """True, wenn EasyOCR installiert ist.

    Damit kann die Delphi-Seite den Menuepunkt ausgrauen, statt dem Anwender
    erst nach dem Klick eine Fehlermeldung zu zeigen.
    """
    return ocr_backend.EasyOcrBackend().verfuegbar()


def dokument_lesen(pfad):
    """Einen Scan erkennen und einordnen. Liefert JSON."""
    try:
        ergebnis = pipeline_holen().verarbeiten(pfad)
        ergebnis['ok'] = ergebnis.get('fehler') is None
        return json.dumps(ergebnis, ensure_ascii=False, default=str)
    except Exception as e:
        return _fehler_als_json(e)


def ordner_lesen(ordner):
    """Alle Bilddateien eines Ordners. Liefert JSON-Liste."""
    try:
        ergebnisse = pipeline_holen().ordner_verarbeiten(ordner)
        for e in ergebnisse:
            e['ok'] = e.get('fehler') is None
        return json.dumps(ergebnisse, ensure_ascii=False, default=str)
    except Exception as e:
        return _fehler_als_json(e)


def text_einordnen(text):
    """Nur kategorisieren, ohne Bild. Braucht kein EasyOCR.

    Gedacht fuer Dokumente, deren Text schon vorliegt -- durchsuchbare PDFs
    oder E-Mail-Text aus dem Mailmodul.
    """
    try:
        e = nur_text_kategorisieren(text)
        d = e.als_dict()
        d['ok'] = True
        return json.dumps(d, ensure_ascii=False)
    except Exception as ex:
        return _fehler_als_json(ex)


def kategorien_auflisten():
    """Alle bekannten Kategorien -- fuer eine Auswahlliste in der Oberflaeche."""
    try:
        from dokument_ocr import Kategorisierer
        k = Kategorisierer()
        return json.dumps({
            'ok': True,
            'kategorien': [
                {'schluessel': kat['schluessel'],
                 'bezeichnung': kat['bezeichnung']}
                for kat in k.kategorien
            ],
        }, ensure_ascii=False)
    except Exception as e:
        return _fehler_als_json(e)


if __name__ == '__main__':
    # Kleiner Selbsttest von der Kommandozeile:
    #   python ocr_caller.py                     -> Kategorien + Status
    #   python ocr_caller.py "C:\Scans\a.png"    -> Dokument lesen
    if len(sys.argv) > 1:
        print(dokument_lesen(sys.argv[1]))
    else:
        print('EasyOCR verfuegbar:', ocr_verfuegbar())
        print(kategorien_auflisten())
