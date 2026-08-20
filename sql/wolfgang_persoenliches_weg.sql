UPDATE dokument SET html = regexp_replace(html,
  '\s*<h4 style="margin-top:1rem;">Persönliches</h4>\s*<p>[^<]*</p>', '', 'g')
 WHERE dokument_id = 5;
SELECT 'Persoenliches noch im HTML: ' ||
       (position('Persönliches' in html) > 0)::text
  FROM dokument WHERE dokument_id = 5;
