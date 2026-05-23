# Build mode

Produces a build plan plus stack-specific scaffold(s) for a new or expanded UI surface. Always ends with the explicit handoff prompt to `frontend-design` (or honors a "skip").

## Why build mode is structured this way

The hard part of frontend work is not the code; it is the standards, IA, and budget decisions that constrain the code. Build mode forces those decisions explicitly and writes them down before any aesthetic execution. The result is that `frontend-design` can be bold without breaking accessibility or performance, and the team has a paper trail when those constraints get challenged later.

## Inputs

- **User goal** — one sentence the user can repeat back. "Let users compare two SKUs side-by-side and add either to a cart." Not "build a product page."
- **Target audience** — internal admin, public consumer, regulated user, AT user, expert power user, casual mobile user. Shapes density, latency tolerance, AAA vs. AA conformance.
- **Scope** — one component / one page / one flow / module of related pages. Larger than a module → decompose first.
- **Stack** — detected or named. Determines `references/stacks/<stack>.md`.
- **Constraints** — performance budget, deployment platform, brand system, regulatory regime, existing component library, time budget.
- **Existing patterns to integrate with** — read the surrounding code. Don't fork the design system.

## Workflow

### 1. Pattern selection

Open `references/domains/patterns.md`. For each major surface in the scope, pick a pattern and record it in the build plan. Use the table in `patterns.md` to justify the choice (use-when / avoid-when).

Surfaces that always need a decision:

- **Global navigation** — sidebar / nav rail / top bar / tab bar / hamburger (mobile only). Visible on larger screens.
- **Local navigation** — tabs, breadcrumbs, in-page anchors, none.
- **Search / command** — full search field, command palette (`Cmd-K`), neither. Required for apps with many destinations.
- **Primary surface pattern** — table, dashboard, form (single-page or wizard), reading view, feed, canvas, kanban, calendar, map, etc.
- **Feedback** — message bar (page-level, persistent), toast (transient), progress bar (determinate wait), spinner (short indeterminate), skeleton (known structure, moderate wait), inline error.

If you find yourself wanting to invent a pattern, stop. The pattern catalog covers ~95% of real product surfaces. Inventing usually means a misread of the user's job.

### 2. IA pass

Before any code, write down:

- The user's primary task on this surface, in one sentence.
- The two or three secondary tasks.
- The destinations the user reaches from here.
- The destinations the user reaches **to** here.
- The point in the flow where this surface sits (entry / midpoint / decision / completion).

This pass is short — a handful of bullet points — but it catches half the IA mistakes that show up in audit later.

### 3. Token plan (structure only)

Define **tier structure**, not values. Values come from `frontend-design`.

Mandatory tiers:

- **Color tiers** — `surface`, `surface-elevated`, `text`, `text-secondary`, `text-muted`, `border`, `accent`, `accent-on-accent`, `success`, `warn`, `error`, `info`, plus state derivatives (hover, pressed, disabled, focus-ring).
- **Typography tiers** — `display`, `heading-1` through `heading-4`, `body`, `body-small`, `code`, plus weight pairs.
- **Spacing tiers** — a scale (e.g., `space-1` through `space-9`) covering 4px / 8px / 12px / 16px / 24px / 32px / 48px / 64px / 96px or whatever cadence the brand uses.
- **Motion tiers** — `duration-instant` (0 ms, for `prefers-reduced-motion`), `duration-fast` (~150 ms), `duration-medium` (~250 ms), `duration-slow` (~400 ms), plus easing tokens (`ease-standard`, `ease-emphasized`, `ease-entry`, `ease-exit`).
- **Elevation / shadow tiers** if the surface uses depth.
- **Radius tiers** — `radius-sm`, `radius-md`, `radius-lg`, `radius-pill`.

Record these in the build plan. `frontend-design` fills the values.

### 4. Component scaffold

Open `references/stacks/<stack>.md`. Use its scaffolds as the structural baseline.

Rules:

- **Semantic HTML first.** `<button>`, `<a>`, `<input>`, `<dialog>`, `<details>`, `<form>`. ARIA only where native is missing.
- **Keyboard path explicit.** Document tab order in a comment in the scaffold. Document keyboard shortcuts (e.g., `Esc` closes, `/` focuses search).
- **Focus management explicit.** Where focus moves on open / close / submit / error / success.
- **Loading / empty / error / success states defined.** Every async surface needs all four.
- **No premature abstraction.** Three similar instances become an abstraction; two do not.

Stack-specific scaffolds in `references/stacks/<stack>.md` give you idiomatic starting points (Storybook stories for component frameworks, Pa11y test harnesses for vanilla, system tests for server-rendered).

### 5. Accessibility acceptance criteria

For each scope, list the WCAG 2.2 SCs that apply. Use `references/checklists/wcag-22-aa.md` to derive. Examples:

- **Form surface**: 1.3.1 Info and Relationships, 1.3.5 Identify Input Purpose, 2.4.3 Focus Order, 3.3.1 Error Identification, 3.3.3 Error Suggestion, 3.3.4 Error Prevention, 4.1.2 Name Role Value, 4.1.3 Status Messages.
- **Data table surface**: 1.3.1, 1.4.10 Reflow, 2.1.1 Keyboard, 2.4.6 Headings and Labels, 1.4.3 Contrast Minimum.
- **Dialog surface**: 1.3.1, 2.1.1, 2.4.3 Focus Order, 2.4.11 Focus Not Obscured, 4.1.2.

