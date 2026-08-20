-- ============================================================================
--  Wolfgang Thiel: alte Seite loeschen, neue anlegen — 03.08.2026
--
--  ANLASS (Walter): "Ich will im Web nichts haben, was ich nicht managen
--  kann." Die alte Seite war eine .razor-Datei — nur ueber den Quelltext
--  aenderbar. Sie wird ersatzlos entfernt.
--
--  DIE NEUE ENTHAELT KEINE PRIVATEN ANGABEN: kein Familienstand, kein
--  Wohnort, keine private Mobilnummer. Nur, was auf eine Firmenseite gehoert.
--  Aendern und Loeschen gehen ab jetzt im Webeditor.
--
--  Laeuft auf Server UND lokal. Idempotent.
-- ============================================================================

-- 1. Alles Alte weg: Verknuepfungen zuerst, sonst greifen die Fremdschluessel
DELETE FROM webinhalt
 WHERE dokument_id IN (SELECT dokument_id FROM dokument
                        WHERE titel LIKE 'Bio%Wolfgang%');
DELETE FROM person_dokument
 WHERE dokument_id IN (SELECT dokument_id FROM dokument
                        WHERE titel LIKE 'Bio%Wolfgang%');
DELETE FROM dokument WHERE titel LIKE 'Bio%Wolfgang%';

-- 2. Neues Dokument
INSERT INTO dokument (typ_id, titel, sprache, html, fuer_web, web_darstellung)
SELECT (SELECT min(typ_id) FROM dokument_typ), 'Profil Wolfgang Thiel DE', 'de',
       $wt$
<section class="section">
  <h2 class="section-title">Über den Gründer</h2>
  <div class="info-grid">
    <div class="info-block">
      <h4>Kontakt</h4>
      <p>TRT Engineering GmbH<br />
         Pulverturmstrasse 9e<br />
         80935 München, Deutschland</p>
      <p>📞 <a href="tel:+498920234060">+49 (0)89-20234060</a><br />
         ✉️ <a href="mailto:wt@trt-engineering.de">wt@trt-engineering.de</a></p>
    </div>
    <div class="info-block">
      <h4>Ausbildung</h4>
      <p>Dipl.-Ing. Elektrotechnik mit Schwerpunkt Kybernetik</p>
    </div>
  </div>
</section>
<section class="section">
  <h2 class="section-title">Berufliche Laufbahn</h2>
  <div class="career-timeline">
    <div class="career-item current">
      <div class="career-period">Januar 2012 – heute</div>
      <div class="career-title">Gründer &amp; Geschäftsführer</div>
      <div class="career-company">TRT Engineering GmbH · München</div>
      <div class="career-desc">Beratung, Engineering &amp; Projektmanagement</div>
    </div>
    <div class="career-item">
      <div class="career-period">Mai 1976 – Oktober 2011</div>
      <div class="career-title">Leiter Emissionsmessung</div>
      <div class="career-company">BMW AG · München</div>
      <div class="career-desc">35 Jahre Expertise in Fahrzeugemissionen und Messtechnik</div>
    </div>
  </div>
</section>
<section class="section">
  <h2 class="section-title">Tätigkeitsfelder</h2>
  <div class="fields-grid">
    <div class="field-tag">Abgasemissionsmessung</div>
    <div class="field-tag">Gasförmige Emissionen</div>
    <div class="field-tag">Partikelemissionen</div>
    <div class="field-tag">Rollenprüfstände</div>
    <div class="field-tag">Motorprüfstände</div>
    <div class="field-tag">Labor- und Prüfzellentechnik</div>
    <div class="field-tag">Wasserstofffahrzeuge</div>
    <div class="field-tag">Hybridfahrzeuge</div>
    <div class="field-tag">Internationale Gesetzgebung</div>
    <div class="field-tag">Akustikprüfstände</div>
  </div>
</section>
<section class="section">
  <h2 class="section-title">Weitere Aktivitäten</h2>
  <ul class="misc-list">
    <li>Vorsitzender der Internationalen Konferenz „Real Driving Emissions", Berlin (2013–2019)</li>
    <li>Autor und Co-Autor zahlreicher Fachpublikationen und Konferenzbeiträge (SAE, International Journal of Hydrogen Energy)</li>
    <li>Dozent bei Firmentrainings, Gastreferent an technischen Akademien und Universitäten</li>
  </ul>
</section>
$wt$, true, 'html';

-- 3. Mit der Person verknuepfen
INSERT INTO person_dokument (person_id, dokument_id, mandant_id, beschreibung)
SELECT p.person_id, d.dokument_id, 1, 'Webprofil'
  FROM person p
  CROSS JOIN (SELECT dokument_id FROM dokument
               WHERE titel = 'Profil Wolfgang Thiel DE'
               ORDER BY dokument_id DESC LIMIT 1) d
 WHERE p.vorname = 'Wolfgang' AND p.nachname_firmenname = 'Thiel'
   AND NOT EXISTS (SELECT 1 FROM person_dokument pd
                    WHERE pd.person_id = p.person_id
                      AND pd.dokument_id = d.dokument_id);

-- 4. Kontrolle: steht irgendwo noch etwas Privates?
SELECT d.dokument_id, d.titel, d.fuer_web, d.web_darstellung,
       length(d.html) AS zeichen,
       (position('Verheiratet' in coalesce(d.html,'')
                 || coalesce(d.ocr_text,'') || coalesce(d.inhalt_text,'')) > 0)
         AS enthaelt_privates
  FROM dokument d
  JOIN person_dokument pd ON pd.dokument_id = d.dokument_id
  JOIN person p ON p.person_id = pd.person_id
 WHERE p.vorname = 'Wolfgang';
