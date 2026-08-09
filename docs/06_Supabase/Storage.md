# Storage

**Status:** Active
**Version:** 1.0
**Last Updated:** 2026-08-06
**Related Documents:** [Row Level Security](../05_Database/Row_Level_Security.md),
[Tables — media_assets](../05_Database/Tables.md#media_assets)

## Purpose

Documents the three storage buckets, their limits, the path convention, and how bucket access is
secured.

## Scope

`supabase/config.toml` `[storage.buckets.*]`, `supabase/migrations/..._storage_buckets_and_policies.sql`.

## Buckets

| Bucket          | Public | Size limit | Allowed MIME types                                                     |
| --------------- | ------ | ---------- | ---------------------------------------------------------------------- |
| `public-images` | Yes    | 5 MiB      | `image/png`, `image/jpeg`, `image/webp`, `image/avif`, `image/svg+xml` |
| `resumes`       | Yes    | 10 MiB     | `application/pdf`                                                      |
| `certificates`  | Yes    | 10 MiB     | `application/pdf`, `image/png`, `image/jpeg`, `image/webp`             |

Declared in **two places, kept in sync**: `supabase/config.toml` (controls local `supabase start`
provisioning) and the storage migration (`insert into storage.buckets ...`, which is what actually
creates them on any remote project the migrations are applied to). If one changes, update the
other — both files say so inline.

## Path Convention

```
{entity}/{entity_id}/{filename}
```

Examples: `projects/<project_id>/cover.webp`, `certificates/<certificate_id>/certificate.pdf`.
Predictable, so a future cleanup/orphan-detection job (Phase 11+) can match storage objects to
`media_assets` rows without guessing. This is an **application-level convention**, not enforced by
RLS — see Security below for why.

## Every Upload Needs a `media_assets` Row

The buckets hold bytes; `public.media_assets` holds the queryable, accessible metadata
(`alt_text`, dimensions, MIME type, uploader). An object with no corresponding `media_assets` row
is an orphan and shouldn't be linked from any content table. See
[Database_Design.md](../05_Database/Database_Design.md#media-asset-strategy).

## Security

`storage.objects` RLS policies (one set per bucket, 12 total): public `SELECT` for everyone,
`INSERT`/`UPDATE`/`DELETE` gated on `authenticated and is_admin()` — same pattern as every table's
RLS. No folder-naming restriction is enforced at the RLS layer; the path convention above is for
humans/tooling, not a security boundary — admin write access is already fully trusted
(single-owner site), so there's nothing a folder-naming check would protect against that
`is_admin()` doesn't already cover.

## References

- [Row Level Security](../05_Database/Row_Level_Security.md)
- [Tables — media_assets](../05_Database/Tables.md#media_assets)
- `supabase/config.toml`
