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
| `bildvorbereitung.py` | Graustufen, Schattenausgleich, Entzerren, Hochskalieren. |
| `ocr_backend.py` | Austauschbare Texterkennung (EasyOCR, Textdatei, Test). |
| `pipeline.py` | Führt alles zusammen, liefert ein `dict` je Dokument. |
| `demo.py` | Vorführung. |
| `../ocr_caller.py` | Einstiegspunkt für Delphi, liefert JSON. |

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
