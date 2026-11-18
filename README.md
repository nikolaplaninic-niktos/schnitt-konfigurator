# Schnitt-Konfigurator – Projekt & Montagestatik (Testversion)

Webanwendung für Fensterelemente: Projekte mit Positionen, Montage- und Glasstatik
(Windlast nach DIN EN 1991-1-4/NA), Vertikal-/Horizontalschnitt, Ansicht und Montageplan.
Export als PDF (einzelne Position, Projekt-Statik, Projekt komplett), Projekt sichern/laden als JSON.

## Starten
Eine einzige Datei: `index.html` im Browser öffnen – keine Installation, kein Build.
Externe Bibliotheken kommen per CDN: jsPDF 2.5.1 (jsDelivr), pdf.js 3.11.174 (cdnjs), supabase-js 2.45.4 (jsDelivr), Schriften IBM Plex und Exo 2 (Google Fonts).

Online stellen: GitHub Pages (Settings → Pages → Branch `main`, Ordner `/`) oder beliebiger statischer Webspace.

## Datenbank (Supabase, Organisation „SJ Test")
- Projekt `xyiwfjvqujfntxxvmocc` (eu-west-1). Schema: `supabase/migrations/`.
- Tabellen: `projekte` (Projektdaten als JSON + Spalten Name/Auftragsnr./Kunde), `positionen` (eine Zeile je Position, JSON + Spalten Stück/Breite/Höhe/Aufteilung), `bibliothek` (eigene Schienen und Produkte).
- Zugriff nur für freigeschaltete Mitglieder (Tabelle `mitglieder`, E-Mail) mit Zwei-Faktor-Anmeldung (Authenticator-App); alle Mitglieder sehen dieselben Projekte (Team).
- Anmeldemaske beim Start: E-Mail + Passwort, beim ersten Mal Authenticator per QR-Code einrichten, danach jeweils 6-stelliger Code.
- Neues Mitglied: E-Mail (klein geschrieben) und Name im Supabase-Dashboard in `mitglieder` eintragen, Person registriert sich in der App. Nur E-Mails aus der Liste können sich registrieren; der Vorname erscheint als Begrüßung „Willkommen, …“.
- Authenticator verloren: Faktor in `auth.mfa_factors` löschen, beim nächsten Login wird neu eingerichtet.
- Änderungen werden nach ca. 1 s automatisch gespeichert; „Neu laden" holt den Stand der anderen.
- Ohne Anmeldung arbeitet die App wie bisher nur im Browser (`localStorage`).
- Gleichzeitiges Bearbeiten derselben Position: der zuletzt gespeicherte Stand gilt.

## Hinweise
- „Zeichnung einlesen" (Beta) funktioniert nur, wenn die Seite als Claude Artifact geöffnet ist;
  in dieser Standalone-Version ist der Bereich deaktiviert.
- PDFs werden außerhalb von Claude direkt im Browser heruntergeladen.
- Testversion: Statikwerte vor Verwendung fachlich prüfen.