Always-applicable: 2.4.7 Focus Visible, 1.4.10 Reflow, 1.4.11 Non-Text Contrast, 2.5.8 Target Size Minimum, 2.4.11 Focus Not Obscured.

### 6. Performance budget

Set p75 budgets, not means. Write them in the build plan:

- **LCP ≤ 2.5 s** — identify the LCP element in advance (typically the largest above-fold media or text block). Plan for its preload / fetch priority.
- **INP ≤ 200 ms** — list the interaction handlers that will run on the surface and confirm none should exceed 50 ms long-task budgets per single interaction.
- **CLS ≤ 0.1** — reserve space for media, embeds, and dynamically inserted content. No layout-shifting font swaps; use `font-display: optional` or `swap` with metric overrides.
- **Loading-feedback choice** with reason: skeleton (structure known, wait > 400 ms), spinner (short indeterminate < 1 s), progress bar (estimable duration), message bar (persistent state).

Bundle / asset budgets where relevant (e.g., 200 KB JS / 100 KB CSS / 1 image preload over the wire on initial load). Tied to `templates/budgets.json` for `gate` mode.

### 7. Trust surface decisions (when applicable)

If the scope touches auth, account settings, or data collection:

- **Auth method** — passkeys (preferred), passkey + password fallback, password + 2FA. Document the choice and the reason. Default: passkeys with email magic link as recovery, password as last-resort fallback.
- **Recovery flow** — what happens on lost passkey / lost device / lost email. No dead ends.
- **Privacy disclosure** — where the layered notice appears at collection. Link to detail page. Granular consent where the regime requires.

### 8. AI surface decisions (when applicable)

If the scope includes AI:

- **Capability legibility** — exactly what does it do? What does it not do? In one sentence each.
- **User control** — stop / override / undo / edit / regenerate.
- **Explanation** — sources, reasoning, confidence display.
- **Correction** — how the user fixes wrong output and what the system does with the correction.
- **Outcome metrics** — resolution rate, escalation rate, edit-after-accept rate, time-to-acceptance.
- **Failure mode** — what happens when the AI doesn't know, or returns nothing, or returns dangerously wrong output. There should be a defined non-AI path.

### 9. Research plan

What method validates this surface lands?

- **Moderated remote test** — small N (5-8), best for diagnosis on a complex flow.
- **Unmoderated remote test** — larger N (20-50), best for completion-rate validation on a known task.
- **Tree test** — IA validation only.
- **Card sort** — IA generation only.
- **A/B test** — causal comparison once instrumentation is in place. Only meaningful for surfaces with measurable outcomes.
- **Heuristic + AT review** — early triage cheap; not a substitute for user evidence.

Record method, sample size, and success metric. The success metric should be a HEART-style product KPI (e.g., task-completion rate, time-on-task, error rate) plus a guardrail (e.g., p75 INP doesn't regress).

### 10. Emit the build plan and scaffold

Fill in `templates/build-plan.md`. Write at least one stack-specific scaffold file in `references/stacks/<stack>.md`'s idiom. Place the scaffold in the project at the path the user expects (or at a clear default like `src/features/<feature-name>/`).

### 11. Handoff to `frontend-design`

End with the exact prompt:

> "UX/standards layer locked. Detected stack: `[stack]`. Pattern set: `[chosen patterns]`. CWV budget at p75: LCP ≤ 2.5s / INP ≤ 200ms / CLS ≤ 0.1. WCAG 2.2 AA acceptance criteria: `[list]`. Token tiers chosen (structure only, not values): `[list]`.
>
> Hand off to `frontend-design` for typography, color, motion, and atmosphere? (Type 'skip' to keep vanilla aesthetics.)"

If the user says "skip", honor it. Provide vanilla aesthetic defaults (system font stack with one tasteful body+display pairing, accessible color values, default motion tokens) and stop.

If the user accepts, hand control to `frontend-design`. After it produces aesthetic decisions, run a quick consistency check:

- Token tier structure preserved? (no new tiers invented, no tiers removed)
- WCAG 2.2 AA contrast still holds for all color combinations?
- Reduced-motion respected?
- Semantic HTML preserved?
- Keyboard path and focus visible after styling?

Any breach → reverse-handoff per `references/handoff/frontend-design-pairing.md`.

## Common build anti-patterns

- **Building before deciding.** Code emerges before pattern selection, IA pass, or token plan. The agent and the user end up reverse-engineering the decisions from the artifact.
- **Inventing patterns.** When a known pattern would do. Inventing is appropriate ~5% of the time. The other 95% is a tell that the team misread the user's job.
- **Over-abstracting on day one.** Three similar surfaces → abstract. Two → don't. One → definitely don't.
- **Skipping research.** "We'll test it after launch" turns the product into the experiment. Pick a method up front.
- **Pre-empting `frontend-design`.** Picking color values, fonts, or motion personality during build mode. That's `frontend-design`'s job. Build mode picks the *structure* (tiers); aesthetic mode picks the *values*.
- **Designing for a single device class.** Test the keyboard path **and** a screen reader **and** mobile reflow before declaring the build plan done.
