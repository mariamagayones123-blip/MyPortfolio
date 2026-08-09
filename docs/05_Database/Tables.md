# Tables

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Database Design](Database_Design.md), [Relationships](Relationships.md),
[Constraints](Constraints.md), [Row Level Security](Row_Level_Security.md)

## Purpose

Complete reference for every table created in Phase 3, matching `supabase/migrations/` exactly.
This is the canonical column list — if this document and a migration ever disagree, the migration
is correct and this document needs updating (see [AI Project
Instructions](../12_AI/AI_Project_Instructions.md) on documentation/implementation conflicts).

## Scope

All 17 tables under the `public` schema, plus `storage.buckets`/`storage.objects` usage (fully
covered in [docs/06_Supabase/Storage.md](../06_Supabase/Storage.md), not repeated here).

## Support Tables

### `app_admins`

Allow-list of Supabase Auth users permitted to write content. Ships empty until Phase 10.

| Column       | Type                                                     | Notes                                                    |
| ------------ | -------------------------------------------------------- | -------------------------------------------------------- |
| `id`         | uuid, PK                                                 |                                                          |
| `user_id`    | uuid, unique, FK → `auth.users(id)`, `on delete cascade` |                                                          |
| `created_at` | timestamptz                                              | No `updated_at` — grants are added/removed, never edited |

### `media_assets`

Shared file metadata for every uploaded file across all three storage buckets.

| Column                     | Type                                                        | Notes                                                                                                    |
| -------------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `id`                       | uuid, PK                                                    |                                                                                                          |
| `bucket`                   | text, `CHECK IN ('public-images','resumes','certificates')` |                                                                                                          |
| `storage_path`             | text, unique                                                | `{entity}/{entity_id}/{filename}` convention                                                             |
| `alt_text`                 | text, nullable                                              | **Required** when `mime_type` is an image type (enforced by `media_assets_alt_text_required_for_images`) |
| `mime_type`                | text                                                        |                                                                                                          |
| `file_size_bytes`          | integer, `CHECK > 0`                                        |                                                                                                          |
| `width`, `height`          | integer, nullable                                           | Images only                                                                                              |
| `uploaded_by`              | uuid, nullable, FK → `auth.users(id)`, `on delete set null` |                                                                                                          |
| `created_at`, `updated_at` | timestamptz                                                 |                                                                                                          |

## Content Tables

### `projects`

| Column                                     | Type                                                | Notes                                                       |
| ------------------------------------------ | --------------------------------------------------- | ----------------------------------------------------------- |
| `id`                                       | uuid, PK                                            |                                                             |
| `slug`                                     | text                                                | Composite unique with `locale`                              |
| `locale`                                   | text, default `'en'`                                |                                                             |
| `title`, `summary`, `description`          | text                                                | `summary`/`description` nullable                            |
| `tech_stack`                               | text[], default `'{}'`                              |                                                             |
| `live_url`, `github_url`, `case_study_url` | text, nullable                                      | `CHECK` matches `^https?://`                                |
| `cover_image_id`                           | uuid, nullable, FK → `media_assets(id)`, `set null` |                                                             |
| `status`                                   | `content_status`, default `draft`                   |                                                             |
| `featured`, `pinned`                       | boolean, default `false`                            |                                                             |
| `sort_order`                               | integer, default `0`                                |                                                             |
| `started_at`, `completed_at`               | date, nullable                                      | `CHECK (completed_at >= started_at)`                        |
| `search_vector`                            | tsvector, generated                                 | title (A) / summary (B) / description (C), `english` config |
| `created_at`, `updated_at`                 | timestamptz                                         |                                                             |

### `project_features`

1:many child of `projects`. `id`, `project_id` (FK, `on delete cascade`), `label`, `sort_order`,
`created_at`, `updated_at`.

### `experiences`

`id`, `company`, `role`, `location` (nullable), `employment_type` (enum, nullable), `start_date`,
`end_date` (nullable — null = current), `description` (nullable), `sort_order`, `created_at`,
`updated_at`. `CHECK (end_date >= start_date)`.

### `education`

