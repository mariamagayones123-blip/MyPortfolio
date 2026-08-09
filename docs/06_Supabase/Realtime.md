# Realtime

**Status:** Architecture defined, not yet wired to any UI
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Row Level Security](../05_Database/Row_Level_Security.md)

## Purpose

Documents the realtime architecture decided in Phase 3. None of this is connected to any frontend
component yet — that happens in the phase that actually needs it (Phase 11 for admin
notifications; a possible small Phase 4 decision for a visitor-count badge, noted below but not
built).

## Scope

Channel/table design only. No client-side subscription code exists yet.

## Visitor Count → Presence, Not `postgres_changes`

Use a **Realtime Presence** channel (`supabase.channel('site-presence')`), not a
`postgres_changes` subscription on a table. Presence is purpose-built for "how many clients are
connected right now" without writing a database row per visit — far lighter than a table-backed
approach for something this ephemeral.

**Important distinction:** Presence tracks _current connections_, not historical traffic. "How
many visitors today/this month" is a separate concern, answered by querying `analytics_events`
(see [Tables.md](../05_Database/Tables.md#analytics_events)), not Presence.

## Live Message/Notification Updates → `postgres_changes`

A `postgres_changes` subscription on `messages` `INSERT`, for a future admin "new message" toast
(Phase 11). Realtime respects RLS — an anonymous client cannot subscribe to see other visitors'
messages, since the same `admin-only SELECT` policy that gates normal queries also gates realtime
change events.

## Not Yet Decided

Whether a small "currently available" Presence-based badge belongs in the Phase 4 header is an
open question for that phase, not resolved here — Phase 3's job was the backend architecture, not
where it eventually surfaces in the UI.

## References

- [Row Level Security](../05_Database/Row_Level_Security.md)
- [Tables — analytics_events](../05_Database/Tables.md#analytics_events)
