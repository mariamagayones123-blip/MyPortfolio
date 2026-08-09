# Security Policies

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Row Level Security](../05_Database/Row_Level_Security.md), [API
Keys](API_Keys.md), [docs/09_Security/Threat_Model.md](../09_Security/Threat_Model.md)

## Purpose

Ties together the three layers of write protection this project uses — RLS, table grants, and
Edge Functions — since no single one of them is the whole story.

## Scope

Cross-cutting summary; each layer's full detail lives in its own document (linked below).

## Layer 1 — Row Level Security (primary boundary)

Every table, no exceptions, default-deny. Full detail in
[Row_Level_Security.md](../05_Database/Row_Level_Security.md). In one sentence: public reads are
filtered to published/approved content (or unconditional where no such concept exists), and every
write is gated on `authenticated and is_admin()`.

## Layer 2 — Table-Level Grants (defense in depth)

RLS alone isn't the full story: Postgres checks table-level `GRANT`s _before_ it ever evaluates a
row policy. Supabase's default project provisioning grants `anon`/`authenticated` broad privileges
on every `public` table — Phase 3's migration `..._policies_and_grants.sql` explicitly `REVOKE`s
those defaults and re-grants only what each table's actual policies rely on. This means a future
RLS policy bug (e.g. an accidentally-permissive `using (true)`) still can't expose a table that
has no base table-level grant for `anon` in the first place — the grant layer limits blast radius
even if the policy layer ever fails.

**Convention:** any new table created after Phase 3 must explicitly `GRANT` what its own policies
need, in its own migration — this project does not rely on `ALTER DEFAULT PRIVILEGES` to
auto-apply to future tables (see
[Migration_Strategy.md](../05_Database/Migration_Strategy.md#convention-for-future-migrations)).

## Layer 3 — Edge Functions (for the two tables RLS alone can't fully protect)

`messages` and `analytics_events` need to accept writes from completely anonymous, untrusted
visitors — but a plain RLS `INSERT` policy can only control _whether_ a row may be written, not
_which columns_ the client sets (a client could self-mark their own spam message as `status =
'read'`, or fabricate `ip_hash`). Both tables instead have **no INSERT policy for any client
role**; writes happen exclusively through Edge Functions using the service-role key
(`submit-message`, `log-analytics-event` — architected in Phase 3, implementation not yet
written), which:

- Validate the payload server-side (mirroring the client-side Zod schema)
- Check the honeypot field (`messages`) and apply basic rate-limiting
- Compute `ip_hash` themselves (SHA-256, never storing the raw IP)
- Force safe defaults (`status = 'unread'`, etc.) that the client cannot override

## Storage

Same three-layer model applied to `storage.objects`: RLS policies per bucket (public read,
`is_admin()`-gated write), size/MIME-type limits enforced at the bucket level (not just
client-side validation), no separate Edge Function needed since Storage's own RLS is sufficient
for admin-only writes (unlike `messages`, there's no "anonymous visitor needs to write" case for
storage). See [Storage.md](Storage.md).

## References

- [Row Level Security](../05_Database/Row_Level_Security.md)
- [API Keys](API_Keys.md)
- [Storage](Storage.md)
- [docs/09_Security/Threat_Model.md](../09_Security/Threat_Model.md)
