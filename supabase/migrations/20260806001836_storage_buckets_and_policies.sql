-- ============================================================================
-- Migration: storage_buckets_and_policies
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 10)
--
-- Purpose:
--   Provision the three storage buckets from the approved spec §8 and their
--   RLS policies on storage.objects, as SQL rather than relying solely on
--   supabase/config.toml. config.toml's [storage.buckets.*] block controls
--   local `supabase start` provisioning; this migration is what actually
--   creates the buckets on any remote project the migrations are applied
--   to, so local and remote never drift apart. Limits/MIME lists here are
--   kept in exact sync with config.toml — if one changes, the other must
--   too (documented in both places).
--
-- Depends on: 20260805040213_app_admins_and_is_admin.sql (is_admin, used by
--   every write policy below).
--
-- Note: storage.objects already has RLS enabled by default as part of
-- Supabase's managed storage schema — this migration does not (and should
-- not) re-issue `alter table storage.objects enable row level security`.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Buckets
-- ----------------------------------------------------------------------------
-- `on conflict (id) do nothing`: idempotent-safe if a bucket already exists
-- from local `supabase start` reading config.toml directly.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  (
    'public-images',
    'public-images',
    true,
    5242880, -- 5 MiB, matches supabase/config.toml
    array['image/png', 'image/jpeg', 'image/webp', 'image/avif', 'image/svg+xml']
  ),
  (
    'resumes',
    'resumes',
    true,
    10485760, -- 10 MiB, matches supabase/config.toml
    array['application/pdf']
  ),
  (
    'certificates',
    'certificates',
    true,
    10485760, -- 10 MiB, matches supabase/config.toml
    array['application/pdf', 'image/png', 'image/jpeg', 'image/webp']
  )
on conflict (id) do nothing;

-- ----------------------------------------------------------------------------
-- Policies on storage.objects
-- ----------------------------------------------------------------------------
-- One policy set per bucket rather than a single combined policy across all
-- three — matches the per-table policy granularity used everywhere else in
-- Phase 3, and keeps it trivial to change just one bucket's rules later
-- (e.g. if a bucket ever needs to stop being public) without touching the
-- others.
--
-- No folder/path-naming restriction is enforced at the RLS layer (e.g.
-- requiring `(storage.foldername(name))[1] = 'projects'`). The storage
-- path convention documented in docs/06_Supabase/Storage.md is an
-- application-level convention for humans/tooling, not a security
-- boundary — admin write access is already fully trusted (single-owner
-- site), so there is nothing for a folder-naming check to protect against
-- here that is_admin() doesn't already cover.

-- --- public-images -----------------------------------------------------
create policy "Public read access to public-images"
  on storage.objects
  for select
  to anon, authenticated
  using (bucket_id = 'public-images');

create policy "Admins can upload to public-images"
  on storage.objects
  for insert
  to authenticated
  with check (bucket_id = 'public-images' and public.is_admin());

create policy "Admins can update public-images objects"
  on storage.objects
  for update
  to authenticated
  using (bucket_id = 'public-images' and public.is_admin())
  with check (bucket_id = 'public-images' and public.is_admin());

create policy "Admins can delete public-images objects"
  on storage.objects
  for delete
  to authenticated
  using (bucket_id = 'public-images' and public.is_admin());

-- --- resumes -------------------------------------------------------------
create policy "Public read access to resumes"
  on storage.objects
  for select
  to anon, authenticated
  using (bucket_id = 'resumes');

create policy "Admins can upload to resumes"
  on storage.objects
  for insert
  to authenticated
  with check (bucket_id = 'resumes' and public.is_admin());

create policy "Admins can update resumes objects"
  on storage.objects
  for update
  to authenticated
  using (bucket_id = 'resumes' and public.is_admin())
  with check (bucket_id = 'resumes' and public.is_admin());

create policy "Admins can delete resumes objects"
  on storage.objects
  for delete
  to authenticated
  using (bucket_id = 'resumes' and public.is_admin());

-- --- certificates ----------------------------------------------------------
create policy "Public read access to certificates"
  on storage.objects
  for select
  to anon, authenticated
  using (bucket_id = 'certificates');

create policy "Admins can upload to certificates"
  on storage.objects
  for insert
  to authenticated
  with check (bucket_id = 'certificates' and public.is_admin());

create policy "Admins can update certificates objects"
  on storage.objects
  for update
  to authenticated
  using (bucket_id = 'certificates' and public.is_admin())
  with check (bucket_id = 'certificates' and public.is_admin());

create policy "Admins can delete certificates objects"
  on storage.objects
  for delete
  to authenticated
  using (bucket_id = 'certificates' and public.is_admin());
