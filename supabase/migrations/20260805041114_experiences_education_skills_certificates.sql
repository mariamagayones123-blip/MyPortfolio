-- ============================================================================
-- Migration: experiences_education_skills_certificates
-- Phase 3 — Supabase Backend & Database (Final Migration Order, Task 5)
--
-- Purpose:
--   Create the four independent, flat "resume" content tables per the
--   approved Phase 3 spec §3/§4/§5/§6: experiences, education, skills,
--   certificates. None relate to each other or to any other table besides
--   certificates -> media_assets.
--
-- Depends on:
--   20260805034921_extensions_and_helpers.sql (gen_random_uuid, set_updated_at)
--   20260805040213_app_admins_and_is_admin.sql (is_admin)
--   20260805040518_media_assets.sql (certificates.file_id FK target)
--
-- Introduces: public.employment_type, public.skill_category — small enums
--   scoped to a single table each (unlike content_status, which is shared
--   across two tables), used for the same data-integrity reasons.
--
-- Index note: none of these four tables gets a dedicated sort/ordering
-- index. They hold inherently small, bounded row counts (one person's
-- career/education/skills/certificate history — realistically single-digit
-- to low-double-digit rows each), where a sequential scan + sort is faster
-- than an index lookup and the write overhead of maintaining an index would
-- be pure cost with no benefit. This matches the approved spec's own
-- performance principle (§17: indexes matched to actual query patterns, not
-- indexed everywhere speculatively) — it is a deliberate omission, not one
-- made by oversight.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Enums
-- ----------------------------------------------------------------------------
create type public.employment_type as enum (
  'full_time',
  'part_time',
  'contract',
  'freelance',
  'internship'
);

create type public.skill_category as enum (
  'language',
  'framework',
  'tool',
  'platform',
  'soft'
);

comment on type public.employment_type is
  'experiences.employment_type. Nullable on the table itself — not every '
  'entry needs to declare one.';
comment on type public.skill_category is
  'skills.category, per the AI Development Specification''s skill grouping.';

-- ----------------------------------------------------------------------------
-- Table: experiences
-- ----------------------------------------------------------------------------
create table public.experiences (
  id uuid primary key default extensions.gen_random_uuid(),
  company text not null,
  role text not null,
  location text,
  employment_type public.employment_type,
  start_date date not null,
  -- null = current position.
  end_date date,
  description text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint experiences_end_after_start check (end_date is null or end_date >= start_date)
);

comment on table public.experiences is
  'Work history (About/Experience section, Phase 6 UI). No status column — '
  'unconditionally publicly readable, like education/skills/certificates '
  '(there is no "draft experience" concept). Admin-only write.';
comment on column public.experiences.end_date is
  'Null means "current position" — rendered as "Present" by the frontend, '
  'not encoded as a separate boolean.';

create trigger set_experiences_updated_at
  before update on public.experiences
  for each row
  execute function public.set_updated_at();

alter table public.experiences enable row level security;

create policy "Experiences are publicly readable"
  on public.experiences
  for select
  to anon, authenticated
  using (true);

create policy "Admins can insert experiences"
  on public.experiences
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update experiences"
  on public.experiences
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete experiences"
  on public.experiences
  for delete
  to authenticated
  using (public.is_admin());

-- ----------------------------------------------------------------------------
-- Table: education
-- ----------------------------------------------------------------------------
create table public.education (
  id uuid primary key default extensions.gen_random_uuid(),
  institution text not null,
  degree text not null,
  field_of_study text,
  start_date date not null,
  end_date date,
  description text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint education_end_after_start check (end_date is null or end_date >= start_date)
);

comment on table public.education is
  'Education history (About/Experience section, Phase 6 UI). Unconditionally '
  'publicly readable — see experiences comment above for the rationale.';

create trigger set_education_updated_at
  before update on public.education
  for each row
  execute function public.set_updated_at();

alter table public.education enable row level security;

create policy "Education is publicly readable"
  on public.education
  for select
  to anon, authenticated
  using (true);

create policy "Admins can insert education"
  on public.education
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update education"
  on public.education
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete education"
  on public.education
  for delete
  to authenticated
  using (public.is_admin());

-- ----------------------------------------------------------------------------
-- Table: skills
-- ----------------------------------------------------------------------------
create table public.skills (
  id uuid primary key default extensions.gen_random_uuid(),
  name text not null unique,
  category public.skill_category not null,
  -- Optional self-rating, 1 (familiar) – 5 (expert). Nullable: not every
  -- skill entry needs to claim a proficiency level.
  proficiency smallint check (proficiency is null or proficiency between 1 and 5),
  icon_key text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.skills is
  'Skill tags (Skills section, Phase 6 UI). Unconditionally publicly '
  'readable. `name` is unique to prevent accidental duplicate entries.';
comment on column public.skills.icon_key is
  'Logical key resolved to a lucide-react icon (or similar) by the '
  'frontend — not a storage reference, so no media_assets FK here.';

create trigger set_skills_updated_at
  before update on public.skills
  for each row
  execute function public.set_updated_at();

alter table public.skills enable row level security;

create policy "Skills are publicly readable"
  on public.skills
  for select
  to anon, authenticated
  using (true);

create policy "Admins can insert skills"
  on public.skills
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update skills"
  on public.skills
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete skills"
  on public.skills
  for delete
  to authenticated
  using (public.is_admin());

-- ----------------------------------------------------------------------------
-- Table: certificates
-- ----------------------------------------------------------------------------
create table public.certificates (
  id uuid primary key default extensions.gen_random_uuid(),
  title text not null,
  issuer text not null,
  issued_at date not null,
  expires_at date,
  credential_url text check (credential_url is null or credential_url ~ '^https?://'),
  file_id uuid references public.media_assets (id) on delete set null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint certificates_expires_after_issued
    check (expires_at is null or expires_at >= issued_at)
);

comment on table public.certificates is
  'Certifications (Certificates section, Phase 8 UI). Unconditionally '
  'publicly readable. `file_id` references media_assets rather than '
  'storing a bare path — see Media Asset Strategy, approved spec §2.';

-- FK column — not auto-indexed by Postgres.
create index certificates_file_id_idx on public.certificates (file_id);

create trigger set_certificates_updated_at
  before update on public.certificates
  for each row
  execute function public.set_updated_at();

alter table public.certificates enable row level security;

create policy "Certificates are publicly readable"
  on public.certificates
  for select
  to anon, authenticated
  using (true);

create policy "Admins can insert certificates"
  on public.certificates
  for insert
  to authenticated
  with check (public.is_admin());

create policy "Admins can update certificates"
  on public.certificates
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy "Admins can delete certificates"
  on public.certificates
  for delete
  to authenticated
  using (public.is_admin());
