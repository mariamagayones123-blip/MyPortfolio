-- ============================================================================
-- Migration: app_admins_and_is_admin
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 2)
--
-- Purpose:
--   Create the `app_admins` table (the single source of truth for "who is
--   allowed to write to this site's content") and the `is_admin()` helper
--   function every later RLS policy in Phase 3 calls to check it.
--
-- Depends on: 20260805034921_extensions_and_helpers.sql (extensions schema,
--   pgcrypto for gen_random_uuid()).
--
-- Scope boundary (Roadmap Compliance):
--   This table ships EMPTY. No login UI, no signup flow, and no way for the
--   app itself to populate it — that's Phase 10 (Authentication). Until
--   then, the only way to grant admin access is a direct SQL insert against
--   your own Supabase project (Dashboard SQL editor or `psql`), e.g.:
--
--     insert into public.app_admins (user_id)
--     values ('<your-auth-user-uuid>');
--
--   This is intentional, not a gap — see docs/06_Supabase/Authentication.md.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: app_admins
-- ----------------------------------------------------------------------------
-- One row per admin user. Single-owner site today (expected to hold exactly
-- one row in practice), but modeled as a table rather than a hardcoded UUID
-- so adding a second trusted editor later is a data change, not a schema
-- migration (see the approved Phase 3 spec, §7 / Future Scalability review).
create table public.app_admins (
  id uuid primary key default extensions.gen_random_uuid(),
  -- `references auth.users(id)` ties this to Supabase Auth's own user table
  -- rather than a duplicated custom users table. `unique` both enforces
  -- "each auth user can only be an admin once" and doubles as this column's
  -- lookup index (a separate index is redundant — see Index Strategy, §5 of
  -- the approved spec).
  user_id uuid not null unique references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

comment on table public.app_admins is
  'Allow-list of Supabase Auth users permitted to write site content. '
  'Ships empty; populated by direct SQL only until Phase 10 '
  '(Authentication) exists. Read via is_admin(), not queried directly by '
  'RLS policies on other tables.';
comment on column public.app_admins.user_id is
  'References auth.users(id). ON DELETE CASCADE: if the underlying auth '
  'user is ever deleted, their admin grant is removed automatically rather '
  'than leaving an orphaned row.';

-- ----------------------------------------------------------------------------
-- Row Level Security: app_admins is deny-by-default like every other table.
-- ----------------------------------------------------------------------------
alter table public.app_admins enable row level security;

-- Admins can see the admin list (useful once Phase 11 exists). Not `force`d,
-- so the table owner (the role migrations run as) still bypasses RLS for
-- direct SQL/Studio access — this is what makes the manual bootstrap insert
-- documented above possible; service_role bypasses RLS globally regardless.
create policy "Admins can view admin list"
  on public.app_admins
  for select
  to authenticated
  using (public.is_admin());

-- Deliberately no INSERT/UPDATE/DELETE policy for `authenticated`: granting
-- admins themselves. Managing the admin list is a superuser/service-role
-- (SQL editor, Studio, or a future Phase 11 admin-of-admins flow) operation,
-- not something the public API should ever expose — even to an existing
-- admin — without a dedicated, carefully-scoped decision later. Default-deny
-- (RLS enabled, no write policy) is correct here, not an oversight.

-- ----------------------------------------------------------------------------
-- Function: is_admin()
-- ----------------------------------------------------------------------------
-- Used by every RLS write policy in later Phase 3 migrations as
-- `using (public.is_admin())` / `with check (public.is_admin())`.
--
-- SECURITY DEFINER: executes with the privileges of the function's owner
-- (the role migrations run as, which owns app_admins and therefore bypasses
-- its RLS by default) rather than the calling anon/authenticated role. This
-- is what avoids the recursive-lockout footgun identified in the Phase 3
-- security review: without SECURITY DEFINER, a non-admin caller's own
-- restrictive SELECT policy on app_admins (or the complete absence of one)
-- would make is_admin() unable to read app_admins at all, and every policy
-- that depends on it would evaluate to false even for the real admin.
--
-- search_path is pinned explicitly for the same reason as set_updated_at()
-- in the previous migration: a SECURITY DEFINER function must never resolve
-- unqualified identifiers against a caller-influenced search_path, or a
-- malicious schema earlier in that path could shadow `app_admins` and
-- return attacker-controlled results.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.app_admins
    where user_id = auth.uid()
  );
$$;

comment on function public.is_admin() is
  'Returns true iff auth.uid() is a listed admin in app_admins. '
  'SECURITY DEFINER with pinned search_path — see inline comment above and '
  'docs/09_Security/Threat_Model.md. Used by RLS policies on every '
  'content/write-restricted table in Phase 3; never called from the client '
  'directly for authorization decisions (RLS is the enforcement point, this '
  'is just the predicate policies share).';

-- `stable` (not `volatile`): is_admin() only reads data and returns the same
-- result for the same auth.uid() within one statement, which lets Postgres
-- cache/reuse the result when a single query evaluates it against many rows
-- (e.g. a policy check across a multi-row UPDATE) instead of re-executing it
-- per row.

-- Least-privilege execute grants: anon/authenticated need to be able to
-- CALL is_admin() (every RLS policy that references it requires that), but
-- that is exactly what evaluating a USING/CHECK clause containing it does
-- automatically for the querying role — no explicit GRANT EXECUTE is
-- required beyond Postgres's default (EXECUTE is granted to PUBLIC on new
-- functions unless revoked). This default is intentional here: the function
-- itself contains no logic an anon/authenticated caller shouldn't be able to
-- invoke (it only tells you whether *you* are an admin, nothing more).
