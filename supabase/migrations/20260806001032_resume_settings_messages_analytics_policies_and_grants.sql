-- ============================================================================
-- Migration: resume_settings_messages_analytics_policies_and_grants
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 9)
--
-- Purpose:
--   Two things, both security-focused, kept together deliberately:
--     1. Add the RLS policies deferred from the previous migration for
--        resume_versions, site_settings, messages, and analytics_events
--        (all four already have RLS *enabled* with zero policies — see
--        that migration's header comment).
--     2. Perform the schema-wide REVOKE/GRANT audit required by the
--        approved Phase 3 spec §6 (security review): explicitly revoke
--        Supabase's broad default table privileges from anon/authenticated
--        across every Phase 3 table, then re-grant only what each table's
--        RLS policies actually rely on. RLS is the primary boundary; this
--        is the defense-in-depth backstop, not a duplicate policy layer —
--        a future RLS policy bug (e.g. an accidentally-permissive `using
--        (true)`) still can't expose a table that has no base table-level
--        grant for anon in the first place.
--
-- Depends on: every table-creating migration so far (all 17 Phase 3 tables
--   must exist for the blanket REVOKE below to apply to all of them).
--
-- Convention for future migrations: any new table created after this one
-- must explicitly GRANT what its own RLS policies need, following the same
-- pattern as below — this migration does NOT set schema-wide default
-- privileges for future tables. That was a deliberate choice: an implicit
-- rule silently applying to tables not yet written is exactly the kind of
-- "spooky action at a distance" this audit exists to move away from
-- (Supabase's own broad defaults being the original example of that
-- problem). Explicit, per-table grants, reviewed in each new table's own
-- migration, are preferred over an invisible blanket rule.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Policies deferred from the previous migration
-- ----------------------------------------------------------------------------

-- resume_versions — unconditionally publicly readable (approved spec §6),
-- admin-only write. Same 4-policy shape as every other public content
-- table.
create policy "Resume versions are publicly readable"
  on public.resume_versions
  for select
  to anon, authenticated
  using (true);

create policy "Admins can insert resume versions"
  on public.resume_versions
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update resume versions"
  on public.resume_versions
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete resume versions"
  on public.resume_versions
  for delete
  to authenticated
  using (public.is_admin());

-- site_settings — same shape. In practice INSERT should essentially never
-- fire again after this migration's structural seed row, but the policy is
-- included for symmetry with every other table and so a deliberate
-- singleton reset (delete + reinsert) remains possible for an admin
-- without a schema change.
create policy "Site settings are publicly readable"
  on public.site_settings
  for select
  to anon, authenticated
  using (true);

create policy "Admins can insert site settings"
  on public.site_settings
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update site settings"
  on public.site_settings
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete site settings"
  on public.site_settings
  for delete
  to authenticated
  using (public.is_admin());

-- messages — admin-only SELECT/UPDATE/DELETE. Deliberately NO INSERT
-- policy for anon or authenticated: see the table's own comment in the
-- previous migration and approved spec §6/§9. Writes happen exclusively
-- through the submit-message Edge Function using service_role, which
-- bypasses RLS entirely and therefore needs no policy here at all.
create policy "Admins can view messages"
  on public.messages
  for select
  to authenticated
  using (public.is_admin());

create policy "Admins can update messages"
  on public.messages
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete messages"
  on public.messages
  for delete
  to authenticated
  using (public.is_admin());

-- analytics_events — admin-only SELECT/DELETE only. No INSERT policy (same
-- reasoning as messages — log-analytics-event Edge Function, service_role
-- only) and deliberately no UPDATE policy either: events are immutable by
-- nature, so there is no legitimate "update an analytics event" operation
-- to authorize in the first place.
create policy "Admins can view analytics events"
  on public.analytics_events
  for select
  to authenticated
  using (public.is_admin());

create policy "Admins can delete analytics events"
  on public.analytics_events
  for delete
  to authenticated
  using (public.is_admin());

-- ----------------------------------------------------------------------------
-- 2. Schema-wide REVOKE / GRANT audit
-- ----------------------------------------------------------------------------
-- Schema-level USAGE on `public` for anon/authenticated is Supabase's own
-- platform-managed baseline and is intentionally left untouched here —
-- revoking it would break access to every table regardless of grants below,
-- and it is not itself a data-exposure risk (USAGE only allows *looking
-- for* objects in the schema, not reading their contents). Only table-level
-- privileges are in scope for this audit.

-- Strip whatever broad default privileges Supabase's initial project
-- provisioning applied (commonly close to ALL PRIVILEGES on every table),
-- across every table this project has defined so far. service_role is
-- deliberately not touched anywhere in this migration — it is managed by
-- the Supabase platform, needs to keep bypassing RLS for the Edge
-- Functions, and revoking anything from it would break them.
revoke all on all tables in schema public from anon, authenticated;

-- --- Group A: public-read, admin-write content tables ----------------------
-- anon: SELECT only. authenticated: full CRUD at the grant level — actual
-- per-row authorization is still enforced by each table's is_admin() RLS
-- policies; the grant only establishes that authenticated is allowed to
-- *attempt* the operation at all.
grant select on
  public.media_assets,
  public.projects,
  public.project_features,
  public.experiences,
  public.education,
  public.skills,
  public.certificates,
  public.blog_tags,
  public.blog_posts,
  public.blog_post_tags,
  public.gallery_items,
  public.testimonials,
  public.resume_versions,
  public.site_settings
to anon, authenticated;

grant insert, update, delete on
  public.media_assets,
  public.projects,
  public.project_features,
  public.experiences,
  public.education,
  public.skills,
  public.certificates,
  public.blog_tags,
  public.blog_posts,
  public.blog_post_tags,
  public.gallery_items,
  public.testimonials,
  public.resume_versions,
  public.site_settings
to authenticated;

-- --- Group B: admin-only tables ---------------------------------------------
-- app_admins: authenticated gets SELECT only — matches its single policy;
-- no write policy exists on this table for authenticated at all (see the
-- app_admins migration), so no write grant is issued either. anon gets
-- nothing.
grant select on public.app_admins to authenticated;

-- messages: authenticated gets SELECT/UPDATE/DELETE, matching the three
-- policies just created above — no INSERT grant, since no INSERT policy
-- exists for authenticated (or anon) on this table.
grant select, update, delete on public.messages to authenticated;

-- analytics_events: authenticated gets SELECT/DELETE only, matching its two
-- policies — no INSERT (Edge Function/service_role only) and no UPDATE
-- (events are immutable).
grant select, delete on public.analytics_events to authenticated;

-- anon gets no grants at all on app_admins, messages, or analytics_events —
-- already true after the blanket REVOKE above; no further statement needed,
-- noted here explicitly so the absence reads as intentional, not missed.
