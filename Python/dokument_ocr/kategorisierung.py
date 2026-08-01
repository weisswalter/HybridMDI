# -*- coding: utf-8 -*-
"""Regelbasierte Kategorisierung von erkanntem Dokumenttext.

Bewusst regelbasiert und nicht mit einem Modell:

  * Es gibt noch keine gelabelten Dokumente, mit denen sich etwas trainieren
    liesse. Regeln liefern ab dem ersten Dokument ein Ergebnis.
  * Das Ergebnis ist nachvollziehbar. Bei einer Fehlzuordnung sieht man in
    der Begruendung, welches Muster gegriffen hat, und korrigiert die Regel.
  * Die Regeln stehen in kategorien.json, also ausserhalb des Codes.

Wenn spaeter genuegend gepruefte Dokumente vorliegen, kann ein Modell
danebengestellt werden -- die Schnittstelle (Text rein, Kategorie raus)
bleibt dieselbe.

OCR-Text ist fehlerbehaftet. Deshalb wird vor dem Pruefen normalisiert:
Umlaute vereinheitlicht, typische Verwechslungen entschaerft und Trennstriche
am Zeilenende zusammengefuegt.
"""

import io
import json
import os
import re
import unicodedata

_HIER = os.path.dirname(os.path.abspath(__file__))
STANDARD_REGELWERK = os.path.join(_HIER, 'kategorien.json')

# Wird zurueckgegeben, wenn kein Muster seinen Mindestwert erreicht.
UNBEKANNT = 'unbekannt'


class Treffer(object):
    """Ein einzelnes Muster, das im Text angeschlagen hat."""

    def __init__(self, regex, gewicht, fundstelle):
        self.regex = regex
        self.gewicht = gewicht
        self.fundstelle = fundstelle

    def __repr__(self):
        return 'Treffer(%r, gewicht=%d, fundstelle=%r)' % (
            self.regex, self.gewicht, self.fundstelle)


class Ergebnis(object):
    """Auswertung eines Dokuments.

    schluessel  -- erkannte Kategorie oder UNBEKANNT
    punkte      -- Punktzahl der Siegerkategorie
    sicher      -- True, wenn der Mindestwert erreicht wurde
    alle_punkte -- Punktzahl je Kategorie, fuer Diagnose
    treffer     -- welche Muster gegriffen haben, fuer die Begruendung
    """

    def __init__(self, schluessel, bezeichnung, punkte, sicher,
                 alle_punkte, treffer):
        self.schluessel = schluessel
        self.bezeichnung = bezeichnung
        self.punkte = punkte
        self.sicher = sicher
        self.alle_punkte = alle_punkte
        self.treffer = treffer

    def begruendung(self):
        """Klartext, warum diese Kategorie gewonnen hat."""
        if not self.treffer:
            return 'Kein Muster hat angeschlagen.'
        teile = ['%r (+%d)' % (t.fundstelle, t.gewicht) for t in self.treffer]
        return 'Erkannt an: ' + ', '.join(teile)

    def als_dict(self):
        return {
            'schluessel': self.schluessel,
            'bezeichnung': self.bezeichnung,
            'punkte': self.punkte,
            'sicher': self.sicher,
            'begruendung': self.begruendung(),
            'alle_punkte': self.alle_punkte,
        }

    def __repr__(self):
        return 'Ergebnis(%s, punkte=%d, sicher=%s)' % (
            self.schluessel, self.punkte, self.sicher)


def text_normalisieren(text):
    """Macht OCR-Text fuer den Mustervergleich vergleichbar.

    Bewusst *nicht* aggressiv: es wird nichts geraten, nur vereinheitlicht.
    """
    if not text:
        return ''

    text = text.lower()

    # Am Zeilenende getrennte Woerter zusammenziehen ("rech-\nnung").
    text = re.sub(r'-\s*\n\s*', '', text)

    # Zeilenumbrueche zu Leerzeichen, damit Muster ueber Zeilen greifen.
    text = re.sub(r'\s+', ' ', text)

    # Umlaute vereinheitlichen. Die Muster in kategorien.json schreiben
    # "gruessen"/"ue", damit sie unabhaengig von der OCR-Qualitaet greifen.
    ersetzungen = {
        'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss',
    }
    for alt, neu in ersetzungen.items():
        text = text.replace(alt, neu)

    # Kombinierende Akzente entfernen, die OCR gelegentlich erzeugt.
    text = unicodedata.normalize('NFKD', text)
    text = ''.join(c for c in text if not unicodedata.combining(c))

    return text


class Kategorisierer(object):
    """Wendet das Regelwerk aus kategorien.json auf Text an."""

    def __init__(self, regelwerk_pfad=None):
        self.regelwerk_pfad = regelwerk_pfad or STANDARD_REGELWERK
        self.kategorien = []
        self._laden()

    def _laden(self):
        with io.open(self.regelwerk_pfad, 'r', encoding='utf-8') as f:
            daten = json.load(f)

        for eintrag in daten.get('kategorien', []):
            muster = []
            for m in eintrag.get('muster', []):
                # Bereits hier uebersetzen: ein Tippfehler in der Regeldatei
                # soll beim Start auffallen, nicht erst beim ersten Dokument.
                muster.append((
                    re.compile(m['regex'], re.IGNORECASE),
                    m['regex'],
                    int(m.get('gewicht', 1)),
                ))
            self.kategorien.append({
                'schluessel': eintrag['schluessel'],
                'bezeichnung': eintrag.get('bezeichnung', eintrag['schluessel']),
                'mindestwert': int(eintrag.get('mindestwert', 1)),
                'muster': muster,
            })

    def schluessel_liste(self):
        return [k['schluessel'] for k in self.kategorien]

    def kategorisieren(self, text):
        """Liefert ein Ergebnis-Objekt fuer den uebergebenen Text."""
        normalisiert = text_normalisieren(text)

        alle_punkte = {}
        bester = None
        beste_punkte = -1
        beste_treffer = []

        for kategorie in self.kategorien:
            punkte = 0
            treffer = []
            for regex, quelltext, gewicht in kategorie['muster']:
                fund = regex.search(normalisiert)
                if fund:
                    punkte += gewicht
                    treffer.append(Treffer(quelltext, gewicht, fund.group(0)))

            alle_punkte[kategorie['schluessel']] = punkte

            # Bei Gleichstand gewinnt die Kategorie, die weiter oben in der
            # Regeldatei steht -- deshalb echtes Groesser statt Groessergleich.
            if punkte > beste_punkte:
                beste_punkte = punkte
                bester = kategorie
                beste_treffer = treffer

        if bester is None or beste_punkte < bester['mindestwert']:
            return Ergebnis(UNBEKANNT, 'Unbekannt', beste_punkte if bester else 0,
                            False, alle_punkte,
                            beste_treffer if bester else [])

        return Ergebnis(bester['schluessel'], bester['bezeichnung'],
                        beste_punkte, True, alle_punkte, beste_treffer)