`id`, `institution`, `degree`, `field_of_study` (nullable), `start_date`, `end_date` (nullable),
`description` (nullable), `sort_order`, `created_at`, `updated_at`. `CHECK (end_date >=
start_date)`.

### `skills`

`id`, `name` (unique), `category` (`skill_category` enum), `proficiency` (smallint 1–5, nullable),
`icon_key` (nullable), `sort_order`, `created_at`, `updated_at`.

### `certificates`

`id`, `title`, `issuer`, `issued_at`, `expires_at` (nullable), `credential_url` (nullable, URL
`CHECK`), `file_id` (nullable, FK → `media_assets(id)`, `set null`), `sort_order`, `created_at`,
`updated_at`. `CHECK (expires_at >= issued_at)`.

### `blog_tags`

`id`, `name` (unique), `slug` (unique), `created_at`, `updated_at`.

### `blog_posts`

Same shape as `projects` where applicable: `id`, `slug` + `locale` (composite unique), `title`,
`excerpt`, `content` (nullable), `cover_image_id` (FK → `media_assets`), `status`
(`content_status`, reused from `projects`), `published_at` (nullable), `reading_time_minutes`
(nullable, `CHECK > 0`), `search_vector` (generated: title A / excerpt B / content C),
`created_at`, `updated_at`.

### `blog_post_tags`

Many:many join. `blog_post_id` + `blog_tag_id` (composite PK, both FK `on delete cascade`),
`created_at`. No `updated_at` — see [Database_Design.md](Database_Design.md#timestamps).

### `gallery_items`

`id`, `media_id` (**required**, FK → `media_assets(id)`, `on delete cascade`), `caption`
(nullable), `sort_order`, `created_at`, `updated_at`.

### `testimonials`

`id`, `author_name`, `author_title` (nullable), `author_company` (nullable), `author_avatar_id`
(nullable, FK → `media_assets`, `set null`), `quote`, `status` (`testimonial_status`, default
`pending`), `sort_order`, `created_at`, `updated_at`.

### `resume_versions`

`id`, `file_id` (**required**, FK → `media_assets(id)`, `on delete cascade`), `label`,
`created_at`, `updated_at`. **No `is_current` column** — see
[Database_Design.md](Database_Design.md) and the Final Architecture Specification §3.

### `site_settings`

Singleton (`id boolean primary key default true`, `CHECK(id)`). `resume_current_version_id`
(nullable, FK → `resume_versions`, `set null` — **sole source of truth for the current résumé**),
`availability_status` (free text, deliberately unconstrained — see inline migration comment),
`contact_email` (nullable, email-format `CHECK`), `social_links` / `seo_defaults` (jsonb, default
`'{}'`), `created_at`, `updated_at`. Exactly one row, inserted structurally by its own migration.

### `messages`

`id`, `name`, `email` (`CHECK` email format), `subject` (nullable), `body`, `status`
(`message_status`, default `unread`), `honeypot_flagged` (boolean, default `false`), `ip_hash`
(SHA-256, never the raw IP), `created_at`, `updated_at`. **No anon INSERT path** — see
[Row_Level_Security.md](Row_Level_Security.md).

### `analytics_events`

`id`, `event_type` (`analytics_event_type` enum), `path` (nullable), `referrer` (nullable),
`session_id` (uuid, client-generated per session, not per event), `created_at`. No `updated_at`
(immutable). **No anon INSERT path.**

## Enums

| Enum                   | Values                                                                                   |
| ---------------------- | ---------------------------------------------------------------------------------------- |
| `content_status`       | `draft`, `published`                                                                     |
| `employment_type`      | `full_time`, `part_time`, `contract`, `freelance`, `internship`                          |
| `skill_category`       | `language`, `framework`, `tool`, `platform`, `soft`                                      |
| `testimonial_status`   | `pending`, `approved`, `hidden`                                                          |
| `message_status`       | `unread`, `read`, `archived`                                                             |
| `analytics_event_type` | `page_view`, `project_click`, `resume_download`, `contact_submit`, `external_link_click` |

## References

- `supabase/migrations/` — the actual source of truth
- [Database Design](Database_Design.md)
- [Relationships](Relationships.md)
