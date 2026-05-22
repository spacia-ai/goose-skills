---
name: supabase-mcp
description: Operator's manual for the Supabase MCP — database, edge functions, storage, advisors. When to read vs migrate.
extensions:
  - supabase
requires:
  - supabase
tags:
  - supabase
  - postgres
  - database
  - extension-skill
min_goose_version: "1.33.0"
---

# Supabase MCP Operator's Manual

The Supabase MCP gives you Postgres database access, edge function management,
storage, and project-level diagnostics. Tools are prefixed `supabase__*`.

## Cardinal rules

1. **Schema changes go through migrations**, not raw SQL. Use
   `supabase__apply_migration` for any DDL (CREATE / ALTER / DROP).
2. **Investigate before changing.** Run `supabase__get_advisors` and
   `supabase__list_tables` before mutating anything.
3. **`supabase__execute_sql` runs against the remote project directly.**
   Treat it like prod. Don't `DELETE FROM users` to "test something."
4. **Branches exist for risky changes.** Create a branch with
   `supabase__create_branch`, test, then merge.

## Read-mostly tools

```
list_tables(schemas?)              → see the database
list_extensions()                  → which extensions are installed
list_migrations()                  → audit trail
get_logs(service)                  → service: api, postgres, edge-functions, etc.
get_advisors(type)                 → 'security' / 'performance' linter findings
get_project()                      → status, region, plan
get_project_url() / get_publishable_keys()
```

Run these freely — they're idempotent reads.

## Write-mostly tools (require user approval)

```
apply_migration(name, query)       → DDL changes. Goes to schema_migrations.
execute_sql(query)                 → arbitrary SQL. DON'T use for DDL — use migrations.
deploy_edge_function(name, files)  → ship serverless code
create_branch(name) / merge_branch / delete_branch / reset_branch / rebase_branch
```

## Investigation pattern

User asks: "why is this slow?"

1. `get_advisors(type='performance')` — does the linter already know?
2. `list_tables()` — what schemas exist?
3. `execute_sql("EXPLAIN ANALYZE <query>")` — actual plan.
4. Propose a fix. Apply via `apply_migration` if it's a schema change.

## Anti-patterns

- **Don't run `DROP TABLE` to "fix" something.** Migrate first.
- **Don't deploy edge functions without reading their source.** Verify the
  user provided the right code.
- **Don't paste secrets into `execute_sql`.** Use the secrets manager pattern
  (see Supabase docs).
- **Don't dump entire result sets**. If a query returns 10k rows, paginate
  or aggregate in SQL before returning to the user.
