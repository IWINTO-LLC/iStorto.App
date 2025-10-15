-- Vendor Social Links - Complete Setup Script
-- Safe to run multiple times; includes IF NOT EXISTS guards and idempotent drops

-- 0) Required extension for gen_random_uuid()
create extension if not exists pgcrypto;

-- 1) Enum for link types
create type if not exists public.social_link_type as enum (
  'website',
  'email',
  'whatsapp',
  'phone',
  'location',
  'linkedin',
  'youtube'
);

-- 2) Table for vendor social links
-- Assumptions:
-- - public.vendors(id uuid, user_id uuid) exists
-- - user_id in vendors table maps to auth.uid() for ownership
create table if not exists public.vendor_social_links (
  id uuid primary key default gen_random_uuid(),
  vendor_id uuid not null references public.vendors(id) on delete cascade,
  type public.social_link_type not null,
  value text not null default '',
  enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint vendor_social_links_vendor_type_unique unique (vendor_id, type)
);

-- 2.a) Migration guard: ensure required columns exist if table pre-existed
alter table public.vendor_social_links
  add column if not exists value text;
alter table public.vendor_social_links
  add column if not exists enabled boolean;
-- Ensure 'vendor_id' column exists first
alter table public.vendor_social_links
  add column if not exists vendor_id uuid;
-- Ensure 'type' column exists (enum) - must come after vendor_id
alter table public.vendor_social_links
  add column if not exists type public.social_link_type;
alter table public.vendor_social_links
  add column if not exists created_at timestamptz;
alter table public.vendor_social_links
  add column if not exists updated_at timestamptz;

-- Set defaults and not-null where missing
update public.vendor_social_links set value = coalesce(value, '') where value is null;
update public.vendor_social_links set enabled = coalesce(enabled, false) where enabled is null;
-- Backfill type with a safe default for any nulls (choose 'website')
update public.vendor_social_links set type = 'website'::public.social_link_type where type is null;

-- Handle case where type column exists but is not the correct enum type
do $$
begin
  -- Check if type column exists but is not the correct enum type
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'vendor_social_links' and column_name = 'type'
      and udt_name != 'social_link_type'
  ) then
    -- Drop and recreate the type column with correct enum type
    alter table public.vendor_social_links drop column if exists type;
    alter table public.vendor_social_links add column type public.social_link_type default 'website';
  end if;
end$$;

alter table public.vendor_social_links alter column value set not null;
alter table public.vendor_social_links alter column enabled set not null;
alter table public.vendor_social_links alter column type set not null;
alter table public.vendor_social_links alter column value set default '';
alter table public.vendor_social_links alter column enabled set default false;
alter table public.vendor_social_links alter column created_at set default now();
alter table public.vendor_social_links alter column updated_at set default now();

-- 2.b) Ensure unique constraint (vendor_id, type)
do $$
begin
  -- Only attempt to create the unique constraint if both columns exist and have correct types
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'vendor_social_links' and column_name = 'vendor_id'
      and udt_name = 'uuid'
  ) and exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'vendor_social_links' and column_name = 'type'
      and udt_name = 'social_link_type'
  ) then
    if not exists (
      select 1 from pg_constraint where conname = 'vendor_social_links_vendor_type_unique'
    ) then
      alter table public.vendor_social_links
        add constraint vendor_social_links_vendor_type_unique unique (vendor_id, type);
    end if;
  end if;
end$$;

-- 3) Timestamp trigger to maintain updated_at
create or replace function public.set_timestamp_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_vendor_social_links_updated_at on public.vendor_social_links;
create trigger trg_vendor_social_links_updated_at
before update on public.vendor_social_links
for each row execute function public.set_timestamp_updated_at();

-- 4) Enable Row Level Security
alter table public.vendor_social_links enable row level security;

-- 5) Policies
-- Read: public can read enabled links; owners can read all
drop policy if exists vendor_social_links_select on public.vendor_social_links;
create policy vendor_social_links_select
on public.vendor_social_links
for select
using (
  enabled
  or exists (
    select 1
    from public.vendors v
    join public.user_profiles up on up.id = v.user_id
    where v.id = vendor_social_links.vendor_id
      and up.user_id = auth.uid()::text
  )
);

-- Insert: only owners
drop policy if exists vendor_social_links_insert on public.vendor_social_links;
create policy vendor_social_links_insert
on public.vendor_social_links
for insert
with check (
  exists (
    select 1
    from public.vendors v
    join public.user_profiles up on up.id = v.user_id
    where v.id = vendor_social_links.vendor_id
      and up.user_id = auth.uid()::text
  )
);

-- Update: only owners
drop policy if exists vendor_social_links_update on public.vendor_social_links;
create policy vendor_social_links_update
on public.vendor_social_links
for update
using (
  exists (
    select 1
    from public.vendors v
    join public.user_profiles up on up.id = v.user_id
    where v.id = vendor_social_links.vendor_id
      and up.user_id = auth.uid()::text
  )
)
with check (
  exists (
    select 1
    from public.vendors v
    join public.user_profiles up on up.id = v.user_id
    where v.id = vendor_social_links.vendor_id
      and up.user_id = auth.uid()::text
  )
);

-- Delete: only owners
drop policy if exists vendor_social_links_delete on public.vendor_social_links;
create policy vendor_social_links_delete
on public.vendor_social_links
for delete
using (
  exists (
    select 1
    from public.vendors v
    join public.user_profiles up on up.id = v.user_id
    where v.id = vendor_social_links.vendor_id
      and up.user_id = auth.uid()::text
  )
);

-- 6) Upsert RPC for convenience
create or replace function public.upsert_vendor_social_link(
  p_vendor_id uuid,
  p_type public.social_link_type,
  p_value text,
  p_enabled boolean
)
returns public.vendor_social_links
language sql
security invoker
as $$
  insert into public.vendor_social_links (vendor_id, type, value, enabled)
  values (p_vendor_id, p_type, coalesce(p_value, ''), coalesce(p_enabled, false))
  on conflict (vendor_id, type)
  do update set
    value = excluded.value,
    enabled = excluded.enabled,
    updated_at = now()
  returning *;
$$;

-- 7) Optional public view for enabled links
create or replace view public.vendor_social_links_public as
select
  vsl.vendor_id,
  vsl.type,
  vsl.value
from public.vendor_social_links vsl
where vsl.enabled = true;


