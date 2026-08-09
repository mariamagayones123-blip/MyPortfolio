-- ============================================================================
-- Migration: blog_tags_posts_and_post_tags
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 6)
--
-- Purpose:
--   Create the Blog content tables per the approved Phase 3 spec §3/§4/§5/
--   §6/§11: blog_tags, blog_posts, and the blog_post_tags join table
--   (many:many between them).
--
-- Depends on:
--   20260805034921_extensions_and_helpers.sql (gen_random_uuid, set_updated_at)
--   20260805040213_app_admins_and_is_admin.sql (is_admin)
--   20260805040518_media_assets.sql (blog_posts.cover_image_id FK target)
--   20260805040755_projects_and_project_features.sql (reuses
--     public.content_status — draft/published is identical for blog_posts,
--     so it is not redefined here)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Table: blog_tags
-- ----------------------------------------------------------------------------
create table public.blog_tags (
  id uuid primary key default extensions.gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.blog_tags is
  'Reusable blog tags. Unconditionally publicly readable — a tag name '
  'existing does not by itself disclose anything about which (possibly '
  'draft) posts use it; contrast with blog_post_tags below, which does '
  'need to guard that.';

create trigger set_blog_tags_updated_at
  before update on public.blog_tags
  for each row
  execute function public.set_updated_at();

alter table public.blog_tags enable row level security;

create policy "Blog tags are publicly readable"
  on public.blog_tags
  for select
  to anon, authenticated
  using (true);

create policy "Admins can insert blog tags"
  on public.blog_tags
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update blog tags"
  on public.blog_tags
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete blog tags"
  on public.blog_tags
  for delete
  to authenticated
  using (public.is_admin());

-- ----------------------------------------------------------------------------
-- Table: blog_posts
-- ----------------------------------------------------------------------------
create table public.blog_posts (
  id uuid primary key default extensions.gen_random_uuid(),

  slug text not null,
  -- Same i18n-readiness rationale as projects.locale — see that migration.
  locale text not null default 'en',

  title text not null,
  excerpt text,
  content text,
  cover_image_id uuid references public.media_assets (id) on delete set null,

  -- Reuses the enum created for projects — identical draft/published
  -- semantics, one shared definition (see approved spec §3).
  status public.content_status not null default 'draft',
  published_at timestamptz,
  reading_time_minutes smallint check (reading_time_minutes is null or reading_time_minutes > 0),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint blog_posts_slug_locale_unique unique (slug, locale),

  -- Full-text search readiness (approved spec §11), same weighting pattern
  -- as projects.search_vector: title > excerpt > content.
  search_vector tsvector generated always as (
    setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(excerpt, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(content, '')), 'C')
  ) stored
);

comment on table public.blog_posts is
  'Blog content (Phase 8 UI, not built yet). Public reads restricted to '
  'status = ''published'' via RLS below, same pattern as projects.';
comment on column public.blog_posts.published_at is
  'Set by the application when status transitions to ''published'' (Phase '
  '11 admin concern) — not automated by a trigger here, since Phase 3 has '
  'no write path to observe that transition yet beyond direct SQL.';

-- ----------------------------------------------------------------------------
-- Indexes
-- ----------------------------------------------------------------------------
create index blog_posts_published_idx on public.blog_posts (status) where status = 'published';

-- Composite, matching the "published, most recent first" query shape a blog
-- index page uses — distinct from projects, which orders by sort_order
-- instead of a date (see approved spec §5).
create index blog_posts_status_published_at_idx
  on public.blog_posts (status, published_at desc);

create index blog_posts_cover_image_id_idx on public.blog_posts (cover_image_id);

create index blog_posts_search_vector_idx on public.blog_posts using gin (search_vector);

create trigger set_blog_posts_updated_at
  before update on public.blog_posts
  for each row
  execute function public.set_updated_at();

-- ----------------------------------------------------------------------------
-- Row Level Security: blog_posts
-- ----------------------------------------------------------------------------
alter table public.blog_posts enable row level security;

create policy "Published blog posts are publicly readable"
  on public.blog_posts
  for select
  to anon, authenticated
  using (status = 'published');

create policy "Admins can insert blog posts"
  on public.blog_posts
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update blog posts"
  on public.blog_posts
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete blog posts"
  on public.blog_posts
  for delete
  to authenticated
  using (public.is_admin());

-- ============================================================================
-- Table: blog_post_tags (join table, many:many)
-- ============================================================================
create table public.blog_post_tags (
  blog_post_id uuid not null references public.blog_posts (id) on delete cascade,
  blog_tag_id uuid not null references public.blog_tags (id) on delete cascade,
  created_at timestamptz not null default now(),

  constraint blog_post_tags_pkey primary key (blog_post_id, blog_tag_id)
);

comment on table public.blog_post_tags is
  'Many:many join between blog_posts and blog_tags. No updated_at/trigger — '
  'unlike project_features, there is no mutable field here beyond the pair '
  'itself; changing a tag assignment is a delete+insert, not an update.';

-- The composite primary key (blog_post_id, blog_tag_id) already serves
-- "find tags for post X" efficiently (blog_post_id is its leading column).
-- The reverse direction — "find posts for tag Y" — needs its own index,
-- since blog_tag_id alone is not a prefix of that composite key.
create index blog_post_tags_blog_tag_id_idx on public.blog_post_tags (blog_tag_id);

-- ----------------------------------------------------------------------------
-- Row Level Security: blog_post_tags
-- ----------------------------------------------------------------------------
alter table public.blog_post_tags enable row level security;

-- Same reasoning as project_features: this join table has no status column
-- of its own, so a naive `using (true)` would let an anonymous reader learn
-- which tags are assigned to a *draft* post even though the post row itself
-- is correctly hidden. Visibility is derived from the referenced post's
-- published state via EXISTS, not independently "public by default".
create policy "Tags of published posts are publicly readable"
  on public.blog_post_tags
  for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.blog_posts p
      where p.id = blog_post_tags.blog_post_id
        and p.status = 'published'
    )
  );

create policy "Admins can insert blog post tags"
  on public.blog_post_tags
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update blog post tags"
  on public.blog_post_tags
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete blog post tags"
  on public.blog_post_tags
  for delete
  to authenticated
  using (public.is_admin());
