# -*- coding: utf-8 -*-
"""Bildaufbereitung vor der Texterkennung.

Der groesste Hebel bei Scans ist nicht die Wahl der OCR-Bibliothek, sondern
das Bild, das man ihr gibt. Schiefe Vorlagen, Schatten aus dem Buchscanner
und zu geringe Aufloesung kosten mehr Erkennungsrate als jede
Parametereinstellung.

Hier passiert deshalb, in dieser Reihenfolge:

  1. Graustufen        -- Farbe hilft der Texterkennung nicht
  2. Schattenausgleich -- ungleichmaessige Ausleuchtung herausrechnen
  3. Entzerren         -- Schraeglage bis etwa +/-15 Grad geradedrehen
  4. Hochskalieren     -- unter ~1000px Breite erkennt jedes OCR schlecht

Die Reihenfolge von 2 und 3 ist nicht beliebig: Die Schraeglagenmessung
arbeitet mit einem Otsu-Schwellwert, und der braucht ein gleichmaessig
ausgeleuchtetes Bild. Bei einem Helligkeitsverlauf -- Buchscanner, Foto vom
Beleg -- wird sonst die halbe Seite als Text gewertet, die Messung liefert
0 Grad und das schiefe Blatt bleibt schief. Genau das ist am 01.08.2026 in
der Vorfuehrung aufgefallen, nachdem die Einzeltests es nicht bemerkt
hatten (dort waren die Testbilder immer sauber ausgeleuchtet).

Jeder Schritt ist einzeln aufrufbar und einzeln testbar. Wer die Pipeline
nicht will, ruft nur das, was er braucht.

Benoetigt OpenCV und NumPy -- beides ist in Walters Umgebung vorhanden,
anders als EasyOCR.
"""

import numpy as np

try:
    import cv2
except ImportError:  # pragma: no cover - nur wenn OpenCV fehlt
    cv2 = None


# Unterhalb dieser Breite lohnt sich Hochskalieren fast immer.
MINDEST_BREITE = 1000
# Groesser als das wird nicht skaliert - kostet nur Zeit.
MAX_FAKTOR = 3.0


def _pruefe_opencv():
    if cv2 is None:
        raise RuntimeError(
            'OpenCV fehlt. Installation: pip install opencv-python')


def nach_graustufen(bild):
    """Farbbild zu Graustufen. Bereits graue Bilder kommen unveraendert zurueck."""
    _pruefe_opencv()
    if bild is None:
        raise ValueError('Kein Bild uebergeben')
    if len(bild.shape) == 2:
        return bild
    return cv2.cvtColor(bild, cv2.COLOR_BGR2GRAY)


def schatten_ausgleichen(grau, kernel=31):
    """Rechnet ungleichmaessige Ausleuchtung heraus.

    Verfahren: Das Bild wird stark weichgezeichnet -- uebrig bleibt der
    Helligkeitsverlauf ohne Text. Teilt man das Original dadurch, bleibt der
    Text und der Verlauf verschwindet. Das ist robuster als eine feste
    Schwelle, weil es sich an jede Stelle des Bildes einzeln anpasst.
    """
    _pruefe_opencv()
    if kernel % 2 == 0:
        kernel += 1  # GaussianBlur verlangt ungerade Kernelgroesse

    hintergrund = cv2.GaussianBlur(grau, (kernel, kernel), 0)
    hintergrund = np.where(hintergrund == 0, 1, hintergrund)

    ausgeglichen = (grau.astype(np.float32) / hintergrund.astype(np.float32))
    ausgeglichen = np.clip(ausgeglichen * 255.0, 0, 255)
    return ausgeglichen.astype(np.uint8)


def schraeglage_messen(grau):
    """Schaetzt die Schraeglage in Grad (positiv = gegen den Uhrzeigersinn).

    Es werden die dunklen Bildpunkte betrachtet und das kleinste umgebende
    Rechteck bestimmt. Dessen Winkel entspricht der Textneigung. Das
    funktioniert bei zusammenhaengendem Flaechentext gut und ist deutlich
    schneller als eine Hough-Transformation.
    """
    _pruefe_opencv()

    # Text dunkel auf hell -> invertieren, damit Text die "Vordergrund"-Punkte
    # sind, die minAreaRect umschliesst.
    _, binaer = cv2.threshold(grau, 0, 255,
                              cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
    punkte = cv2.findNonZero(binaer)
    if punkte is None or len(punkte) < 10:
        return 0.0

    winkel = cv2.minAreaRect(punkte)[-1]

    # OpenCV liefert je nach Version -90..0 oder 0..90. Auf einen Bereich
    # um 0 normieren, sonst dreht man ein fast gerades Bild um 90 Grad.
    if winkel < -45:
        winkel = 90 + winkel
    elif winkel > 45:
        winkel = winkel - 90
    return float(winkel)


def entzerren(bild, max_winkel=15.0):
    """Dreht ein schiefes Dokument gerade.

    Ueber max_winkel wird nicht gedreht: Ein groesserer Messwert deutet eher
    auf ein Fehlmessung (Tabelle, Bild, Rahmen) als auf eine schiefe Vorlage
    hin, und eine falsche Drehung macht das Ergebnis schlechter.
    """
    _pruefe_opencv()
    grau = nach_graustufen(bild)
    winkel = schraeglage_messen(grau)

    if abs(winkel) < 0.2 or abs(winkel) > max_winkel:
        return bild, 0.0

    hoehe, breite = bild.shape[:2]
    mitte = (breite // 2, hoehe // 2)
    matrix = cv2.getRotationMatrix2D(mitte, winkel, 1.0)
    gedreht = cv2.warpAffine(
        bild, matrix, (breite, hoehe),
        flags=cv2.INTER_CUBIC,
        borderMode=cv2.BORDER_REPLICATE)
    return gedreht, winkel


def hochskalieren(bild, mindest_breite=MINDEST_BREITE):
    """Vergroessert kleine Scans, damit die Schrift genug Pixel bekommt."""
    _pruefe_opencv()
    hoehe, breite = bild.shape[:2]
    if breite >= mindest_breite:
        return bild, 1.0

    faktor = min(float(mindest_breite) / float(breite), MAX_FAKTOR)
    neu = cv2.resize(bild, None, fx=faktor, fy=faktor,
                     interpolation=cv2.INTER_CUBIC)
    return neu, faktor


def aufbereiten(bild, entzerrung=True, schatten=True, skalierung=True):
    """Komplette Aufbereitung. Liefert (bild, protokoll).

    Das Protokoll haelt fest, was tatsaechlich gemacht wurde -- bei einem
    schlechten Erkennungsergebnis sieht man so, woran es lag.
    """
    _pruefe_opencv()
    protokoll = {'gedreht_um': 0.0, 'skaliert_um': 1.0,
                 'schatten_ausgeglichen': False}

    # 1. Graustufen
    ergebnis = nach_graustufen(bild)

    # 2. Schatten VOR dem Entzerren: die Winkelmessung braucht ein
    #    gleichmaessig ausgeleuchtetes Bild (siehe Modulkopf).
    if schatten:
        ergebnis = schatten_ausgleichen(ergebnis)
        protokoll['schatten_ausgeglichen'] = True

    # 3. Entzerren
    if entzerrung:
        ergebnis, winkel = entzerren(ergebnis)
        protokoll['gedreht_um'] = round(winkel, 2)

    # 4. Hochskalieren zum Schluss -- vorher waere es nur teurer
    if skalierung:
        ergebnis, faktor = hochskalieren(ergebnis)
        protokoll['skaliert_um'] = round(faktor, 2)

    return ergebnis, protokoll
