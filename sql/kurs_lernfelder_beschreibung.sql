-- ============================================================================
-- Ausfuehrliche Beschreibungen zu den Lernfeldern
-- (aus "Detaillierte Beschreibung des Ressourcenplan — Lernfelder &
--  Faehigkeiten", Walters Vorlage, 28.07.2026)
--
-- Aufteilung: kurs.lernziele = Kurzform aus der Uebersichtstabelle,
--             kurs.beschreibung = der ausfuehrliche Fliesstext hier.
--
-- Wiederholt ausfuehrbar (UPDATE je Kurs-Nr).
-- ============================================================================

UPDATE kurs SET beschreibung =
'Für Klient*innen ist es wichtig, grundlegende Kenntnisse über ERP-Systeme zu erlangen. Diese Einführung in die digitale Welt bietet erste Berührungspunkte mit einer ERP-Lösung und ermöglicht es, grundlegende digitale Kompetenzen in diesem Bereich zu erlangen, die bei einem späteren Übergang in den regulären Arbeitsmarkt von Vorteil sind.

Warum sind digitale Grundkompetenzen wichtig?
• Vielen Unternehmen ist es wichtig, dass die Mitarbeiter wissen, wie man sich in digitalen Umgebungen bewegt.
• Es wird möglich, schneller und besser zu arbeiten, weil die digitalen Systeme die Arbeit unterstützen, vereinfachen und für den ökologischen Fussabdruck gut sind.
• Die Digitalisierung ist ein wichtiger Bestandteil der heutigen Welt.

Es ist eine Voraussetzung und vereinfacht es, einen Job zu finden und erfolgreich darin zu sein.'
WHERE mandant_id = 1 AND kurs_nr = 'LF-01';

UPDATE kurs SET beschreibung =
'Klient*innen sollen lernen, effektiv mit digitalen Kommunikationswerkzeugen umzugehen, um mit Sozialarbeiter*innen oder anderen Klient*innen zu interagieren. Wichtig ist es auch, dass sie die Chancen bekommen, ihre Bedürfnisse und Ziele klar zu kommunizieren.

Heute werden oft Aufgaben in der Arbeitswelt digital erledigt. Daher ist es für Klient*innen von Vorteil, sich mit dieser digitalen Umgebung vertraut zu machen. Durch das Erlernen digitaler Kommunikationsfähigkeiten können sie nicht nur besser kommunizieren, sondern auch selbstbestimmt an ihren Zielen arbeiten.

Verständlich für digitale Abläufe und klare Kommunikation von Bedürfnissen und Zielen sind entscheidend für Klient*innen in der arbeitsagogischen Arbeitswelt. Diese Fähigkeiten helfen ihnen, effizient zu arbeiten und passende Arbeitsabläufe zu entwickeln, die ihren Bedürfnissen entsprechen.

Klient*innen sollen lernen, dass in der Arbeitswelt heute viel mittels Software und digitalen Medien kommuniziert wird und Abläufe / Arbeitsrapporte etc. digital abgebildet und bearbeitet werden. Durch das Auswählen der Arbeiten können sie selbstbestimmt an ihren Bedürfnissen und Zielen arbeiten.'
WHERE mandant_id = 1 AND kurs_nr = 'LF-03';

UPDATE kurs SET beschreibung =
'Klient*innen sollten in der Lage sein, ihre eigenen Bedürfnisse und Fortschritte zu erkennen. Sie können persönliche Ziele mithilfe der Software festlegen und verfolgen. Die Software zeigt sichtbare Ziele, die gemeinsam betrachtet werden können. Persönliche Ziele werden visuell dargestellt und können in Echtzeit verfolgt werden.

Diese Selbstreflexion und Zielverfolgung fördern die Autonomie der Klient*innen.'
WHERE mandant_id = 1 AND kurs_nr = 'LF-04';

UPDATE kurs SET beschreibung =
'Medienkompetenzen sollen damit geschult werden. Klient*innen sollen erlernen, welche Auswirkungen gewisse Klicks haben und was damit ausgelöst werden kann. Auch hier dient dies als Ergänzung zu anderen digitalen Medien und Schulungen.

Klient*innen sollten grundlegende technologische Fähigkeiten erlernen, um die Software eigenständig zu nutzen. Dabei ist es auch wichtig, das Bewusstsein für Sicherheit und den Schutz persönlicher Informationen zu vermitteln.

Die Schulung dieser Fähigkeiten fördert auch die Medienkompetenz der Klient*innen. Klient*innen sollen des Weiteren verstehen, welche Auswirkungen ihre Handlungen innerhalb der Software haben können.'
WHERE mandant_id = 1 AND kurs_nr = 'LF-05';
