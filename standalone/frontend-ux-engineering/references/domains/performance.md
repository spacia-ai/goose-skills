# Domain — performance

Core Web Vitals at p75. Field measurement first; lab is diagnostic. Perceived performance is a real engineering discipline.

## Why p75 field metrics

Field metrics — measured on actual users' devices and networks — are the only measurements that matter for shipping decisions. Lab metrics (Lighthouse, WebPageTest from a single location) are diagnostic tools, useful for debugging but not for deciding "is this fast enough."

p75 (the 75th percentile) is the conventional threshold because it represents "most users have at least this experience." It's stricter than the median (which can hide bad tails), looser than p99 (which is dominated by extreme outliers).

If your p75 LCP is 3.2 seconds, 25% of your users wait longer than 3.2 seconds. That's the population you've decided is acceptable to under-serve. Decide deliberately.

## Core Web Vitals

| Metric | Target at p75 | What it measures |
|---|---|---|
| **LCP** Largest Contentful Paint | ≤ 2.5 s | Time from navigation start until the largest visible content element is rendered. Proxy for perceived load speed. |
| **INP** Interaction to Next Paint | ≤ 200 ms | Latency of the slowest user interaction with the page (click, tap, key). Proxy for perceived responsiveness. Replaced FID in 2024. |
| **CLS** Cumulative Layout Shift | ≤ 0.1 | Sum of layout shifts that aren't user-initiated. Proxy for perceived stability. |

Also worth tracking, though not part of CWV:

- **TTFB** Time to First Byte — server-render and network latency. Affects LCP directly. Target: ≤ 800 ms at p75.
- **FCP** First Contentful Paint — when *any* content first paints. ≤ 1.8 s at p75 is "good".
- **TBT** Total Blocking Time — sum of long tasks > 50 ms during page load. Lab proxy for INP.

## How to measure (field)

### CrUX (Chrome User Experience Report)

Free, public, derived from real Chrome users who opt in. Available via:

- **Public Search Console** — free per-property dashboards.
- **CrUX API** — programmatic access by URL or origin. Returns histograms; the script `scripts/extract_cwv_field.py` queries it and computes p75.
- **CrUX BigQuery dataset** — large-scale historical analysis.

Limitations: Chrome-only, limited per-route granularity (origin-level easier than URL-level for low-traffic pages), aggregated over 28 days (can be slow to reflect changes).

### Real-User Monitoring (RUM)

Per-page, per-session, in your own infrastructure or via Sentry, Datadog, etc. Better granularity than CrUX, slower to set up.

Key requirements:

- Capture LCP, INP, CLS via the `web-vitals` library.
- Aggregate to p75 by route and by traffic segment (geography, device class).
- Display p75 over rolling windows (7d, 28d) so trends are visible.

## How to measure (lab)

### Lighthouse

For diagnosis, not gating sole truth.

- Mobile profile primary; most field traffic is mobile.
- Desktop profile secondary.
- Run multiple times (Lighthouse has run-to-run variance up to ~10% on the same code).
- Report variance with median across N runs.
- Treat scores as directional. A 90 → 80 regression on mobile is real; a 92 → 90 is noise.

### WebPageTest

More lab-environment control. Useful for filmstrip view of LCP and visual completion.

### DevTools Performance panel

For diagnosing specific bottlenecks: long tasks, layout shifts, paint events, main-thread occupancy.

## Optimizing each metric

### LCP

LCP is dominated by resource fetch and render of the largest above-fold element (typically a hero image, hero text block, or above-fold video poster).

- **Identify the LCP element.** DevTools shows it. Most teams discover their LCP element is not what they assumed.
- **Preload critical assets.** `<link rel="preload" as="image" href="..." fetchpriority="high">` for the hero image. Not for everything — preloading too much defeats the purpose.
- **Use modern image formats.** AVIF / WebP with fallback. Significantly smaller than JPEG/PNG at equivalent quality.
- **Use `srcset` and `sizes`.** Serve the right image for the viewport.
- **Inline critical CSS.** The browser can't paint until CSS arrives. Inline what's needed for above-fold; defer the rest.
- **Avoid render-blocking JS** in `<head>`. Use `defer` or `async`. Or move to `<body>` end.
- **Use a CDN** for static assets, with edge caching.
- **Server-render or prerender** for first navigation. Hydration cost on a CSR-only app pushes LCP into the seconds.
- **Avoid LCP element being below the fold.** Sometimes a redesign moves the largest element out of the initial viewport, which shifts the metric to a different element.

### INP

INP is the *worst* (highest) interaction latency on the page. Improving the median doesn't help; you have to fix the slowest single interaction.

