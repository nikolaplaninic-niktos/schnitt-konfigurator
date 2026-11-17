-- Schnitt-Konfigurator: Projekte, Positionen, eigene Bibliothek (Testbetrieb, Team = alle angemeldeten Nutzer)
create table public.projekte (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  name text generated always as (data->>'p_name') stored,
  auftragsnr text generated always as (data->>'p_nr') stored,
  kunde text generated always as (data->>'p_kunde') stored,
  sort int not null default 0,
  created_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.positionen (
  projekt_id text not null references public.projekte(id) on delete cascade,
  idx int not null,
  data jsonb not null default '{}'::jsonb,
  bezeichnung text generated always as (data->>'pos') stored,
  einbauort text generated always as (data->>'raum') stored,
  stueck int generated always as (coalesce(nullif(data->>'stk','')::numeric, 1)::int) stored,
  breite_mm int generated always as (nullif(data->>'eb','')::numeric::int) stored,
  hoehe_mm int generated always as (nullif(data->>'eh','')::numeric::int) stored,
  aufteilung text generated always as (data->>'eauf') stored,
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_at timestamptz not null default now(),
  primary key (projekt_id, idx)
);

create table public.bibliothek (
  key text primary key check (key in ('schienen','produkte')),
  data jsonb not null default '[]'::jsonb,
  updated_by uuid references auth.users(id) on delete set null default auth.uid(),
  updated_at timestamptz not null default now()
);

create or replace function public.touch_updated()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  new.updated_by := coalesce(auth.uid(), new.updated_by);
  return new;
end $$;

create trigger projekte_touch before update on public.projekte for each row execute function public.touch_updated();
create trigger positionen_touch before update on public.positionen for each row execute function public.touch_updated();
create trigger bibliothek_touch before update on public.bibliothek for each row execute function public.touch_updated();

alter table public.projekte enable row level security;
alter table public.positionen enable row level security;
alter table public.bibliothek enable row level security;

create policy "Team liest Projekte" on public.projekte for select to authenticated using (true);
create policy "Team legt Projekte an" on public.projekte for insert to authenticated with check (true);
create policy "Team ändert Projekte" on public.projekte for update to authenticated using (true) with check (true);
create policy "Team löscht Projekte" on public.projekte for delete to authenticated using (true);

create policy "Team liest Positionen" on public.positionen for select to authenticated using (true);
create policy "Team legt Positionen an" on public.positionen for insert to authenticated with check (true);
create policy "Team ändert Positionen" on public.positionen for update to authenticated using (true) with check (true);
create policy "Team löscht Positionen" on public.positionen for delete to authenticated using (true);

create policy "Team liest Bibliothek" on public.bibliothek for select to authenticated using (true);
create policy "Team legt Bibliothek an" on public.bibliothek for insert to authenticated with check (true);
create policy "Team ändert Bibliothek" on public.bibliothek for update to authenticated using (true) with check (true);

create index positionen_projekt_idx on public.positionen (projekt_id);
create index projekte_created_by_idx on public.projekte (created_by);
create index projekte_updated_by_idx on public.projekte (updated_by);
create index positionen_updated_by_idx on public.positionen (updated_by);
create index bibliothek_updated_by_idx on public.bibliothek (updated_by);

revoke all on public.projekte, public.positionen, public.bibliothek from anon;
