---
name: code-review
description: Review code changes for correctness, security, and reliability — focused, citation-style, no nitpicking.
extensions: []
requires: []
tools:
  - developer__shell
  - developer__text_editor
tags:
  - code
  - review
  - security
  - reliability
  - standalone
min_goose_version: "1.33.0"
---

# Code Review

This is a standalone skill — it doesn't depend on any MCP extension. It uses
`developer__shell` to run git commands and `developer__text_editor` to read
files.

## What "review" means here

A focused pass for **correctness**, **security**, and **reliability** issues.
Not a style audit. Not bikeshedding variable names. If the user wants a
style review they'll ask for one.

## The four categories

| Category | What to look for |
|---|---|
| **Correctness** | Off-by-one, wrong-API, missing-case in match, race conditions, lost errors. |
| **Security** | Injection (SQL, command, path), unvalidated input, secret leakage, auth bypass. |
| **Reliability** | Unbounded loops, no-timeout I/O, blocking-on-async, panics in library code. |
| **Test coverage** | New behavior without a test, removed tests, mocks where integration tests would catch regressions. |

## Workflow

```
1. git diff --name-only HEAD~1                 # what changed
2. For each file: developer__text_editor view  # actually read it
3. For changes touching SQL / shell / paths:
     grep for the four security patterns
4. For changes touching async / I/O:
     check for timeouts + error propagation
5. For deleted tests:
     ask why
6. Surface findings as a short list, citation-style:
     `path/to/file.rs:42 — possible SQL injection on user_input`
```

## Citation format

```
path/to/file.rs:42 — <one-line concern>
```

Don't paste the offending code into the review unless it's longer than 3 lines
and isn't trivially findable by `file:line`.

## Severity classification

- **Block-on-merge**: security issues, broken correctness, crashes.
- **Should-fix**: missing tests, missing timeouts, dropped errors.
- **Nice-to-have**: refactor opportunities, better naming.

Lead with block-on-merge. Don't bury security issues under naming nitpicks.

## Anti-patterns

- **Don't review every line.** Focus on what's new + what touches risky surfaces.
- **Don't make stylistic claims.** "I'd write this differently" isn't a finding.
- **Don't speculate beyond the diff.** If the file uses an existing pattern,
  trust it unless the pattern itself is wrong.
- **Don't pile on.** If you found 12 things, the user reads 3. Pick the
  biggest 3 + briefly mention the rest.
