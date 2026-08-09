# Row Level Security

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Tables](Tables.md), [Database Design](Database_Design.md),
[docs/09_Security/Threat_Model.md](../09_Security/Threat_Model.md),
[docs/06_Supabase/Security_Policies.md](../06_Supabase/Security_Policies.md)

## Purpose

Documents the RLS model applied to every table — the primary security boundary for this project,
not an afterthought layered on top of application logic.

## Scope

All `public` schema tables and `storage.objects`. Function-level security (`is_admin()`) is
covered here since every policy depends on it; `app_admins`/grants/database-permissions detail
lives in [docs/09_Security/Threat_Model.md](../09_Security/Threat_Model.md).

## The `is_admin()` Function

```sql
create or replace function is_admin()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (select 1 from app_admins where user_id = auth.uid());
$$;
```

- **`SECURITY DEFINER`**: executes with the privileges of the function's owner (the migration
  role, which owns `app_admins` and therefore bypasses its RLS by default) rather than the calling
  role. Without this, a non-admin caller's own restrictive access to `app_admins` would make the
  function unable to read it at all — every policy depending on it would evaluate `false` even for
  the real admin. This is what avoids that recursive-lockout failure mode.
- **Pinned `search_path`**: prevents a malicious schema earlier in a caller-influenced search path
  from shadowing `app_admins` and returning attacker-controlled results.
- **`stable`**: lets Postgres reuse the result within a single multi-row policy evaluation instead
  of re-querying per row.

## Policy Pattern (applies to nearly every table)

**Public content tables** (no status column, or status-filtered):

- `SELECT`: `anon, authenticated` — `using (true)` (no status column) or `using (status =
'published'/'approved')`
- `INSERT`/`UPDATE`/`DELETE`: `authenticated` only, gated on `is_admin()`

## Per-Table Policy Summary

| Table                                                                 | Public SELECT condition         | Write access                                       |
| --------------------------------------------------------------------- | ------------------------------- | -------------------------------------------------- |
| `app_admins`                                                          | none (admin-only SELECT)        | No write policy at all — see below                 |
| `media_assets`                                                        | `true`                          | admin                                              |
| `projects`                                                            | `status = 'published'`          | admin                                              |
| `project_features`                                                    | derived from parent (see below) | admin                                              |
| `experiences`, `education`, `skills`, `certificates`, `gallery_items` | `true`                          | admin                                              |
| `blog_tags`                                                           | `true`                          | admin                                              |
| `blog_posts`                                                          | `status = 'published'`          | admin                                              |
| `blog_post_tags`                                                      | derived from parent (see below) | admin                                              |
| `testimonials`                                                        | `status = 'approved'`           | admin                                              |
| `resume_versions`, `site_settings`                                    | `true`                          | admin                                              |
| `messages`                                                            | none (admin-only SELECT)        | admin only, **no INSERT policy** — see below       |
| `analytics_events`                                                    | none (admin-only SELECT)        | admin SELECT/DELETE only, **no INSERT, no UPDATE** |

## Derived Visibility: Child Tables With No Status Column of Their Own

`project_features` and `blog_post_tags` have no `status` column. A naive `using (true)` SELECT
policy (fine for `media_assets`, which holds nothing sensitive) would leak a _draft_ project's or
post's child rows even while the parent row itself stays correctly hidden. Both instead use an
`EXISTS` subquery joining back to the parent:

```sql
using (
  exists (
    select 1 from projects p
    where p.id = project_features.project_id
      and p.status = 'published'
  )
)
```

Child-table visibility is derived from the parent's, not independently "public by default".

## `app_admins`: No Write Policy At All

`app_admins` has RLS enabled and a `SELECT` policy for admins, but **no INSERT/UPDATE/DELETE
policy for `authenticated`**, deliberately. Managing who is an admin is a direct SQL/Studio
operation (the table's owning role bypasses its own RLS), never exposed through the public API —
even to an existing admin — without a dedicated, carefully-scoped decision in a later phase. This
also resolves the bootstrapping problem: the very first admin cannot self-insert via the API,
since `is_admin()` is `false` for everyone until a row exists.

## `messages` / `analytics_events`: No Anon INSERT Policy

The originally-considered design used `with check (true)` to let anonymous visitors submit the
contact form directly. This was rejected: RLS restricts _whether_ a row may be written, not _which
columns_ the client controls — a client could self-set `status = 'read'` or fabricate `ip_hash` on
their own insert. Both tables instead have **no INSERT policy for `anon` or `authenticated` at
all**. Writes happen exclusively through Edge Functions (`submit-message`,
`log-analytics-event`) using the service-role key, which bypasses RLS entirely and computes
sensitive fields (`ip_hash`) server-side. See
[docs/06_Supabase/Security_Policies.md](../06_Supabase/Security_Policies.md).

## Storage (`storage.objects`)

Same public-read/admin-write pattern, scoped per bucket (`bucket_id = 'x' and is_admin()` for
writes). See [docs/06_Supabase/Storage.md](../06_Supabase/Storage.md).

## References

- [Tables](Tables.md)
- [docs/09_Security/Threat_Model.md](../09_Security/Threat_Model.md)
- [docs/06_Supabase/Security_Policies.md](../06_Supabase/Security_Policies.md)
