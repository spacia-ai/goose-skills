# Supabase diagnostic recipes

Lazy-load before mutating anything. Read-only patterns first; mutation
patterns later.

## Always-run-first sequence

When the user asks you to investigate any Supabase issue:

1. `supabase__get_project` — confirm which project we're looking at.
2. `supabase__list_tables` — get the schema map.
3. `supabase__get_advisors` — surface known security/perf warnings.
4. `supabase__get_logs` — check for recent errors before assuming the
   issue is in code.

Do NOT skip this even if the question seems narrow. Step 3 (advisors)
in particular surfaces issues — missing indexes, RLS gaps, leaked
secrets — that change the right answer.

## Read-only investigation queries

Run these via `supabase__execute_sql`. All read-only, no side effects.

```sql
-- Table row counts (approximate, fast):
SELECT relname, n_live_tup
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC
LIMIT 20;

-- Find slow queries from pg_stat_statements (if extension enabled):
SELECT calls, mean_exec_time, query
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- RLS policy audit per table:
SELECT schemaname, tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public';

-- Index usage:
SELECT schemaname, relname, indexrelname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC
LIMIT 20;  -- unused indexes at the top
```

## Migration patterns

Always go through `supabase__apply_migration`, never raw DDL via
`execute_sql`. The migration goes through the migrations history,
which is the source of truth other tooling reads.

**Adding a column to a hot table** (>100k rows):

```sql
-- Migration 1: add nullable column.
ALTER TABLE orders ADD COLUMN priority text;

-- Migration 2: backfill in batches via a separate script, then:
ALTER TABLE orders ALTER COLUMN priority SET NOT NULL;
ALTER TABLE orders ALTER COLUMN priority SET DEFAULT 'normal';
```

The 2-step pattern avoids a long `ACCESS EXCLUSIVE` lock that a single
`ADD COLUMN ... NOT NULL DEFAULT ...` would cause.

## Branches

For any change that could break the app:

1. `supabase__create_branch` — gets a throwaway environment.
2. Apply migrations to the branch.
3. Run app smoke tests against the branch's connection string.
4. `supabase__merge_branch` only after verification.

Skip branches for read-only investigation, or for additive non-breaking
changes (new tables, new columns that are nullable + no constraints).

## Anti-patterns

- **`DELETE` / `UPDATE` without a `WHERE`** — even on a "test" table.
  Use `supabase__create_branch` if you need to experiment.
- **`DROP TABLE` to "clean up"** — there's no undo on the live project.
  Ask first, always.
- **Disabling RLS to make a query work** — fix the policy or run as
  service role; never leave RLS off.
- **Treating `execute_sql` as a calculator** — every call hits the
  remote project. Batch related reads into one query.
