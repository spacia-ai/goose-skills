---
name: frontend-ux-engineering
description: Use when designing, building, auditing, reviewing, or shipping any web UI where standards, accessibility, performance, or measured quality matter. Triggers on intents like "audit this UI", "is this accessible", "WCAG", "Core Web Vitals", "INP/LCP/CLS", "passkeys", "privacy notice", "design tokens", "AI feature UX", "form error recovery", "data table", "dashboard", "skeleton vs spinner", and on general "build/improve/review a web app" prompts. Pairs with frontend-design — this skill owns standards, semantics, performance, trust, research, and delivery; frontend-design owns aesthetic execution. Use this skill before frontend-design on greenfield work so the UX/standards layer is locked first.
extensions: []
requires: []
tools:
  - developer__shell
  - developer__text_editor
tags:
  - frontend
  - ux
  - accessibility
  - performance
  - wcag
  - core-web-vitals
  - standalone
min_goose_version: "1.33.0"
---

# Frontend UX Engineering

Standards-led, measurement-led web-app UX: accessibility, semantic patterns, Core Web Vitals, trust (passkeys + privacy), AI feature UX, mixed-method research, and the design-token → Storybook → Playwright → field-telemetry delivery loop.

This skill is the **engineering counterpart** to `frontend-design`:

- `frontend-design` owns aesthetic execution — typography, color values, motion personality, atmospheric textures, the "unforgettable" point of view.
- `frontend-ux-engineering` (this skill) owns the standards, semantics, performance, trust, research, and delivery layers.

The two are designed to **pair**, not compete. This skill runs first on shared prompts, locks the standards layer, then explicitly hands off to `frontend-design` for aesthetic execution unless the user opts out. See `references/handoff/frontend-design-pairing.md` for the full contract.

## Mode dispatch

You operate in one of four modes. Pick before doing anything else.

| Mode  | Default trigger phrases | Output |
|-------|-------------------------|--------|
| `audit` | "audit / review / is this accessible / why is this slow / WCAG check" | severity-ranked report |
| `build` | "build / design / implement / scaffold this UI / make a dashboard" | plan + scaffold + acceptance |
| `gate`  | "wire CI / set up axe / Lighthouse / Playwright / performance budget" | CI configs + scripts |
| `learn` | "teach / curriculum / hiring rubric / evaluate a UX candidate" | curriculum / rubric / capstone |

If the user's intent is ambiguous, **default to `audit`**. Audit always produces a useful artifact and surfaces what the next step should be.

You may switch modes mid-session, but announce the switch.

## Mandatory first step (every mode)

1. **Detect the stack** by inspecting the project root. Run `scripts/detect_stack.sh` if a working shell is available, or do it manually using the priority order in the `Stack detection signals` section below. Cache the result.
2. **Load the matching stack reference**: `references/stacks/<detected>.md`. If detection returns `unknown`, default to React+TypeScript, **announce the assumption**, and offer one chance to switch before proceeding.
3. **Identify scope** — component / page / flow / whole app. This determines how many domain references to load.
4. **Load the mode reference**: `references/modes/<mode>.md` and follow it.
5. **Only then** start producing the artifact.

User-provided stack name always overrides detection.

## Stack detection signals

In priority order:

1. `package.json` deps → `react` / `vue` / `svelte` / `@angular/core` (→`angular`) / `solid-js` (→`solid`) / `@builder.io/qwik` (→`solid` skeleton fallback) / `astro` / `next` (→`react`) / `nuxt` (→`vue`) / `@sveltejs/kit` (→`svelte`) / `@remix-run/*` (→`react`).
2. Config files at root: `astro.config.*`, `nuxt.config.*`, `svelte.config.*`, `next.config.*`, `remix.config.*`, `angular.json`.
3. `Gemfile` containing `stimulus`/`turbo` → `server-rendered` (Rails Hotwire).
4. `mix.exs` containing `phoenix` or `phoenix_live_view` → `server-rendered` (Phoenix LiveView).
5. `requirements.txt` / `pyproject.toml` containing Django/Flask + Jinja templates → `server-rendered`.
6. `composer.json` containing `laravel/framework` + Blade → `server-rendered`.
7. Presence of `hx-*` HTML attributes anywhere in source → `server-rendered` (htmx).
8. Root `.html` files with no JS framework → `vanilla`.
9. Nothing detected → `unknown`. Default to React+TS with announcement.

## Progressive loading map

