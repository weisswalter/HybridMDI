# -*- coding: utf-8 -*-
"""Tests der Bildaufbereitung.

Es werden echte Bilder erzeugt und wieder vermessen -- keine Attrappen.
Ein schief gedrehtes Testbild muss hinterher messbar gerader sein als
vorher, sonst taugt das Entzerren nichts.

Braucht OpenCV und NumPy (beides vorhanden). Ohne OpenCV werden die Tests
uebersprungen statt zu scheitern.
"""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)))))

try:
    import cv2
    import numpy as np
    HAT_CV = True
except ImportError:  # pragma: no cover
    HAT_CV = False

if HAT_CV:
    from dokument_ocr import bildvorbereitung as bv


def testseite(breite=1200, hoehe=800, zeilen=12):
    """Weisse Seite mit schwarzen Textzeilen -- Ersatz fuer einen Scan."""
    bild = np.full((hoehe, breite), 255, dtype=np.uint8)
    for i in range(zeilen):
        y = 60 + i * 55
        cv2.putText(bild, 'Rechnung Nr 4711 Betrag CHF 1240.00',
                    (50, y), cv2.FONT_HERSHEY_SIMPLEX, 0.9, 0, 2)
    return bild


def drehen(bild, grad):
    hoehe, breite = bild.shape[:2]
    matrix = cv2.getRotationMatrix2D((breite // 2, hoehe // 2), grad, 1.0)
    return cv2.warpAffine(bild, matrix, (breite, hoehe),
                          flags=cv2.INTER_CUBIC,
                          borderMode=cv2.BORDER_CONSTANT,
                          borderValue=255)


@unittest.skipUnless(HAT_CV, 'OpenCV nicht verfuegbar')
class TestGraustufen(unittest.TestCase):

    def test_farbbild_wird_grau(self):
        farbe = np.zeros((10, 10, 3), dtype=np.uint8)
        self.assertEqual(len(bv.nach_graustufen(farbe).shape), 2)

    def test_graubild_bleibt_unveraendert(self):
        grau = np.zeros((10, 10), dtype=np.uint8)
        self.assertIs(bv.nach_graustufen(grau), grau)

    def test_ohne_bild_gibt_es_einen_fehler(self):
        with self.assertRaises(ValueError):
            bv.nach_graustufen(None)


@unittest.skipUnless(HAT_CV, 'OpenCV nicht verfuegbar')
class TestSchraeglage(unittest.TestCase):

    def test_gerade_seite_misst_nahe_null(self):
        self.assertLess(abs(bv.schraeglage_messen(testseite())), 1.0)

    def test_schraege_seite_wird_erkannt(self):
        schief = drehen(testseite(), -7.0)
        gemessen = bv.schraeglage_messen(schief)
        # Vorzeichen und Groessenordnung muessen stimmen
        self.assertGreater(gemessen, 4.0)
        self.assertLess(gemessen, 10.0)

    def test_leeres_bild_liefert_null(self):
        leer = np.full((100, 100), 255, dtype=np.uint8)
        self.assertEqual(bv.schraeglage_messen(leer), 0.0)


@unittest.skipUnless(HAT_CV, 'OpenCV nicht verfuegbar')
class TestEntzerren(unittest.TestCase):

    def test_schiefes_bild_wird_messbar_gerader(self):
        original = testseite()
        schief = drehen(original, -6.0)

        vorher = abs(bv.schraeglage_messen(schief))
        gerade, winkel = bv.entzerren(schief)
        nachher = abs(bv.schraeglage_messen(bv.nach_graustufen(gerade)))

        self.assertGreater(vorher, 3.0, 'Testbild war gar nicht schief')
        self.assertLess(nachher, 1.5, 'Nach dem Entzerren immer noch schief')
        self.assertLess(nachher, vorher)
        self.assertNotEqual(winkel, 0.0)

    def test_gerades_bild_wird_nicht_angefasst(self):
        gerade = testseite()
        ergebnis, winkel = bv.entzerren(gerade)
        self.assertEqual(winkel, 0.0)
        self.assertIs(ergebnis, gerade)

    def test_zu_starke_schraeglage_wird_nicht_gedreht(self):
        # Ueber max_winkel ist die Messung vermutlich falsch -- dann lieber
        # gar nichts tun, als das Bild zu verschlimmbessern.
        schief = drehen(testseite(), -30.0)
        _, winkel = bv.entzerren(schief, max_winkel=15.0)
        self.assertEqual(winkel, 0.0)


@unittest.skipUnless(HAT_CV, 'OpenCV nicht verfuegbar')
class TestSchattenUndSkalierung(unittest.TestCase):

    def test_schattenausgleich_hebt_dunkle_ecke_an(self):
        bild = testseite()
        # Kuenstlicher Helligkeitsverlauf wie bei schlechter Ausleuchtung
        hoehe, breite = bild.shape
        verlauf = np.linspace(0.35, 1.0, breite, dtype=np.float32)
        abgedunkelt = np.clip(bild * verlauf, 0, 255).astype(np.uint8)

        links_vorher = abgedunkelt[:, :100].mean()
        ausgeglichen = bv.schatten_ausgleichen(abgedunkelt)
        links_nachher = ausgeglichen[:, :100].mean()

        self.assertLess(links_vorher, 150, 'Testbild war nicht dunkel genug')
        self.assertGreater(links_nachher, links_vorher + 40)

    def test_kleines_bild_wird_hochskaliert(self):
        klein = testseite(breite=500, hoehe=300)
        gross, faktor = bv.hochskalieren(klein)
        self.assertGreater(faktor, 1.0)
        self.assertGreaterEqual(gross.shape[1], bv.MINDEST_BREITE)

    def test_grosses_bild_bleibt_unveraendert(self):
        gross = testseite(breite=1600, hoehe=1000)
        ergebnis, faktor = bv.hochskalieren(gross)
        self.assertEqual(faktor, 1.0)
        self.assertIs(ergebnis, gross)


@unittest.skipUnless(HAT_CV, 'OpenCV nicht verfuegbar')
class TestGesamtlauf(unittest.TestCase):

    def test_protokoll_haelt_fest_was_geschah(self):
        schief = drehen(testseite(breite=600, hoehe=400), -5.0)
        ergebnis, protokoll = bv.aufbereiten(schief)

        self.assertEqual(len(ergebnis.shape), 2, 'Ergebnis muss grau sein')
        self.assertNotEqual(protokoll['gedreht_um'], 0.0)
        self.assertGreater(protokoll['skaliert_um'], 1.0)
        self.assertTrue(protokoll['schatten_ausgeglichen'])

    def test_schief_und_schlecht_beleuchtet_wird_trotzdem_gerade(self):
        """Der Fall, der die Reihenfolge in aufbereiten() bestimmt.

        Wird zuerst entzerrt und erst danach der Schatten ausgeglichen,
        misst die Winkelmessung auf dem ungleich beleuchteten Bild 0 Grad
        und das Blatt bleibt schief. Genau das war am 01.08.2026 der Fall.
        """
        seite = testseite()
        schief = drehen(seite, -6.0)

        # Helligkeitsverlauf wie beim Foto eines Belegs
        hoehe, breite = schief.shape
        verlauf = np.linspace(0.35, 1.0, breite, dtype=np.float32)
        schlecht = np.clip(schief * verlauf, 0, 255).astype(np.uint8)

        fertig, protokoll = bv.aufbereiten(schlecht)

        self.assertNotEqual(
            protokoll['gedreht_um'], 0.0,
            'Schraeglage wurde nicht erkannt -- Schatten vor dem Entzerren?')
        rest = abs(bv.schraeglage_messen(fertig))
        self.assertLess(rest, 1.5,
                        'Nach der Aufbereitung immer noch schief: %.2f' % rest)

    def test_einzelne_schritte_abschaltbar(self):
        _, protokoll = bv.aufbereiten(testseite(), entzerrung=False,
                                      schatten=False, skalierung=False)
        self.assertEqual(protokoll['gedreht_um'], 0.0)
        self.assertEqual(protokoll['skaliert_um'], 1.0)
        self.assertFalse(protokoll['schatten_ausgeglichen'])


if __name__ == '__main__':
    unittest.main(verbosity=2)
