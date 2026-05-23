# Learn mode

Surfaces the curriculum, hiring kit, and capstone for teams investing in web-app UX systems capability. Adapts depth to the audience.

## Why a learn mode exists

The other three modes (audit / build / gate) ship work. Learn mode builds the team that ships the work. A team that can audit, build, and gate UX consistently is built deliberately, not by hiring "good designers" and hoping they collide with the right standards.

This mode is small, but it's where the report's training value lives. If a user asks "how do I level up my team on this", "evaluate this candidate", or "give me a curriculum", this is the right entry point.

## Audience triage

Pick the audience first; the rest of the workflow depends on it.

| Audience | Default output |
|---|---|
| Solo dev / IC | Self-study reading order through `domains/*.md`, mapped to weekly objectives |
| Team lead / EM | The full 10-week program (below), plus a capstone brief |
| Hiring manager | The hiring kit: work-sample tasks + weighted rubric |
| Candidate prepping for interview | The hiring kit (read it as a study guide), plus the capstone brief |
| Staff+ engineer / architect | Full curriculum + capstone + cross-team coordination notes |

If the audience is unclear, ask once before producing.

## The 10-week program

The curriculum is intentionally short and intense. Ten weeks is enough to install habits and produce a real artifact; longer programs lose engagement.

### Week 1 — Foundations

**Objectives:** WCAG 2.2 AA, semantic HTML, ARIA / APG, IA fundamentals.

**Exercises:**
- Audit one existing flow in your product for semantics, keyboard path, and heading hierarchy. Use `modes/audit.md` and `domains/accessibility.md`.
- Pick three custom widgets in your product. Decide if they should be APG patterns or native; document the choice.

**Assessment:**
- Can explain why native HTML beats custom controls when possible.
- Identifies high-severity accessibility gaps with WCAG SC citations.
- Distinguishes filling a gap with ARIA from reinventing native.

### Week 2 — Navigation, forms, and states

**Objectives:** Differentiate global vs. local navigation; design for transactional flows; cover all four states (loading, empty, error, success).

**Exercises:**
- Redesign one app shell for desktop **and** mobile web. Both must work. Use `domains/patterns.md`.
- Build a multi-step form with question-page wizard, inline + summary errors, value preservation. Use `checklists/forms-recovery.md`.

**Assessment:**
- Clear labeling and visible wayfinding.
- Sensible responsive adaptation that preserves the task model.
- Form preserves user effort on error; validates at sensible times.

### Week 3 — Tables, dashboards, and data UX

**Objectives:** Task-centered table design; dashboard-as-decision-surface; chart selection.

**Exercises:**
- Design a CRUD table with sort, filter, single-row edit, and bulk action. Use `domains/patterns.md`.
- Design one dashboard overview with at-a-glance situational awareness for a real metric set. Define the actions a viewer takes from each chart.

**Assessment:**
- Sorting / filtering / action model is coherent and keyboard-accessible.
- Charts support comparison and trend recognition, not ornament.
- No data cardified that should be tabular.

### Week 4 — Adaptive UI

**Objectives:** Container queries, view transitions, multi-pane adaptive layouts.

**Exercises:**
- Rebuild two complex components with container-query-based behavior, not viewport-only breakpoints.
- Implement one navigation transition with View Transitions API as progressive enhancement.

**Assessment:**
- Components adapt without breaking hierarchy or keyboard path.
- Transitions degrade gracefully where unsupported.

### Week 5 — Design systems and tokens

**Objectives:** Token tiers, component governance, documentation discipline, the design-token format.

**Exercises:**
- Create token tiers for a mini design system: color, type, spacing, motion, elevation, radius.
- Wire Storybook coverage for one component family, including all states.
- Write component contracts (props, slots, events, a11y guarantees).

**Assessment:**
- Tokens are consistent, reusable, and implementation-oriented.
- Storybook stories cover default + hover + focus + pressed + disabled + error + loading + empty.

