-- Erstbelegung von web_seite. Idempotent: vorhandene slugs bleiben stehen.
INSERT INTO web_seite (mandant_id, slug, sprache, titel, untertitel,
                       darstellung, im_menue, menue_text, reihenfolge, aktiv,
                       html_inhalt, text_inhalt)
SELECT * FROM (VALUES
  (1, '', 'de', 'TRT Engineering', 'Ihr Partner für Projektmanagement, Beratung und Softwareentwicklungen', 'html', true, 'Start', 10, true, '<section class="section"><h2 class="section-title">Unsere Leistungen</h2><div class="row g-4"><div class="col-12 col-md-6"><div class="service-card"><h3 class="sc-title">Projektmanagement</h3><div class="sc-body">Planung, Steuerung und erfolgreiche Umsetzung technischer Projekte.</div></div></div><div class="col-12 col-md-6"><div class="service-card"><h3 class="sc-title">Beratung</h3><div class="sc-body">Technische Expertise, Architekturentscheidungen und Prozessoptimierungen.</div></div></div><div class="col-12 col-md-6"><div class="service-card"><h3 class="sc-title">Softwareentwicklung</h3><div class="sc-body">Individuelle Softwarelösungen für Web, Desktop und Automatisierung.</div></div></div></div></section>', NULL),
  (1, 'impressum', 'de', 'Impressum', NULL, 'html', true, 'Impressum', 90, true, '<div class="row g-4"><div class="col-12 col-md-6"><div class="service-card"><h3 class="sc-title">Angaben gem&auml;&szlig; &sect; 5 TMG</h3><div class="sc-body">Jürgen Rischkau<br />Musterstraße 1<br />80935 München<br />Deutschland</div></div></div><div class="col-12 col-md-6"><div class="service-card"><h3 class="sc-title">Kontakt</h3><div class="sc-body">Telefon: +49 (0) 000 000000<br />E-Mail: info@trt-engineering.de</div></div></div><div class="col-12 col-md-6"><div class="service-card"><h3 class="sc-title">Umsatzsteuer-ID</h3><div class="sc-body">Umsatzsteuer-Identifikationsnummer gemäß § 27 a Umsatzsteuergesetz:<br />DE000000000</div></div></div><div class="col-12 col-md-6"><div class="service-card"><h3 class="sc-title">Haftung für Inhalte</h3><div class="sc-body">Als Diensteanbieter sind wir gemäß § 7 Abs.1 TMG für eigene Inhalte auf diesen Seiten nach den allgemeinen Gesetzen verantwortlich.</div></div></div><div class="col-12 col-md-6"><div class="service-card"><h3 class="sc-title">Haftung für Links</h3><div class="sc-body">Unser Angebot enthält Links zu externen Webseiten Dritter, auf deren Inhalte wir keinen Einfluss haben. Für diese Inhalte übernehmen wir keine Gewähr.</div></div></div></div>', NULL),
  (1, 'team', 'de', 'Unser Team', 'Die Menschen hinter TRT Engineering GmbH', 'html', true, 'Team', 30, true, '', NULL)
) AS v(mandant_id, slug, sprache, titel, untertitel, darstellung, im_menue,
       menue_text, reihenfolge, aktiv, html_inhalt, text_inhalt)
 WHERE NOT EXISTS (SELECT 1 FROM web_seite s
                    WHERE s.mandant_id = v.mandant_id AND s.slug = v.slug
                      AND s.sprache = v.sprache);

-- Teamseiten aus den vorhandenen Dokumenten uebernehmen: die Bruecke vom
-- alten Aufbau (dokument) in den neuen (web_seite).
INSERT INTO web_seite (mandant_id, slug, sprache, titel, untertitel,
                       darstellung, im_menue, reihenfolge, aktiv,
                       html_inhalt, text_inhalt, person_id)
SELECT 1,
       'team/' || lower(p.vorname),
       'de',
       trim(coalesce(p.vorname,'') || ' ' || p.nachname_firmenname),
       rt.rollen_bezeichnung,
       CASE WHEN coalesce(d.html,'') <> '' THEN 'html' ELSE 'text' END,
       false, 50, pm.im_web_anzeigen,
       nullif(d.html,''),
       coalesce(nullif(d.ocr_text,''), d.inhalt_text),
       p.person_id
  FROM person_dokument pd
  JOIN person p   ON p.person_id = pd.person_id
  JOIN dokument d ON d.dokument_id = pd.dokument_id
  JOIN person_mandant pm ON pm.person_id = p.person_id AND pm.mandant_id = 1
  LEFT JOIN person_beziehung pb ON pb.quell_person_id = p.person_id AND pb.mandant_id = 1
  LEFT JOIN rolle_typ rt ON rt.rolle_id = pb.rolle_id
 WHERE pd.mandant_id = 1
   AND NOT EXISTS (SELECT 1 FROM web_seite s
                    WHERE s.mandant_id = 1 AND s.slug = 'team/' || lower(p.vorname));

SELECT seite_id, slug, titel, darstellung, aktiv, im_menue,
       zeichen_text, zeichen_html, coalesce(hinweis,'-') AS hinweis
  FROM v_web_seite WHERE mandant_id = 1 ORDER BY reihenfolge, slug;
