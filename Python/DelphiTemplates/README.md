# Delphi-Design-Vorlagen für Python-Fenster

Diese `.pas`/`.dfm`-Paare sind **keine** Bestandteile des Heisenberg-Projekts.
Sie dienen nur als visuelle Design-Quelle für die Python-Fenster im übergeordneten
`Python`-Ordner (`frm_kunden.pydfm`, `frm_artikel.pydfm`, ...).

**Workflow:**
1. Hier die passende `.pas`/`.dfm`-Datei im Delphi-Form-Designer öffnen und visuell anpassen
2. Export anstoßen (Claude überträgt das Layout in die entsprechende `.pydfm`-Datei im `Python`-Ordner)
3. Python-Modul (`modul_*.py`) bleibt unverändert — nur die GUI-Beschreibung ändert sich

**Hinweis:** Diese Dateien liegen aktuell lose ohne eigenes `.dproj`. Zum Öffnen im
Form-Designer braucht RAD Studio einen Projektkontext — bei Bedarf ein kleines
Scratch-Projekt dafür anlegen.

Der automatische `.dfm → .pydfm`-Exporter ist noch nicht gebaut (siehe Roadmap,
Abschnitt "Ribbon-GUI" / DFM-Exporter-Konzept) — aktuell wird das Layout manuell/
durch Claude übertragen.
