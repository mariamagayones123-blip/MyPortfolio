# Migrations

See [docs/05_Database/Migration_Strategy.md](../../docs/05_Database/Migration_Strategy.md) for
the full strategy. Quick reference:

- **Naming:** `<timestamp>_<snake_case_description>.sql`, generated via `supabase migration new
<name>` — never created by hand, so the timestamp ordering is always correct.
- **Additive only.** Never edit a migration that has already been applied anywhere (including
  locally) — write a new corrective migration instead.
- **Self-contained where possible.** Each migration enables RLS and adds its own policies for the
  tables it creates. The one deliberate exception (`resume_settings_messages_analytics` →
  `..._policies_and_grants`) is documented in both files' header comments.
- **Every migration** documents its dependencies on prior migrations in its own header comment.
