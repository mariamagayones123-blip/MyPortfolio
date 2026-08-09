-- ============================================================================
-- Migration: extensions_and_helpers
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 1)
--
-- Purpose:
--   Enable the Postgres extensions every later Phase 3 migration depends on,
--   and define the single shared `updated_at` trigger function reused by
--   every table that has an `updated_at` column.
--
-- Scope:
--   - pgcrypto  → gen_random_uuid(), used as the default for every table's
--                 `id` primary key.
--   - vector    → enabled now per the approved Phase 3 spec (§3/§2 of the
--                 Future Scalability review) so that adding an `embedding`
--                 column later is a plain `ALTER TABLE`, not a new-extension
--                 migration. No `embedding` columns are created by this or
--                 any other Phase 3 migration — that remains a future,
--                 explicitly-scoped decision (AI-powered features are not a
--                 Phase 3 concern).
--   - set_updated_at() → generic trigger function; every table created in
--                 later Phase 3 migrations attaches its own
--                 `BEFORE UPDATE ... EXECUTE FUNCTION set_updated_at()`
--                 trigger rather than duplicating this logic per table.
--
-- Out of scope (belongs to later Phase 3 tasks per the Final Migration
-- Order): app_admins, is_admin(), and all content tables.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Extensions
-- ----------------------------------------------------------------------------
-- Installed into the dedicated `extensions` schema (not `public`), matching
-- Supabase convention and this project's `supabase/config.toml`
-- (api.extra_search_path already includes "extensions", so extension
-- functions/types remain resolvable without schema-qualifying every call).
create schema if not exists extensions;

-- gen_random_uuid() — used as every table's primary-key default.
create extension if not exists pgcrypto with schema extensions;

-- vector type — enabled now as a zero-cost future hook (see migration header
-- above). No columns of this type exist yet.
create extension if not exists vector with schema extensions;

-- ----------------------------------------------------------------------------
-- Shared trigger function: keep `updated_at` accurate on every UPDATE
-- ----------------------------------------------------------------------------
-- SECURITY: `search_path` is pinned explicitly, consistent with every other
-- function defined across the Phase 3 migrations (see is_admin() in the next
-- migration for the same rationale) — prevents search_path hijacking and
-- keeps behavior deterministic regardless of the caller's session settings.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

comment on function public.set_updated_at() is
  'Shared BEFORE UPDATE trigger function: sets updated_at = now() on every '
  'row update. Attached per-table by later Phase 3 migrations rather than '
  'duplicated. See docs/05_Database/Database_Design.md.';
