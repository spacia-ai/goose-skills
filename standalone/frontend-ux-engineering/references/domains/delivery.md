# Domain — delivery

The design-token → Storybook → Playwright → field-telemetry loop. Adaptive layouts via container queries. View transitions as progressive enhancement. The design-tokens-format spec.

## Why delivery is its own domain

A team can have great research, beautiful designs, and rigorous accessibility on paper, and still ship a product that contradicts all of it because the delivery pipeline doesn't enforce anything. Delivery is the discipline that turns design intent into running code, and keeps the two from drifting.

The 2026 baseline: tokens feed specs, specs feed stories, stories feed tests, tests feed release, release feeds telemetry, telemetry feeds research. That loop is the real "skill" — not any single tool.

## The delivery loop

```
Research inputs (interviews, tests, analytics)
        ↓
UX decisions (flows, IA, states)
        ↓
Design tokens (color, type, spacing, motion, elevation, radius)
        ↓
Figma specs (Dev Mode, ready-for-dev annotations, version cues)
        ↓
Component stories (Storybook, all states)
        ↓
Automated checks (axe, visual regression, performance budgets)
        ↓
Release
        ↓
Field telemetry (CWV, errors, funnels, AT path)
        ↓
back to Research inputs
```

Every arrow is a place where intent gets lost without enforcement.

## Design tokens

Tokens are named, semantic design decisions encoded as data. They are the source of truth for color, type, spacing, motion, elevation, and radius — and the substrate every consumer (Figma, code, Storybook, marketing site) reads from.

### The Design Tokens Format

The W3C Community Group's [Design Tokens Format](https://www.designtokens.org/) reached its first stable release in late 2025. It's a vendor-neutral JSON-based spec for expressing tokens.

Example shape:

```json
{
  "color": {
    "background": {
      "surface": { "$value": "#ffffff", "$type": "color" },
      "surface-elevated": { "$value": "#f5f5f7", "$type": "color" }
    },
    "text": {
      "primary": { "$value": "#0a0a0a", "$type": "color" },
      "secondary": { "$value": "#525252", "$type": "color" }
    }
  },
  "spacing": {
    "100": { "$value": "4px", "$type": "dimension" },
    "200": { "$value": "8px", "$type": "dimension" },
    "300": { "$value": "12px", "$type": "dimension" },
    "400": { "$value": "16px", "$type": "dimension" }
  },
  "duration": {
    "fast": { "$value": "150ms", "$type": "duration" },
    "medium": { "$value": "250ms", "$type": "duration" }
  }
}
```

The format is a Community Group spec, not a W3C Standard, so adoption is voluntary. But it's the closest thing the industry has to a vendor-neutral interchange format. Tools that support it: Figma (variables export), Style Dictionary, Tokens Studio, several others.

### Token tiers (semantic vs. raw)

A mature token system has at least two tiers:

- **Raw / primitive tokens.** The actual values. `gray-900: #0a0a0a`, `space-400: 16px`.
- **Semantic / alias tokens.** Reference primitives by intent. `text-primary: { value: "{color.gray.900}" }`, `space-md: { value: "{spacing.400}" }`.

Components reference *only* semantic tokens. This means changing the visual identity (theming, dark mode, brand variant) only requires editing the alias layer, not every component.

For larger systems, a third tier of *component-specific* tokens (e.g., `button-primary-background`) is useful. But don't add it preemptively; only add when the same alias is being used differently in different components.

### Common token anti-patterns

- **One-tier tokens** (raw values only). Theming is impossible without rewriting components.
- **Hex values in component code.** Tokens exist precisely to avoid this. If `#0a0a0a` is anywhere outside the token file, it's a leak.
- **Numeric scale without semantic alias.** `space-400` everywhere in markup. Refactoring spacing requires touching every component.
- **Tokens that don't match Figma variables.** Designers and developers diverge over time. Use a sync tool (Tokens Studio, Style Dictionary) so both read the same source.

## Figma + Dev Mode

Figma is the dominant design tool in 2026. Dev Mode (paid) provides:

