# -*- coding: utf-8 -*-
"""Harte Daten aus erkanntem Text ziehen: Betrag, Datum, Nummern, IBAN.

Warum das nicht mit einem einfachen "Total: (\\d+)" geht:

Die Texterkennung zerlegt Belege in Fragmente. Aus

    Total inkl. MWST      CHF 1240.00

wird regelmaessig

    Total inkl:. MWST
    CHF 1240.00

-- Schluesselwort und Betrag landen in getrennten Zeilen, und im
Schluesselwort steckt ein Erkennungsfehler. Deshalb wird hier nicht nach
festen Zeilenmustern gesucht, sondern:

  1. ALLE Betraege im Text eingesammelt, mit ihrer Position
  2. jedem Betrag Punkte gegeben, je nachdem welche Schluesselwoerter in
     seiner Naehe stehen ("total", "zahlbar", "mwst" ...)
  3. der Betrag mit der hoechsten Punktzahl gewinnt

Naehe heisst: innerhalb eines Fensters von einigen Zeichen davor und
danach. Das ueberlebt zerrissene Zeilen und Tippfehler im Schluesselwort.

Schweizer Eigenheiten, die bewusst abgedeckt sind:
  * Tausendertrennung mit Hochkomma:  1'240.00
  * QR-Referenz, 27 Stellen, in Fuenferbloecken
  * IBAN in Viererbloecken, CH und LI
  * Datum mit Punkt (12.07.2026), auch zweistelliges Jahr
"""

import re
from datetime import date


# -- Betraege ---------------------------------------------------------------

# 1'240.00 | 1.240,00 | 1240.00 | 1 240.00 | 124
_BETRAG = re.compile(r"""
    (?<![\d.,'])                 # nicht mitten in einer laengeren Zahl
    (\d{1,3}(?:[.'\s]\d{3})+     # mit Tausendertrennung
     (?:[.,]\d{2})?
     |
     \d+[.,]\d{2}                # einfache Dezimalzahl
     |
     \d+                         # ganze Zahl
    )
    (?![\d])
    (?![.,/-]\s*\d)              # kein Datum: '12.07' aus '12.07.2026'
""", re.VERBOSE)

# Was in der Naehe eines Betrags dafuer spricht, dass es der Endbetrag ist
_BETRAG_HINWEISE = [
    (re.compile(r'total|gesamt|endbetrag|rechnungsbetrag|summe'), 5),
    (re.compile(r'zu\s*zahlen|zahlbar|betrag'), 4),
    (re.compile(r'\bchf\b|\beur\b|\bfr\.'), 3),
    (re.compile(r'inkl|brutto'), 2),
    (re.compile(r'mwst|mehrwertsteuer'), 1),
]

# Was dagegen spricht -- Zwischenzeilen, Steuersaetze, Mengen
_BETRAG_ABZUEGE = [
    (re.compile(r'netto|zwischensumme|subtotal'), 3),
    (re.compile(r'menge|stk|stueck|anzahl'), 4),
    (re.compile(r'\bpos\b|position'), 3),
    (re.compile(r'%|prozent|satz'), 3),
    # Zahlungsfristen stehen direkt neben Geldwoertern ("zahlbar bis 30 Tage
    # netto") und sammelten dadurch fast so viele Punkte wie der Endbetrag.
    (re.compile(r'\btage?\b|frist|monate?\b|jahre?\b'), 6),
    # Postleitzahl in der Absenderzeile
    (re.compile(r'\b(ch|de|at|li)\s*-?\s*$|strasse|str\.|gasse|weg\b'), 4),
]

WAEHRUNGEN = ('CHF', 'EUR', 'USD')

# Fenster um einen Betrag. Hinweise duerfen weiter weg stehen, weil die
# Texterkennung Zeilen zerreisst und "Total" dann Zeilen vor dem Betrag
# landet. Abzuege muessen dagegen dicht dabeistehen -- sonst zieht ein
# "30 Tage" zwei Zeilen weiter oben dem Endbetrag die Punkte ab. Genau das
# ist am 01.08.2026 passiert.
_FENSTER_DAVOR = 45
_FENSTER_DANACH = 25
_ABZUG_DAVOR = 14
_ABZUG_DANACH = 12


