-- Zugriff nur für freigeschaltete Mitglieder (Allowlist) mit Zwei-Faktor-Anmeldung (Authenticator, aal2)
create table public.mitglieder (
  email text primary key check (email = lower(email)),
  name text,
  created_at timestamptz not null default now()
);
alter table public.mitglieder enable row level security;
revoke all on public.mitglieder from anon, authenticated;
-- Pflege nur im Supabase-Dashboard / per SQL (keine Policies für Clients)

-- true, wenn das angemeldete Konto eine bestätigte E-Mail hat, die in mitglieder steht
create or replace function public.ist_mitglied()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from auth.users u join public.mitglieder m on m.email = lower(u.email)
    where u.id = (select auth.uid()) and u.email_confirmed_at is not null)
$$;
revoke all on function public.ist_mitglied() from public, anon;
grant execute on function public.ist_mitglied() to authenticated;

-- Restriktive Policies: zusätzlich zu den Team-Policies muss Mitglied + aal2 erfüllt sein
create policy "Nur Mitglieder mit 2FA" on public.projekte as restrictive for all to authenticated
  using ((select auth.jwt()->>'aal') = 'aal2' and (select public.ist_mitglied()))
  with check ((select auth.jwt()->>'aal') = 'aal2' and (select public.ist_mitglied()));
create policy "Nur Mitglieder mit 2FA" on public.positionen as restrictive for all to authenticated
  using ((select auth.jwt()->>'aal') = 'aal2' and (select public.ist_mitglied()))
  with check ((select auth.jwt()->>'aal') = 'aal2' and (select public.ist_mitglied()));
create policy "Nur Mitglieder mit 2FA" on public.bibliothek as restrictive for all to authenticated
  using ((select auth.jwt()->>'aal') = 'aal2' and (select public.ist_mitglied()))
  with check ((select auth.jwt()->>'aal') = 'aal2' and (select public.ist_mitglied()));
