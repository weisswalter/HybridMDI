INSERT INTO web_text (mandant_id, schluessel, sprache, wert, bemerkung)
VALUES (1, 'stil.css', 'de', $css$
/* ==========================================================================
   TRT_Web — Aussehen
   Alle Farben kommen als CSS-Variablen aus web_farbe und werden vom Layout
   als :root-Block vor dieses Stylesheet gesetzt. Die Werte hier sind nur
   Rueckfall, falls die Datenbank nicht erreichbar ist.
   ========================================================================== */
:root{
  --farbe-akzent:#4FE3E7; --farbe-akzent-2:#00E676; --farbe-akzent-3:#FFD600;
  --farbe-kopf-von:#0d1b3e; --farbe-kopf-bis:#3d0a4a;
  --farbe-leiste-von:#0d1b3e; --farbe-leiste-bis:#3d0a4a;
  --farbe-leiste-aktiv:#4a5490;
  --farbe-grund:#7b7f9e; --farbe-flaeche:#2d0a4a;
  --farbe-schrift:#eef1f7; --farbe-gedaempft:#8b93a7; --farbe-linie:#d7dbe6;
}

*{box-sizing:border-box}
html,body{margin:0;padding:0;height:100%}
body{
  font-family:'Segoe UI',system-ui,sans-serif;
  background:var(--farbe-grund);
  color:var(--farbe-schrift);
}

/* Grundraster: Navigationsleiste links, Inhalt rechts */
.seite{display:grid;grid-template-columns:250px 1fr;min-height:100vh}

/* ── Navigationsleiste ─────────────────────────────────────────────────── */
.kopf{
  background:linear-gradient(180deg,var(--farbe-leiste-von),var(--farbe-leiste-bis));
  display:flex;flex-direction:column;
}
.marke{
  display:block;padding:1.1rem 1rem;
  color:var(--farbe-schrift);text-decoration:none;
  font-size:1.05rem;font-weight:600;
  border-bottom:1px solid rgba(255,255,255,.12);
}
.menue{display:flex;flex-direction:column;padding:.75rem 0}
.menue a{
  padding:.7rem 1rem;margin:.15rem .6rem;border-radius:6px;
  color:var(--farbe-schrift);text-decoration:none;font-size:.95rem;
}
.menue a:hover{background:var(--farbe-leiste-aktiv)}

/* ── Inhalt ────────────────────────────────────────────────────────────── */
.inhalt{padding:0 0 3rem 0;overflow-x:hidden}

/* Titelleiste ueber dem Inhalt */
.artikel-kopf{
  background:linear-gradient(120deg,var(--farbe-kopf-von),var(--farbe-kopf-bis));
  border-bottom:3px solid var(--farbe-akzent);
  padding:2.5rem 2rem;text-align:center;margin:1.5rem 1.5rem 2rem 1.5rem;
}
.artikel-kopf h1{
  margin:0;font-size:2.6rem;color:var(--farbe-akzent);
  text-shadow:0 0 18px rgba(79,227,231,.35);
}
.artikel-kopf .untertitel{margin:.6rem 0 0;color:var(--farbe-schrift);opacity:.9}

.artikel{max-width:1100px;margin:0 auto;padding:0 1.5rem}
.section{margin:0 0 2.5rem}
.section-title{color:var(--farbe-akzent);font-size:1.7rem;font-weight:400;margin:0 0 1.2rem}

/* Karten */
.row{display:grid;gap:1rem}
.service-card{
  background:var(--farbe-flaeche);border:1px solid var(--farbe-akzent);
  border-radius:4px;padding:1rem 1.2rem;
}
.sc-title{color:var(--farbe-akzent);margin:0 0 .4rem;font-size:1.15rem;font-weight:500}
.sc-body{color:var(--farbe-akzent);opacity:.9;font-size:.95rem;line-height:1.5}

/* Kacheln fuer Unterseiten */
.kacheln{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:1rem}
.kachel{
  display:flex;flex-direction:column;gap:.3rem;
  background:var(--farbe-flaeche);border:1px solid var(--farbe-akzent);
  border-radius:4px;padding:1.1rem;text-decoration:none;
}
.kachel-titel{color:var(--farbe-akzent);font-size:1.1rem;font-weight:500}
.kachel-unter{color:var(--farbe-schrift);opacity:.8;font-size:.9rem}

/* Inhalte aus der Datenbank */
.reintext{white-space:pre-wrap;font-family:inherit;margin:0;
  background:var(--farbe-flaeche);border:1px solid var(--farbe-akzent);
  border-radius:4px;padding:1.2rem;color:var(--farbe-schrift);line-height:1.55}
.pdf{width:100%;height:80vh;border:0;background:var(--farbe-flaeche)}

.career-timeline{border-left:2px solid var(--farbe-akzent);padding-left:1.2rem}
.career-item{margin-bottom:1.4rem}
.career-period{color:var(--farbe-akzent);font-size:.85rem}
.career-item.current .career-period{color:var(--farbe-akzent-2)}
.career-title{font-weight:600}
.career-company{opacity:.85;font-size:.92rem}
.career-desc{opacity:.75;font-size:.9rem}

.fields-grid{display:flex;flex-wrap:wrap;gap:.5rem}
.field-tag{background:var(--farbe-flaeche);border:1px solid var(--farbe-akzent);
  border-radius:999px;padding:.35rem .9rem;font-size:.88rem;color:var(--farbe-akzent)}

.misc-list{line-height:1.7}

/* ── Fuss ──────────────────────────────────────────────────────────────── */
.fuss{grid-column:1 / -1;display:flex;gap:1.2rem;justify-content:center;
  padding:1.2rem;border-top:1px solid rgba(255,255,255,.15)}
.fuss a{color:var(--farbe-schrift);opacity:.8;text-decoration:none;font-size:.9rem}

@media (max-width:800px){
  .seite{grid-template-columns:1fr}
  .menue{flex-direction:row;flex-wrap:wrap}
}

$css$,
        'Stylesheet der Website. Wird vom Layout in die Seite gesetzt.')
ON CONFLICT (mandant_id, schluessel, sprache) DO UPDATE SET wert = EXCLUDED.wert;
SELECT schluessel, length(wert) AS zeichen FROM web_text
 WHERE mandant_id=1 AND schluessel='stil.css';