### Week 6 — Performance and perceived performance

**Objectives:** Connect UX decisions to Core Web Vitals; choose loading feedback by latency shape; prevent layout shift.

**Exercises:**
- Instrument a prototype for wait states. Pick skeleton vs. spinner vs. progress per surface.
- Measure p75 LCP, INP, CLS in a prod-like environment. If your team has CrUX access, compare lab to field.

**Assessment:**
- Correct loading-state choices.
- Understands field-vs.-lab distinction.
- Stable layouts; transforms-not-layout for animation.

### Week 7 — Trust UX

**Objectives:** Passkeys / WebAuthn, layered privacy, granular consent.

**Exercises:**
- Design account settings for passkey creation, naming, and removal.
- Design a recovery flow that doesn't dead-end on a lost device.
- Place a layered privacy notice at the point of collection for one form in your product.

**Assessment:**
- Strong authentication with humane fallback.
- Clear privacy notices at relevant collection points; easy withdrawal.

### Week 8 — AI UX

**Objectives:** Evaluate AI features against the four-question test (legibility / control / explanation / correction).

**Exercises:**
- Prototype one AI feature with explicit capability legibility, control, explanation, and correction.
- Define outcome metrics: resolution rate, edit-after-accept rate, escalation rate.
- Define the failure mode: what happens when the AI doesn't know.

**Assessment:**
- AI surface solves a clear job.
- Failure mode is defined and dignified.
- Metrics are real, not vanity.

### Week 9 — Research and experimentation

**Objectives:** Mixed-method literacy; HEART framework; A/B discipline; AI-augmented research with human review.

**Exercises:**
- Plan a small mixed-method study: 5 moderated tests, then an unmoderated pass at N=30, plus heuristic and AT review.
- Wire one A/B test with proper instrumentation, success metric, guardrail metric, and stopping rule.

**Assessment:**
- Method matches the question.
- Success and guardrail metrics defined before the test runs.
- Knows when AI augmentation helps and when human review is required.

### Week 10–11 — Capstone

A two-week capstone that integrates everything. Brief below.

## Capstone brief

Build a **responsive analytics-and-operations module** for a fictional B2B SaaS product.

**Required surfaces:**
- App shell with global nav and search / command access.
- One multi-step form (e.g., create-customer, configure-rule, run-export).
- One data table (sortable, filterable, single-row edit, bulk action).
- One dashboard overview (3-5 metrics with decision actions).
- One account / security area (passkeys + recovery + privacy controls).
- One AI-assisted workflow aid (e.g., draft a report, suggest a filter, summarize a row).

**Required evidence:**
- Accessibility checklist filled for every surface.
- Storybook stories with all-state coverage for at least three component families.
- Visual regression tests with Playwright.
- Core Web Vitals plan (lab measurements + field telemetry plan).
- Mixed-method research plan (one moderated, one unmoderated, plus heuristic + AT review).
- Token tiers documented.
- CI gates wired (axe, Lighthouse CI, Playwright).

**Stretch:**
- Reverse-handoff exercise: collaborate with someone using `frontend-design` and integrate their aesthetic POV without breaking standards.

**What success looks like:** the candidate or team can defend every choice with a reference (WCAG SC, hard target, pattern catalog, research method). They don't say "I thought it looked good" — they say "I picked tabs because the views are sibling categories on a single surface, per `domains/patterns.md`."

## Hiring kit

For senior frontend / UX engineer roles. Tests systems thinking across UX and frontend, not tool fluency.

### Work-sample tasks

