# Dokument-Texterkennung und Kategorisierung

Gebaut in der Nacht vom 31.07. auf den 01.08.2026.

Liest Scans ein, erkennt den Text und ordnet das Dokument einer Art zu
(Rechnung, Mahnung, Lieferschein, Lohnabrechnung, Kursunterlage …). Die
Rückgabe ist auf die Spalten der Tabelle `dokument` zugeschnitten, die es im
Dokumente-Modul schon gibt (`ocr_text`, `typ_id`, `titel`, `sprache`,
`mime_type`, `dateigroesse_kb`).

## Sofort ausprobieren

Aus dem Ordner `Python\`:

```
python -m dokument_ocr.demo
```

Zeigt Kategorisierung und Bildaufbereitung an Beispielen. Installiert nichts
und schreibt nichts in die Datenbank.

Tests:

```
python -m unittest discover -s dokument_ocr\tests
```

48 Tests, laufen ohne EasyOCR.

## Was ohne Installation läuft

Alles bis auf die Texterkennung selbst:

* **Kategorisierung** – braucht nur die Standardbibliothek
* **Bildaufbereitung** – braucht OpenCV und NumPy, beides ist vorhanden

## Was EasyOCR braucht

Nur das Erkennen von Text in Bildern:

```
pip install easyocr
```

**Bewusst nicht automatisch installiert**, weil PyTorch mitkommt, rund 2 GB.
Der erste Lauf lädt zusätzlich die Sprachmodelle (~100 MB) nach
`%USERPROFILE%\.EasyOCR`.

## Aufbau

| Datei | Zweck |
|---|---|
| `kategorien.json` | Das Regelwerk. Hier werden Kategorien gepflegt – ohne Code. |
| `kategorisierung.py` | Wendet die Regeln an, liefert Kategorie samt Begründung. |
| `extraktion.py` | Zieht Betrag, Datum, Rechnungsnummer, IBAN, QR-Referenz. |
| `bildvorbereitung.py` | Graustufen, Schattenausgleich, Entzerren, Hochskalieren. |
| `ocr_backend.py` | Austauschbare Texterkennung (EasyOCR, Textdatei, Test). |
| `pdf_leser.py` | Text aus durchsuchbaren PDFs, erkennt Scans. |
| `pipeline.py` | Führt alles zusammen, liefert ein `dict` je Dokument. |
| `demo.py` | Vorführung. |
| `../ocr_caller.py` | Einstiegspunkt für Delphi, liefert JSON. |

## Extrahierte Daten

Aus dem erkannten Text werden zusätzlich die harten Werte gezogen:

| Feld | Beispiel |
|---|---|
| `betrag`, `betrag_waehrung` | `1240.0`, `CHF` |
| `datum` | `2026-07-12` |
| `rechnungsnummer` | `2026-4711` |
| `iban` | `CH4431999123000889012` |
| `qr_referenz` | 27-stellig, ohne Leerzeichen |

Der **Betrag** ist der interessante Fall. Ein einfaches `Total: (\d+)` scheitert,
weil die Texterkennung Zeilen zerreisst — aus

```
Total inkl. MWST      CHF 1240.00
```

wird real

```
Total inkl:. MWST
CHF 1240.00
```

Schlüsselwort und Betrag landen in getrennten Zeilen, und im Schlüsselwort steckt
ein Erkennungsfehler. Deshalb werden **alle** Beträge eingesammelt und nach ihrem
Umfeld bewertet: `total` zählt +5, `chf` +3, `netto` −3, `menge` −4. Der Betrag mit
den meisten Punkten gewinnt, und die Begründung steht im Ergebnis:

```
betrag       : 1240.0 CHF
betrag_grund : +5 total, +3 \bchf\b, +2 inkl, +1 mwst, -3 netto
```

Die 124.00 aus der Positionszeile verliert damit gegen den Endbetrag. Findet sich
gar kein Hinweis, wird `None` geliefert statt einer Zufallszahl.

Schweizer Formate sind abgedeckt: Hochkomma-Tausender (`1'240.00`), QR-Referenz in
Fünferblöcken, IBAN für CH und LI.

## PDF

Durchsuchbare PDFs brauchen **kein OCR** — der Text wird direkt ausgelesen, das ist
schnell und fehlerfrei. Die Pipeline erkennt das selbst; ein solches PDF läuft sogar
ohne gesetztes OCR-Backend durch.

