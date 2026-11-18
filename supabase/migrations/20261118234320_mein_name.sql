-- Anzeigename des angemeldeten Mitglieds (für die Begrüßung in der App); null, wenn kein Mitglied
create or replace function public.mein_name()
returns text language sql stable security definer set search_path = '' as $$
  select m.name from auth.users u join public.mitglieder m on m.email = lower(u.email)
  where u.id = (select auth.uid()) and u.email_confirmed_at is not null
$$;
revoke all on function public.mein_name() from public, anon;
grant execute on function public.mein_name() to authenticated;
