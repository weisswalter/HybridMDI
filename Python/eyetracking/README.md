# Augensteuerung (Eye-Tracking-Mauszeiger)

Webcam-basierte Augensteuerung fuer den Pitch — kein Spezial-Hardware (kein
Tobii o.ae.) noetig, nur eine normale Webcam.

## Funktionsweise

1. MediaPipe FaceLandmarker (Tasks-API) liefert 478 Gesichts-Landmarks
   inkl. Iris-Position (Indizes 468–477) aus dem Webcam-Bild.
2. **Kalibrierung:** 4 Bildschirmecken nacheinander ansehen (Kopf dabei
   ruhig halten). Aus den gemessenen Iris-Positionen wird eine Homographie
   berechnet, die Kamera-Pixel auf Bildschirmkoordinaten abbildet.
3. **Steuerung:** Iris-Position wird laufend in Bildschirmkoordinaten
   umgerechnet und geglaettet (exponentielle Glaettung gegen Zittern), der
   Windows-Cursor folgt in Echtzeit.
4. **Klick:** Ein bewusstes Blinzeln beider Augen (Eye-Aspect-Ratio-Methode)
   loest einen Linksklick aus. Die Blinzel-Schwelle wird NICHT fest
   vorgegeben, sondern waehrend der Kalibrierung aus den echten
   "Augen offen"-Werten abgeleitet (75% des gemessenen Basiswerts) — ein
   fixer Schwellenwert lag in Tests zu nah an normalen offenen Augen und
   loeste Fehlklicks aus.

## Voraussetzungen

```
pip install opencv-python mediapipe pyautogui pywin32
```

Modell-Datei `models/face_landmarker.task` (Google, offizielles
MediaPipe-Modell) muss vorhanden sein — liegt bereits im Repo.
Bei Bedarf neu laden:

```
curl -L -o models/face_landmarker.task ^
  https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task
```

## Start

```
python eye_mouse_control.py
```

Tasten waehrend des Laufs (Fokus auf dem Vorschau-Fenster):
- `c` — Kalibrierung neu starten
- `p` — Steuerung pausieren/fortsetzen (Cursor bleibt dann in Ruhe,
  praktisch um kurz die Maus wieder selbst zu benutzen)
- `q` — Beenden

**NOTAUS: `ESC` beendet das Programm IMMER**, unabhaengig davon, welches
Fenster gerade den Tastaturfokus hat. Das ist wichtig: ein Blinzel-Klick
ausserhalb des Vorschau-Fensters (z.B. in Heisenberg) gibt DIESEM Fenster
den Fokus — dann kommen `q`/`p`/`c` nicht mehr an, weil sie ueber das
Vorschau-Fenster abgefragt werden. `ESC` wird stattdessen global ueber
Windows abgefragt (`GetAsyncKeyState`) und greift deshalb immer.

## Fuer den Pitch

Eigenstaendig lauffaehig, keine Delphi-Aenderung noetig — steuert den
echten Windows-Cursor und funktioniert damit sofort auch in Heisenberg
selbst. Einfach parallel zu Heisenberg.exe starten und live durch die GUI
navigieren (z.B. Personen-Modul: mit den Augen zwischen den Tabs wechseln,
Blinzeln klickt Buttons).

## Bekannte Grenzen (v1, ehrlich benannt)

- Kopf muss waehrend Nutzung relativ ruhig bleiben (kein Head-Pose-
  Ausgleich in dieser Version — reine Iris-Pixel-Homographie, kein
  normalisierter Blickvektor).
- Kalibrierung gilt nur fuer die aktuelle Kopf-/Kameraposition; bei
  spuerbarer Ungenauigkeit einfach `c` druecken und neu kalibrieren.
- Ein Gesicht gleichzeitig (num_faces=1).
