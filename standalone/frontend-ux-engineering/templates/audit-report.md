# UX Engineering Audit — `<project>` @ `<git sha or version>`

**Stack:** `<detected>`
**Scope:** `<component | page | flow | whole app>`
**Mode:** audit
**Date:** `<YYYY-MM-DD>`
**Auditor:** `<name or "frontend-ux-engineering skill">`
**Live URL:** `<url, or "not available — static-source review">`

## Executive summary

| Severity | Count |
|---|---:|
| Critical | `<n>` |
| High | `<n>` |
| Medium | `<n>` |
| Low | `<n>` |
| Info | `<n>` |

**Headline pass / fail per domain**:

- Accessibility: `<pass | gaps | fail>`
- Patterns: `<pass | gaps | fail>`
- Performance: `<pass | gaps | fail>`
- Trust: `<pass | gaps | fail | n/a>`
- AI UX: `<pass | gaps | fail | n/a>`

**Top three things to fix this sprint**:

1. `<one-line summary, finding ID>`
2. `<one-line summary, finding ID>`
3. `<one-line summary, finding ID>`

---

## Findings

Severity bands defined in `references/modes/audit.md`.

### Critical — blocks task completion or is unusable for assistive-tech users

#### F-001 — `<one-line summary>`

- **File:** `path/to/file.ext:42`
- **Domain:** `<accessibility | patterns | performance | trust | ai-ux>`
- **Failed:** `<WCAG 2.2 SC X.X.X | hard-target name | reference anchor>`
- **Evidence:** `<axe rule id | measured value | screenshot path | quoted source>`
- **Fix:** `<concrete code change or pattern change>`
- **Effort:** `<S | M | L>`
- **Reference:** `references/<domains|checklists|stacks>/<file>.md`

#### F-002 — `<one-line summary>`

…

### High — WCAG 2.2 AA gap or CWV breach at p75

#### F-XXX — `<one-line summary>`

- **File:** `path/to/file.ext:42`
- **Domain:** `<...>`
- **Failed:** `<...>`
- **Evidence:** `<...>`
- **Fix:** `<...>`
- **Effort:** `<S | M | L>`
- **Reference:** `<...>`

…

### Medium — best-practice gap

#### F-XXX — `<one-line summary>`

…

### Low — polish

#### F-XXX — `<one-line summary>`

…

### Info — acknowledged, no action

#### F-XXX — `<one-line summary>`

`<deliberate choice or already-resolved issue>`

---

## Field measurements

| Metric | Target (p75) | Measured (p75) | Pass / fail | Source |
|---|---|---|---|---|
| LCP | ≤ 2.5 s | `<value>` | `<pass | fail>` | `<CrUX | RUM | lab estimate>` |
| INP | ≤ 200 ms | `<value>` | `<pass | fail>` | `<...>` |
| CLS | ≤ 0.1 | `<value>` | `<pass | fail>` | `<...>` |

If field data is unavailable, mark every CWV row as "lab estimate, field truth not yet measured" and recommend deploying CrUX or RUM as a Critical finding.

---

## Aesthetic-driven breaches (reverse-handoff candidates)

If any finding is caused by an aesthetic decision (low-contrast color values, motion that ignores reduced-motion, focus removed by styling, hero blocking LCP), list it here with the constraint set to reassert during regeneration. See `references/handoff/frontend-design-pairing.md`.

- **F-XXX** → reverse-handoff prompt: "Regenerate `<surface>` with these constraints reasserted: `<list>`. The aesthetic POV should be reapplied within these constraints, not by removing them."

---

## Recommended next mode

`<build | gate | audit again later>` — `<one sentence why>`

Suggested re-audit cadence: `<every N weeks at p75 field data refresh>`.

---

## How to reproduce this audit

```bash
# from project root
scripts/run_audit.sh --url <url>
# or
scripts/run_audit.sh --build "npm run build" --serve
```

Outputs land in `.frontend-ux/audit/`:
- `axe.json`
- `lighthouse-mobile.json`
- `lighthouse-desktop.json`
- `pa11y.json` (if Pa11y is installed)

Field data (if applicable):

```bash
scripts/extract_cwv_field.py --crux <origin>
```
