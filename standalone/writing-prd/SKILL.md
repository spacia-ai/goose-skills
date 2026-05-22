---
name: writing-prd
description: Draft a product requirements document — problem framing, user stories, success criteria, scope cuts.
extensions: []
requires: []
tools:
  - developer__text_editor
tags:
  - writing
  - product
  - prd
  - standalone
min_goose_version: "1.33.0"
---

# Writing a PRD

Standalone skill. Use `developer__text_editor` to read background context
and write the draft.

## Structure (don't deviate without reason)

```
1. Problem            — what's broken, for whom, how do we know
2. Users              — who hits it, in what flow
3. Goals              — what success looks like, measurable if possible
4. Non-goals          — what we are deliberately not doing this round
5. Proposal           — the actual change, concrete
6. Open questions     — things the team needs to decide
7. Out-of-scope (v2)  — natural follow-ups that aren't in this scope
```

Keep each section ≤ 200 words. A PRD that takes 30 minutes to read won't
get read.

## Writing rules

- **Problem first, solution second.** Don't lead with "we should build X."
  Lead with the user pain.
- **One reader at a time.** Pick the primary audience (eng / product / exec)
  and write for them. Glossary at the bottom for jargon.
- **Quantify when you can.** "Many users see this" is weak. "23% of trial
  conversions stall here" is strong.
- **Mark uncertainty.** "We believe ..." vs "we know ..." — different
  epistemic weight, the reader needs to know which.
- **Be wrong on paper.** A PRD that hedges every claim is unreadable. State
  positions; let reviewers push back.

## Anti-patterns

- **Don't include implementation details in the proposal section.** Save
  for a tech-spec doc.
- **Don't end with "next steps".** End with open questions. Next-steps
  belong in the project tracker, not the PRD.
- **Don't write the success criteria after the proposal.** Goals should
  shape the proposal, not be backfilled.
- **Don't accept "no scope cuts."** Every PRD has tradeoffs; if you can't
  list non-goals, the scope isn't sharp enough yet.

## When to ask the user vs. when to draft

- **Ask first**: who is the audience, what's the deadline, what context
  documents exist, what does success look like.
- **Draft first**: once you have answers, sketch the whole PRD in one pass.
  Then iterate. Don't write section-by-section in conversation.

## Output format

Markdown. Use `##` for section headers (not `#`) so the doc nests cleanly
under an existing wiki page. Bullets sparingly — prose carries nuance better.
