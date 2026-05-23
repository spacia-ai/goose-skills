# Domain — research and experimentation

Mixed-method research, KPI stacks, A/B discipline, and where AI augmentation helps vs. hurts.

## Why research is part of UX engineering

A team that ships UX without research data ships UX on opinions. Opinions are unreliable, biased toward whoever speaks loudest, and don't update on contact with reality. Research data — qualitative and quantitative — is the only reliable input to UX decisions at scale.

This domain is not about running a research org. It is about the smallest set of methods, metrics, and disciplines that frontend / UX engineers and PMs need to make evidence-based decisions on the work they ship.

## The methods matrix

No single method is sufficient. Pick the right method for the question.

| Method | Best for | Main strength | Main risk |
|---|---|---|---|
| Remote moderated test | Diagnosing why a task fails | Deep probing, follow-up questions | Lower throughput; moderator skill required |
| Remote unmoderated test | Fast validation at scale | Speed, sample breadth | Weaker causal diagnosis |
| Card sorting | Defining IA labels and groups | Reveals user mental models | Weak at validating final structure |
| Tree testing | Validating navigation structure | Measures findability directly | No surface-level UI signal |
| Product analytics + RUM | Post-launch friction detection | Real behavior in production | Can show what, not always why |
| A/B experiment | Causal comparison | Strongest evidence for trade-offs | Easy to misuse with weak metrics or poor stats |
| Heuristic review | Early triage | Cheap, fast | Not a substitute for user evidence |
| Accessibility task test | AT and keyboard usability | Reveals real inclusion gaps | Requires specialized coverage |
| Diary study | Long-horizon behavior | Reveals real-life context | Recruitment hard, attrition real |
| Field study / ethnography | Understanding context of use | Reveals invisible context | Expensive, slow |

### Method-to-question mapping

- **"Will users complete this task?"** → unmoderated test at N=20-50.
- **"Why are users failing this task?"** → moderated test at N=5-8.
- **"What labels make sense for these things?"** → card sort.
- **"Is the navigation findable?"** → tree test.
- **"Why are users dropping off step 3?"** → analytics + RUM, then moderated probe.
- **"Is variant A better than variant B at converting?"** → A/B test, with proper stats.
- **"Is this accessible?"** → accessibility task test with real AT users.
- **"How do users actually use this in their job?"** → diary study or field study.
- **"Are there any obvious problems before we test?"** → heuristic review.

### When AI augments research

AI accelerates parts of research; it doesn't substitute for human judgment.

- **AI is good for:** transcription, initial clustering of open-text responses, draft summaries, outlier detection in survey data, recruitment screening, generating test prompts.
- **AI is mediocre for:** moderating live tests (diagnostic depth suffers), running heuristic review (misses subtle issues), summarizing interviews without human pass-through.
- **AI is bad for:** identifying root causes, choosing methods, prioritizing findings, making product decisions.

The operational rule: use AI to draft, cluster, summarize, or suggest. Require human review for interpretation, prioritization, and methodological soundness. Don't ship findings that haven't been read by a human.

## The KPI stack

Combine layers; don't pick only one.

### Layer 1 — Product quality (HEART)

Google's HEART framework. One per layer, not all five every quarter.

| Letter | Stands for | Question | Example metrics |
|---|---|---|---|
| H | Happiness | Are users satisfied? | NPS, CSAT, satisfaction surveys |
| E | Engagement | How deeply are users using this? | Sessions, time-on-task, feature adoption depth |
| A | Adoption | Are new users finding this? | New-user activation rate, feature trial rate |
| R | Retention | Do users come back? | DAU/MAU, weekly retention curves |
| T | Task success | Do users complete the task? | Completion rate, error rate, time-on-task |

For a product surface, pick **at least one** HEART metric and a guardrail metric (something that should not regress).

### Layer 2 — Task UX

Task-level metrics. These map to the report's "good look-like" standards.

- **Completion rate.** % of attempts that succeed.
- **First-click success rate.** % of users whose first action moves them toward the goal.
- **Time on task.** How long the median attempt takes.
- **Error rate.** % of attempts where the user makes a recoverable mistake.
- **Abandonment rate.** % of attempts that quit without completing.
- **Self-recovery rate.** Of users who error, % who recover without escalation.

### Layer 3 — Technical UX

Performance, stability, accessibility. Already covered in `domains/performance.md` and `domains/accessibility.md`.

- LCP / INP / CLS at p75.
- JavaScript error rate.
- Failed request rate.
- Keyboard task-completion rate.
- Focus-visible coverage.
- Screen-reader task success rate.