- Inspection of values without "design" intent (colors as actual hex, spacing as actual px).
- Ready-for-dev states on frames (developers can filter to what's ready).
- Version history and change cues (developers see what's new since last sync).
- Code snippets per component (Figma → Tailwind / CSS / iOS / Android).
- Plugin ecosystem for token export and component linking.

Workflow expectations:

- Designers tag frames "ready for dev" when the design is decided.
- Developers inspect via Dev Mode, not by exporting screenshots.
- Tokens (Figma variables) are the source of truth for color, spacing, radius, and (where supported) motion durations.
- Component-to-Figma linking exists where possible — clicking a Storybook story shows the Figma source.

## Storybook

Storybook is the dominant component-isolation tool. It lets engineers develop components in isolation, document them, and exercise their states.

### What Storybook is for

- **Isolation.** Develop a component without booting the whole app.
- **State coverage.** Every state of a component is a story (default, hover, focus, error, loading, empty, populated).
- **Visual regression input.** Stories are the test cases for visual regression.
- **A11y testing.** With `@storybook/addon-a11y`, every story is checked against axe.
- **Living documentation.** Storybook is the first place a new engineer or designer goes to understand a component.

### Story coverage rules

For each component, write stories for:

- **Default.** No-arg state.
- **All variants.** Primary / secondary / destructive button. Outlined / filled / ghost. Light / dark.
- **All states.** Hover, focus, pressed, disabled, error, loading.
- **Edge content.** Long text, RTL languages, missing avatar, missing label.
- **Composition.** When the component nests inside another (button-in-toast, input-in-form).

A component without state coverage is a component that ships bugs. Treat story coverage as part of "done."

## Playwright (visual regression)

Visual regression catches the unintended visual change. UI bugs are notorious for being invisible to type checkers and unit tests; visual regression sees them.

### Playwright for visual regression

- Headed Chromium and WebKit (and Firefox if the audience includes it).
- Snapshot per Storybook story per browser.
- Snapshots live in `__snapshots__/` and are committed.
- On a PR with visual change, the diff fails CI; the PR's owner reviews the diff and either fixes the regression or labels the PR `update-snapshots` to update baselines.

### What to snapshot

- Every Storybook story (one per state).
- Critical full-page flows (login, signup, primary task flow, account settings).
- Mobile breakpoint variants of the same.

### What not to snapshot

- Animations mid-frame (use `await page.locator('...').waitFor()` to settle first).
- Time-sensitive content (mock timestamps, randomness, network calls).
- Content that varies per run.

## Container queries and adaptive layouts

Container queries are now mature enough for production. Container-query-based responsiveness lets a component adapt to its *container's* size, not just the viewport's.

```css
.card {
  container-type: inline-size;
  container-name: card;
}

@container card (min-width: 400px) {
  .card-content {
    grid-template-columns: 1fr 2fr;
  }
}
```

This is genuinely better than viewport-only media queries when:

- A component appears in different layout contexts (e.g., the same "card" in a sidebar and on a wide page).
- The same component needs density variations independent of viewport.

Pair container queries with the Material adaptive strategies: **show / hide**, **levitate** (move to a different container), **reflow** (change layout direction), and **window-size-class** layouts (multi-pane on large screens, single-pane on small).

## View transitions

The View Transitions API is moving from novel to expected. It animates between page or DOM states without manual orchestration.

```js
document.startViewTransition(() => {
  // DOM update
  swapToNewPage();
});
```

Treat view transitions as **progressive enhancement**:

- Use them where supported (Chrome, Edge, Safari).
- Degrade to no animation where not.
- Honor `prefers-reduced-motion: reduce`.

Advanced uses (cross-document transitions, navigations) are still emerging. Don't make a flow depend on view transitions; make the flow work without them and feel better with them.

## Field telemetry

Already covered in `domains/performance.md` and `modes/gate.md`. Quick recap of what to monitor:

- Core Web Vitals at p75 (CrUX or RUM).
- JavaScript error rate (per route, per browser).
- Failed network request rate.
- Funnel completion rates per primary user journey.
- AT-path success rate (where instrumented).
- Feature adoption / retention curves.

The telemetry feeds research; research feeds the next loop iteration.

## Integration: how the loop runs in a real team

For a typical 5-15 person team:

1. **Design system team** owns tokens, Storybook, and the visual regression baselines. They version the design system separately from the product app.
2. **Product engineers** consume tokens via the design system, write components against Storybook stories, and run visual regression in CI.
3. **Design** uses Figma with Dev Mode for handoff. Tokens flow from Figma to code via a sync tool.
4. **PM / research** uses telemetry and research methods (`domains/research.md`) to feed the next sprint's UX decisions.
5. **CI** enforces accessibility (axe), performance (Lighthouse + budgets), and visual regression (Playwright) on every PR.
6. **Field telemetry** runs continuously; weekly summary post to a channel humans actually read.

Smaller teams (1-4 people) can collapse roles, but the loop steps cannot collapse. Skipping any of (tokens, stories, visual regression, accessibility CI, performance budgets, field telemetry) creates a gap that fills with regressions.

## Common delivery anti-patterns

- **Tokens in a Figma file but not in code.** Designers see one set of values; engineers ship another. Sync mandatory.
- **Storybook with default-only stories.** Real bugs hide in non-default states.
- **Visual regression without state coverage.** Snapshotting only the default catches almost nothing.
- **Snapshot updates without review.** "Update all snapshots" merges should be banned. Each updated snapshot must be visually reviewed.
- **CI gates that the team learns to ignore.** Flaky tests, false positives, cryptic errors → engineers click "skip" → the gate stops gating. Fewer, sharper gates.
- **Field telemetry in a dashboard nobody opens.** Push the digest to people, not to a URL.
- **Design system frozen at v1.** Living systems require ongoing investment. Frozen systems become "the legacy DS" within a year.
- **Tokens added per PR, never reviewed holistically.** Token sprawl. Periodically review and consolidate.

## Bibliography

- "Design Tokens Format Module" — W3C Design Tokens Community Group.
- Figma Dev Mode documentation.
- Storybook documentation, especially Component Story Format and Test Runner.
- Playwright visual comparison documentation.
- "Container Queries" — web.dev primer and CSS spec.
- "View Transitions API" — web.dev and the W3C CSS View Transitions Module.
- "Adaptive Design" — Material Design 3.
- "App Design Patterns" — Apple HIG (sidebars, tab bars, multi-pane).