def _zahl_lesen(text):
    """'1'240.00' -> 1240.0. Liefert None, wenn nichts Sinnvolles drinsteht."""
    roh = text.strip().replace("'", '').replace(' ', '')

    # Deutsches Format 1.240,00 -> Punkt ist Tausender, Komma ist Dezimal
    if ',' in roh and '.' in roh:
        if roh.rfind(',') > roh.rfind('.'):
            roh = roh.replace('.', '').replace(',', '.')
        else:
            roh = roh.replace(',', '')
    elif ',' in roh:
        # Nur Komma: zwei Nachkommastellen -> Dezimal, sonst Tausender
        if re.search(r',\d{2}$', roh):
            roh = roh.replace(',', '.')
        else:
            roh = roh.replace(',', '')
    else:
        # Nur Punkte: mehrere -> Tausendertrennung
        if roh.count('.') > 1:
            roh = roh.replace('.', '')

    try:
        return float(roh)
    except ValueError:
        return None


def betraege_finden(text):
    """Alle Betraege mit Bewertung. Liefert Liste von dicts, beste zuerst."""
    if not text:
        return []

    klein = text.lower()
    gefunden = []

    for treffer in _BETRAG.finditer(text):
        wert = _zahl_lesen(treffer.group(1))
        if wert is None:
            continue

        start, ende = treffer.span()
        umfeld = klein[max(0, start - _FENSTER_DAVOR):ende + _FENSTER_DANACH]
        nahfeld = klein[max(0, start - _ABZUG_DAVOR):ende + _ABZUG_DANACH]

        punkte = 0
        gruende = []
        for muster, gewicht in _BETRAG_HINWEISE:
            if muster.search(umfeld):
                punkte += gewicht
                gruende.append('+%d %s' % (gewicht, muster.pattern.split('|')[0]))
        for muster, abzug in _BETRAG_ABZUEGE:
            if muster.search(nahfeld):
                punkte -= abzug
                gruende.append('-%d %s' % (abzug, muster.pattern.split('|')[0]))

        # Zwei Nachkommastellen sprechen fuer einen Geldbetrag, eine nackte
        # ganze Zahl ist meist eine Menge oder eine Positionsnummer.
        if re.search(r"[.,]\d{2}$", treffer.group(1)):
            punkte += 2
        else:
            punkte -= 1

        waehrung = None
        for w in WAEHRUNGEN:
            if w.lower() in umfeld:
                waehrung = w
                break

        gefunden.append({
            'wert': wert,
            'text': treffer.group(1),
            'waehrung': waehrung,
            'punkte': punkte,
            'begruendung': ', '.join(gruende) if gruende else 'kein Hinweis',
            'position': start,
        })

    # Bei Gleichstand gewinnt der groessere Betrag: der Endbetrag ist auf
    # einer Rechnung praktisch nie kleiner als eine einzelne Position.
    gefunden.sort(key=lambda b: (b['punkte'], b['wert']), reverse=True)
    return gefunden


def betrag_finden(text):
    """Der wahrscheinlichste Endbetrag, oder None."""
    alle = betraege_finden(text)
    if not alle:
        return None
    bester = alle[0]
    # Ohne jeden Hinweis lieber nichts behaupten, als eine Zufallszahl
    # in einen Beleg zu schreiben.
    if bester['punkte'] <= 0:
        return None
    return bester


# -- Datum ------------------------------------------------------------------

