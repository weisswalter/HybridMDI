# -*- coding: utf-8 -*-
"""
Augensteuerung (Eye-Tracking-Mauszeiger) — Webcam-basiert, kein Spezial-Hardware.

Idee: MediaPipe FaceMesh liefert Iris-Landmarks aus dem Webcam-Bild. Nach
einer kurzen 4-Punkt-Kalibrierung (Bildschirmecken ansehen) wird die
Iris-Position per Homographie auf Bildschirmkoordinaten abgebildet und der
Windows-Mauszeiger bewegt. Ein bewusstes Blinzeln (beide Augen, ~0.3s) loest
einen Linksklick aus.

Eigenstaendig lauffaehig — keine Delphi-Integration noetig, steuert den
echten System-Cursor und funktioniert damit sofort auch in Heisenberg
selbst (oder jeder anderen Anwendung). Fuer den Pitch: einfach parallel zu
Heisenberg laufen lassen und mit den Augen durch die GUI navigieren.

Aufruf:  python eye_mouse_control.py
Tasten waehrend des Laufs (Fokus auf dem Vorschau-Fenster):
  c   = Kalibrierung neu starten
  p   = Steuerung pausieren/fortsetzen (Cursor bleibt dann in Ruhe)
  q   = Beenden

NOTAUS: ESC-Taste beendet das Programm IMMER, unabhaengig davon, welches
Fenster gerade den Tastaturfokus hat (per GetAsyncKeyState global abgefragt,
nicht ueber cv2.waitKey). Wichtig, weil ein Blinzel-Klick ausserhalb des
Vorschau-Fensters (z.B. in Heisenberg) diesem Fenster den Fokus gibt — dann
wuerden q/p/c nicht mehr ankommen, waehrend der Cursor weiter automatisch
bewegt/klickt. ESC greift trotzdem.
"""

import ctypes
import os
import sys
import time

import cv2
import numpy as np
import mediapipe as mp
from mediapipe.tasks import python as mp_python
from mediapipe.tasks.python import vision as mp_vision
import win32api
import win32con

MODEL_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                          "models", "face_landmarker.task")

# ── Konstanten ──────────────────────────────────────────────────────────────

# MediaPipe FaceMesh Iris-Landmarks (bei refine_landmarks=True aktiv).
# Je 4 Punkte auf dem Iris-Rand; Mittelpunkt = Durchschnitt der 4 Punkte.
LEFT_IRIS = [474, 475, 476, 477]
RIGHT_IRIS = [469, 470, 471, 472]

# Augen-Eckpunkte fuer den Blinzel-Erkenner (Eye Aspect Ratio).
LEFT_EYE_H = (33, 133)     # aussen, innen
LEFT_EYE_V = (159, 145)    # oberes, unteres Lid
RIGHT_EYE_H = (362, 263)
RIGHT_EYE_V = (386, 374)

BLINK_MIN_FRAMES = 3           # so viele Frames am Stueck geschlossen = Blinzeln
BLINK_COOLDOWN_SEC = 0.6       # Sperre nach einem ausgeloesten Klick

SMOOTHING_ALPHA = 0.3          # Exponentielle Glaettung des Cursors (0..1) — hoeher = spontaner, aber zittriger
CALIB_SAMPLE_FRAMES = 40       # Frames pro Kalibrierpunkt, die gemittelt werden

# Verstaerkung um die Bildschirmmitte: bei der eigentlichen Nutzung bewegen
# sich Kopf/Augen meist WENIGER als beim bewussten Anschauen der Ecken
# waehrend der Kalibrierung. Ohne Verstaerkung bleibt der Cursor dann in der
# Bildschirmmitte "kleben".
#
# NACH OBEN schauen dreht den Kopf kaum mit (anatomisch eingeschraenkt) —
# der bei der Kalibrierung erfasste Bewegungsbereich ist dort deshalb
# kleiner als nach unten/links/rechts. Eine einheitliche Verstaerkung reicht
# fuer "oben" nicht aus (Cursor kommt nur bis zur Bildschirmmitte), waere
# aber fuer "unten" (das bereits bis zur Taskleiste funktioniert) zu viel.
# Deshalb getrennte Verstaerkung je nach Richtung von der Mitte aus.
GAIN_X = 1.25         # horizontal (bisher unauffaellig)
GAIN_DOWN = 1.25      # nach unten — funktioniert bereits gut, unveraendert
GAIN_UP = 2.2         # nach oben — deutlich staerker, kleinerer Kalibrierbereich

