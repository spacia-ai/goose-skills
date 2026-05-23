# Handoff — pairing with `frontend-design`

The cross-skill contract. This file is the single source of truth for how `frontend-ux-engineering` (this skill) and `frontend-design` (the official aesthetic-execution skill) work together.

## Why this contract exists

Both skills can plausibly trigger on "build me a UI." Without an explicit contract, they overlap, contradict, or one silently takes precedence. The contract is: **this skill runs first** to lock the standards layer; **`frontend-design` runs second** to execute aesthetic decisions inside those constraints. Each owns its own discipline. Neither overrides the other's responsibilities.

## What each skill owns

### This skill (`frontend-ux-engineering`) owns

- **Standards.** WCAG 2.2 AA conformance, ARIA correctness, semantic HTML.
- **Information architecture.** Global / local navigation decisions, search and command surfaces, breadcrumbs, the structure of how the user navigates.
- **Pattern selection.** Which pattern to use for navigation, forms, tables, dashboards, dialogs, feedback. Drawn from `domains/patterns.md`.
- **Accessibility acceptance criteria.** The specific WCAG SCs that apply to each surface.
- **Performance targets.** Core Web Vitals at p75 (LCP / INP / CLS), perceived-performance choices (skeleton vs. spinner vs. progress).
- **Trust UX.** Auth flow shape (passkey-first), recovery design, layered privacy notices, granular consent.
- **AI feature shape.** Capability legibility, control, explanation, correction, outcome metrics, failure modes.
- **Research plan.** Method, sample size, success metric, guardrail metric.
- **Token tier *structure*.** What tiers exist (color, type, spacing, motion, elevation, radius). NOT the values.
- **CI gates.** axe, Lighthouse CI, Playwright visual regression, Storybook a11y addon.
- **Field telemetry plan.** CrUX or RUM for p75 measurement.

### `frontend-design` owns

- **Typography decisions.** Specific fonts, font pairings, weight pairs, distinctive type choices.
- **Color values.** Specific hex / RGB / OKLCH for each token tier. Brand-appropriate palettes.
- **Motion personality.** Easing curves, durations within the tier structure, motion choreography.
- **Atmospheric details.** Textures, gradients, noise, decorative borders, custom cursors, grain overlays.
- **Layout drama.** Asymmetry, overlap, diagonal flow, grid-breaking, density.
- **The "unforgettable" point of view.** What makes this product visually distinctive.

### Shared (both contribute, this skill arbitrates)

- **Spacing scale.** This skill defines the tier structure (e.g., `space-100` to `space-900`); `frontend-design` picks the cadence (e.g., `4 / 8 / 12 / 16 / 24 / 32 / 48 / 64 / 96` vs. `4 / 8 / 16 / 32 / 64`). If the chosen cadence violates touch-target minimums (24×24 CSS px for WCAG 2.5.8) or makes typography unreadable, this skill overrides.
- **Component density.** This skill picks the structure (compact / comfortable / spacious as a token); `frontend-design` decides which the product defaults to and how density transitions feel.

## The handoff prompt (build mode)

At the end of every successful `build`-mode run, emit this prompt verbatim, substituting the bracketed values:

> "UX/standards layer locked. Detected stack: `[stack]`. Pattern set: `[chosen patterns]`. CWV budget at p75: LCP ≤ 2.5s / INP ≤ 200ms / CLS ≤ 0.1. WCAG 2.2 AA acceptance criteria: `[list]`. Token tiers chosen (structure only, not values): `[list]`.
>
> Hand off to `frontend-design` for typography, color, motion, and atmosphere? (Type 'skip' to keep vanilla aesthetics.)"

What to substitute:

- `[stack]` — the detected stack (`react`, `vue`, `svelte`, etc.). `frontend-design` will emit aesthetic code in the matching idiom.
- `[chosen patterns]` — from build-mode pattern selection (e.g., "sidebar nav, question-page wizard form, sortable data table, message-bar feedback").
- `[list]` — the specific WCAG SCs (e.g., "1.3.1, 1.4.3, 1.4.11, 2.4.7, 3.3.1, 3.3.3, 4.1.2") and the chosen token tiers (e.g., "color: 11 semantic tiers; type: 6; spacing: 9; motion: 4 durations + 4 easings; elevation: 4; radius: 4").

If the user says "skip", honor it. Provide vanilla-aesthetic defaults (system font stack, accessible default colors via tokens, default motion tiers) and stop. Do not invoke `frontend-design`.

If the user accepts, hand control to `frontend-design`. After it returns aesthetic decisions, run a consistency check (below).

## Post-handoff consistency check

