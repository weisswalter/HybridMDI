# -*- coding: utf-8 -*-
"""Texterkennung und Kategorisierung fuer das Dokumente-Modul.

Zwei Teile, die unabhaengig voneinander benutzbar sind:

  * Kategorisierung -- Text rein, Dokumentart raus. Braucht nichts ausser
    der Standardbibliothek und laeuft damit ueberall.
  * Texterkennung   -- Scan rein, Text raus. Braucht OpenCV (vorhanden)
    und EasyOCR (muss installiert werden, zieht PyTorch nach).

Der Import dieses Pakets zieht EasyOCR NICHT nach. Wer nur kategorisieren
will, kann das ohne jede zusaetzliche Installation.

Schnellstart:

    from dokument_ocr import nur_text_kategorisieren
    e = nur_text_kategorisieren('Rechnung Nr. 4711, zahlbar bis 30.08.')
    print(e.schluessel, e.begruendung())

Kompletter Lauf ueber einen Scan:

    from dokument_ocr import DokumentPipeline, ocr_backend
    p = DokumentPipeline(backend=ocr_backend.standard_backend())
    print(p.verarbeiten(r'C:\\Scans\\beleg.png'))
"""

from .kategorisierung import (
    Kategorisierer,
    Ergebnis,
    UNBEKANNT,
    text_normalisieren,
)
from .pipeline import (
    DokumentPipeline,
    nur_text_kategorisieren,
    als_json,
)
from . import ocr_backend

__all__ = [
    'Kategorisierer',
    'Ergebnis',
    'UNBEKANNT',
    'text_normalisieren',
    'DokumentPipeline',
    'nur_text_kategorisieren',
    'als_json',
    'ocr_backend',
]

__version__ = '0.1.0'
