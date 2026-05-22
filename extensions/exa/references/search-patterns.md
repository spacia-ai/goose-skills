# Exa search patterns

Lazy-load this from `SKILL.md` when you actually need to design a query.

## Picking the right tool

| Question shape | Tool |
|---|---|
| "What does the current docs / web say about X?" | `web_search_exa` |
| "Read this specific page / scrape this URL" | `crawling_exa` |
| "Academic / scientific paper on X" | `research_paper_search_exa` |
| "What is company X doing / funding / hiring" | `company_research_exa` |
| "Code that does X" / "issues mentioning Y" | `github_search_exa` |
| "Background / canonical reference on X" | `wikipedia_search_exa` |
| "Who works at X / who built Y" | `linkedin_search_exa` |

When in doubt, start with `web_search_exa`. The others are sharper but
return less when the question is open-ended.

## Query shape

**Be specific, not creative.** Exa indexes the web; it doesn't infer
intent. Good queries are short noun-phrases plus disambiguators:

- Good: `tokio mpsc unbounded channel backpressure`
- Bad: `how do I deal with too many messages in rust async code`

**Add a year for recency-sensitive queries** (`2025`, `2026`). LLM
training data is stale; the web is not. If the user asks "is X still
the recommended approach?", the year filter matters.

**Quote literal terms.** When searching for an error message or a
function signature, quote it:

- `"E0382" "borrow of moved value"`
- `"axum::Router::layer"`

## When to chain searches

One search rarely answers a research-grade question. Plan two passes:

1. **Discovery pass** — broad query, scan top 3-5 results for terminology.
2. **Targeted pass** — re-search with the actual vocabulary the field uses.

Example: user asks "what's the modern way to do distributed locks in
postgres?" → first search returns mentions of advisory locks, FOR
UPDATE SKIP LOCKED, `pg_locks`. Second search: `"FOR UPDATE SKIP
LOCKED" job queue` returns canonical implementations.

## Citation discipline

Always cite the URL of the page that justifies a claim. Format:

```
The Tokio docs recommend bounded channels by default ([source](https://docs.rs/tokio/latest/tokio/sync/mpsc/fn.channel.html)).
```

Never paraphrase a source you didn't actually read — `crawling_exa` the
page before quoting it if you only saw it in search-snippet form.

## Anti-patterns

- **Don't translate the user's question into a search query verbatim.**
  Their phrasing is conversational; search wants keywords.
- **Don't re-search the same query with synonyms hoping for different
  results.** Pivot the *terminology* (advisory lock → row-level lock →
  optimistic concurrency), not the syntax.
- **Don't search when you already know.** If the user asks a definition
  question and you're confident, answer it and offer to cite if they
  want a source. A search round-trip for "what is a hashmap" is theater.
