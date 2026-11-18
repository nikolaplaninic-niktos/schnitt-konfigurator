# CLAUDE.md – Schnitt-Konfigurator (Testversion)

Test project for Nikola Planinic and a friend: how a shared database works for the
"Projekt & Montagestatik" window tool. App texts: **German**. Communication with Nikola: **Croatian** (casual, "brate").

## What it is
- One standalone page `index.html` (~215 KB, no build): projects with positions, montage + glass statics
  (wind load DIN EN 1991-1-4/NA), vertical/horizontal section, view, montage plan, PDF export
  (jsPDF 2.5.1 via jsDelivr, pdf.js 3.11.174 via cdnjs), JSON export/import, supabase-js 2.45.4 via jsDelivr.
- Originally a Claude Artifact. "Zeichnung einlesen" (Beta) needs `window.claude` and is disabled outside Claude.
  Outside Claude, PDFs download directly via a Blob link.
- Main switch `const APP = 'projekt'`. All code lives in one IIFE at the end of `index.html`.

## Database (Supabase)
- Organization "SJ Test" (`oyrldddlgmtrcefstlni`), project `xyiwfjvqujfntxxvmocc` (eu-west-1). The Supabase MCP has access.
- URL `https://xyiwfjvqujfntxxvmocc.supabase.co`, publishable key in `index.html` (`SB_KEY`, public by design).
- Schema: `supabase/migrations/` (keep in sync with every migration you apply).
  - `projekte`: `id` text (app id), `data` jsonb (project fields `p_*`, `wz`, `gh`), generated `name/auftragsnr/kunde`, `sort`.
  - `positionen`: PK (`projekt_id`, `idx`), `data` jsonb (~117 form fields), generated `bezeichnung/einbauort/stueck/breite_mm/hoehe_mm/aufteilung`.
  - `bibliothek`: key `schienen` | `produkte`, `data` jsonb array.
  - Trigger `touch_updated` sets `updated_at/updated_by`. RLS: only `authenticated`, members share everything (team). `anon` has no access.
  - `mitglieder` (email, name): allowlist, no client policies (edit via dashboard/SQL). `ist_mitglied()` (security definer, confirmed email in list).
    Restrictive policy "Nur Mitglieder mit 2FA" on all 3 tables: `aal = 'aal2'` AND `ist_mitglied()`. Advisor warnings for this are intentional.
  - `mein_name()` (security definer): name from `mitglieder` for the greeting "Willkommen, <Vorname>" in the cloud bar.
  - Trigger `nur_mitglieder_registrieren` on `auth.users`: sign-up only for e-mails in `mitglieder`.
  - Lost authenticator: `delete from auth.mfa_factors where user_id = (select id from auth.users where email = '…')` → user enrolls again at next login.
- App sync (search `// ---- Datenbank (Supabase)` in `index.html`):
  - `dbStore()` → `cloudQueue()` (1.2 s debounce) → `cloudSync()`: upsert projects + positions, delete positions with `idx >= length`,
    delete only projects explicitly removed in this browser (`cloudGone`) – never other users' new projects.
  - Login mask `#auth` (search `// ---- Anmeldemaske`): `authState()` → password → no factor: enroll TOTP (QR + secret) / factor: code → aal2 →
    `rpc('ist_mitglied')` → not member: "Kein Zugriff" step. "Ohne Anmeldung weiter" = local only (sessionStorage flag).
  - `cloudLoad()` after login: loads everything; non-empty local-only projects are uploaded.
  - `storeRails/storeLib` → `cloudLibQueue()`.
  - Abmelden / Neu laden: `cloudFlush()` uploads only pending changes (`cloudDirty`), never a full re-upload.
  - Without login: localStorage only. Same position edited by two people → last save wins.

## Testing
- Playwright/Chromium is preinstalled. Cloud environment `schnitt-konfigurator` allows the Supabase host, jsDelivr, cdnjs and Google Fonts.
- Test user: create via SQL, add to `mitglieder`; TOTP code in test computed from the shown secret (HMAC-SHA1, 30 s). Create (insert into `auth.users` + `auth.identities`, password via `extensions.crypt`), **delete it and its data afterwards**.
- Check: wrong password + wrong code message, enroll → 2nd context asks code, non-member gets "Kein Zugriff", login → "Datenbank: verbunden", edit → saved, second browser context sees the data, 390 px without horizontal overflow, no console errors.

## Mobile layout (19.11.2026)
- ≤880 px: input first, sticky jump bar (#jump), sections + "Alle öffnen/schließen"; ≤760 px: Statik/Übersicht tables become cards (`cardify()` sets td data-label).
- Touch: inputs 16 px, targets ≥44 px, inputmode on number fields (not on fields that allow negatives). Drawing fits width, "Vergrößern" toggles .sheet.zoom.
- Check after changes: calculation/drawing hashes before vs after must be identical.

## Status (19.11.2026)
- Repo is **public**, GitHub Pages live from `main` / root: https://nikolaplaninic-niktos.github.io/schnitt-konfigurator/
  (deploys automatically on every push; `.nojekyll` present).
- Supabase Auth Site URL set to the Pages URL by Nikola.
- Allowlist + mandatory authenticator (2FA) live. Nikola registered, email confirmed, TOTP verified, member. Friend added to `mitglieder` (18.11.2026), e-mail confirmed, logged in once, authenticator (2FA) not set up yet.
- Live under https://konfigurator.niktos.com/ (CNAME in repo).
- Earlier plan (done): own subdomain on Nikola's Niktos domain (DNS at Hostinger), e.g. `konfigurator.<niktos-domain>`:
  Hostinger DNS CNAME → `nikolaplaninic-niktos.github.io`, GitHub Pages custom domain (+ `CNAME` file in repo), Enforce HTTPS,
  then Supabase Site URL + Redirect URLs to the new address.
- Open ideas: Supabase Realtime instead of "Neu laden", password reset ("Passwort vergessen"),
  disable "Confirm email" if the built-in mail limit blocks sign-ups.
