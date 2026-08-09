# API Keys

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Environment](Environment.md), [Security_Policies](Security_Policies.md),
[docs/09_Security/Threat_Model.md](../09_Security/Threat_Model.md)

## Purpose

Explains the two Supabase API keys this project uses, why they're never interchangeable, and
exactly where each one is allowed to live.

## Scope

`anon` key and `service_role` key. Does not cover Auth provider OAuth secrets (Google/GitHub
client secrets) — those are Phase 10.

## The `anon` Key

- **Where it lives:** `VITE_SUPABASE_ANON_KEY`, bundled into the client — anyone can see it in the
  browser, and that's fine by design.
- **What protects data with this key in use:** Row Level Security, not the key's secrecy. Every
  table's RLS policies are written assuming the `anon` role's requests are fully public/untrusted.
- **Used by:** `src/lib/supabase.ts` (Phase 1; becomes `src/lib/supabase/client.ts`, typed, once
  `database.ts` is generated — see [Database.md](Database.md)).

## The `service_role` Key

- **Where it lives:** Supabase project secrets only (`supabase secrets set
SUPABASE_SERVICE_ROLE_KEY=...` or the Dashboard), consumed inside Edge Functions.
- **What it does:** bypasses RLS entirely. This is exactly why it must never reach the client —
  every RLS policy in this schema becomes meaningless the moment this key is exposed.
- **Used by:** the (not-yet-implemented) `submit-message` and `log-analytics-event` Edge
  Functions, to insert into `messages`/`analytics_events` on behalf of anonymous visitors who have
  no other write path to those tables — see
  [Row_Level_Security.md](../05_Database/Row_Level_Security.md#messages--analytics_events-no-anon-insert-policy).

## Hard Rule

**The service-role key never enters a `VITE_*` environment variable, never enters the client
bundle, and CI/deploy pipelines must treat it as a Supabase secret, not a build-time variable.**
This is the single most consequential rule in the whole Phase 3 security model — everything else
(RLS, grants, storage policies) assumes it holds.

## Verifying the Boundary

Before shipping any change that touches environment variable handling, confirm:

- No `VITE_`-prefixed variable is ever set to the service-role key's value
- `.env.example` (repo root) lists only the anon key, never service-role
- `supabase/functions/.env.example` documents the service-role key's _name_ only, never a real
  value

## References

- [Environment](Environment.md)
- [Security_Policies](Security_Policies.md)
- [docs/09_Security/Threat_Model.md](../09_Security/Threat_Model.md)
