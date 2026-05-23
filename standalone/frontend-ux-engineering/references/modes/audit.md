# Audit mode

The default mode when intent is ambiguous. Produces a severity-ranked report with file:line citations, anchored to WCAG 2.2 criteria, hard targets, and reference files.

## Why this mode is the default

An audit always produces a useful artifact. Even when the user's real goal is "build" or "gate", an audit-first run surfaces the existing problems the build/gate work needs to address. Auditing before changing anything also leaves the user with a baseline they can re-run later to measure improvement.

## Inputs

Capture before doing anything else:

- **Repo path** — where the code lives.
- **Scope** — single component / single page / single flow / whole app. Audit-the-whole-app is rarely the right call on the first pass; pick the most important flow.
- **Stack** — from `scripts/detect_stack.sh` or asked. Determines which `references/stacks/<stack>.md` to load.
- **Target users** — assistive-tech use? Mobile-heavy? Low-bandwidth? Regulated industry? This shapes severity bands.
- **Prior audit, if any** — read it first. Don't repeat findings the team already knows about.
- **Live URL or build instructions** — needed to run `scripts/run_audit.sh`. If neither exists, fall back to static-source heuristics and flag the limitation.

## Workflow

Walk the seven domains in this fixed order. Load each domain reference only when its checks fire. Do not preload all seven.

### 1. Run automated checks first

Before any manual review, collect machine-verified evidence. Run:

```bash
scripts/run_audit.sh --url <url>
# or
scripts/run_audit.sh --build "npm run build" --serve
```

This produces JSON in `.frontend-ux/audit/`:

- `axe.json` — axe-core findings, by impact (Critical / Serious / Moderate / Minor).
- `lighthouse-mobile.json` and `lighthouse-desktop.json` — full Lighthouse runs.
- `pa11y.json` — Pa11y findings if Pa11y is installed.

Read these files. Do **not** paraphrase them in the report — cite specific rule IDs and measured values.

If `run_audit.sh` cannot run (no live URL, no working build), drop to static-source review and mark every CWV finding as "lab estimate, field truth not yet measured" in the report's field-measurements section.

### 2. Walk the seven domains

In this order. Each step says when to stop and load the corresponding `references/domains/*.md`.

#### a. Semantics (load `domains/accessibility.md`)

- Are interactive controls native HTML (`<button>`, `<a>`, `<input>`, `<select>`, `<dialog>`, `<details>`)?
- Where ARIA appears, is it filling a gap or reinventing native?
- Are headings ordered, with one `<h1>` per main region?
- Are landmarks present (`<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>`)?
- Are images either described (`alt`) or marked decorative (`alt=""`)?
- Are form controls labelled (visible `<label>` or `aria-labelledby` to a visible element)?

#### b. Keyboard and focus (load `domains/accessibility.md`)

- Tab through the entire flow. Every interactive element must be reachable.
- Focus indicator visible on every focusable element. Custom focus styles must meet 3:1 contrast against adjacent colors.
- Focus order matches reading order.
- Dialogs trap focus, restore on close, and Escape dismisses.
- Drawers and popovers behave like dialogs when modal.
- No keyboard traps in custom widgets (combobox, grid, listbox, tree).

#### c. Forms (load `domains/patterns.md` and `checklists/forms-recovery.md`)

- Labels associated to inputs (`for`/`id` or wrapping `<label>`).
- Required fields marked semantically (`required`) and visibly.
- Errors paired: inline next to the field **and** summary at the top that receives focus on submit.
- User-entered values preserved across error rerenders.
- Validation timing: on progress / submit, not on every keystroke (unless research justifies otherwise).
- Question-page wizards used for high-consequence flows; single-page batch forms for low-stakes settings.

#### d. Patterns and IA (load `domains/patterns.md`)

- Global navigation visible on larger screens (no hamburger-only on desktop).
- Tabs used for sibling categories, not as catch-all global navigation.
- Breadcrumbs only when hierarchy adds orientation value.
- Search / command access for large apps.
- Tables for comparison; dashboards for monitoring; cards for narrative or unique items. Don't cardify dense comparable data.

#### e. Performance (load `domains/performance.md` and `checklists/core-web-vitals.md`)

Read Lighthouse output. Cross-reference with field data from CrUX or RUM if available (`scripts/extract_cwv_field.py`).

- LCP at p75 ≤ 2.5 s. Identify LCP element. Check it is preloaded, not lazy-loaded, sized.
- INP at p75 ≤ 200 ms. Long tasks > 50 ms in main thread. Check for blocking JS during interaction.
- CLS at p75 ≤ 0.1. Reserved space for images, embeds, and dynamically inserted content.
- Loading-feedback choice matches wait shape (skeleton / spinner / progress / message bar).
- Animations use `transform` and `opacity`, not layout-affecting properties.
- `prefers-reduced-motion` honored.