# Bremse gegen ruckartige Spruenge: maximale Cursor-Bewegung (Pixel) pro
# Frame. Landmark-Rauschen erzeugt gelegentlich einzelne Ausreisser-Frames;
# ohne Deckel schlagen die 1:1 als sichtbares Zittern/Sprung durch.
MAX_STEP_PX = 45

# ── Hilfsfunktionen ─────────────────────────────────────────────────────────

def panic_key_pressed():
    """Prueft die ESC-Taste GLOBAL ueber GetAsyncKeyState — unabhaengig davon,
    welches Fenster den Tastaturfokus hat. Im Gegensatz zu cv2.waitKey (das
    nur Tasten sieht, wenn das cv2-Fenster fokussiert ist) funktioniert das
    immer, auch wenn ein Blinzel-Klick den Fokus an ein anderes Fenster
    (z.B. Heisenberg) abgegeben hat."""
    # High-Bit gesetzt = Taste ist gerade gedrueckt
    return bool(win32api.GetAsyncKeyState(win32con.VK_ESCAPE) & 0x8000)


def get_screen_size():
    w = win32api.GetSystemMetrics(win32con.SM_CXSCREEN)
    h = win32api.GetSystemMetrics(win32con.SM_CYSCREEN)
    return w, h


def eye_aspect_ratio(landmarks, h_pts, v_pts, frame_w, frame_h):
    def px(idx):
        lm = landmarks[idx]
        return np.array([lm.x * frame_w, lm.y * frame_h])

    horiz = np.linalg.norm(px(h_pts[0]) - px(h_pts[1]))
    vert = np.linalg.norm(px(v_pts[0]) - px(v_pts[1]))
    if horiz < 1e-6:
        return 1.0
    return vert / horiz


def iris_center(landmarks, indices, frame_w, frame_h):
    pts = np.array([[landmarks[i].x * frame_w, landmarks[i].y * frame_h] for i in indices])
    return pts.mean(axis=0)


def click_left():
    win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
    time.sleep(0.03)
    win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)


# ── Kalibrierung ────────────────────────────────────────────────────────────

def detect_landmarks(landmarker, frame):
    """Ein Frame durch den FaceLandmarker jagen (Tasks-API, VIDEO-Modus
    braucht monoton steigende Zeitstempel in ms). Liefert die Landmark-Liste
    des ersten erkannten Gesichts oder None."""
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)
    ts_ms = int(time.time() * 1000)
    result = landmarker.detect_for_video(mp_image, ts_ms)
    if result.face_landmarks:
        return result.face_landmarks[0]
    return None


def run_calibration(cap, landmarker, screen_w, screen_h):
    """4-Punkt-Kalibrierung (Bildschirmecken). Liefert (Homographie,
    Blinzel-Schwelle) oder None, falls abgebrochen.

    Die Blinzel-Schwelle wird NICHT fest verdrahtet, sondern aus den
    waehrend der Kalibrierung gemessenen EAR-Werten bei offenen Augen
    abgeleitet (75% des Mittelwerts) — ein Test mit echter Webcam zeigte,
    dass ein fixer Schwellenwert (0.19) mitten in der normalen Streuung
    offener Augen liegen kann (variiert mit Kamera/Lichtverhaeltnissen/
    Gesicht) und dann staendig Fehlklicks ausloest.
    """

    margin = 60
    targets = [
        (margin, margin),
        (screen_w - margin, margin),
        (screen_w - margin, screen_h - margin),
        (margin, screen_h - margin),
    ]

    win_name = "Kalibrierung — auf den roten Punkt schauen"
    cv2.namedWindow(win_name, cv2.WND_PROP_FULLSCREEN)
    cv2.setWindowProperty(win_name, cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)

    iris_points = []
    ear_samples = []
    for tx, ty in targets:
        samples = []
        frame_count = 0
        while frame_count < CALIB_SAMPLE_FRAMES:
            ok, frame = cap.read()
            if not ok:
                continue
            frame = cv2.flip(frame, 1)
            lm = detect_landmarks(landmarker, frame)

            canvas = np.zeros((screen_h, screen_w, 3), dtype=np.uint8)
            cv2.circle(canvas, (tx, ty), 22, (0, 0, 255), -1)
            cv2.putText(canvas, "Punkt anschauen — Kopf ruhig, aber leicht mitdrehen erlaubt", (40, 40),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.9, (255, 255, 255), 2)
            cv2.imshow(win_name, canvas)

            if lm is not None:
                fh, fw = frame.shape[0], frame.shape[1]
                left = iris_center(lm, LEFT_IRIS, fw, fh)
                right = iris_center(lm, RIGHT_IRIS, fw, fh)
                samples.append((left + right) / 2.0)

                ear_l = eye_aspect_ratio(lm, LEFT_EYE_H, LEFT_EYE_V, fw, fh)
                ear_r = eye_aspect_ratio(lm, RIGHT_EYE_H, RIGHT_EYE_V, fw, fh)
                ear_samples.append((ear_l + ear_r) / 2.0)
                frame_count += 1

            key = cv2.waitKey(1) & 0xFF
            if key == 27 or key == ord('q') or panic_key_pressed():
                # ESC (auch global per GetAsyncKeyState) oder q bricht ab —
                # unabhaengig davon, ob das Fenster gerade den Fokus hat.
                cv2.destroyWindow(win_name)
                return None

        if not samples:
            cv2.destroyWindow(win_name)
            print("Kalibrierung fehlgeschlagen: kein Gesicht erkannt.")
            return None
        iris_points.append(np.mean(samples, axis=0))

    cv2.destroyWindow(win_name)

    src = np.array(iris_points, dtype=np.float32)
    dst = np.array(targets, dtype=np.float32)
    homography, _ = cv2.findHomography(src, dst)

    open_eye_baseline = float(np.mean(ear_samples))
    blink_threshold = open_eye_baseline * 0.75
    print(f"Offene-Augen-EAR-Basiswert: {open_eye_baseline:.3f} "
          f"-> Blinzel-Schwelle: {blink_threshold:.3f}")

    return homography, blink_threshold