_DATUM_MUSTER = [
    # 12.07.2026 / 12.7.26 / 12-07-2026 / 12/07/2026
    (re.compile(r'\b(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{2,4})\b'), 'tmj'),
    # 2026-07-12
    (re.compile(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b'), 'jmt'),
]

_DATUM_HINWEISE = [
    # Das Belegdatum muss deutlich schwerer wiegen als irgendein Datum.
    # Ohne Wortgrenze traf 'datum' auch in 'Lieferdatum', beide Kandidaten
    # bekamen gleich viele Punkte und das zuerst genannte gewann -- also
    # das falsche.
    (re.compile(r'rechnungs-?datum|beleg-?datum'), 5),
    (re.compile(r'\bdatum\b|\bvom\b'), 2),
    (re.compile(r'zahlbar|faellig|valuta'), 1),
]


def _datum_bauen(a, b, c, reihenfolge):
    try:
        if reihenfolge == 'tmj':
            tag, monat, jahr = int(a), int(b), int(c)
            if jahr < 100:
                jahr += 2000 if jahr < 70 else 1900
        else:
            jahr, monat, tag = int(a), int(b), int(c)
        return date(jahr, monat, tag)
    except ValueError:
        return None


def datum_finden(text):
    """Wahrscheinlichstes Belegdatum als date, oder None."""
    if not text:
        return None

    klein = text.lower()
    kandidaten = []

    for muster, reihenfolge in _DATUM_MUSTER:
        for treffer in muster.finditer(text):
            d = _datum_bauen(treffer.group(1), treffer.group(2),
                             treffer.group(3), reihenfolge)
            if d is None:
                continue
            # Offensichtlich unsinnige Jahre aussortieren
            if not (1990 <= d.year <= 2100):
                continue

            start = treffer.start()
            umfeld = klein[max(0, start - 40):treffer.end() + 10]
            punkte = 0
            for hinweis, gewicht in _DATUM_HINWEISE:
                if hinweis.search(umfeld):
                    punkte += gewicht
            kandidaten.append((punkte, -start, d))

    if not kandidaten:
        return None
    # Bei Gleichstand das zuerst genannte Datum -- Belegkoepfe stehen oben.
    kandidaten.sort(reverse=True)
    return kandidaten[0][2]


# -- Nummern ----------------------------------------------------------------

_IBAN = re.compile(r'\b([A-Z]{2}\d{2}(?:[ ]?[A-Z0-9]{4}){2,7}[ ]?[A-Z0-9]{1,4})\b')
_QR_REFERENZ = re.compile(r'\b(\d{2}(?:[ ]?\d{5}){5})\b')
# Zwischen Schluesselwort und Nummer steht fast immer noch "Nr." -- das ist
# selbst ein Wort und darf deshalb nicht ueber [^\w] abgedeckt werden, sonst
# greift das Muster bei "RECHNUNG Nr. 2026-4711" nicht.
_RECHNUNGSNR = re.compile(
    r'(?:rechnung|beleg|invoice)s?'
    r'\s*(?:-?\s*nr\.?|nummer|no\.?)?'
    r'\s*[:.\-]?\s*'
    r'([A-Z0-9][A-Z0-9\-/]{2,20})', re.IGNORECASE)


def iban_finden(text):
    """Erste IBAN im Text, ohne Leerzeichen. Prueft die Laenge grob."""
    if not text:
        return None
    for treffer in _IBAN.finditer(text.upper()):
        roh = treffer.group(1).replace(' ', '')
        # CH und LI haben 21 Zeichen; alles zwischen 15 und 34 ist plausibel
        if 15 <= len(roh) <= 34:
            return roh
    return None


def qr_referenz_finden(text):
    """Schweizer QR-Referenz (27 Stellen) ohne Leerzeichen."""
    if not text:
        return None
    treffer = _QR_REFERENZ.search(text)
    if not treffer:
        return None
    roh = treffer.group(1).replace(' ', '')
    return roh if len(roh) == 27 else None


def rechnungsnummer_finden(text):
    """Nummer, die auf ein Schluesselwort wie 'Rechnung Nr.' folgt."""
    if not text:
        return None
    treffer = _RECHNUNGSNR.search(text)
    if not treffer:
        return None
    nummer = treffer.group(1).strip(' .,;:-/')
    # Reine Wortfolgen aussortieren ("Rechnung Nr. wurde ...")
    if not any(c.isdigit() for c in nummer):
        return None
    return nummer


# -- Gesamtauswertung -------------------------------------------------------

def daten_ziehen(text):
    """Alles auf einmal. Liefert ein dict, fehlende Werte sind None."""
    betrag = betrag_finden(text)
    datum = datum_finden(text)

    return {
        'betrag': betrag['wert'] if betrag else None,
        'betrag_waehrung': betrag['waehrung'] if betrag else None,
        'betrag_punkte': betrag['punkte'] if betrag else 0,
        'betrag_begruendung': betrag['begruendung'] if betrag else None,
        'datum': datum.isoformat() if datum else None,
        'rechnungsnummer': rechnungsnummer_finden(text),
        'iban': iban_finden(text),
        'qr_referenz': qr_referenz_finden(text),
    }
