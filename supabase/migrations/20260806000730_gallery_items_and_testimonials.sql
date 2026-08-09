-- ============================================================================
-- Migration: gallery_items_and_testimonials
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 7)
--
-- Purpose:
--   Create gallery_items and testimonials per the approved Phase 3 spec
--   §2/§3/§4/§5/§6. Both are independent, flat tables — no relationship to
--   each other. Self-contained: table, indexes, trigger, and full RLS all
--   applied inline, same pattern as every migration since Task 4.
--
-- Depends on:
--   20260805034921_extensions_and_helpers.sql (gen_random_uuid, set_updated_at)
--   20260805040213_app_admins_and_is_admin.sql (is_admin)
--   20260805040518_media_assets.sql (gallery_items.media_id,
--     testimonials.author_avatar_id FK targets)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: gallery_items
-- ----------------------------------------------------------------------------
-- Per the approved Media Asset Strategy (§2): "a gallery item *is* a media
-- asset + caption + order, nothing else" — media_id is required, not
-- nullable, and this table stores no bucket/path/mime data of its own.
create table public.gallery_items (
  id uuid primary key default extensions.gen_random_uuid(),
  media_id uuid not null references public.media_assets (id) on delete cascade,
  caption text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.gallery_items is
  'Gallery/photos (Gallery section, Phase 8 UI). A thin wrapper around a '
  'required media_assets row plus a caption and sort order — see approved '
  'spec §2, Media Asset Strategy. ON DELETE CASCADE from media_assets: '
  'unlike certificates/testimonials (where the file is incidental to a '
  'record that still means something without it), a gallery item has no '
  'purpose once its underlying media is gone.';

-- FK column — not auto-indexed by Postgres. No dedicated sort_order index:
-- a photo gallery is expected to hold, realistically, dozens of rows at
-- most — a sequential scan + sort costs nothing at that scale, and an
-- index would be pure write overhead with no measurable read benefit (same
-- reasoning applied to experiences/education/skills/certificates in the
-- previous migration).
create index gallery_items_media_id_idx on public.gallery_items (media_id);

create trigger set_gallery_items_updated_at
  before update on public.gallery_items
  for each row
  execute function public.set_updated_at();

alter table public.gallery_items enable row level security;

create policy "Gallery items are publicly readable"
  on public.gallery_items
  for select
  to anon, authenticated
  using (true);

create policy "Admins can insert gallery items"
  on public.gallery_items
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update gallery items"
  on public.gallery_items
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete gallery items"
  on public.gallery_items
  for delete
  to authenticated
  using (public.is_admin());

-- ----------------------------------------------------------------------------
-- Enum: testimonial_status
-- ----------------------------------------------------------------------------
-- Distinct from content_status (draft/published) — testimonials have their
-- own three-state moderation lifecycle, so this is its own type rather than
-- reusing or overloading content_status.
create type public.testimonial_status as enum ('pending', 'approved', 'hidden');

comment on type public.testimonial_status is
  'testimonials.status moderation lifecycle. pending = newly added, not '
  'yet reviewed; approved = publicly visible; hidden = reviewed but '
  'deliberately not shown. Moderation UI is Phase 11, not Phase 3.';

-- ----------------------------------------------------------------------------
-- Table: testimonials
-- ----------------------------------------------------------------------------
-- Admin-curated, not a public submission form: unlike `messages`, there is
-- no anon INSERT path here or planned for one — the AI Development
-- Specification describes testimonials as portfolio content (e.g.
-- recommendations the owner adds), not an open public form. All writes are
-- admin-only, same as every other content table.
create table public.testimonials (
  id uuid primary key default extensions.gen_random_uuid(),
  author_name text not null,
  author_title text,
  author_company text,
  author_avatar_id uuid references public.media_assets (id) on delete set null,
  quote text not null,
  status public.testimonial_status not null default 'pending',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.testimonials is
  'Recommendations/testimonials (Testimonials section, Phase 6/7 UI). '
  'Public reads restricted to status = ''approved'' via RLS below — '
  '''pending''/''hidden'' stay invisible until moderated (Phase 11).';

-- Mirrors the projects/blog_posts pattern: a status column with real
-- selectivity (most rows are eventually 'approved', but 'pending'/'hidden'
-- must never leak) justifies a partial + composite index, unlike the flat
-- resume tables which have no filtering dimension at all.
create index testimonials_approved_idx on public.testimonials (status) where status = 'approved';
create index testimonials_status_sort_order_idx on public.testimonials (status, sort_order);
create index testimonials_author_avatar_id_idx on public.testimonials (author_avatar_id);

create trigger set_testimonials_updated_at
  before update on public.testimonials
  for each row
  execute function public.set_updated_at();

alter table public.testimonials enable row level security;

create policy "Approved testimonials are publicly readable"
  on public.testimonials
  for select
  to anon, authenticated
  using (status = 'approved');

create policy "Admins can insert testimonials"
  on public.testimonials
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update testimonials"
  on public.testimonials
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete testimonials"
  on public.testimonials
  for delete
  to authenticated
  using (public.is_admin());
