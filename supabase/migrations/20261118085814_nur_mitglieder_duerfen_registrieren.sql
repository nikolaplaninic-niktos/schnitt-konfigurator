-- Registrierung nur für E-Mails aus der Allowlist public.mitglieder (Trigger auf auth.users)
create or replace function public.nur_mitglieder_registrieren()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (select 1 from public.mitglieder m where lower(m.email) = lower(new.email)) then
    raise exception 'E-Mail nicht freigeschaltet';
  end if;
  return new;
end;
$$;
revoke all on function public.nur_mitglieder_registrieren() from public, anon, authenticated;
drop trigger if exists nur_mitglieder_registrieren on auth.users;
create trigger nur_mitglieder_registrieren
  before insert on auth.users
  for each row execute function public.nur_mitglieder_registrieren();
