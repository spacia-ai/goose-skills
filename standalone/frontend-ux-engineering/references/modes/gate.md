# Gate mode

Wires the project's CI / CD pipeline so that the standards from `audit` and `build` mode are enforced automatically on every change. The output is a working pipeline, not advice.

## Why gates matter

Audits and build plans rot fast without enforcement. A single rushed PR that disables a focus style or ships a 3 MB hero image can erase weeks of accessibility and performance work. Gates make those regressions visible at the moment they happen, when fixing them is cheap.

The four gates this mode wires:

1. **axe** — accessibility regressions, runs on every build.
2. **Lighthouse CI** — Core Web Vitals against `templates/budgets.json`.
3. **Playwright visual regression** — UI drift, runs on every PR.
4. **Storybook a11y addon** — component-level checks before integration (component-framework stacks only).

Plus periodic field-telemetry monitoring via `scripts/extract_cwv_field.py`.

## Inputs

- **CI host** — GitHub Actions / GitLab CI / CircleCI / Jenkins / other. Default: GitHub Actions if no CI exists.
- **Stack** — detected. Determines test harness conventions.
- **Build command and serve URL** — how to produce and host the artifact CI will test against. Most projects already have these (`npm run build` and a preview deploy URL); confirm or ask.
- **Existing pipeline structure** — read it before adding to it. Don't replace working steps; add alongside them.

## Workflow

### 1. CI inventory

Read `.github/workflows/`, `.gitlab-ci.yml`, `.circleci/config.yml`, `Jenkinsfile`, etc. Note:

- What runs today (lint / test / build / deploy)?
- Where in the pipeline does the deployable artifact land?
- Is there a preview deploy URL per PR? (Vercel, Netlify, Cloudflare Pages, Render, custom?) If yes, we run gates against the preview URL. If no, we serve the build locally inside the runner.

### 2. Wire axe

Drop `templates/ci-axe.yml` into the CI directory. The action:

- Installs `@axe-core/cli`.
- Runs against the URL list configured in the workflow (preview URL pages or `localhost` if serving locally).
- Saves JSON output as a workflow artifact.
- Fails the job on Critical or Serious findings.

For projects without a preview URL, add a serve step to the workflow:

```yaml
- run: npm run build
- run: npx serve dist &
- run: sleep 5
- run: npx @axe-core/cli http://localhost:3000/ http://localhost:3000/login http://localhost:3000/dashboard ...
```

Configure the URL list to cover the **critical user paths**, not every page. 5-10 URLs is usually right.

### 3. Wire Lighthouse CI

Drop `templates/ci-lighthouse.yml` and `templates/budgets.json` into the project. Adjust paths and URLs to match. The budgets file enforces the hard targets:

- LCP ≤ 2500 ms
- INP ≤ 200 ms (when LH runs in a browser that supports it)
- CLS ≤ 0.1
- TBT ≤ 200 ms (warn)

Run mobile and desktop profiles. Mobile is the primary gate because most field traffic is mobile and CWV at p75 typically fails mobile first.

For projects with a Lighthouse CI server, configure `lhci.serverBaseUrl`. For one-shot reports, use `temporary-public-storage` and copy the link into the PR comment.

### 4. Wire Playwright visual regression

Drop `templates/ci-playwright.yml`. The action:

- Runs Playwright in headed Chromium and WebKit.
- Snapshots specific component states (default, hover, focus, error, loading).
- Compares against committed baselines (`__snapshots__/`).
- On diff, fails the job and uploads the diff images as artifacts.
- On a labeled PR (`update-snapshots`), updates baselines instead of failing.

Where to place tests: per-component spec files alongside the component, or one centralized `tests/visual/*.spec.ts`. Either is fine; pick one and use it consistently.

### 5. Wire Storybook a11y addon (component-framework stacks only)

Add `@storybook/addon-a11y` to `.storybook/main.{ts,js}` and the test runner config. This catches accessibility regressions at the component level, before integration. Store-level gates catch what slips through.

```ts
// .storybook/main.ts
addons: [
  '@storybook/addon-a11y',
  // …other addons
]
```

For test-runner integration:

```ts
// .storybook/test-runner.ts
import { getStoryContext } from '@storybook/test-runner';
import { injectAxe, checkA11y } from 'axe-playwright';

export default {
  async preVisit(page) { await injectAxe(page); },
  async postVisit(page, context) {
    await checkA11y(page, '#storybook-root', {
      detailedReport: true,
      detailedReportOptions: { html: true },
    });
  },
};
```

Skip this gate for vanilla and server-rendered stacks; they have other component-isolation strategies (see their stack references).

### 6. Wire field telemetry

Pure CI gates measure lab. Field truth comes from real users.

Two options:

- **CrUX API** (free, public) — origin-level p75 LCP/INP/CLS, updated monthly. Good for projects with public traffic.
- **RUM** (Sentry, Datadog, custom) — real per-route field data, updated continuously. Better but requires instrumentation.

Schedule `scripts/extract_cwv_field.py` to run weekly via a cron-style CI job. Output goes to `.frontend-ux/field/<date>.md` and is committed (or posted to Slack / a dashboard). When p75 trends up, the team gets early warning before a CWV failure shows up in user complaints.

```yaml
# .github/workflows/cwv-field.yml
on:
  schedule:
    - cron: '0 8 * * 1'  # Monday 08:00 UTC
  workflow_dispatch:
```

### 7. Document the gates

The CI directory needs a short README so future contributors don't disable gates they don't understand. Suggested content:

- What each gate does and what failing it means.
- How to update Playwright snapshots (`gh pr label add update-snapshots`, or whatever the chosen mechanism is).
- How to read Lighthouse CI's report URL.
- The hard targets (CWV at p75, axe Critical/Serious, WCAG 2.2 AA).
- The escalation path: if a gate fails and the user genuinely can't fix it for this PR, who approves a temporary skip?

Skip-gate approvals should be rare and explicit (e.g., a `gate-waiver` label that requires a code-owner approval and auto-files a follow-up issue).

## Common gate anti-patterns

- **Wiring without baselines.** Adding axe to a project with 100 existing failures means the next PR can't pass. Fix the existing failures first or freeze the baseline (`axe --include-tags=wcag2a,wcag2aa --baseline=...`).
- **Mobile-only or desktop-only.** Most teams ship to both. Run both.
- **Lighthouse without budgets.** A passing Lighthouse score is meaningless without thresholds. The gate must enforce numbers.
- **Playwright without state coverage.** Snapshotting only the default state misses 80% of UI bugs. Cover hover, focus, error, loading, empty.
- **Field telemetry as a write-only dashboard.** If nobody reads it, it doesn't gate anything. Send digests to a channel humans actually read.
- **Disabling gates instead of fixing.** "Just turn off axe for this PR" is the start of the regression. The gate is the defense; turning it off is the failure.
- **Gate sprawl.** Adding a 12th flaky check that fires on 30% of PRs trains the team to ignore CI. Fewer, sharper gates beat more, noisier ones.
