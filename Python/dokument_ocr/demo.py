# -*- coding: utf-8 -*-
"""Vorfuehrung ohne Installation: zeigt, was das Paket kann.

Aufruf aus dem Ordner Python\\:

    python -m dokument_ocr.demo

Es wird nichts installiert und nichts in die Datenbank geschrieben. Die
Bildaufbereitung laeuft an einem erzeugten Testscan, die Kategorisierung an
Beispieltexten. Die eigentliche Texterkennung braucht EasyOCR und wird
uebersprungen, solange es fehlt.
"""

from __future__ import print_function

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dokument_ocr import Kategorisierer, ocr_backend            # noqa: E402
from dokument_ocr.pipeline import DokumentPipeline, sprache_raten  # noqa: E402


BEISPIELE = [
    ('Rechnung', """
        Muster AG, 9658 Wildhaus
        RECHNUNG Nr. 2026-4711
        Rechnungsdatum: 12.07.2026
        Zahlbar bis 30 Tage netto
        Total inkl. MWST      CHF 1'240.00
     """),
    ('Schweizer QR-Rechnung', """
        Empfangsschein                    Zahlteil
        Konto / Zahlbar an
        CH44 3199 9123 0008 8901 2
        Referenz 21 00000 00003 13947 14300 09017
        Waehrung  CHF        Betrag  199.95
        Annahmestelle
     """),
    ('Mahnung', """
        2. Mahnung
        Trotz unserer Rechnung vom 12.05.2026 konnten wir bisher keinen
        Zahlungseingang feststellen. Mahngebuehr CHF 20.00, Verzugszins 5%.
     """),
    ('Lohnabrechnung', """
        Lohnabrechnung Juli 2026
        Bruttolohn        6'500.00
        AHV/IV/EO          -344.50
        Pensionskasse BVG  -420.00
        Nettolohn         5'664.00
     """),
    ('Kursunterlage', """
        Grundkurs Metallbearbeitung
        Lernziele der Module
        Unterkurs: Digitale Grundkompetenzen
        Teilnehmerliste siehe Anhang
     """),
    ('Einkaufszettel (soll nicht erkannt werden)', """
        Milch, Brot, Butter, Kaffee
     """),
]


def trennlinie(titel):
    print()
    print('=' * 70)
    print(titel)
    print('=' * 70)


def kategorien_zeigen():
    trennlinie('1. Kategorisierung (braucht keinerlei Installation)')
    k = Kategorisierer()
    print('Regelwerk: %s' % os.path.basename(k.regelwerk_pfad))
    print('Bekannte Kategorien: %s' % ', '.join(k.schluessel_liste()))
    print()

    for name, text in BEISPIELE:
        e = k.kategorisieren(text)
        marke = 'OK ' if e.sicher else '?? '
        print('%s%-42s -> %-16s (%d Punkte)'
              % (marke, name, e.schluessel, e.punkte))
        print('       %s' % e.begruendung())
        sprache = sprache_raten(text)
        if sprache:
            print('       Sprache: %s' % sprache)
        print()


def bildaufbereitung_zeigen():
    trennlinie('2. Bildaufbereitung (braucht OpenCV -- vorhanden)')
    try:
        import cv2
        import numpy as np
        from dokument_ocr import bildvorbereitung as bv
    except ImportError as e:
        print('Uebersprungen, OpenCV fehlt: %s' % e)
        return

    # Testscan bauen: Seite mit Text, schief gedreht und ungleich beleuchtet
    seite = np.full((800, 1200), 255, dtype=np.uint8)
    for i in range(12):
        cv2.putText(seite, 'Rechnung Nr 4711 Betrag CHF 1240.00',
                    (50, 60 + i * 55), cv2.FONT_HERSHEY_SIMPLEX, 0.9, 0, 2)

    matrix = cv2.getRotationMatrix2D((600, 400), -6.0, 1.0)
    schief = cv2.warpAffine(seite, matrix, (1200, 800),
                            borderMode=cv2.BORDER_CONSTANT, borderValue=255)
    verlauf = np.linspace(0.35, 1.0, 1200, dtype=np.float32)
    schlecht = np.clip(schief * verlauf, 0, 255).astype(np.uint8)

    print('Testscan: 6 Grad schief, linke Seite abgedunkelt')
    print('  Helligkeit links/rechts : %.0f / %.0f'
          % (schlecht[:, :100].mean(), schlecht[:, -100:].mean()))
    print('  Winkelmessung roh       : %+.2f Grad  <- falsch! Der'
          % bv.schraeglage_messen(schlecht))
    print('     Helligkeitsverlauf verdirbt den Schwellwert; die halbe')
    print('     Seite gilt als Text. Deshalb wird der Schatten ZUERST')
    print('     ausgeglichen und erst danach entzerrt.')

    nur_hell = bv.schatten_ausgleichen(schlecht)
    print('  Winkelmessung danach    : %+.2f Grad  <- so stimmt es'
          % bv.schraeglage_messen(nur_hell))

    fertig, protokoll = bv.aufbereiten(schlecht)

    print('  --> vollstaendig aufbereitet')
    print('  Restschraeglage         : %+.2f Grad'
          % bv.schraeglage_messen(fertig))
    print('  Helligkeit links/rechts : %.0f / %.0f'
          % (fertig[:, :100].mean(), fertig[:, -100:].mean()))
    print('  Protokoll               : %s' % protokoll)


def gesamtlauf_zeigen():
    trennlinie('3. Gesamtlauf (Texterkennung braucht EasyOCR)')

    verfuegbar = ocr_backend.EasyOcrBackend().verfuegbar()
    print('EasyOCR installiert: %s' % ('ja' if verfuegbar else 'nein'))

    if not verfuegbar:
        print()
        print('Der Lauf wird mit einem Ersatz-Backend gezeigt, das einen')
        print('festen Text liefert -- so sieht die Rueckgabe spaeter aus:')

    backend = (ocr_backend.standard_backend() if verfuegbar
               else ocr_backend.TestBackend(BEISPIELE[0][1]))
    p = DokumentPipeline(backend=backend)

    # Ohne echte Datei: nur der Kategorisierungsteil des Ergebnisses
    ergebnis = p.verarbeiten('beispiel_rechnung.png')
    print()
    for feld in ('titel', 'kategorie', 'kategorie_bezeichnung',
                 'kategorie_sicher', 'sprache', 'mime_type',
                 'ocr_zuversicht', 'fehler'):
        print('  %-22s %s' % (feld + ':', ergebnis.get(feld)))


def hinweise():
    trennlinie('Naechste Schritte')
    print("""\
Damit die Texterkennung echte Scans liest:

    pip install easyocr          (zieht PyTorch nach, ~2 GB)

Danach liest

    python ocr_caller.py "C:\\Scans\\beleg.png"

ein Dokument und liefert JSON -- dieselbe Form, die die Delphi-Seite
auswertet.

Kategorien anpassen: dokument_ocr\\kategorien.json bearbeiten. Neue Regeln
brauchen keinen Codeeingriff. Nach einer Aenderung:

    python -m unittest discover -s dokument_ocr\\tests
""")


def main():
    print('Dokument-Texterkennung und Kategorisierung -- Vorfuehrung')
    kategorien_zeigen()
    bildaufbereitung_zeigen()
    gesamtlauf_zeigen()
    hinweise()


if __name__ == '__main__':
    main()