- **Identify long tasks during interaction.** DevTools Performance panel shows them.
- **Break up long tasks.** Use `scheduler.yield()` or `setTimeout`/`requestIdleCallback` to yield to the main thread.
- **Defer non-essential work.** Analytics, tracking, third-party scripts run as if they own the main thread; they don't.
- **Avoid heavy work in event handlers.** Click handlers should respond instantly; heavy work goes to a microtask, idle callback, or web worker.
- **Use `content-visibility: auto`** to skip rendering offscreen content.
- **Hydration is not free.** SSR + hydration apps often have very poor INP early in the page load. Consider streaming SSR, partial hydration (islands), or progressive enhancement.

### CLS

CLS measures unexpected layout movement. The fix is almost always reserving space.

- **Reserve space for images and embeds.** Use `width` and `height` attributes (not just CSS) so the browser can compute the aspect ratio before the image arrives.
- **Reserve space for ads, third-party widgets, and iframes.** Min-height the container.
- **Avoid late-injected banners and notifications.** Cookie banners that appear after first paint cause large CLS. Server-render them or reserve space.
- **Avoid swap-in fonts that change metrics.** Use `font-display: optional` or `font-display: swap` with `size-adjust` and metric-override descriptors so the swap doesn't shift content.
- **Use CSS `contain` and `aspect-ratio`** for predictable layout.

## Perceived performance

Real performance is what the metric measures. Perceived performance is what the user *feels*. They diverge — and the second one matters too.

### The hierarchy of perceived performance

1. **Stability.** Layout doesn't move under the user's pointer or eye.
2. **Responsiveness.** The interface acknowledges input within ~100 ms.
3. **Predictability.** Loading feedback shape matches the actual wait shape.
4. **Speed.** Real elapsed time.

A user will tolerate 2 seconds of stable, responsive, predictable wait better than 800 ms of jumpy, unresponsive surprise.

### Loading feedback by wait shape

| Wait shape | Feedback |
|---|---|
| < 200 ms (imperceptible) | None. A flash of skeleton or spinner is worse than silence. |
| 200 ms - 1 s (short indeterminate) | Spinner, optionally with subtle text. |
| 400 ms - 5 s (moderate, structure known) | Skeleton matching the eventual content shape. |
| Long, estimable | Determinate progress bar. |
| Long, indeterminate | Indeterminate progress bar (distinct from determinate). |
| Long, background | Persistent indicator (e.g., a small badge); don't block the user. |

### Animation and motion

- Use `transform` and `opacity` for animation. They run on the compositor and don't trigger layout.
- Avoid animating `width`, `height`, `top`, `left`, `margin` — they trigger layout.
- Use `will-change` sparingly; it's a hint, and overuse memory.
- Honor `prefers-reduced-motion`. See `domains/accessibility.md`.
- Animation should communicate state change or maintain continuity, not decorate. If removing it doesn't change comprehension, it's decorative.

## Performance budgets

A budget is a number above which a change is rejected. Without budgets, performance regresses incrementally and invisibly.

Suggested budgets for a typical product:

- LCP at p75 ≤ 2500 ms (mobile field).
- INP at p75 ≤ 200 ms (mobile field).
- CLS at p75 ≤ 0.1 (mobile field).
- TBT lab ≤ 200 ms (mobile lab).
- Initial JS ≤ 150 KB (gzipped).
- Initial CSS ≤ 50 KB (gzipped).
- Initial above-fold image ≤ 100 KB (preloaded, modern format).
- Total initial transfer ≤ 500 KB.

These are starting points. Adjust to your audience (more generous for low-bandwidth users; stricter for high-end consumer products).

`templates/budgets.json` encodes these for Lighthouse CI. `gate` mode wires it.

## Common performance anti-patterns

- **Optimizing for Lighthouse score instead of field metrics.** A green Lighthouse score with a slow CrUX p75 is a lie.
- **Treating spinners as a fix for slowness.** They make 200 ms feel like 200 ms with a spinner. They don't make slow fast.
- **Lazy-loading the LCP element.** `loading="lazy"` on the hero image is one of the most common and hardest-to-find LCP regressions.
- **Hydrating everything.** Most surfaces don't need hydration. Static is fast.
- **Animating layout properties.** `transition: width 300ms` is a CLS factory.
- **Forgetting font-loading shifts.** A custom font that loads after FCP and changes metric metrics is a CLS multiplier.
- **One-time benchmark, no monitoring.** Performance regresses constantly. Without continuous monitoring, you ship the regression.
- **Mobile assumed equals desktop, just smaller.** Mobile field metrics are usually 2-3x worse than desktop on the same code. Test mobile.

## Bibliography

- "Web Vitals" — Google.
- "Core Web Vitals: thresholds, methodology, and updates" — web.dev.
- "Optimize INP" — Philip Walton, Jeremy Wagner, web.dev.
- "Optimize Largest Contentful Paint" — web.dev.
- "Optimize Cumulative Layout Shift" — web.dev.
- "Why Lab and Field Data Can Be Different (and What to Do About It)" — web.dev.
- HTTP Archive Web Almanac — performance chapter, annual.
- "JavaScript Misbehaviors and the Cost of Rendering on the Main Thread" — Addy Osmani.