Load only what the current mode + scope needs. Do **not** preemptively load all domains.

| If you need to … | Load |
|---|---|
| Decide WCAG conformance, ARIA, keyboard, focus | `references/domains/accessibility.md` + `references/checklists/wcag-22-aa.md` |
| Pick a navigation / form / table / dashboard / dialog / feedback pattern | `references/domains/patterns.md` |
| Set or check Core Web Vitals targets | `references/domains/performance.md` + `references/checklists/core-web-vitals.md` |
| Design auth, recovery, privacy notice | `references/domains/trust.md` + `references/checklists/auth-passkeys.md` |
| Add or audit an AI surface | `references/domains/ai-ux.md` + `references/checklists/ai-feature-ux.md` |
| Plan or evaluate research / metrics / experiments | `references/domains/research.md` |
| Wire tokens → Storybook → Playwright → field telemetry | `references/domains/delivery.md` |
| Emit framework-specific code | `references/stacks/<stack>.md` |
| Hand off to aesthetic execution | `references/handoff/frontend-design-pairing.md` |
| Forms with error recovery | `references/checklists/forms-recovery.md` |

## Hard targets (non-negotiable defaults)

These are stable 2026 baselines. Override only with explicit user instruction, and document the waiver in the artifact when you do.

- **WCAG 2.2 AA** as the conformance target. WCAG 3 is a working draft, not a shipping target.
- **Core Web Vitals at p75:** LCP ≤ 2.5 s, INP ≤ 200 ms, CLS ≤ 0.1.
- **Semantic HTML first; ARIA only to fill gaps.** No ARIA reinvention of native controls. "No ARIA is better than bad ARIA."
- **Full keyboard path with visible focus**, including dialogs, drawers, hover-revealed actions, and command surfaces.
- **Honor `prefers-reduced-motion`, contrast preferences, and reduced-data preferences** where useful.
- **Forms:** validate on progress / submit (not on every keystroke unless research justifies it). Preserve user-entered values across errors. Pair inline field errors with a top-of-form summary that receives focus.
- **Auth:** prefer passkeys (WebAuthn) with humane recovery and visible passkey management in account settings.
- **Privacy:** layered notices, granular consent, easy withdrawal, just-in-time disclosure.
- **AI surfaces:** capability legibility, user control, support for explanation and correction, and measured outcomes (resolution rate, edit-after-accept rate, escalation rate).
- **Field measurement is authoritative; lab measurement is diagnostic.** Ship to p75 distributions of real users, not Lighthouse screenshots.

If the user requests something that violates a hard target, **name the conflict, cite the relevant reference file, and ask for confirmation** before proceeding.

## Pairing with `frontend-design`

After the standards layer, IA, pattern selection, accessibility acceptance criteria, and CWV budgets are settled here, end the build-mode run with this exact handoff prompt (substituting the bracketed values):

> "UX/standards layer locked. Detected stack: `[stack]`. Pattern set: `[chosen patterns]`. CWV budget at p75: LCP ≤ 2.5s / INP ≤ 200ms / CLS ≤ 0.1. WCAG 2.2 AA acceptance criteria: `[list]`. Token tiers chosen (structure only, not values): `[list]`.
>
> Hand off to `frontend-design` for typography, color, motion, and atmosphere? (Type 'skip' to keep vanilla aesthetics.)"

What this skill **refuses to override** even after handoff:

- WCAG 2.2 AA conformance — `frontend-design` cannot trade contrast for aesthetic.
- Reduced-motion respect — animation choices must honor the preference.
- Semantic HTML — no aesthetic override that turns a `<button>` into a styled `<div>`.
- Keyboard path and visible focus — must remain after styling.

If `frontend-design` ran first and audit-mode finds an aesthetic-driven WCAG/CWV breach, classify it as **Critical** with the fix being "regenerate the offending surface with the constraints reasserted to `frontend-design`". The reverse-handoff callback prompt is in `references/handoff/frontend-design-pairing.md`.

## Red flags — stop and reconsider

These thoughts mean stop. They are the most common ways teams accidentally regress UX while feeling productive.

