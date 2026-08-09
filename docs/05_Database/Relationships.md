# Relationships

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Tables](Tables.md), [Database Design](Database_Design.md),
[Constraints](Constraints.md)

## Purpose

Documents every foreign-key relationship in the schema and the reasoning behind each `ON DELETE`
behavior — these were deliberately chosen per-relationship, not applied uniformly.

## Scope

All foreign keys under the `public` schema, as created across `supabase/migrations/`.

## Relationship Diagram

```
auth.users ──< app_admins.user_id                          (cascade)
auth.users ──< media_assets.uploaded_by                    (set null)

media_assets ──< projects.cover_image_id                   (set null)
             ──< certificates.file_id                      (set null)
             ──< blog_posts.cover_image_id                 (set null)
             ──< testimonials.author_avatar_id              (set null)
             ──< resume_versions.file_id                    (cascade)
             ──< gallery_items.media_id                     (cascade)

projects ──< project_features.project_id                    (cascade)

blog_posts >──< blog_tags   (via blog_post_tags, both FKs cascade)

resume_versions ──< site_settings.resume_current_version_id (set null)
```

Everything else (`experiences`, `education`, `skills`, `messages`, `analytics_events`) is
independent — flat, ordered lists with no cross-table relationships. This is intentional: a
personal portfolio's data model is naturally shallow, and normalizing further would add join
complexity with no real query benefit.

## ON DELETE Behavior — Why Each Choice Was Made

| Relationship                                                         | Behavior         | Reasoning                                                                                                                                                                 |
| -------------------------------------------------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app_admins.user_id → auth.users`                                    | `CASCADE`        | Deleting the auth user should remove their admin grant with it — an orphaned grant pointing at a nonexistent user is meaningless.                                         |
| `media_assets.uploaded_by → auth.users`                              | `SET NULL`       | Deleting the uploader must never delete the media they uploaded — only its attribution.                                                                                   |
| `projects/certificates/blog_posts/testimonials.*_id → media_assets`  | `SET NULL`       | The parent record still means something without its file (a certificate without an image is still a real certificate) — losing the reference shouldn't delete the record. |
| `resume_versions.file_id → media_assets`                             | `CASCADE`        | A résumé version's _entire_ purpose is the file — a version record with no file is meaningless.                                                                           |
| `gallery_items.media_id → media_assets`                              | `CASCADE`        | Per the Media Asset Strategy, a gallery item _is_ its media plus a caption — same reasoning as `resume_versions`.                                                         |
| `project_features.project_id → projects`                             | `CASCADE`        | Feature bullets have no independent existence apart from their project.                                                                                                   |
| `blog_post_tags.blog_post_id / blog_tag_id → blog_posts / blog_tags` | `CASCADE` (both) | A join-table row with no valid pair on either side is meaningless.                                                                                                        |
| `site_settings.resume_current_version_id → resume_versions`          | `SET NULL`       | Deleting the current résumé version shouldn't delete site settings — it should just leave "current résumé" unset until an admin picks a new one.                          |

## Many-to-Many: `blog_posts` ↔ `blog_tags`

Modeled as a typed join table (`blog_post_tags`) with real foreign keys and a composite primary
key `(blog_post_id, blog_tag_id)` — deliberately **not** a generic polymorphic
`tags(taggable_type, taggable_id)` design. Polymorphic associations can't carry a real foreign key
in Postgres, trading referential integrity for a reusability that isn't worth it at this schema's
size (only one taggable entity exists).

## References

- [Tables](Tables.md)
- [Constraints](Constraints.md)