After `frontend-design` produces aesthetic decisions, this skill verifies:

- [ ] **Token tier structure preserved.** `frontend-design` filled values; it didn't add or remove tiers.
- [ ] **WCAG 2.2 AA contrast holds.** Run a contrast check on every color combination produced. Text 4.5:1; large text 3:1; non-text UI 3:1.
- [ ] **`prefers-reduced-motion` respected.** Motion definitions include the reduced-motion override.
- [ ] **Semantic HTML preserved.** No aesthetic override that turned a `<button>` into a styled `<div>`.
- [ ] **Keyboard path still works.** Visible focus on every focusable element after styling.
- [ ] **Target sizes still meet 24×24 CSS px** at minimum.
- [ ] **Loading-feedback choices unchanged** (skeleton / spinner / progress / message bar still match the wait shape).

Any breach → enter the **reverse-handoff** flow.

## Reverse handoff

When `frontend-design` ran first (greenfield aesthetic work) or when the post-handoff consistency check fails, this skill performs a constrained regeneration request:

1. **Identify the breach precisely.** Which WCAG SC, which CWV target, or which UX pattern is violated. Cite the offending file and the offending choice.
2. **Build the constraint set.** Restate the hard targets the surface must meet — WCAG SCs, CWV targets, reduced-motion respect, semantic HTML preservation, keyboard path.
3. **Send back to `frontend-design` with the constraint set as input**, using this prompt:

> "The aesthetic decisions for `[surface]` violate these constraints: `[list of violations with citations]`. Please regenerate with these constraints reasserted: `[constraint list]`. The aesthetic POV should be reapplied within these constraints, not by removing them."

4. **Verify again.** If the regeneration still fails, escalate to the user with both versions and a request for trade-off acceptance.

## Audit-mode handling of aesthetic-driven breaches

When `audit` mode finds an issue caused by aesthetic decisions (low-contrast color values, motion that ignores reduced-motion, custom focus removed by a styling layer, oversized hero blocking LCP), classify as **Critical** in the audit report and add this paragraph to the fix:

> Aesthetic-driven breach. Regenerate the offending surface with `frontend-design`, supplying these constraints: `[the list]`. The aesthetic POV should be reapplied within these constraints, not by removing them.

This is the reverse-handoff prompt restated for the audit context.

## Opt-outs and edge cases

### "Skip aesthetics"

User wants vanilla defaults. Honor it. Provide:

- System font stack: `system-ui, -apple-system, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Helvetica Neue", Arial, sans-serif`.
- Accessible default color values: high-contrast text, neutral surfaces, sufficiently saturated accent (the values in `stacks/vanilla.md`'s tokens.css are reasonable defaults).
- Default motion durations: `fast: 150ms, medium: 250ms, slow: 400ms` with reduced-motion override.

This is "ship-quality, no aesthetic POV." Useful for internal tools, prototypes, and projects where the design system has already been established elsewhere.

### "Skip standards"

User asks to violate a hard target (WCAG conformance, CWV budget, semantic HTML, etc.). Refuse politely; cite the relevant reference; explain that this skill exists to enforce these. If the user persists with explicit acknowledgment, document the waiver in the artifact (audit report, build plan, or gate config) and proceed under protest.

### "Use frontend-design alone, skip you"

This is the user's prerogative. Honor it. Note in the conversation that the standards layer is being skipped, recommend a follow-up audit run, and stand down.

### Both skills triggered for a small change (one-off styling tweak)

Don't over-process. If the change is a single component style update with no IA, semantic, performance, trust, AI, or research implications, this skill can confirm the standards layer is unaffected and defer to `frontend-design` immediately. The handoff prompt becomes:

> "Standards layer unaffected (no IA / semantic / performance / trust / AI / research changes). Hand off to `frontend-design`."

## Anti-patterns in pairing

- **This skill picking color values.** Out of scope. Token *structure*, yes; color *values*, no.
- **`frontend-design` removing focus styles for aesthetics.** Always violates WCAG 2.4.7. Reverse-handoff with the focus-style requirement reasserted.
- **`frontend-design` choosing fonts that fail metric matching** and cause font-loading CLS. Use `font-display: optional` or `swap` with size-adjust / metric overrides; specify in handoff.
- **Either skill silently overriding the other.** The contract is explicit; honor it.
- **Skipping the handoff prompt** because "the user obviously wants the aesthetic too." Always emit the prompt; the user might surprise you with "skip".

## Bibliography

- WCAG 2.2 — W3C, October 2023.
- "frontend-design" skill — claude-plugins-official (companion skill).
- This skill's `domains/*.md` references for the standards being enforced in pairing.