# ── Hauptschleife ────────────────────────────────────────────────────────────

def make_dpi_aware():
    """Muss VOR jedem GetSystemMetrics/SetCursorPos-Aufruf passieren. Ohne
    das meldet Windows bei aktivierter Anzeigeskalierung (z.B. 125%) eine
    virtualisierte, zu KLEINE Aufloesung (bei Walter: 1536x864 statt echter
    1920x1080), waehrend SetCursorPos-Koordinaten dann nicht mehr eindeutig
    auf die reale Anzeige passen — sichtbar als "haengt in einer Ecke" und
    "Cursor verschwindet gelegentlich", weil er auf Koordinaten landet, die
    fuer die skalierte Ansicht ausserhalb liegen."""
    try:
        ctypes.windll.shcore.SetProcessDpiAwareness(2)  # PER_MONITOR_DPI_AWARE
    except Exception:
        try:
            ctypes.windll.user32.SetProcessDPIAware()   # Fallback, aeltere Windows-Versionen
        except Exception:
            print("WARNUNG: DPI-Awareness konnte nicht gesetzt werden — "
                  "bei aktivierter Anzeigeskalierung kann der Cursor an "
                  "Bildschirmraendern ungenau werden.")


def main():
    make_dpi_aware()
    screen_w, screen_h = get_screen_size()
    print(f"Bildschirmaufloesung erkannt: {screen_w}x{screen_h}")

    cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)
    if not cap.isOpened():
        print("FEHLER: Webcam konnte nicht geoeffnet werden.")
        sys.exit(1)

    if not os.path.isfile(MODEL_PATH):
        print(f"FEHLER: Modell nicht gefunden unter {MODEL_PATH}")
        print("Bitte face_landmarker.task herunterladen (siehe README).")
        cap.release()
        sys.exit(1)

    base_options = mp_python.BaseOptions(model_asset_path=MODEL_PATH)
    landmarker_options = mp_vision.FaceLandmarkerOptions(
        base_options=base_options,
        running_mode=mp_vision.RunningMode.VIDEO,
        num_faces=1,
        min_face_detection_confidence=0.5,
        min_tracking_confidence=0.5,
    )
    landmarker = mp_vision.FaceLandmarker.create_from_options(landmarker_options)

    print("Starte Kalibrierung — bitte nacheinander die 4 roten Punkte fixieren.")
    calib_result = run_calibration(cap, landmarker, screen_w, screen_h)
    if calib_result is None:
        print("Kalibrierung abgebrochen. Beende.")
        cap.release()
        return
    homography, blink_threshold = calib_result

    print("Kalibrierung abgeschlossen. Augensteuerung aktiv.")
    print("Tasten: c=neu kalibrieren, p=Pause/Weiter, q=Beenden")

    smoothed = None
    closed_frames = 0
    last_click_time = 0.0
    paused = False

    cv2.namedWindow("Augensteuerung – Vorschau", cv2.WINDOW_NORMAL)
    cv2.resizeWindow("Augensteuerung – Vorschau", 480, 360)

    while True:
        if panic_key_pressed():
            # Sofort raus, bevor in diesem Durchlauf noch Cursor bewegt oder
            # geklickt wird — greift unabhaengig vom Fensterfokus.
            break

        ok, frame = cap.read()
        if not ok:
            continue
        frame = cv2.flip(frame, 1)
        fh, fw = frame.shape[0], frame.shape[1]
        lm = detect_landmarks(landmarker, frame)

        status_text = "PAUSIERT" if paused else "AKTIV"
        color = (0, 165, 255) if paused else (0, 200, 0)

        if lm is not None:
            left_c = iris_center(lm, LEFT_IRIS, fw, fh)
            right_c = iris_center(lm, RIGHT_IRIS, fw, fh)
            gaze_px = (left_c + right_c) / 2.0

            cv2.circle(frame, tuple(left_c.astype(int)), 3, (255, 0, 0), -1)
            cv2.circle(frame, tuple(right_c.astype(int)), 3, (255, 0, 0), -1)

            if not paused:
                pt = np.array([[gaze_px]], dtype=np.float32)
                screen_pt = cv2.perspectiveTransform(pt, homography)[0][0]

                # Verstaerkung um die Bildschirmmitte: kompensiert, dass beim
                # normalen Nutzen meist weniger Kopf-/Augenbewegung passiert
                # als beim Fixieren der Ecken waehrend der Kalibrierung.
                # Vertikal getrennt nach Richtung (siehe Kommentar bei GAIN_UP).
                center = np.array([screen_w / 2.0, screen_h / 2.0])
                dx = screen_pt[0] - center[0]
                dy = screen_pt[1] - center[1]
                gain_y = GAIN_UP if dy < 0 else GAIN_DOWN  # y kleiner = weiter oben
                amplified = np.array([center[0] + GAIN_X * dx,
                                      center[1] + gain_y * dy])

                sx = int(np.clip(amplified[0], 0, screen_w - 1))
                sy = int(np.clip(amplified[1], 0, screen_h - 1))

                target = np.array([sx, sy], dtype=np.float32)
                if smoothed is None:
                    smoothed = target
                else:
                    new_smoothed = (SMOOTHING_ALPHA * target
                                     + (1 - SMOOTHING_ALPHA) * smoothed)
                    # Geschwindigkeitsbremse: Schritt auf MAX_STEP_PX begrenzen,
                    # statt Ausreisser-Frames als sichtbaren Sprung durchzulassen.
                    step = new_smoothed - smoothed
                    step_len = np.linalg.norm(step)
                    if step_len > MAX_STEP_PX:
                        step = step * (MAX_STEP_PX / step_len)
                    smoothed = smoothed + step

                win32api.SetCursorPos((int(smoothed[0]), int(smoothed[1])))

                # Diagnose: rohe (unverstaerkte) und finale Position anzeigen,
                # damit man im Vorschau-Fenster sofort sieht, ob/wohin gemappt
                # wird — hilfreich, wenn der Cursor "nicht folgt".
                cv2.putText(frame, f"roh: {int(screen_pt[0])},{int(screen_pt[1])}",
                            (10, 55), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
                cv2.putText(frame, f"cursor: {int(smoothed[0])},{int(smoothed[1])}",
                            (10, 75), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)

            # Blinzel-Erkennung ueber beide Augen (Eye Aspect Ratio)
            ear_left = eye_aspect_ratio(lm, LEFT_EYE_H, LEFT_EYE_V, fw, fh)
            ear_right = eye_aspect_ratio(lm, RIGHT_EYE_H, RIGHT_EYE_V, fw, fh)
            ear = (ear_left + ear_right) / 2.0

            if ear < blink_threshold:
                closed_frames += 1
            else:
                if closed_frames >= BLINK_MIN_FRAMES and not paused:
                    now = time.time()
                    if now - last_click_time > BLINK_COOLDOWN_SEC:
                        click_left()
                        last_click_time = now
                        cv2.putText(frame, "KLICK!", (10, fh - 20),
                                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
                closed_frames = 0
        else:
            cv2.putText(frame, "Kein Gesicht erkannt", (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)

        cv2.putText(frame, status_text, (10, fh - 10),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)
        cv2.imshow("Augensteuerung – Vorschau", frame)

        key = cv2.waitKey(1) & 0xFF
        if key == ord('q') or panic_key_pressed():
            # panic_key_pressed() greift auch, wenn ein Blinzel-Klick den
            # Fokus an ein anderes Fenster abgegeben hat und q/p/c dadurch
            # nicht mehr ueber cv2.waitKey ankommen wuerden.
            break
        elif key == ord('p'):
            paused = not paused
            smoothed = None  # beim Fortsetzen ohne Sprung neu einschwingen
        elif key == ord('c'):
            calib_result = run_calibration(cap, landmarker, screen_w, screen_h)
            if calib_result is None:
                break
            homography, blink_threshold = calib_result
            smoothed = None

    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
