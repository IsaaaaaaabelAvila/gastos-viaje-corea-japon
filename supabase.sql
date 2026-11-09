-- =====================================================================
--  Viaje Corea + Japón 2027 · Isa e Iván
--  Pega TODO este archivo en Supabase > SQL Editor > New query > Run.
--  Es seguro correrlo más de una vez (no duplica nada).
--
--  Los dos correos autorizados están en la función es_viajero() de abajo.
--  Si algún día quieres cambiarlos, edita esa función y vuelve a correrla.
-- =====================================================================

-- 1) GASTOS ------------------------------------------------------------
create table if not exists public.gastos (
  id            uuid primary key default gen_random_uuid(),
  fecha         date          not null default current_date,
  monto         numeric(14,2) not null check (monto >= 0),
  moneda        text          not null check (moneda in ('MXN','KRW','JPY')),
  categoria     text          not null,
  pagado_por    text          not null check (pagado_por in ('isa','ivan')),
  para_quien    text          not null check (para_quien in ('isa','ivan','compartido')),
  metodo        text          check (metodo in ('efectivo','tarjeta')),
  cuenta        text,                       -- tarjeta usada, o cuenta de donde se retiró el efectivo
  ciudad        text,
  pais          text          check (pais in ('kr','jp','otro')),
  nota          text,
  tc            numeric(18,8) not null default 1,   -- MXN por 1 unidad de la moneda, al momento del registro
  monto_mxn     numeric(14,2) not null,
  tipo          text          not null default 'gasto' check (tipo in ('gasto','ajuste')),
  registrado_por text,                      -- correo de quien lo capturó
  created_at    timestamptz   not null default now(),
  updated_at    timestamptz   not null default now()
);

create index if not exists gastos_fecha_idx on public.gastos (fecha desc);

-- 2) CONFIGURACIÓN COMPARTIDA (tramos, presupuestos, tipo de cambio, etc.)
create table if not exists public.config (
  key         text primary key,
  value       jsonb not null,
  updated_at  timestamptz not null default now(),
  updated_by  text
);

-- 3) SOLO ISA E IVÁN ---------------------------------------------------
create or replace function public.es_viajero()
returns boolean
language sql
stable
set search_path = ''
as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) in (
    'avilaisabel1218@gmail.com',     -- Isa
    'ivan.maceda.2309@gmail.com'     -- Iván
  );
$$;

alter table public.gastos enable row level security;
alter table public.config enable row level security;

drop policy if exists "viajeros_gastos" on public.gastos;
create policy "viajeros_gastos" on public.gastos
  for all to authenticated
  using (public.es_viajero())
  with check (public.es_viajero());

drop policy if exists "viajeros_config" on public.config;
create policy "viajeros_config" on public.config
  for all to authenticated
  using (public.es_viajero())
  with check (public.es_viajero());

revoke all on public.gastos from anon;
revoke all on public.config from anon;
grant select, insert, update, delete on public.gastos to authenticated;
grant select, insert, update, delete on public.config to authenticated;

-- 4) updated_at automático ---------------------------------------------
create or replace function public.tocar_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists gastos_updated on public.gastos;
create trigger gastos_updated before update on public.gastos
  for each row execute function public.tocar_updated_at();

drop trigger if exists config_updated on public.config;
create trigger config_updated before update on public.config
  for each row execute function public.tocar_updated_at();

-- 5) TIEMPO REAL -------------------------------------------------------
alter table public.gastos replica identity full;
alter table public.config replica identity full;

do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'gastos') then
    alter publication supabase_realtime add table public.gastos;
  end if;
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'config') then
    alter publication supabase_realtime add table public.config;
  end if;
end $$;

-- 6) DATOS PRECARGADOS -------------------------------------------------
-- Vuelos ya pagados (la fecha es la de compra aproximada; se pueden editar desde la app)
insert into public.gastos
  (id, fecha, monto, moneda, categoria, pagado_por, para_quien, metodo, cuenta, ciudad, pais, nota, tc, monto_mxn, tipo, registrado_por)
values
  ('a0000000-0000-4000-8000-000000000001', '2026-11-01', 22601.04, 'MXN', 'Vuelos', 'isa',  'isa',  'tarjeta', null, null, 'otro',
   'Vuelo redondo a Corea (precargado)', 1, 22601.04, 'gasto', 'avilaisabel1218@gmail.com'),
  ('a0000000-0000-4000-8000-000000000002', '2026-11-01', 22601.04, 'MXN', 'Vuelos', 'ivan', 'ivan', 'tarjeta', null, null, 'otro',
   'Vuelo redondo a Corea (precargado)', 1, 22601.04, 'gasto', 'ivan.maceda.2309@gmail.com')
on conflict (id) do nothing;

-- Configuración inicial (se puede cambiar desde Ajustes en la app)
insert into public.config (key, value) values
  ('viaje',   '{"inicio":"2027-07-12","fin":"2027-07-29","presupuesto":{"isa":120000,"ivan":120000}}'),
  ('tramos',  '[{"pais":"kr","desde":"2027-07-12","hasta":"2027-07-16"},{"pais":"jp","desde":"2027-07-17","hasta":"2027-07-25"},{"pais":"kr","desde":"2027-07-26","hasta":"2027-07-29"}]'),
  ('tc',      '{"KRW":0.0135,"JPY":0.125,"fecha":null}'),
  ('ciudades','[{"n":"Seúl","p":"kr"},{"n":"Busan","p":"kr"},{"n":"Incheon","p":"kr"},{"n":"Jeju","p":"kr"},{"n":"Tokio","p":"jp"},{"n":"Osaka","p":"jp"},{"n":"Kioto","p":"jp"},{"n":"Nara","p":"jp"},{"n":"Fukuoka","p":"jp"}]'),
  ('cuentas', '{"tarjetas":["Tarjeta Isa","Tarjeta Iván"],"cuentas":["Cuenta Isa","Cuenta Iván"]}'),
  ('presCat', '{}')
on conflict (key) do nothing;

-- 7) SOLO ISA E IVÁN PUEDEN CREAR CUENTA (correo + contraseña, sin enviar correos) ----------
-- Bloquea cualquier registro con otro correo. (Ya aplicado en el proyecto.)
create or replace function public.bloquear_registro_ajeno()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if lower(coalesce(new.email, '')) not in ('avilaisabel1218@gmail.com', 'ivan.maceda.2309@gmail.com') then
    raise exception 'Registro no permitido';
  end if;
  return new;
end;
$$;
revoke all on function public.bloquear_registro_ajeno() from public, anon, authenticated;

drop trigger if exists solo_viajeros on auth.users;
create trigger solo_viajeros before insert on auth.users
  for each row execute function public.bloquear_registro_ajeno();

-- La Edge Function "registro" (supabase/functions/registro/index.ts) crea la cuenta ya confirmada
-- para esos dos correos, así no depende de ningún correo de confirmación.
