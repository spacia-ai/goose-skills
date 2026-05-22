# PRD section deep-dive

Lazy-load when drafting the actual sections. Each section from the
`SKILL.md` structure, expanded with "what good looks like" + common
failure modes.

## 1. Problem

**Good**: 2-3 sentences. Names the user, names the pain, names how we
know it's real (incident? support volume? sales loss?).

**Bad**: paragraph of background context that buries the actual pain.
"Our system has evolved over time and ..." is not a problem statement.

Example of good:

> Enterprise customers can't restrict which integrations a workspace
> uses, leading to security review failures during procurement. This
> has blocked 3 deals in the last quarter (per sales-ops report).

## 2. Users

**Good**: name the persona, name the flow they're in when they hit the
problem. Reference real users if you can.

**Bad**: "all users" / "any developer". If the answer is "everyone",
the problem isn't well-scoped.

## 3. Goals

**Good**: 3-5 bullets. Measurable when possible — "<X> drops by 20%",
"task completion rate >80%". When not measurable, name the outcome
("users can complete X without escalating to support").

**Bad**: feature list dressed up as goals. "Ship a settings page" is a
deliverable, not a goal. "Customers can restrict integrations per
workspace" is a goal.

## 4. Non-goals

**Good**: 2-4 bullets that name things a reader might reasonably expect
to be in scope, but aren't. Forces clarity.

**Bad**: empty. Every project has non-goals; not naming them invites
scope creep.

Example:

> - Per-channel restrictions (workspace-level only this round).
> - UI-level restrictions for end users (admin-only configuration).
> - Audit log of restriction changes (separate compliance project).

## 5. Proposal

**Good**: concrete enough that someone could disagree with it. Names
the actual UX, the actual data model change, the actual API. If the
proposal could mean five different things, the PRD isn't done.

**Bad**: aspirational. "We will build a system that ..." is a sentence,
not a proposal.

Include a mock or wireframe if there's any UI. ASCII is fine if Figma
isn't available; it just has to be unambiguous.

## 6. Open questions

**Good**: things the team has to decide *before* this can ship. Tag
each with an owner if possible.

**Bad**: things the author hasn't bothered to think through yet. Open
questions are the ones where there's genuine team disagreement or
missing data, not where the author just hasn't done the work.

If "open questions" is empty, the PRD probably isn't ready for review.
If it's >10 items, the PRD isn't ready for *drafting* — go answer
some of them first.

## 7. Out-of-scope (v2)

**Good**: natural extensions you've considered but deliberately cut.
Signals to readers that you've thought beyond v1 without committing.

**Bad**: dumping ground for everything that didn't fit. v2 items should
be specific enough that you'd recognize them in 3 months.

## Length

Most PRDs should be **1-3 pages**. If you're at 5+ pages, you're either
(a) writing an engineering design doc (different artifact) or (b)
hiding the actual proposal under explanation.

Edit before you ship for review. The first draft is for you; the final
draft is for your readers.
