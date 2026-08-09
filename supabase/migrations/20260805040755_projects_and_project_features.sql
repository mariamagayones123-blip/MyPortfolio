-- ============================================================================
-- Migration: projects_and_project_features
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 4)
--
-- Purpose:
--   Create `projects` (the Projects Showcase content table) and its 1:many
--   child `project_features` (per-project feature bullets), per the
--   approved Phase 3 spec §3/§4/§5/§6/§11.
--
-- Depends on:
--   20260805034921_extensions_and_helpers.sql (gen_random_uuid, set_updated_at)
--   20260805040213_app_admins_and_is_admin.sql (is_admin)
--   20260805040518_media_assets.sql (cover_image_id FK target)
--
-- Introduces: public.content_status enum ('draft', 'published') — shared,
--   reused by blog_posts in a later migration rather than redefined, since
--   both tables need identical draft/published semantics.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Shared enum: content_status
-- ----------------------------------------------------------------------------
create type public.content_status as enum ('draft', 'published');

comment on type public.content_status is
  'Shared publish-state enum for content tables (projects, blog_posts). '
  'A single definition, not a per-table CHECK constraint, so both tables '
  'stay in lockstep if a state is ever added.';

-- ----------------------------------------------------------------------------
-- Table: projects
-- ----------------------------------------------------------------------------
create table public.projects (
  id uuid primary key default extensions.gen_random_uuid(),

  slug text not null,
  -- Present now (default 'en') even though only English content exists —
  -- widening a unique constraint later, after real project URLs depend on
  -- bare slugs, is a much riskier migration than narrowing one now. See
  -- approved spec §2 (Future Scalability — Multi-language content).
  locale text not null default 'en',

  title text not null,
  summary text,
  description text,
  tech_stack text[] not null default '{}',

  live_url text check (live_url is null or live_url ~ '^https?://'),
  github_url text check (github_url is null or github_url ~ '^https?://'),
  case_study_url text check (case_study_url is null or case_study_url ~ '^https?://'),

  cover_image_id uuid references public.media_assets (id) on delete set null,

  status public.content_status not null default 'draft',
  featured boolean not null default false,
  pinned boolean not null default false,
  sort_order integer not null default 0,

  started_at date,
  completed_at date,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint projects_slug_locale_unique unique (slug, locale),
  constraint projects_completed_after_started
    check (completed_at is null or started_at is null or completed_at >= started_at),

  -- Full-text search readiness (approved spec §11): title weighted highest,
  -- then summary, then description, so a match on the title ranks above a
  -- match buried in the long-form description. `english` config is correct
  -- while `locale = 'en'` is the only content that exists; revisit per-
  -- locale text search configuration if/when non-English content is added
  -- — not a Phase 3 concern, flagged for whichever future phase adds it.
  search_vector tsvector generated always as (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(summary, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'C')
  ) stored
);

comment on table public.projects is
  'Projects Showcase content (Phase 7 UI, not built yet). Public reads are '
  'restricted to status = ''published'' via RLS below.';
comment on column public.projects.locale is
  'ISO-ish locale tag, default ''en''. No multi-language UI exists yet — '
  'this column exists so the (slug, locale) uniqueness shape never has to '
  'change later. See approved spec, Future Scalability.';
comment on column public.projects.tech_stack is
  'Denormalized text[] rather than a join table — deliberate: no cross-'
  'project tech-stack querying/filtering is planned that would justify the '
  'join overhead. Revisit only if that requirement actually appears.';
comment on column public.projects.search_vector is
  'Generated, stored tsvector (title weight A, summary B, description C). '
  'Backs the GIN index below. Search UI is Phase 7/8, not Phase 3 — this '
  'column exists so its shape does not need to change once that UI exists.';

-- ----------------------------------------------------------------------------
-- Indexes
-- ----------------------------------------------------------------------------
-- Partial index: every public listing/detail query filters on this, so a
-- partial index (published rows only) stays small regardless of how much
-- draft content ever accumulates.
create index projects_published_idx on public.projects (status) where status = 'published';

-- Composite, matching the exact "published, ordered by sort_order" query
-- shape the frontend will use — avoids a separate sort step.
create index projects_status_sort_order_idx on public.projects (status, sort_order);

-- FK column — not auto-indexed by Postgres.
create index projects_cover_image_id_idx on public.projects (cover_image_id);

-- Full-text search (approved spec §11).
create index projects_search_vector_idx on public.projects using gin (search_vector);

-- ----------------------------------------------------------------------------
-- updated_at trigger
-- ----------------------------------------------------------------------------
create trigger set_projects_updated_at
  before update on public.projects
  for each row
  execute function public.set_updated_at();

-- ----------------------------------------------------------------------------
-- Row Level Security: projects
-- ----------------------------------------------------------------------------
alter table public.projects enable row level security;

create policy "Published projects are publicly readable"
  on public.projects
  for select
  to anon, authenticated
  using (status = 'published');

create policy "Admins can insert projects"
  on public.projects
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update projects"
  on public.projects
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete projects"
  on public.projects
  for delete
  to authenticated
  using (public.is_admin());

-- ============================================================================
-- Table: project_features
-- ============================================================================
create table public.project_features (
  id uuid primary key default extensions.gen_random_uuid(),
  project_id uuid not null references public.projects (id) on delete cascade,
  label text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.project_features is
  'Per-project feature bullets (1:many from projects). Visibility mirrors '
  'the parent project''s published status — see RLS policy below, not a '
  'status column of its own.';

-- FK column — not auto-indexed by Postgres, and this is joined constantly
-- when rendering a project's feature list.
create index project_features_project_id_idx on public.project_features (project_id);
create index project_features_project_id_sort_order_idx
  on public.project_features (project_id, sort_order);

create trigger set_project_features_updated_at
  before update on public.project_features
  for each row
  execute function public.set_updated_at();

-- ----------------------------------------------------------------------------
-- Row Level Security: project_features
-- ----------------------------------------------------------------------------
alter table public.project_features enable row level security;

-- IMPORTANT: project_features has no status column of its own. A naive
-- `using (true)` policy (as used for media_assets, which has no sensitive
-- content) would leak draft projects' feature bullets publicly even while
-- the parent projects row itself stays correctly hidden. This policy joins
-- back to projects and only allows reading features of a *published*
-- project — the child table's visibility is derived from its parent's,
-- not independently "public by default".
create policy "Features of published projects are publicly readable"
  on public.project_features
  for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.projects p
      where p.id = project_features.project_id
        and p.status = 'published'
    )
  );

create policy "Admins can insert project features"
  on public.project_features
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update project features"
  on public.project_features
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete project features"
  on public.project_features
  for delete
  to authenticated
  using (public.is_admin());
