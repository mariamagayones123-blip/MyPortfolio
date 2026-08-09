# Database Design

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Tables](Tables.md), [Relationships](Relationships.md), [Row Level
Security](Row_Level_Security.md), [Migration Strategy](Migration_Strategy.md), [Project
Roadmap](../01_Project/Project_Roadmap.md)

## Purpose

Describes the overall design philosophy behind the PostgreSQL schema implemented in Phase 3
(Supabase Backend & Database), so future changes stay consistent with the reasoning that produced
it rather than just the resulting DDL.

## Scope

Applies to every table, function, enum, and extension created under `supabase/migrations/`. Does
not cover application-level data-fetching patterns (query hooks, caching) — those belong to the
content phases (6–9) that actually consume this schema.

## Design Principles

This is a **single-owner content site**, not a multi-tenant SaaS application. That single fact
shapes nearly every decision below:

- **Public (anon) role:** read-only access to _published_/_approved_ content only.
- **Authenticated role:** exactly one real user will ever hold it (the site owner), once Phase 10
  adds login. Modeled via an `app_admins` allow-list table rather than a hardcoded UUID, so adding
  a second trusted editor later is a data change, not a schema migration.
- **Privileged operations** (contact-form inserts, analytics inserts) go through Supabase Edge
  Functions using the service-role key — never trusted directly from the client, even via RLS.

## Media Asset Strategy

Every entity that holds a file (project covers, certificates, blog covers, testimonial avatars,
résumé PDFs, gallery images) references a row in the shared `media_assets` table instead of
storing a bare storage path itself. One table holds accessibility metadata (`alt_text`), file
identity, and dimensions — reused everywhere a file is attached, rather than duplicated (or
forgotten) per table. See [Tables.md](Tables.md#media_assets) for the full column list and
[docs/06_Supabase/Storage.md](../06_Supabase/Storage.md) for the bucket/path convention.

## Shared Enums

Two enum types are intentionally reused across tables rather than redefined per table:

| Enum                             | Values               | Used by                                                                                                                                                                 |
| -------------------------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `content_status`                 | `draft`, `published` | `projects`, `blog_posts`                                                                                                                                                |
| (others are single-table-scoped) | —                    | `employment_type` (experiences), `skill_category` (skills), `testimonial_status` (testimonials), `message_status` (messages), `analytics_event_type` (analytics_events) |

A single shared definition for `content_status` means both tables that need identical
draft/published semantics can never drift out of sync on valid states.

## Timestamps

Every table gets `id` (UUID, `gen_random_uuid()` default), `created_at`, and `updated_at` as a
baseline — `updated_at` maintained by the shared `public.set_updated_at()` trigger function
(defined once, attached per table) rather than duplicated. Two documented exceptions:

- `app_admins` has no `updated_at` — admin grants are only ever added or removed, never edited.
- `blog_post_tags` and `analytics_events` have no `updated_at` — both are append-only/immutable by
  nature (a tag assignment is deleted and re-created, not updated; an analytics event is never
  legitimately modified after it happens).

## Future Scalability Hooks

Two low-cost decisions were made specifically to avoid expensive migrations later, per the
approved Phase 3 architecture review:

- **`locale text not null default 'en'`** on `projects` and `blog_posts`, with `(slug, locale)`
  composite uniqueness instead of a bare `unique(slug)` — no multi-language UI exists yet, but
  widening a unique constraint after live URLs depend on bare slugs is a much riskier migration
  than narrowing one now.
- **`pgvector` extension enabled**, with no `embedding` columns added — a zero-cost hook so a
  future AI-powered feature (e.g. semantic search) is a plain `ALTER TABLE`, not a new-extension
  migration.

## References

- [Tables](Tables.md)
- [Relationships](Relationships.md)
- [Row Level Security](Row_Level_Security.md)
- [Migration Strategy](Migration_Strategy.md)
- Migration files: `supabase/migrations/`
