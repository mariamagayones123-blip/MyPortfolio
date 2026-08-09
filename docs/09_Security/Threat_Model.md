# Threat Model

**Status:** Active (Phase 3 scope — database/backend surface only)
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Row Level Security](../05_Database/Row_Level_Security.md), [Security
Policies](../06_Supabase/Security_Policies.md), [API Keys](../06_Supabase/API_Keys.md)

## Purpose

Names the concrete threats the Phase 3 backend design defends against, and the specific mechanism
that defends against each one — so future changes can be checked against "does this still hold?"
rather than relying on the design's original reasoning being remembered correctly.

## Scope

Database/backend attack surface only (RLS, grants, storage, secrets). Frontend threats (XSS,
dependency vulnerabilities, etc.) and infrastructure threats (DNS, hosting) belong to a broader
security review in a later phase — this document will grow as later phases add attack surface
(Phase 10 auth flows, Phase 11 admin dashboard).

## Threats and Mitigations

| Threat                                                                                                       | Mitigation                                                                                                                                                                                                 |
| ------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Anonymous user reads draft/unpublished content                                                               | RLS `SELECT` policies filter on `status = 'published'`/`'approved'` on every content table that has such a concept                                                                                         |
| Anonymous user reads a _draft_ project's/post's child rows (features, tags) even though the parent is hidden | Child-table RLS policies (`project_features`, `blog_post_tags`) derive visibility via an `EXISTS` subquery against the parent's status, not independent `using (true)`                                     |
| Anonymous or non-admin authenticated user writes/edits/deletes content                                       | Every write policy gated on `authenticated and is_admin()`; `is_admin()` checks the `app_admins` allow-list, which ships empty until an admin is bootstrapped by direct SQL                                |
| A future RLS policy bug (e.g. accidental `using (true)` on a write policy)                                   | Table-level `GRANT` audit (see [Security_Policies.md](../06_Supabase/Security_Policies.md)) limits blast radius — a table with no base grant for `anon` stays inaccessible even if its RLS policy is wrong |
| Non-admin `app_admins` self-management (a user grants themselves admin)                                      | No INSERT/UPDATE/DELETE policy exists for `authenticated` on `app_admins` at all — managing admins is a direct-SQL-only operation                                                                          |
| `is_admin()` recursive lockout (function can't read the table it checks)                                     | `SECURITY DEFINER` — function runs as its owning role, which bypasses `app_admins`' own RLS by owner default, rather than as the calling (possibly non-admin) role                                         |
| Search-path hijacking against a `SECURITY DEFINER` function                                                  | `search_path` pinned explicitly (`public, pg_temp`) on `is_admin()`                                                                                                                                        |
| Anonymous contact-form submitter tampers with `status`/`ip_hash` on their own insert                         | No RLS `INSERT` policy exists for `messages`/`analytics_events` at all — writes only via Edge Functions (service-role, computes sensitive fields server-side)                                              |
| Contact-form spam / abuse                                                                                    | Honeypot field + `ip_hash`-based rate-limiting, enforced server-side in the (not-yet-implemented) `submit-message` Edge Function — never trusted from the client                                           |
| `service_role` key exposure                                                                                  | Never a `VITE_*` variable, never in the client bundle — see [API_Keys.md](../06_Supabase/API_Keys.md) for the hard rule and how to verify it                                                               |
| Storage bucket abuse (oversized/wrong-type uploads)                                                          | Per-bucket `file_size_limit`/`allowed_mime_types`, enforced by Storage itself, not just client-side validation                                                                                             |
| Orphaned/unattributed storage objects                                                                        | Path convention (`{entity}/{entity_id}/{filename}`) + every object expected to have a matching `media_assets` row — enables a future cleanup job, though none exists yet                                   |
| Non-image media missing accessibility text                                                                   | Database-enforced, not just convention: `media_assets_alt_text_required_for_images` CHECK constraint makes `alt_text` mandatory for any image-type row                                                     |
| PII exposure via analytics                                                                                   | No raw IP or user-agent ever stored on `analytics_events` — only a random per-session UUID; `messages.ip_hash` stores a SHA-256 hash, never the raw IP                                                     |

## Explicitly Out of Scope for Phase 3

- Authentication attack surface (session fixation, OAuth redirect validation, credential stuffing)
  — Phase 10 will need its own review once login UI exists
- Admin dashboard attack surface (CSRF on admin actions, etc.) — Phase 11
- Rate-limiting beyond the basic `ip_hash` lookup — a full rate-limiting strategy is a Phase 9
  (Contact & Resume) implementation detail once the Edge Functions are actually written
- Frontend security (CSP headers, dependency audit) — Phase 13 (SEO & Accessibility) / Phase 14/15

## References

- [Row Level Security](../05_Database/Row_Level_Security.md)
- [Security Policies](../06_Supabase/Security_Policies.md)
- [API Keys](../06_Supabase/API_Keys.md)
