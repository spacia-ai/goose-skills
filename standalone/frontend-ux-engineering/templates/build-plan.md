# UX Engineering Build Plan — `<feature>`

**Stack:** `<detected | chosen>`
**Scope:** `<surfaces in scope>`
**Goal:** `<user goal in one sentence>`
**Date:** `<YYYY-MM-DD>`

## Information architecture

- **User's primary task on this surface:** `<one sentence>`
- **Secondary tasks (2-3):**
  - `<...>`
  - `<...>`
- **Where this sits in the flow:** `<entry | midpoint | decision | completion>`
- **Destinations reachable from here:** `<list>`
- **Destinations that reach to here:** `<list>`

### Navigation decisions

- **Global navigation:** `<sidebar | nav rail | top bar | tab bar | hamburger>` — `<reason>`
- **Local navigation:** `<tabs | breadcrumbs | in-page anchors | none>` — `<reason>`
- **Search / command access:** `<full search | command palette | both | neither>` — `<reason>`

## Pattern selections

From `references/domains/patterns.md`:

| Surface | Pattern | Why this one | Avoid-when notes |
|---|---|---|---|
| `<surface>` | `<pattern>` | `<reason from patterns.md>` | `<applicable avoid-when>` |
| `<surface>` | `<pattern>` | `<reason>` | `<...>` |

## Token tiers (structure only — values from `frontend-design`)

- **Color tiers:** `<list of semantic tiers — surface, surface-elevated, text, text-secondary, text-muted, border, accent, accent-on-accent, success, warn, error, info, plus state derivatives>`
- **Typography tiers:** `<list — display, heading-1..4, body, body-small, code, plus weight pairs>`
- **Spacing tiers:** `<scale — e.g., space-100..900>`
- **Motion tiers:** `<duration-instant, fast, medium, slow + easing tokens>`
- **Elevation / shadow tiers:** `<list, if used>`
- **Radius tiers:** `<radius-sm, md, lg, pill>`

## Component scaffold

- **Files:** `<list>`
- **Semantic HTML baseline:** `<one snippet per surface>`
- **ARIA additions (only where native is missing):** `<list>`
- **Keyboard path:** `<tab order + shortcuts>`
- **Focus management:** `<where focus moves on open / close / submit / error / success>`
- **Required states (loading, empty, error, success):** `<defined for each async surface>`

## Accessibility acceptance criteria

WCAG 2.2 SCs that apply (from `references/checklists/wcag-22-aa.md`):

- [ ] **<SC X.X.X> — <name>** — `<how to verify>`
- [ ] `<...>`

Always-applicable:
- [ ] **2.4.7 Focus Visible** — visible focus on every focusable element.
- [ ] **1.4.10 Reflow** — content reflows at 320 CSS px width without horizontal scroll.
- [ ] **1.4.11 Non-Text Contrast** — UI components and graphical objects 3:1.
- [ ] **2.5.8 Target Size (Minimum)** — interactive targets 24×24 CSS px or sufficient spacing.
- [ ] **2.4.11 Focus Not Obscured** — focused element visible despite sticky elements.

## Performance budget at p75

- [ ] **LCP** ≤ 2.5 s — LCP element identified: `<element>`. Strategy: `<preload / fetchpriority / SSR / etc.>`
- [ ] **INP** ≤ 200 ms — interactions on this surface: `<list>`. Strategy: `<defer / chunk / web worker / etc.>`
- [ ] **CLS** ≤ 0.1 — layout-shift sources to prevent: `<images / fonts / late banners / etc.>`. Strategy: `<aspect-ratio / dimensions / font-display: optional / size-adjust / etc.>`
- **Loading-feedback choice:** `<skeleton | spinner | progress bar | message bar>` — `<reason matching wait shape>`

Bundle / asset budgets (if relevant):
- Initial JS ≤ `<150 KB gz>`
- Initial CSS ≤ `<50 KB gz>`
- Initial images (above-fold) ≤ `<100 KB>`

## Trust surface (if applicable)

- **Auth method:** `<passkeys | passkeys + password fallback | password + 2FA>` — `<reason>`
- **Recovery flow:** `<design — multiple passkeys, recovery codes, recovery email, etc. No dead ends.>`
- **Privacy disclosure:** `<layered notice placement — at point of collection, with link to detail>`
- **Granular consent:** `<consent toggles per purpose where regime requires>`
- **Visible passkey management:** `<account-settings location and capabilities>`

## AI surface (if applicable)

- **Capability legibility:** `<one-sentence "does" + one-sentence "doesn't">`
- **User control:** `<stop / override / edit / undo / regenerate>`
- **Explanation:** `<sources / reasoning / confidence / provenance>`
- **Correction:** `<how user fixes wrong output, what system does with correction>`
- **Outcome metrics defined:** `<resolution rate | acceptance rate | edit-after-accept rate | escalation rate | confidence-mismatch rate>`
- **Failure mode:** `<defined non-AI path when AI doesn't know / fails / returns dangerously wrong>`
- **Opt-out:** `<location of off switch>`

## Research plan

- **Method:** `<moderated remote test | unmoderated remote test | tree test | card sort | RUM | A/B | heuristic + AT review>`
- **Sample size:** `<N>`
- **Duration:** `<weeks>`
- **Success metric:** `<HEART layer + specific KPI>`
- **Guardrail metric:** `<what should not regress>`

## Handoff to `frontend-design`

- [ ] **Hand off** — typography / color / motion / atmosphere
- [ ] **Skip** — vanilla aesthetics

If handing off, the prompt to send (from `references/handoff/frontend-design-pairing.md`):

> "UX/standards layer locked. Detected stack: `<stack>`. Pattern set: `<chosen patterns>`. CWV budget at p75: LCP ≤ 2.5s / INP ≤ 200ms / CLS ≤ 0.1. WCAG 2.2 AA acceptance criteria: `<list>`. Token tiers chosen (structure only, not values): `<list>`.
>
> Hand off to `frontend-design` for typography, color, motion, and atmosphere?"

## Post-handoff consistency check

(After `frontend-design` returns aesthetic decisions.)

- [ ] Token tier structure preserved (no tiers added or removed)
- [ ] WCAG 2.2 AA contrast holds for every color combination (4.5:1 / 3:1 / 3:1)
- [ ] `prefers-reduced-motion` respected
- [ ] Semantic HTML preserved (no `<button>` → styled `<div>`)
- [ ] Keyboard path and visible focus preserved
- [ ] Target sizes still meet 24×24 CSS px
- [ ] Loading-feedback choices unchanged
