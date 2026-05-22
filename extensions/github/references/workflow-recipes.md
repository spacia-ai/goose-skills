# GitHub MCP workflow recipes

End-to-end patterns for common GitHub work. Lazy-load when you're about
to coordinate across multiple `github__*` tool calls.

## Recipe: Review a pull request

1. **Pull the PR metadata** — number, base/head branches, author, status checks.
2. **Read the diff in full.** Don't review on description alone.
3. **Read the linked issue(s)** referenced in the body — that's where
   the "why" lives.
4. **Check CI status.** If checks are failing, the diff isn't reviewable
   yet — surface that to the user first.
5. **Look at the conversation thread.** Prior reviewers may have flagged
   things you'd otherwise raise.
6. **Post review comments inline**, one per concrete issue. Don't bundle
   five unrelated concerns into one comment.
7. **Approve / request-changes / comment** — pick one based on severity.

## Recipe: Triage open issues

1. **Filter by `is:open is:issue no:assignee`** to find untouched issues.
2. **Group by label** — bug / feature / question / docs.
3. **For each unlabeled issue**, infer the right label from title + body
   and propose it (don't apply unilaterally unless the user asks).
4. **Surface duplicates** — if you see two issues describing the same
   bug, link them.
5. **Never close an issue without explicit user instruction.**

## Recipe: Find when a regression was introduced

1. **Get the commit history** for the file or area in question.
2. **`git bisect` candidates** — surface the last 10-20 commits as a
   list with one-line summaries.
3. **Check linked PRs** for each candidate commit — the PR description
   often explains intent better than the commit message.
4. **Don't speculate** about which commit broke it without running the
   actual failing test against each candidate.

## Cardinal rules (mirroring SKILL.md)

- Never push, force-push, or delete without explicit user instruction.
- Confirm the repo before acting — "the PR" is ambiguous.
- Default to the user's open PRs/issues, not the full org's.
- For any state-mutating operation (create issue, create PR, merge, add
  label, request review), confirm the exact text/target with the user
  before calling the tool.

## REST vs GraphQL

Prefer REST for simple lookups (issue by number, PR by number, single
file). Use GraphQL when you need to fetch multiple related objects in
one round-trip (issue + comments + linked PRs). The GitHub MCP exposes
both; pick based on how many follow-up calls a REST approach would
require.

## Common pitfalls

- **Pagination silently truncates.** If you ask "all open issues" and
  the org has 500, the default page size will miss most. Always check
  the response for a continuation token.
- **Search vs list.** `search/issues` is GitHub-wide and has different
  query syntax than `list-issues`. For a known repo, `list` is faster
  and more deterministic.
- **Rate limits matter.** Bulk operations across many repos can hit
  secondary rate limits — batch and back off.