Gescannte PDFs enthalten nur Bilder. Dafür müssten die Seiten gerendert werden, was
`pdf2image` **und Poppler als Systeminstallation** braucht — das ist bewusst nicht
eingebaut. Stattdessen meldet die Pipeline verständlich, dass es sich um einen Scan
handelt. Vorab prüfen lässt sich das mit `ocr_caller.pdf_pruefen(pfad)`.

Braucht `pypdf` (installiert, klein, keine weiteren Abhängigkeiten).

## Von Delphi aus

Nach dem Muster von `mail_caller.py`:

```pascal
// Kategorien für eine Auswahlliste
_json := ocr_caller.kategorien_auflisten();

// Ein Dokument lesen und einordnen
_json := ocr_caller.dokument_lesen('C:\Scans\beleg.png');

// Nur Text einordnen, ohne Bild - braucht kein EasyOCR.
// Sinnvoll für durchsuchbare PDFs und für Mailtexte aus dem Mailmodul.
_json := ocr_caller.text_einordnen(LText);

// Vorher prüfen, ob die Erkennung überhaupt möglich ist
_verfuegbar := ocr_caller.ocr_verfuegbar();
```

Jede Funktion gibt JSON zurück und wirft keine Ausnahme – Fehler stehen im
Feld `fehler`, `ok` sagt, ob es geklappt hat. Ein unlesbarer Scan bricht
damit keinen Stapellauf ab.

## Warum Regeln und kein Modell

Es gibt noch keine gelabelten Dokumente, mit denen sich etwas trainieren
liesse. Regeln liefern ab dem ersten Beleg ein Ergebnis, und man sieht in der
Begründung, welches Muster gegriffen hat:

```
mahnung (11 Punkte)
Erkannt an: 'mahnung' (+4), '2. mahnung' (+4), 'mahngebuehr' (+3)
```

Bei einer Fehlzuordnung wird die Regel korrigiert, nicht das Modell neu
trainiert. Wenn später genug geprüfte Dokumente vorliegen, kann ein Modell
daneben gestellt werden – die Schnittstelle bleibt gleich.

Die Punktevergabe sorgt dafür, dass die **spezifischere** Kategorie gewinnt:
Eine Schweizer QR-Rechnung enthält das Wort „Rechnung", zählt aber über
`Empfangsschein` und `Zahlteil` so viele Punkte, dass sie sich gegen die
allgemeine Rechnung durchsetzt. Dasselbe bei einer Mahnung, die sich auf eine
Rechnung bezieht.

## Kategorien anpassen

`kategorien.json` bearbeiten. Jede Kategorie hat Muster (reguläre Ausdrücke)
mit Gewichten und einen Mindestwert, ab dem sie als erkannt gilt. Danach die
Tests laufen lassen.

Die Muster werden gegen **normalisierten** Text geprüft: kleingeschrieben,
Umlaute zu `ae/oe/ue`, Zeilenumbrüche zu Leerzeichen, am Zeilenende getrennte
Wörter zusammengezogen. Deshalb steht in den Mustern `gruessen` und nicht
`grüssen` – so greifen sie unabhängig davon, wie sauber die Erkennung war.

## Offene Punkte

* **PDF** wird noch nicht gelesen. Für durchsuchbare PDFs genügt eine
  Textextraktion (`pypdf`) und dann `text_einordnen`; für gescannte PDFs
  braucht es zusätzlich das Rendern der Seiten (`pdf2image` + Poppler).
* **Betragserkennung** wäre der nächste sinnvolle Schritt: Rechnungsbetrag,
  Datum und Referenznummer aus dem Text ziehen und gleich in den Beleg
  übernehmen. Das Regelwerk dafür stünde neben `kategorien.json`.
* **Anbindung an die Datenbank**: Das Zuordnen von `kategorie` auf `typ_id`
  gehört auf die Delphi-Seite. Dieses Paket kennt die Datenbank absichtlich
  nicht.
* Die Kategorien sind ein **Startsatz** aus dem Geschäftsalltag. Welche
  Dokumentarten in der Arbeitsagogik wirklich anfallen, weiss Walter besser –
  `kategorien.json` ist dafür da.
