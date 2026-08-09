# Authentication

**Status:** Active (config prepared, UI deferred)
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Project Roadmap](../01_Project/Project_Roadmap.md), [Row Level
Security](../05_Database/Row_Level_Security.md), `supabase/config.toml`

## Purpose

Documents what Phase 3 prepared for authentication, and — just as importantly — what it
deliberately did not build, per Roadmap Compliance.

## Scope

Auth-related schema (`app_admins`), local CLI config (`supabase/config.toml`), and the intended
provider set. Does **not** cover login UI, session handling, or OAuth redirect flows — that is
Phase 10 (Authentication) in full.

## What Phase 3 Built

- **`app_admins`** table — allow-list of `auth.users` permitted to write content. Ships empty.
- **`is_admin()`** function — the predicate every RLS write policy depends on.
- **`supabase/config.toml`** — `[auth]` section enabled, `site_url`/`additional_redirect_urls`
  pointed at the local Vite dev server, and disabled stubs for `[auth.external.google]` /
  `[auth.external.github]` (the two OAuth providers named in the AI Development Specification,
  alongside Email/Magic Link).

## What Phase 3 Deliberately Did Not Build

- No login page, no signup flow, no session context/hook
- No OAuth credential wiring or redirect handling
- No protected-route component
- Google/GitHub external auth remain `enabled = false`

All of the above belong to **Phase 10 — Authentication**, per
[Project_Roadmap.md](../01_Project/Project_Roadmap.md).

## Bootstrapping an Admin (Between Phase 3 and Phase 10)

Until Phase 10 exists, there is no way to create an admin through the app. To grant yourself
access once you have a real Supabase Auth user (e.g. created via the Dashboard):

```sql
insert into public.app_admins (user_id)
values ('<your-auth-user-uuid>');
```

Run this via the Supabase Studio SQL editor or `psql` against your project — not through the
client API (no policy permits it, by design; see
[Row_Level_Security.md](../05_Database/Row_Level_Security.md#app_admins-no-write-policy-at-all)).

## Content Creation Before Phase 10

Between Phase 3 and Phase 10, all content (projects, blog posts, etc.) must be inserted directly
via SQL/Supabase Studio using your own Postgres credentials — the app has no write UI yet (that's
Phase 11, Admin Dashboard) and no login (Phase 10) to authenticate as the admin RLS policies
require.

## Intended Providers (Phase 10 scope)

Per the AI Development Specification: **Email/Password**, **Magic Link**, **Google**, **GitHub**.
All four map onto Supabase Auth's built-in `auth.users` table — no custom users table is planned.

## References

- [Row Level Security](../05_Database/Row_Level_Security.md)
- `supabase/config.toml`
- [Project Roadmap](../01_Project/Project_Roadmap.md)
