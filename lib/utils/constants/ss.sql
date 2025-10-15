create table public.vendors (
  id uuid not null default gen_random_uuid (),
  user_id uuid null,
  organization_name text not null,
  organization_bio text null default ''::text,
  banner_image text null default ''::text,
  organization_logo text null default ''::text,
  organization_cover text null default ''::text,
  brief text null,
  exclusive_id text null default ''::text,
  store_message text null default ''::text,
  in_exclusive boolean null default false,
  is_subscriber boolean null default false,
  is_verified boolean null default false,
  is_royal boolean null default false,
  enable_iwinto_payment boolean null default false,
  enable_cod boolean null default false,
  organization_deleted boolean null default false,
  organization_activated boolean null default true,
  default_currency text null default 'USD'::text,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  selected_major_categories text null,
  share_count integer null default 0,
  constraint vendors_pkey primary key (id),
  constraint vendors_slugn_key unique (brief),
  constraint vendors_user_id_fkey foreign KEY (user_id) references user_profiles (id) on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_vendors_user_id on public.vendors using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_vendors_slugn on public.vendors using btree (brief) TABLESPACE pg_default;

create index IF not exists idx_vendors_is_verified on public.vendors using btree (is_verified) TABLESPACE pg_default;

create index IF not exists idx_vendors_organization_activated on public.vendors using btree (organization_activated) TABLESPACE pg_default;

create index IF not exists idx_vendors_share_count on public.vendors using btree (share_count desc) TABLESPACE pg_default;

create index IF not exists idx_vendors_id on public.vendors using btree (id) TABLESPACE pg_default;

create index IF not exists idx_vendors_name on public.vendors using btree (organization_name) TABLESPACE pg_default;

create index IF not exists idx_vendors_bio on public.vendors using btree (organization_bio) TABLESPACE pg_default;

create index IF not exists idx_vendors_activated on public.vendors using btree (organization_activated) TABLESPACE pg_default;

create index IF not exists idx_vendors_deleted on public.vendors using btree (organization_deleted) TABLESPACE pg_default;

create index IF not exists idx_vendors_verified on public.vendors using btree (is_verified) TABLESPACE pg_default;

create index IF not exists idx_vendors_name_gin on public.vendors using gin (
  to_tsvector('arabic'::regconfig, organization_name)
) TABLESPACE pg_default;

create index IF not exists idx_vendors_bio_gin on public.vendors using gin (
  to_tsvector('arabic'::regconfig, organization_bio)
) TABLESPACE pg_default;

create trigger trigger_auto_create_vendor_sections
after INSERT on vendors for EACH row
execute FUNCTION auto_create_vendor_sections ();

create trigger trigger_vendors_search_refresh
after INSERT
or DELETE
or
update on vendors for EACH STATEMENT
execute FUNCTION trigger_refresh_search_on_vendors ();

create trigger update_vendors_updated_at BEFORE
update on vendors for EACH row
execute FUNCTION update_updated_at_column ();

create table public.user_profiles (
  id uuid not null default gen_random_uuid (),
  user_id text not null,
  username text null,
  name text not null default ''::text,
  email text null,
  phone_number text null,
  profile_image text null default ''::text,
  bio text null default ''::text,
  brief text null default ''::text,
  is_active boolean null default true,
  email_verified boolean null default false,
  phone_verified boolean null default false,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  default_currency text null default 'USD'::text,
  account_type numeric null default '0'::numeric,
  cover text null,
  constraint users_pkey primary key (id),
  constraint users_email_key unique (email),
  constraint users_user_id_key unique (user_id),
  constraint users_username_key unique (username)
) TABLESPACE pg_default;

create index IF not exists idx_users_user_id on public.user_profiles using btree (user_id) TABLESPACE pg_default;

create index IF not exists idx_users_username on public.user_profiles using btree (username) TABLESPACE pg_default;

create index IF not exists idx_users_email on public.user_profiles using btree (email) TABLESPACE pg_default;

create index IF not exists idx_users_is_active on public.user_profiles using btree (is_active) TABLESPACE pg_default;

create index IF not exists idx_user_profiles_cover on public.user_profiles using btree (cover) TABLESPACE pg_default
where
  (
    (cover is not null)
    and (cover <> ''::text)
  );

create trigger update_users_updated_at BEFORE
update on user_profiles for EACH row
execute FUNCTION update_updated_at_column ();