If field data unavailable, mark all CWV findings as "lab estimate". Recommend installing CrUX or RUM as a Critical finding in the field-measurements section.

#### f. Trust (load `domains/trust.md` and `checklists/auth-passkeys.md`)

If the surface includes auth, account settings, or data collection:

- Passkey support present? If only passwords, this is a **High** finding (or Critical if the product handles regulated data).
- Passkey management visible in account settings (create, name, remove).
- Recovery path is humane (not a dead end on lost device).
- Privacy notice layered (concise first layer, expansion for detail) and present at point of collection.
- Granular consent where required; easy withdrawal.

#### g. AI surfaces (load `domains/ai-ux.md` and `checklists/ai-feature-ux.md`)

If the surface includes any AI feature:

- Capability legible? User can predict what it will and won't do.
- User control: can stop, override, edit, or undo.
- Explanation: AI's claims are inspectable (sources, reasoning, confidence).
- Correction: user can fix output and the system learns or at least respects the edit.
- Outcome metrics defined (resolution rate, edit-after-accept rate, escalation rate).

### 3. Severity ranking

Severity is **never** based on aesthetic or convenience. It is based on user impact and standards conformance.

- **Critical** — blocks task completion or is unusable for assistive-tech users. Examples: missing form labels, focus traps with no exit, modals without close, illegible contrast, broken keyboard path on a primary action, non-functional auth, AI feature with no way to correct or escape.
- **High** — WCAG 2.2 AA failure that is recoverable but visible (e.g., 3.5:1 text contrast, missing focus indicator), CWV breach at p75 (LCP > 2.5 s, INP > 200 ms, CLS > 0.1) on a primary surface, missing passkeys on a regulated product, missing layered privacy notice at collection.
- **Medium** — best-practice gap. Examples: live keystroke validation, hamburger nav on desktop, cardified data table that should be a real table, modal stack two deep, missing reduced-motion handling for non-essential animation.
- **Low** — polish gap. Examples: inconsistent button sizing, suboptimal toast vs. message-bar choice, missing loading skeleton on a moderate wait.
- **Info** — acknowledged, no action needed; documents a deliberate choice or already-resolved issue. Use sparingly to avoid noise.

### 4. Emit the report

Use `templates/audit-report.md`. Fill it in. Do not paraphrase the structure.

Each finding must have:

- One-line summary.
- File path with line number (`path/to/file.tsx:42`).
- Domain label.
- Failed WCAG SC or hard-target name.
- Evidence (axe rule id, measured CWV value, screenshot path, or quoted source).
- Concrete fix (code change or pattern change).
- Effort estimate: S (< 1 day) / M (1-3 days) / L (> 3 days).
- Reference anchor (`references/domains/<file>.md` or `references/checklists/<file>.md`).

### 5. Recommend the next mode

Close the report with one paragraph: which mode should run next?

- **Build** — if the worst offender needs a new pattern selection or scaffold.
- **Gate** — if no CI checks exist; the audit's findings will recur without gates.
- **Audit again later** — if the team needs time to absorb findings; suggest a re-audit cadence (e.g., every 8 weeks at p75 field data refresh).

## Reverse handoff to `frontend-design`

If the audit finds a WCAG/CWV breach that traces to an aesthetic decision (e.g., low-contrast color values, motion that violates reduced-motion, custom focus removal, oversized hero blocking LCP), classify it as **Critical** and add this paragraph to the fix:

> Aesthetic-driven breach. Regenerate the offending surface with `frontend-design`, supplying these constraints: WCAG 2.2 AA (specific SC), CWV target (p75 LCP/INP/CLS), reduced-motion respect, semantic HTML preserved. The aesthetic POV should be reapplied within these constraints, not by removing them.

See `references/handoff/frontend-design-pairing.md` for the full reverse-handoff protocol.

## Common audit anti-patterns

- **Paraphrasing axe output.** The agent rewrites a clear axe rule id into vague prose. Cite the rule id; quote measured values.
- **Skipping field measurement.** Lighthouse-only audits miss the half of the population on real-world networks. If field data is unavailable, say so explicitly and treat its absence as a finding.
- **Ranking by visibility, not impact.** A subtle but blocking issue (focus trap) is Critical regardless of how invisible it looks; a flashy but harmless detail (animation length) is Low.
- **One-time audit with no re-run plan.** The report must include a recommended re-audit cadence and the commands the team will use.
- **Accepting "we'll fix it later".** "Later" is not a severity. Either the finding is real and gets ranked, or it is not a finding.
