# Environment

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [API_Keys](API_Keys.md), `.env.example`, `src/config/env.ts`

## Purpose

Documents every environment variable this project uses, split by where it lives and who can see
it — the split itself is a security control (see [API_Keys.md](API_Keys.md)).

## Scope

Client (`VITE_*`), Supabase-side secrets, and local CLI tooling variables.

## Client Variables (`VITE_*`, exposed to the browser bundle)

Defined and Zod-validated in `src/config/env.ts`; documented in `.env.example` at the repo root.

| Variable                 | Purpose                                                                                          |
| ------------------------ | ------------------------------------------------------------------------------------------------ |
| `VITE_SUPABASE_URL`      | Project API URL                                                                                  |
| `VITE_SUPABASE_ANON_KEY` | Public anon key — safe for client exposure; RLS (not key secrecy) is what actually protects data |
| `VITE_SITE_URL`          | Canonical deployed site URL (SEO/OG tags, absolute links)                                        |
| `VITE_APP_ENV`           | `development` \| `staging` \| `production`                                                       |

No new client variables were added in Phase 3 — the anon key + RLS model is sufficient for
everything the client needs.

## Supabase-Side Secrets (never client-side, set via `supabase secrets set` / Dashboard)

| Secret                           | Used by                                                | Required for Phase 3?                                                 |
| -------------------------------- | ------------------------------------------------------ | --------------------------------------------------------------------- |
| `SUPABASE_SERVICE_ROLE_KEY`      | `submit-message`, `log-analytics-event` Edge Functions | **Yes** — both functions depend on it to bypass RLS for their inserts |
| `RESEND_API_KEY` (or equivalent) | Contact-form notification email                        | No — added when Phase 9 wires up actual email delivery                |
| `ADMIN_NOTIFICATION_EMAIL`       | Same                                                   | No — Phase 9                                                          |

See `supabase/functions/.env.example` for the local-dev placeholder shape (never real values).

## Local CLI Tooling Variables (not `VITE_*`, not shipped to the client)

| Variable                | Purpose                                         |
| ----------------------- | ----------------------------------------------- |
| `SUPABASE_PROJECT_REF`  | `supabase link` target                          |
| `SUPABASE_ACCESS_TOKEN` | CLI auth for migration/type-generation commands |

These live in your local shell/CI secrets, not in `.env.example`'s client section.

## References

- [API_Keys](API_Keys.md)
- `.env.example`
- `src/config/env.ts`