| Thought | Reality |
|---|---|
| "Just slap `role='button'` on a div" | Use `<button>`. ARIA is for gaps in native semantics, not reinvention. |
| "Validate on every keystroke" | Validate on progress / submit. Live validation only with research evidence that it helps. |
| "Cards everywhere, even comparable rows" | Tables exist for comparison. Don't cardify dense comparable data. |
| "Lighthouse score is green, ship it" | Lighthouse is lab. Ship to p75 field metrics from CrUX or RUM. |
| "Toast every status change" | Persistent state belongs in message bars / banners. Toasts are transient secondary status. |
| "Add a chatbot" | AI only when it compresses real friction. Make capability legible, support correction, measure outcomes. |
| "Hide nav behind a hamburger on desktop" | Visible navigation on larger screens. Hidden navigation adds interaction cost. |
| "WCAG 3 is newer, target that" | WCAG 3 is a draft. Ship to WCAG 2.2 AA. |
| "Disable the submit button until the form is valid" | Allow submission, let validation explain what to fix. Disabled buttons hide reasoning. |
| "Use `aria-label` to rename the button" | Most `aria-label` problems are missing visible text. Add a real label first. |
| "We'll add focus styles later" | Focus visibility is the keyboard user's only way to navigate. It is not optional polish. |
| "The dialog is a div with z-index" | A dialog is `<dialog>` or APG dialog pattern: focus trap, Escape to close, restore focus, role/aria. |
| "Skeleton everywhere" | Skeleton when structure is known and wait is moderate. Spinner for short indeterminate. Progress for known duration. |

## Acceptance criteria for a skill run

A run is acceptable when **all** of these hold:

1. **Mode dispatched correctly.** A clear mode (`audit` / `build` / `gate` / `learn`) was picked and announced before any artifact work began.
2. **Stack detected or asked.** `detect_stack.sh` ran, or the user named the stack. The matching `references/stacks/<stack>.md` was loaded.
3. **Only relevant references loaded.** The progressive-loading map was respected; no preemptive load of all seven domain files.
4. **Mandatory artifact produced.** Every mode emits a concrete file:
   - `audit` → `templates/audit-report.md` filled in, severity-classified, with file:line citations and reference anchors per finding.
   - `build` → `templates/build-plan.md` filled in **plus** at least one stack-specific scaffold file.
   - `gate` → at least the three CI yamls plus `budgets.json` written into the project's CI directory.
   - `learn` → curriculum, rubric, and capstone surfaced from `references/modes/learn.md`.
5. **Hard targets not violated.** Every recommendation either complies with the hard-targets table, or carries an explicit user-acknowledged waiver in the artifact.
6. **No advice without an anchor.** Every Critical/High finding cites either a WCAG criterion, a hard-target name, or a reference file. No vibes-based severity.
7. **Cross-skill behavior correct.** Build mode ended with the handoff prompt to `frontend-design` (or honored an explicit "skip"). Audit mode flagged aesthetic-driven WCAG/CWV breaches as Critical with the reverse-handoff callback when applicable.

## Failure modes — what to do

| Symptom | Response |
|---|---|
| `detect_stack.sh` returns `unknown` | Default to React+TS, announce the assumption, offer one chance to switch before proceeding. |
| User asks for AAA conformance | Honor it; flag in the artifact that AAA is non-default and incurs design constraints (e.g., 7:1 contrast); load AAA criteria into `wcag-22-aa.md` for the duration. |
| User has no CI at all (gate mode) | Pick GitHub Actions as default; offer one switch to GitLab / CircleCI / Jenkins. |
| Lighthouse cannot run (no live URL or build) | Substitute static-source heuristics from `domains/performance.md`; mark CWV findings as "lab estimate, field truth not yet measured"; recommend deploying CrUX. |
| User insists on a deprecated pattern (modal-on-modal, every-keystroke-validation, etc.) | Document the violation; cite the reference; ask for explicit waiver; then proceed under protest. |
| Stack reference is a skeleton (vue/svelte/angular/solid/astro/server-rendered) | Use the skeleton's structure; fall back to `vanilla.md` for semantic baselines; flag in the artifact: "stack reference is incomplete; semantic baselines from vanilla.md were used". |

## Where to start

If this is your first time using this skill in a session:

1. Read `references/modes/<chosen-mode>.md` end-to-end before producing anything.
2. Load `references/stacks/<detected-stack>.md`.
3. Pull in `references/domains/*.md` and `references/checklists/*.md` as the progressive-loading map directs.
4. Use `templates/*` as the artifact skeleton — fill in, do not paraphrase.
5. Run scripts when they exist for what you're doing — they collect evidence so your findings have anchors.

The references explain **why** things are the way they are, not just what to do. Read them; don't skim. The "why" is what makes this skill survive contact with edge cases.
