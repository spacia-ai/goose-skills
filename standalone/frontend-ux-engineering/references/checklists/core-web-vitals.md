# Checklist — Core Web Vitals at p75

Copy-into-PR-ready checklist. p75 (75th percentile) is the threshold; lab measurements are diagnostic only.

## Targets

| Metric | Good (p75) | Needs improvement | Poor |
|---|---|---|---|
| **LCP** Largest Contentful Paint | ≤ 2.5 s | 2.5 – 4.0 s | > 4.0 s |
| **INP** Interaction to Next Paint | ≤ 200 ms | 200 – 500 ms | > 500 ms |
| **CLS** Cumulative Layout Shift | ≤ 0.1 | 0.1 – 0.25 | > 0.25 |

Mobile field data is the gate. Desktop is a secondary check. Most products ship to mobile-first traffic, and CWV at p75 typically fails mobile first.

## LCP — Largest Contentful Paint

- [ ] **Identified the LCP element.** Use DevTools → Performance → LCP marker. Most teams discover their LCP element is not what they assumed.
- [ ] **LCP element is not lazy-loaded.** No `loading="lazy"` on the hero image or above-fold media.
- [ ] **LCP image is preloaded.** `<link rel="preload" as="image" href="..." fetchpriority="high">` for the LCP image, or `fetchpriority="high"` on the `<img>`.
- [ ] **LCP image is in modern format.** AVIF or WebP with fallback.
- [ ] **LCP image uses `srcset` and `sizes`.** Right size for viewport.
- [ ] **LCP image has explicit dimensions.** `width` and `height` attributes (not just CSS) so aspect ratio reserves space (ties to CLS).
- [ ] **No render-blocking JS in `<head>`.** Use `defer`, `async`, or move to body end.
- [ ] **Critical CSS is inlined or fast.** First paint shouldn't wait on a slow CSS bundle.
- [ ] **CDN serves static assets.** Edge caching for images, fonts, CSS.
- [ ] **Initial HTML is server-rendered or prerendered.** Pure CSR (client-side rendered) apps usually fail LCP.
- [ ] **TTFB ≤ 800 ms at p75.** Server / origin latency directly bounds LCP.

## INP — Interaction to Next Paint

INP is the *worst* (highest) interaction latency on the page. Improving the median doesn't help; you have to fix the slowest single interaction.

- [ ] **No long tasks > 50 ms during interaction.** Use DevTools Performance panel; record while interacting.
- [ ] **Heavy work is deferred or chunked.** `scheduler.yield()`, `setTimeout(fn, 0)`, `requestIdleCallback`, web workers.
- [ ] **Click handlers respond instantly.** Heavy work moves to a microtask or async; the handler returns within ~16 ms.
- [ ] **Third-party scripts do not block.** Analytics, A/B tools, chat widgets — load lazy or deferred.
- [ ] **Hydration is not page-blocking.** Streaming SSR, partial hydration (islands), or progressive enhancement.
- [ ] **`content-visibility: auto`** on offscreen content where applicable.
- [ ] **No synchronous layout thrash.** Avoid alternating reads (`offsetHeight`) and writes (`style.height = ...`) in the same tick.
- [ ] **Animations use compositor properties.** `transform` and `opacity`, not `top`/`left`/`width`.

## CLS — Cumulative Layout Shift

- [ ] **All `<img>` have `width` and `height` attributes.** Browser computes aspect ratio before image arrives.
- [ ] **All `<iframe>` have `width` and `height` attributes** (or are reserved via container CSS).
- [ ] **Embeds (videos, maps, social widgets) have reserved space.** Min-height on the container.
- [ ] **Banners and notifications don't shift content.** Either render server-side, or reserve space, or overlay.
- [ ] **Cookie banner doesn't cause CLS.** Server-render it or reserve space at the bottom.
- [ ] **No font swap that changes metrics.** Use `font-display: optional`, or `swap` with `size-adjust` and `ascent-override` / `descent-override` matching the fallback to the web font.
- [ ] **No `height: auto` on dynamic content** without a fallback minimum.
- [ ] **No interaction-triggered shifts.** Clicking an element should not push other elements.
- [ ] **`aspect-ratio` CSS used** for media containers when dimensions can't be set on the element.

## Quick-diagnosis flow

1. Run Lighthouse in mobile profile. Note LCP, INP (or TBT lab), CLS.
2. Pull p75 field metrics from CrUX (`scripts/extract_cwv_field.py --crux <origin>`) or RUM. Compare lab to field.
3. If field LCP > 2.5 s: identify LCP element, check preload, lazy-load, format, and TTFB.
4. If field INP > 200 ms: identify worst interaction in DevTools Performance, look for long tasks > 50 ms, defer or chunk.
5. If field CLS > 0.1: scroll through the page slowly while watching DevTools' Layout Shift overlay; identify the shifting element and reserve space.

## Bundle / asset budgets

These are typical product budgets; adjust per audience:

- [ ] **Initial JS** ≤ 150 KB gzipped.
- [ ] **Initial CSS** ≤ 50 KB gzipped.
- [ ] **Initial image bytes (above-fold)** ≤ 100 KB.
- [ ] **Initial transfer total** ≤ 500 KB.
- [ ] **Per-route additional JS** ≤ 50 KB gzipped.

`templates/budgets.json` encodes these for Lighthouse CI.

## Bibliography

- "Web Vitals" — Google.
- "Optimize INP" / "Optimize LCP" / "Optimize CLS" — web.dev.
- "Why Lab and Field Data Can Be Different" — web.dev.
