# Indexes

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Tables](Tables.md), [Database Design](Database_Design.md)

## Purpose

Documents every index in the schema and, just as importantly, the tables that **deliberately
don't** have one — indexes here are matched to actual expected query patterns, not applied
everywhere by default.

## Scope

All indexes created under `supabase/migrations/`, `public` schema.

## Unique Indexes

| Table          | Columns                                      |
| -------------- | -------------------------------------------- |
| `projects`     | `(slug, locale)`                             |
| `blog_posts`   | `(slug, locale)`                             |
| `media_assets` | `storage_path`                               |
| `blog_tags`    | `name`, `slug` (two separate unique indexes) |
| `skills`       | `name`                                       |
| `app_admins`   | `user_id`                                    |

## Partial Indexes

Filtered to the exact rows public queries actually read, so the index stays small regardless of
how much draft/pending content accumulates:

- `projects (status) WHERE status = 'published'`
- `blog_posts (status) WHERE status = 'published'`
- `testimonials (status) WHERE status = 'approved'`

## Composite Indexes

Matched to the exact "filter + sort" shape each listing query uses, so Postgres can satisfy both
in one index scan instead of a separate sort step:

- `projects (status, sort_order)`
- `blog_posts (status, published_at desc)` — note the different sort key vs. `projects`: a blog
  index page sorts by recency, a project showcase sorts by manual `sort_order`.
- `testimonials (status, sort_order)`
- `messages (status, created_at desc)` — future admin inbox view
- `analytics_events (event_type, created_at desc)`
- `project_features (project_id, sort_order)`

## Full-Text Search (GIN)

- `projects (search_vector)`
- `blog_posts (search_vector)`

Both back a generated, weighted `tsvector` column (title > summary/excerpt > body) — see
[Database_Design.md](Database_Design.md). Search _UI_ is Phase 7/8, not Phase 3; this exists so
the column/index shape doesn't need to change once that UI is built.

## Foreign Key Indexes

Postgres does not automatically index foreign key columns — every FK below is explicitly indexed
because it is joined or filtered on regularly:

`projects.cover_image_id`, `project_features.project_id`, `blog_posts.cover_image_id`,
`blog_post_tags.blog_tag_id` (the composite PK's leading column already covers the
`blog_post_id` direction), `certificates.file_id`, `gallery_items.media_id`,
`testimonials.author_avatar_id`, `resume_versions.file_id`, `media_assets.uploaded_by`.

## Deliberately Un-Indexed Tables

`experiences`, `education`, `skills`, `certificates`, `gallery_items` (beyond their one FK index)
have **no dedicated sort/ordering index**. These tables hold inherently small, bounded row counts
— one person's career/education/skills/certificate/gallery history, realistically single- to
low-double-digit rows. At that scale, a sequential scan + sort is faster than an index lookup, and
the write overhead of maintaining an index is pure cost with no measurable read benefit. This is a
deliberate omission, documented inline in the migrations, not an oversight — see the approved
Phase 3 spec §17 (Performance Considerations: "indexes matched to actual query patterns, not
indexed everywhere speculatively").

## References

- [Tables](Tables.md)
- [Database Design](Database_Design.md)
