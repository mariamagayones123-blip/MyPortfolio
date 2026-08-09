-- ============================================================================
-- Migration: media_assets
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 3)
--
-- Purpose:
--   Create the shared `media_assets` table — the single place every file
--   attached to any content table (project covers, certificates, blog
--   covers, testimonial avatars, résumé PDFs, gallery images) is described:
--   its storage location, accessibility text, MIME type, and dimensions.
--   Per the approved Media Asset Strategy (Phase 3 spec §2), tables that
--   hold a file reference a row here by id rather than storing a bare
--   storage path themselves — created in a later migration once
--   media_assets exists for them to reference.
--
-- Depends on:
--   20260805034921_extensions_and_helpers.sql (extensions.gen_random_uuid(),
--     public.set_updated_at())
--   20260805040213_app_admins_and_is_admin.sql (public.is_admin())
--
-- Note on timestamps: the approved spec's per-table column list (§2) showed
-- only `created_at` for media_assets, but its consolidated Final Schema
-- table (§3) states every table gets `id`/`created_at`/`updated_at` as a
-- baseline. `updated_at` is applied here to resolve that in favor of the
-- more general rule — media metadata (most notably `alt_text`) is exactly
-- the kind of field expected to be corrected after the fact (e.g. from the
-- Phase 11 admin dashboard), so tracking edits is genuinely useful here,
-- not just mechanical consistency.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: media_assets
-- ----------------------------------------------------------------------------
create table public.media_assets (
  id uuid primary key default extensions.gen_random_uuid(),

  -- Matches the three buckets declared in supabase/config.toml exactly.
  -- A `check` constraint (not a Postgres enum type) because this set is
  -- tightly coupled to Storage bucket configuration rather than an
  -- independent domain concept — see approved spec §3, which types this
  -- column as plain `text`.
  bucket text not null check (bucket in ('public-images', 'resumes', 'certificates')),

  -- Full path within the bucket, e.g. "projects/<project_id>/cover.webp".
  -- Unique because a storage object should only ever be described by one
  -- media_assets row; this also serves as the lookup index for the path
  -- itself (a separate index would be redundant).
  storage_path text not null unique,

  -- Required for images (accessibility — WCAG AA per the Design System's
  -- own requirement), optional for non-image files (a résumé PDF has no
  -- meaningful "alt text"). Enforced below, not just by convention.
  alt_text text,

  mime_type text not null,

  file_size_bytes integer not null check (file_size_bytes > 0),

  -- Nullable: only meaningful for images, and only known once the file has
  -- actually been processed/measured (not necessarily at insert time).
  width integer check (width is null or width > 0),
  height integer check (height is null or height > 0),

  -- Nullable because Phase 3 has no authentication yet — early media rows
  -- (inserted manually alongside early content, per docs/06_Supabase/
  -- Authentication.md) will have no uploader. `on delete set null` (not
  -- `cascade`, unlike app_admins.user_id): removing an auth user should
  -- never delete the media they uploaded, only its attribution.
  uploaded_by uuid references auth.users (id) on delete set null,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  -- Accessibility enforcement: any row whose mime_type is an image type
  -- must carry alt_text. Non-image rows (PDFs, etc.) are unconstrained.
  constraint media_assets_alt_text_required_for_images
    check (mime_type not like 'image/%' or alt_text is not null)
);

comment on table public.media_assets is
  'Shared metadata for every uploaded file, across all three storage '
  'buckets. Content tables reference a row here (e.g. projects.cover_'
  'image_id) instead of storing a bare storage path themselves — see the '
  'approved Phase 3 spec, Media Asset Strategy (§2), and '
  'docs/05_Database/Database_Design.md.';
comment on column public.media_assets.bucket is
  'One of the three buckets declared in supabase/config.toml: '
  'public-images, resumes, certificates.';
comment on column public.media_assets.storage_path is
  'Path convention: {entity}/{entity_id}/{filename} within the bucket, '
  'e.g. projects/<project_id>/cover.webp — see approved spec §6 (Storage '
  'Buckets).';
comment on column public.media_assets.alt_text is
  'Required (enforced by media_assets_alt_text_required_for_images) when '
  'mime_type is an image type. Null is valid for non-image files.';
comment on column public.media_assets.uploaded_by is
  'References auth.users(id). ON DELETE SET NULL: deleting the uploader '
  'account does not delete their uploaded media, only its attribution — '
  'contrast with app_admins.user_id, which cascades.';

-- ----------------------------------------------------------------------------
-- Indexes
-- ----------------------------------------------------------------------------
-- Supports "list all assets in a given bucket" (e.g. a future Phase 11
-- media-library view) without a full table scan.
create index media_assets_bucket_idx on public.media_assets (bucket);

-- FK column — Postgres does not index foreign keys automatically, and this
-- one will be looked up whenever attribution/ownership matters.
create index media_assets_uploaded_by_idx on public.media_assets (uploaded_by);

-- ----------------------------------------------------------------------------
-- updated_at trigger (shared function from the extensions_and_helpers migration)
-- ----------------------------------------------------------------------------
create trigger set_media_assets_updated_at
  before update on public.media_assets
  for each row
  execute function public.set_updated_at();

-- ----------------------------------------------------------------------------
-- Row Level Security
-- ----------------------------------------------------------------------------
alter table public.media_assets enable row level security;

-- Public content table (approved spec §6): no status column, so read access
-- is unconditional rather than filtered — every bucket this table describes
-- is itself public-read (approved spec §8), so exposing this metadata adds
-- no new exposure beyond what Storage already serves.
create policy "Media assets are publicly readable"
  on public.media_assets
  for select
  to anon, authenticated
  using (true);

create policy "Admins can insert media assets"
  on public.media_assets
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update media assets"
  on public.media_assets
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete media assets"
  on public.media_assets
  for delete
  to authenticated
  using (public.is_admin());
