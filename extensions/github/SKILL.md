---
name: github
description: Operator's manual for the GitHub MCP — issues, PRs, comments, and code search. When to use REST vs GraphQL.
extensions:
  - github
requires:
  - github
tags:
  - github
  - issues
  - pull-requests
  - code-review
  - extension-skill
min_goose_version: "1.33.0"
---

# GitHub MCP Operator's Manual

The `github` MCP exposes tools for issues, PRs, comments, releases, and code
search. Tools are prefixed `github__*`.

## Cardinal rules

1. **Never push, force-push, or delete** without explicit user instruction.
   Anything that modifies remote state needs user-in-the-loop approval.
2. **Identify the repo first.** Don't assume — if the user says "the PR",
   confirm which repo + PR number.
3. **Default to the user's open PRs / issues**, not the full org's.

## Common tool patterns

```
list_pull_requests(owner, repo, state, sort)        # filter, don't enumerate all
get_pull_request(owner, repo, pr_number)            # the detail you need
create_pull_request_review(owner, repo, pr_number)  # ALWAYS approval first
list_issues(owner, repo, state, labels)
get_issue(owner, repo, issue_number)
create_issue_comment(owner, repo, issue_number)     # ALWAYS approval first
search_code(query, repos)                           # code search
```

## When to use code search

```
question                                    →  tool
where is X defined in repo Y?               →  search_code("X", "Y")
which repos use library Z?                  →  search_code("import Z", org filter)
find usages of function foo                 →  search_code("foo(", path filter)
```

Don't use code search for big concepts — it's full-text, not semantic.

## When to use issues vs PRs

Issues: bug reports, feature requests, discussion threads.
PRs: code changes (open / merged / closed without merge).

A "discussion about a bug" is an issue. A "let's review this code change" is
a PR.

## Anti-patterns

- **Don't post review comments without reading the diff first.** Use
  `get_pull_request` or pull the diff via `developer__shell git diff`.
- **Don't generate fake PR numbers**. If unsure, search first.
- **Don't mass-comment.** If you find 30 issues that need triage, present
  the list to the user; let them decide which to act on.
