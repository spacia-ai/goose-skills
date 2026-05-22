---
name: exa
description: Operator's manual for the Exa web-research MCP — when to search, how to dereference, citation patterns.
extensions:
  - exa
requires:
  - exa
tools:
  - exa__web_search_exa
  - exa__crawling_exa
  - exa__research_paper_search_exa
  - exa__company_research_exa
  - exa__github_search_exa
  - exa__wikipedia_search_exa
  - exa__linkedin_search_exa
tags:
  - search
  - web
  - research
  - extension-skill
min_goose_version: "1.33.0"
---

# Exa Operator's Manual

You have access to the **Exa** MCP server. Its tools are prefixed `exa__*`.
Read this skill in full **before** your first Exa call in any session.

## When to use Exa

- Recency: questions about current events, releases, versions, prices.
- Verification: any factual claim where citation is expected.
- Discovery: "find me the docs for X", "who's working on Y", "papers about Z".
- Triangulation: contested facts — verify against 2+ sources.

## When **not** to use Exa

- Pure-opinion or brainstorm prompts.
- Questions answerable from files already in the conversation (use
  `developer__text_editor` instead).
- Math, language-spec text, or well-known constants you have high confidence on.
- Anything the user already pasted a URL for — go straight to
  `exa__crawling_exa(url)`.

## The seven tools

| Tool | Use it for |
|---|---|
| `exa__web_search_exa(query, num_results?)` | Default keyword search. Returns title/url/snippet/date. |
| `exa__crawling_exa(url)` | Fetch the rendered text of one URL. Slow + uses credit; use after a search. |
| `exa__research_paper_search_exa(query, num_results?)` | Academic / arXiv / preprint bias. |
| `exa__company_research_exa(company, ...)` | Biographical / financial lookup. |
| `exa__github_search_exa(query)` | Code / repo-targeted. |
| `exa__wikipedia_search_exa(query)` | Wikipedia-only. |
| `exa__linkedin_search_exa(query)` | People / company on LinkedIn. |

Pick the **most specific** tool for the query type. Default to web search
otherwise.

## Decision tree

```
factual lookup, recent  → exa__web_search_exa, num_results=5
multi-source synthesis  → exa__web_search_exa then exa__crawling_exa on top 3-5
citation check          → exa__web_search_exa for the claim, exa__crawling_exa to verify wording
academic question       → exa__research_paper_search_exa
"how is this used"      → exa__github_search_exa
person/role query       → exa__linkedin_search_exa
company finance/bio     → exa__company_research_exa
```

## Query phrasing

Search engines aren't LLMs. **Keywords, not questions.**

```
Good: goose mcp extension config reference 2026
Bad : Can you tell me how I should configure a goose mcp extension please?
```

## Triangulation rule

For any **load-bearing** claim (one the user is likely to act on or share),
require two independent sources agreeing. If only one source, mark the claim
as "single-source" in the response.

## Citation format

```
[Title](https://full.url) (YYYY-MM-DD)
```

Inline at the relevant claim. Never separate citation sections at the end —
the reader can't tell which source backs which claim.

## Anti-patterns

- **Never fabricate a URL.** If search returned nothing, say so.
- **Don't paraphrase a source into a different claim.** Cite what the source
  literally says.
- **Don't loop on the same query.** Vary scope: drop product names, add a
  year, change tense.
- **Don't dump raw results.** Synthesize. Cite the ones you used.

## Anti-anti-pattern (when raw is fine)

The user asked for a search results list verbatim — just emit the top N as
a table. They asked for the search, not synthesis.