| Task | Format | What it reveals | Good prompt |
|---|---|---|---|
| Accessibility triage | 60-90 min live exercise | Semantics, keyboarding, focus, debugging | "Fix the broken modal, tabs, and form validation in this small CRUD app." |
| IA + nav redesign | Whiteboard or take-home | Labeling, hierarchy, responsive thinking | "Redesign this crowded left-nav and command/search model for desktop and mobile web." |
| Data-grid workflow | Pairing or take-home | Data UX judgment, interaction detail | "Turn this raw admin list into a usable table for find / compare / edit / bulk action." |
| AI feature critique | Portfolio review + scenario | Separates novelty from utility | "Should this product add an AI assistant? If yes, where and how would you bound it?" |
| Systems delivery | Short take-home | Design-code workflow maturity | "Show how you would connect tokens, component docs, visual tests, and release criteria." |

### Weighted rubric

Use a numerical rubric, not gut feel. Calibrate the panel before the loop.

| Dimension | Weight | What strong looks like |
|---|--:|---|
| Problem framing | 20% | Starts from user goals, constraints, and failure modes. Not from "let's wireframe." |
| Accessibility and semantics | 20% | Chooses native patterns, anticipates AT and keyboard behavior. ARIA discipline. |
| IA and interaction design | 20% | Uses the right patterns for wayfinding, forms, and feedback. Doesn't invent unnecessarily. |
| Implementation literacy | 15% | Understands component structure, state, responsiveness, and testability. Reads code, not just designs. |
| Performance and trust | 15% | Includes CWV, perceived performance, privacy, and security considerations. Not as afterthoughts. |
| Measurement mindset | 10% | Proposes success metrics, guardrail metrics, and validation methods. |

Anything above 75% on this rubric is a strong hire. 60-75% is a hire-with-development-plan. Below 60% is a no-hire on this loop.

### Bar-raising signals

- Reaches for native HTML before component libraries.
- Talks about p75, not means.
- Distinguishes lab from field measurement unprompted.
- Mentions reduced-motion / contrast preferences without being asked.
- Has opinions about toast vs. message bar.
- Has built or contributed to a design system, not just consumed one.
- Has shipped at least one a11y fix that required changing existing code, not just adding new code.
- Talks about research evidence, not just "user feedback."

### Red-flag signals

- "Add `role='button'` to the div." (Use `<button>`.)
- "We'll add focus styles later."
- "We don't need WCAG; we use Material UI."
- "Lighthouse score is 95, we're good."
- "Just disable the submit button until the form is valid."
- "We'll just toast everything."
- "Skeletons everywhere look modern."

## Suggested reading order by audience

### Solo dev (4-6 weeks self-study)
1. `domains/accessibility.md` — Week 1.
2. `domains/patterns.md` + `checklists/forms-recovery.md` — Week 2.
3. `domains/performance.md` + `checklists/core-web-vitals.md` — Week 3.
4. `domains/delivery.md` + `stacks/<your-stack>.md` — Week 4.
5. `domains/trust.md` + `checklists/auth-passkeys.md` — Week 5.
6. `domains/ai-ux.md` + `domains/research.md` — Week 6.

### Team lead (10 weeks, full program)
Run the curriculum as written. Weekly 90-minute sessions with the exercises pre-assigned. Capstone in weeks 10-11.

### Hiring manager (one prep session)
Read the hiring kit. Calibrate the panel on the rubric before any candidate sees it.

### Candidate prepping (1-2 weeks)
Read the hiring kit (it tells you what's measured), then read `domains/accessibility.md`, `domains/patterns.md`, and `domains/performance.md`. Build a small artifact you can demo. Have measured numbers, not vibes.

## Common learn-mode anti-patterns

- **Lecturing without exercises.** Curriculum without artifacts produces zero retention. Every week has an exercise; every exercise produces a demonstrable thing.
- **Hiring on portfolio narration alone.** Use the work-sample tasks. Portfolios over-represent best work and under-represent process.
- **Optimizing for the rubric instead of the work.** The rubric is calibrated for systems thinking, not for memorizing buzzwords. Coach the panel away from "did they say WCAG" and toward "did they make the right call."
- **Treating accessibility as week 7 instead of week 1.** It is foundational, not a specialization. The curriculum is deliberately ordered.
