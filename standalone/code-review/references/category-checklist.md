# Code review category checklist

The four categories from `SKILL.md` expanded into actionable bullets.
Lazy-load when you're working through a diff systematically.

## 1. Correctness

- **Does the change actually do what the PR description claims?** Read
  the description, then verify in the diff. Mismatches are the #1
  source of bugs that ship.
- **Off-by-one in loops, ranges, slices.** `0..n` vs `0..=n`,
  `len()-1` vs `len()`.
- **Nil/None/Option unwrap paths.** Every `unwrap()` and `?` is a
  branch — what happens on the error side?
- **Error propagation.** If a function returns `Result`, does every
  caller handle it? Are errors logged once, not re-logged at every
  layer?
- **Concurrency.** Shared mutable state across threads. `Send`/`Sync`
  bounds. Locks held across `.await`.
- **Time / timezones.** `Utc::now()` vs `Local::now()`. Off-by-DST.
- **Pagination.** Does the code assume a single page? What happens at
  page 2? At an empty result?
- **Empty / one-element edge cases.** Loops that work for n=10 often
  break at n=0 or n=1.

## 2. Security

- **Input validation at boundaries.** Don't trust HTTP requests, file
  contents, env vars without validation.
- **SQL — is it parameterized?** Any string concatenation into SQL is a
  finding.
- **Path traversal.** User-controlled paths joined to a base — does
  `..` escape the base?
- **Secret leakage.** Tokens / keys in logs, in error messages, in
  response bodies, in git history.
- **Auth bypasses.** Did a new route get added without auth middleware?
- **Default-deny vs default-allow.** New permission checks should fail
  closed.
- **Cryptography.** Hand-rolled crypto is almost always wrong. Flag any
  custom hashing / encryption that isn't using the standard library or
  a vetted crate.

## 3. Reliability

- **Timeouts on every external call.** HTTP, DB, queue. No
  `client.get(url).send()` without `.timeout()`.
- **Retry / backoff for transient failures.** And a cap on retries.
- **Error states are observable.** Logs, metrics, traces — not just
  silently swallowed.
- **Resource cleanup.** File handles, DB connections, locks. RAII
  helps but not always.
- **Panic-free paths.** Library code: no `unwrap` / `expect` / `panic!`
  outside of test code.
- **Memory bounds.** Unbounded `Vec` growth, unbounded channel buffers,
  unbounded recursion.
- **Backwards compat at boundaries.** API/DB schema changes — can the
  old version of the caller still work during deploy?

## 4. (Out of scope unless asked)

- **Style** — variable naming, formatting, idioms. The linter has an
  opinion; trust it.
- **Architecture** — "you should have used a Strategy pattern here".
  Only if the user asked for an architecture review.
- **Test coverage** — note if obvious paths are untested, but don't
  block on coverage numbers.

## Output format

For each finding:

```
[<category>] <file>:<line> — <one-line summary>
<2-4 lines of why this matters + suggested fix>
```

Group by category, ordered Security → Correctness → Reliability → other.
