-- ============================================================================
-- Migration: resume_settings_messages_analytics
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 8)
--
-- Purpose:
--   Create the four remaining Phase 3 tables — resume_versions,
--   site_settings, messages, analytics_events — per the approved spec
--   §3/§4/§5/§6/§9.
--
-- Depends on:
--   20260805034921_extensions_and_helpers.sql (gen_random_uuid, set_updated_at)
--   20260805040518_media_assets.sql (resume_versions.file_id FK target)
--
-- *** IMPORTANT — RLS/policy sequencing, read before editing this file ***
-- Every table below gets `alter table ... enable row level security`
-- immediately, in THIS migration — RLS is never left disabled, even
-- briefly. What is deferred to the next migration
-- (resume_settings_messages_analytics_policies, Task 9 in the approved
-- plan) is the actual POLICY set for these four tables, because:
--   - `messages` and `analytics_events` need the "no anon INSERT policy at
--     all — writes go through an Edge Function using service_role" design
--     from the approved spec (§6, security review) — a more involved,
--     security-critical decision that deserves its own reviewed migration
--     rather than being rushed inline with basic table DDL for four
--     tables at once.
--   - `site_settings` needs a structural singleton row inserted as part of
--     its own setup (see below) — again cleaner as a focused follow-up.
--
-- Enabling RLS with zero policies here is NOT "insecure in the meantime":
-- RLS-enabled + no policies is Postgres/Supabase's strictest possible
-- state — anon and authenticated get nothing at all (service_role still
-- works, since it bypasses RLS globally regardless of policies). If these
-- migrations are ever applied one at a time rather than as a single batch,
-- there is no window where any of these four tables is unprotected.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: resume_versions
-- ----------------------------------------------------------------------------
-- `is_current` is deliberately NOT a column here — see the approved Final
-- Architecture Specification, §3: the original draft had both
-- resume_versions.is_current and site_settings.resume_current_version_id,
-- two disagreeing sources of truth for "which résumé is live". The latter
-- (below) is the sole source of truth.
create table public.resume_versions (
  id uuid primary key default extensions.gen_random_uuid(),
  -- Required, not nullable: a résumé version's entire purpose is the file.
  -- ON DELETE CASCADE (not SET NULL, unlike certificates.file_id): a
  -- résumé version with no file is meaningless, so removing the underlying
  -- media removes the version record with it.
  file_id uuid not null references public.media_assets (id) on delete cascade,
  label text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.resume_versions is
  'Résumé file history (Resume section, Phase 9 UI). "Current" résumé is '
  'tracked solely by site_settings.resume_current_version_id, not a column '
  'on this table — see the Final Architecture Specification §3. '
  'Unconditionally publicly readable per approved spec §6 (all versions, '
  'not just the current one — no visibility-restricting column exists on '
  'this table by design).';

create index resume_versions_file_id_idx on public.resume_versions (file_id);

create trigger set_resume_versions_updated_at
  before update on public.resume_versions
  for each row
  execute function public.set_updated_at();

alter table public.resume_versions enable row level security;
-- Policies: see resume_settings_messages_analytics_policies migration.

-- ----------------------------------------------------------------------------
-- Table: site_settings
-- ----------------------------------------------------------------------------
-- Singleton-table pattern: `id` is a boolean primary key that can only ever
-- be `true` (enforced by the CHECK below), so a second row's insert
-- violates the primary key — Postgres cannot hold two rows with the same
-- PK value, and no other PK value is legal. This is a well-known idiom for
-- "exactly one row, enforced by the schema itself" rather than a UUID PK
-- plus an application-level convention that could be violated by a bad
-- insert.
create table public.site_settings (
  id boolean primary key default true,
  resume_current_version_id uuid references public.resume_versions (id) on delete set null,
  availability_status text,
  contact_email text check (contact_email is null or contact_email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  social_links jsonb not null default '{}'::jsonb,
  seo_defaults jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint site_settings_singleton check (id)
);

comment on table public.site_settings is
  'Single-row site-wide configuration. Singleton enforced by the boolean '
  'primary key + CHECK(id) pattern, not application convention — see '
  'inline comment above. Unconditionally publicly readable.';
comment on column public.site_settings.resume_current_version_id is
  'Sole source of truth for "which résumé is live" — see resume_versions '
  'comment above and the Final Architecture Specification §3.';
comment on column public.site_settings.availability_status is
  'Deliberately unconstrained text, not an enum — the approved spec named '
  'this column without specifying a fixed value set, and inventing one in '
  'a migration would be a product decision beyond Phase 3''s scope. Adding '
  'a CHECK/enum later, once the actual values are decided, is a cheap '
  'follow-up, not a large migration.';

create trigger set_site_settings_updated_at
  before update on public.site_settings
  for each row
  execute function public.set_updated_at();

alter table public.site_settings enable row level security;
-- Policies: see resume_settings_messages_analytics_policies migration.

-- Structural seed: a singleton table is unusable until its one row exists
-- (UPDATE against zero rows is a silent no-op) — this INSERT is part of
-- the table's own setup, not sample/dev-only content, and so belongs here
-- rather than supabase/seed.sql. Runs as the migration's owning role,
-- which bypasses the RLS just enabled above.
insert into public.site_settings (id) values (true);

-- ----------------------------------------------------------------------------
-- Enum: message_status
-- ----------------------------------------------------------------------------
create type public.message_status as enum ('unread', 'read', 'archived');

-- ----------------------------------------------------------------------------
-- Table: messages
-- ----------------------------------------------------------------------------
-- Contact form submissions. Per the approved spec §6/§9 (security review):
-- there is intentionally NO anon INSERT policy on this table at all — see
-- the policies migration. All writes happen through the `submit-message`
-- Edge Function using the service_role key, which computes ip_hash
-- server-side and bypasses RLS entirely. A plain RLS `with check (true)`
-- INSERT policy was the original (rejected) design: it cannot stop a
-- client from setting `status` or `ip_hash` to arbitrary values on their
-- own insert, since RLS restricts *whether* a row may be written, not
-- *which columns* the client controls.
create table public.messages (
  id uuid primary key default extensions.gen_random_uuid(),
  name text not null,
  email text not null check (email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  subject text,
  body text not null,
  status public.message_status not null default 'unread',
  honeypot_flagged boolean not null default false,
  -- SHA-256 of the submitter's IP, computed by the Edge Function — never
  -- the raw IP (see approved spec §16, Security Considerations).
  ip_hash text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.messages is
  'Contact form submissions (Contact section, Phase 9 UI). No anon INSERT '
  'policy exists on this table — writes only happen via the '
  'submit-message Edge Function (service_role, bypasses RLS). See '
  'supabase/functions/submit-message and docs/09_Security/Threat_Model.md.';
comment on column public.messages.ip_hash is
  'SHA-256 of the submitter''s IP address. Never the raw IP — used only '
  'for basic rate-limiting lookups, not stored as identifiable PII.';

create index messages_status_created_at_idx on public.messages (status, created_at desc);
create index messages_ip_hash_idx on public.messages (ip_hash);

create trigger set_messages_updated_at
  before update on public.messages
  for each row
  execute function public.set_updated_at();

alter table public.messages enable row level security;
-- Policies: see resume_settings_messages_analytics_policies migration.
-- (Deliberately no INSERT policy will be added there either — see comment
-- above and on the table itself.)

-- ----------------------------------------------------------------------------
-- Enum: analytics_event_type
-- ----------------------------------------------------------------------------
-- A starting set matching the AI Development Specification's named
-- examples. Adding a value later is a cheap `alter type ... add value`,
-- not a breaking migration — this list is expected to grow.
create type public.analytics_event_type as enum (
  'page_view',
  'project_click',
  'resume_download',
  'contact_submit',
  'external_link_click'
);

-- ----------------------------------------------------------------------------
-- Table: analytics_events
-- ----------------------------------------------------------------------------
-- Same "no anon INSERT policy — Edge Function only" design as messages,
-- via the log-analytics-event Edge Function. No updated_at/trigger: events
-- are immutable/append-only by nature, same reasoning as blog_post_tags
-- (nothing here is ever legitimately updated after insert).
create table public.analytics_events (
  id uuid primary key default extensions.gen_random_uuid(),
  event_type public.analytics_event_type not null,
  path text,
  referrer text,
  -- Random per-browser-session identifier, generated client-side and
  -- reused across every event in one session — NOT defaulted here, since a
  -- server-side default would generate a new value per row instead of
  -- grouping a session's events together. Non-PII by design (approved
  -- spec §16): no raw IP or user-agent is ever stored on this table.
  session_id uuid not null,
  created_at timestamptz not null default now()
);

comment on table public.analytics_events is
  'Privacy-conscious analytics (no raw IP/user-agent stored — see approved '
  'spec §16). No anon INSERT policy — writes only via the '
  'log-analytics-event Edge Function. Append-only: no updated_at column, '
  'no UPDATE policy will be added in the follow-up migration either.';
comment on column public.analytics_events.session_id is
  'Random UUID generated client-side per browser session, not per event — '
  'groups related events together without identifying the visitor.';

create index analytics_events_type_created_at_idx
  on public.analytics_events (event_type, created_at desc);

alter table public.analytics_events enable row level security;
-- Policies: see resume_settings_messages_analytics_policies migration.
