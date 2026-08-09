# Migration Strategy

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Database Design](Database_Design.md), [Environment](../06_Supabase/Environment.md)

## Purpose

Documents how schema changes are made, ordered, and applied for this project.

## Scope

`supabase/migrations/*.sql` and the tooling around them. Does not cover application deployment
(Vercel) — that's Phase 16.

## Approach

**Supabase CLI-managed migrations**, one SQL file per logical change, timestamp-prefixed via
`supabase migration new <name>`. This is version-controlled and reviewable — no dashboard-only
schema changes. Each migration is additive and forward-only; rollbacks are handled by writing a
new corrective migration, not by editing history, matching the project's own "never break existing
functionality" principle applied to schema.

## Current Migration Order (Phase 3)

| #   | File                                        | Contents                                                                                                                                                                  |
| --- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `extensions_and_helpers`                    | `pgcrypto`, `vector` extensions; `set_updated_at()` trigger function                                                                                                      |
| 2   | `app_admins_and_is_admin`                   | `app_admins` table; `is_admin()` function                                                                                                                                 |
| 3   | `media_assets`                              | Shared file-metadata table                                                                                                                                                |
| 4   | `projects_and_project_features`             | `content_status` enum; `projects`, `project_features`                                                                                                                     |
| 5   | `experiences_education_skills_certificates` | `employment_type`, `skill_category` enums; four flat resume tables                                                                                                        |
| 6   | `blog_tags_posts_and_post_tags`             | `blog_tags`, `blog_posts` (reuses `content_status`), `blog_post_tags`                                                                                                     |
| 7   | `gallery_items_and_testimonials`            | `gallery_items`; `testimonial_status` enum; `testimonials`                                                                                                                |
| 8   | `resume_settings_messages_analytics`        | `resume_versions`, `site_settings` (+ singleton seed), `message_status`/`analytics_event_type` enums, `messages`, `analytics_events` — RLS **enabled**, policies deferred |
| 9   | `..._policies_and_grants`                   | Policies for migration 8's four tables; schema-wide `REVOKE`/`GRANT` audit                                                                                                |
| 10  | `storage_buckets_and_policies`              | Three storage buckets; `storage.objects` RLS policies                                                                                                                     |

Every migration's own header comment documents its dependencies on prior migrations and its
rationale — this table is a summary, the migration files are the source of truth.

## Convention for Future Migrations

Any new table must, in its own migration:

1. Enable RLS immediately (never left disabled, even briefly)
2. Add its own policies (or explicitly note if policies are deferred to a clearly-named follow-up
   migration, as migrations 8→9 above did for a documented reason)
3. Explicitly `GRANT` what its policies need to `anon`/`authenticated` — this project does **not**
   rely on `ALTER DEFAULT PRIVILEGES` for future tables (see
   [Row_Level_Security.md](Row_Level_Security.md)); each table's grants are reviewed in its own
   migration, not inherited invisibly.

## Local Development

```bash
supabase start        # requires Docker — not available in this project's build sandbox
supabase db reset      # re-applies all migrations + supabase/seed.sql from scratch
```

## Applying to a Remote Project

```bash
supabase link --project-ref <project-ref>
supabase db push
```

## Type Generation

After migrations are applied to a real database:

```bash
supabase gen types typescript --local > src/types/database.ts
# or, against a linked remote project:
supabase gen types typescript --project-id <project-id> > src/types/database.ts
```

`src/types/database.ts` is **generated output** — it must never be hand-edited. See
[docs/06_Supabase/Database.md](../06_Supabase/Database.md) for how the rest of the codebase
consumes it (`src/types/database-helpers.ts`, once created).

## A Note on This Sandbox

The migrations in this repository were authored and statically verified (parsed against real
PostgreSQL grammar via `libpg_query`, with AST-level inspection of every constraint, policy, and
grant) in an environment with no network access to Supabase and no Docker, so none of them have
been executed against a live database yet. Run `supabase db push` (remote) or `supabase start` +
`supabase db reset` (local) from an environment with connectivity before considering Phase 3
"verified" in the fullest sense — see the Risks section of the approved Phase 3 architecture
specification.

## References

- [Database Design](Database_Design.md)
- [Environment](../06_Supabase/Environment.md)
- `supabase/migrations/README.md`
