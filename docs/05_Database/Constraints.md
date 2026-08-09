# Constraints

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Tables](Tables.md), [Relationships](Relationships.md)

## Purpose

Documents every `CHECK`/`UNIQUE` constraint beyond primary/foreign keys (covered in
[Relationships.md](Relationships.md)), and the data-integrity rule each one enforces.

## Scope

All non-FK/PK constraints defined in `supabase/migrations/`.

## Uniqueness

| Table          | Constraint                      | Rule                                                                                                |
| -------------- | ------------------------------- | --------------------------------------------------------------------------------------------------- |
| `projects`     | `projects_slug_locale_unique`   | `(slug, locale)` — allows the same slug across different locales once multi-language content exists |
| `blog_posts`   | `blog_posts_slug_locale_unique` | Same pattern                                                                                        |
| `media_assets` | `storage_path` unique           | One row per storage object                                                                          |
| `blog_tags`    | `name`, `slug` unique           | Prevents duplicate tags                                                                             |
| `skills`       | `name` unique                   | Prevents duplicate skill entries                                                                    |
| `app_admins`   | `user_id` unique                | One admin row per auth user                                                                         |

## Date/Time Sanity Checks

| Table          | Constraint                          | Rule                                                                       |
| -------------- | ----------------------------------- | -------------------------------------------------------------------------- |
| `projects`     | `projects_completed_after_started`  | `completed_at is null or started_at is null or completed_at >= started_at` |
| `experiences`  | `experiences_end_after_start`       | `end_date is null or end_date >= start_date`                               |
| `education`    | `education_end_after_start`         | Same pattern                                                               |
| `certificates` | `certificates_expires_after_issued` | `expires_at is null or expires_at >= issued_at`                            |

## Format Validation

| Table.Column                                          | Rule                                                                        |
| ----------------------------------------------------- | --------------------------------------------------------------------------- |
| `projects.live_url` / `github_url` / `case_study_url` | `null or ~ '^https?://'`                                                    |
| `certificates.credential_url`                         | Same pattern                                                                |
| `site_settings.contact_email`                         | `null or ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'`                                    |
| `messages.email`                                      | Same pattern, **not nullable** (a message always needs a real sender email) |

These are basic sanity checks, not full validation — comprehensive format/length validation
happens in the application layer (Zod schemas), consistent with the project's own principle that
"length constraints belong in Zod validation, not the schema" (AI Development Specification). The
database constraints exist to catch obviously malformed data even if a future write path forgets
to validate first.

## Numeric Range Checks

| Table.Column                      | Rule                      |
| --------------------------------- | ------------------------- |
| `media_assets.file_size_bytes`    | `> 0`                     |
| `media_assets.width` / `height`   | `null or > 0`             |
| `skills.proficiency`              | `null or between 1 and 5` |
| `blog_posts.reading_time_minutes` | `null or > 0`             |

## Accessibility Enforcement

`media_assets_alt_text_required_for_images` on `media_assets`:
`mime_type not like 'image/%' or alt_text is not null` — makes `alt_text` mandatory for any row
whose `mime_type` is an image type, while leaving it optional for non-image files (a résumé PDF
has no meaningful "alt text"). This turns the project's own WCAG AA requirement (Design System,
Phase 2) into something the database enforces, not just a convention content editors might forget.

## Singleton Enforcement

`site_settings` uses `id boolean primary key default true` plus `constraint
site_settings_singleton check (id)` — a second row's insert violates the primary key, since `id`
can only ever legally be `true`. This is a schema-enforced guarantee of "exactly one row", not an
application-level convention that a bad insert could silently violate.

## References

- [Tables](Tables.md)
- [Relationships](Relationships.md)