### Layer 4 — Data-work UX (for analytics-heavy surfaces)

- **Filter usage rate.** Are users actually filtering, or do they ignore the filters?
- **Time to first insight.** From dashboard load to first user action.
- **Export / share rate.** Are users taking results elsewhere?
- **Zero-result rate.** % of queries / filters that return no data.

### Layer 5 — AI feature UX

Already detailed in `domains/ai-ux.md`. Resolution rate, acceptance rate, edit-after-accept rate, escalation rate, confidence-mismatch rate, opt-out rate.

## A/B testing discipline

A/B testing is the strongest causal evidence available for UX decisions. It is also the most-misused method.

### Required inputs before running an A/B test

- **A primary metric** that the change is hypothesized to move. Picked *before* the experiment, not after looking at results.
- **A guardrail metric** that should not regress. (E.g., conversion is the primary; INP is the guardrail.)
- **A minimum detectable effect (MDE).** What's the smallest meaningful change?
- **A power calculation.** Given the MDE, the baseline rate, and the traffic, how long does the test need to run?
- **A stopping rule.** Defined in advance. Stop early only on pre-specified conditions.

### Common A/B testing failures

- **Peeking.** Stopping early when you see significance, then stopping again later when you don't. Inflates false-positive rate dramatically.
- **HARKing** (Hypothesizing After Results Known). Looking at the results, picking the winning metric, calling it the original hypothesis.
- **Multiple comparisons** without correction. Testing 20 metrics, finding one significant by chance, declaring victory.
- **Underpowered tests.** Insufficient traffic or duration to detect the MDE. Result is "no significant difference," misread as "no difference."
- **Treating local optima as global.** Many A/B tests pick local UX wins that erode product coherence over time. Always evaluate against the product's larger model.

### When A/B testing isn't the right answer

- **Low-traffic surfaces.** Not enough users to power a test in reasonable time. Use moderated tests or heuristic review.
- **High-stakes one-off changes.** Auth flow, account deletion, payment. The test exposes some users to a worse version, with high downside. Ship the better-tested option.
- **Regulated changes.** Some changes (privacy notices, accessibility) are not optional. Don't A/B test what's required.

## Common research anti-patterns

- **Skipping research because "we'll see in production."** Production is the worst place to learn this — costs of fixing post-launch are 10x.
- **Single method for every question.** A team that only does unmoderated tests, or only A/B tests, has blind spots.
- **Over-recruiting power users.** They don't represent the new-user experience.
- **Under-recruiting AT users.** Most accessibility issues are missed because no AT user was in the study.
- **Confirming, not testing.** Designing the study to validate the team's hunch. Pre-register hypotheses to avoid this.
- **Stopping at the artifact.** Findings that don't connect to product decisions are wasted. Every research session should end with "what changes as a result?"
- **Treating qualitative as anecdotal and quantitative as authoritative.** They are complementary. Quantitative tells you *what*; qualitative tells you *why*.
- **Anchoring on the loudest voice.** The user who articulates the problem best is not necessarily representative. Look at the distribution.

## Sample sizes

Rough rules of thumb for the most common methods:

- **Moderated diagnostic test:** N=5 catches ~85% of major usability issues; N=8 catches ~95%. More is rarely worth it.
- **Unmoderated validation test:** N=20 minimum; N=30-50 for confident completion-rate estimates.
- **Card sort:** N=15-20 for stable groupings.
- **Tree test:** N=50+ for confidence in findability scores.
- **A/B test:** depends on baseline rate, MDE, and acceptable false-positive rate. Use a power calculator.

## Reporting findings

A useful research report is short and decision-oriented.

- **One-sentence headline.** What changed in the team's understanding?
- **What we did.** Method, sample, scope.
- **What we found.** 3-5 findings, ordered by impact.
- **What we recommend.** 1-3 specific changes, each tied to a finding.
- **What we're watching.** Metrics or future studies that will validate the recommendations.

Long reports go unread. The artifact is meant to drive decisions, not to document for the archive.

## Bibliography

- "Designing UX Research" / Erika Hall — operational guide.
- "Just Enough Research" / Erika Hall — method-selection focused.
- "How Many Users Should You Test?" — Nielsen Norman Group on N=5.
- "Trustworthy Online Controlled Experiments" — Kohavi, Tang, Xu — A/B testing reference.
- "HEART Framework" — Google.
- "Tree Testing" / "Card Sorting" — articles from Optimal Workshop, NN/g.
- CHI / DIS proceedings on AI-assisted UX evaluation, 2024-2026.
- "What is Statistical Power?" — primer for non-statisticians.
