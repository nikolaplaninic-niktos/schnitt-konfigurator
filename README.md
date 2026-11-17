# Schnitt-Konfigurator – Projekt & Montagestatik (Testversion)

Webanwendung für Fensterelemente: Projekte mit Positionen, Montage- und Glasstatik
(Windlast nach DIN EN 1991-1-4/NA), Vertikal-/Horizontalschnitt, Ansicht und Montageplan.
Export als PDF (einzelne Position, Projekt-Statik, Projekt komplett), Projekt sichern/laden als JSON.

## Starten
Eine einzige Datei: `index.html` im Browser öffnen – keine Installation, kein Build.
Externe Bibliotheken kommen per CDN: jsPDF 2.5.1 (jsDelivr), pdf.js 3.11.174 (cdnjs), Schrift IBM Plex (Google Fonts).

Online stellen: GitHub Pages (Settings → Pages → Branch `main`, Ordner `/`) oder beliebiger statischer Webspace.

## Hinweise
- Daten bleiben im Browser (eigene Führungsschienen in `localStorage`, Projekte über JSON-Export sichern).
- „Zeichnung einlesen" (Beta) funktioniert nur, wenn die Seite als Claude Artifact geöffnet ist;
  in dieser Standalone-Version ist der Bereich deaktiviert.
- PDFs werden außerhalb von Claude direkt im Browser heruntergeladen.
- Testversion: Statikwerte vor Verwendung fachlich prüfen.
