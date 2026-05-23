# Domain — accessibility

WCAG 2.2 AA, ARIA 1.2, semantic HTML, keyboard and focus, motion preferences. The foundational domain: most other domains assume this one is solid.

## Why accessibility is foundational

Accessibility is not a checklist you run at the end. It is the constraint set that determines whether the interface works for the full range of human ability, input device, and assistive technology. Treat it as a layer your team has to consciously remove to lose, not consciously add to gain.

Most "we'll add accessibility later" code becomes "we'll never add accessibility." Adding it later means rewriting the markup, the focus logic, and the keyboard handling — so it doesn't happen. Building accessibility in from the start costs almost nothing and survives.

## The conformance target

**WCAG 2.2 AA** is the stable shipping target as of 2026. WCAG 3 is a working draft with a different conformance model and a different vocabulary; it is not expected to replace WCAG 2 for years. Treat WCAG 3 as horizon-scanning, not as a delivery checklist.

Where regulated industries require **AAA** (e.g., parts of the public sector, some healthcare and finance contexts), honor it. Note in the artifact that AAA is non-default and that it imposes constraints (e.g., 7:1 text contrast, no live captions exceptions, no images of text) that the design must accept up front.

## The semantic-HTML-first principle

Native HTML elements ship with:

- The right ARIA role.
- The right keyboard behavior (Enter / Space activation, Tab focus, arrow keys for grouped widgets).
- The right state exposure to assistive technology.
- The right behavior across browsers and platforms without testing.
- Default styling that signals interactivity.

ARIA does **none** of these. ARIA only **describes** semantics; it does not provide them. A `role="button"` on a `<div>` requires you to manually implement focusability, keyboard activation, hover/focus/pressed states, and screen-reader announcement — and your implementation will almost certainly miss something.

The W3C's official guidance: **"No ARIA is better than bad ARIA."** Use ARIA only where native HTML lacks the semantics. Otherwise, use the native element.

### Common reinventions that should be native

| Custom version | Native version |
|---|---|
| `<div role="button">` | `<button>` |
| `<a>` with no `href` and a JS click handler | `<button>` |
| `<div role="link">` | `<a href="...">` |
| `<div role="checkbox">` | `<input type="checkbox">` |
| `<div role="textbox">` | `<input>` or `<textarea>` |
| `<div role="dialog">` | `<dialog>` (HTML element) |
| `<div role="region">` for a section | `<section>` with `aria-labelledby` |
| `<div role="navigation">` | `<nav>` |
| `<div role="main">` | `<main>` |
| Custom toggle widget | `<button aria-pressed>` or `<input type="checkbox">` |
| Custom expand/collapse | `<details>` / `<summary>` or `<button aria-expanded>` |

When you genuinely need ARIA (custom comboboxes, listboxes, grids, trees, tabs, tablists), follow the **WAI ARIA Authoring Practices Guide (APG)** patterns exactly. The APG provides reference implementations for every common interactive widget that lacks a native equivalent.

## WCAG 2.2 SCs new since 2.1

These are the criteria most teams have not yet internalized. Pay particular attention.

| SC | Title | Level | What it means in practice |
|---|---|---|---|
| 2.4.11 | Focus Not Obscured (Minimum) | AA | Sticky headers, footers, and floating components must not fully hide a focused element. Test with keyboard navigation through a long page with a sticky header. |
| 2.5.7 | Dragging Movements | AA | Any drag-and-drop must have a single-pointer alternative (e.g., a button to move the item, or click-then-click placement). |
| 2.5.8 | Target Size (Minimum) | AA | Interactive targets at least 24×24 CSS px, or with sufficient spacing. The bigger spec target (44×44) is best practice for touch surfaces. |
| 3.2.6 | Consistent Help | A | If you have a help mechanism on multiple pages, it appears in the same relative location. |
| 3.3.7 | Redundant Entry | A | Don't ask the user to re-enter data they've already provided in the same session, unless re-entry is essential. |
| 3.3.8 | Accessible Authentication (Minimum) | AA | Authentication doesn't require a cognitive function test (memory, transcription, etc.) without alternatives. Passkeys and password-manager autofill satisfy this. |

Other long-standing AA criteria that still trip teams:

- **1.4.3 Contrast (Minimum)** — text contrast 4.5:1; large text (18pt or 14pt bold) 3:1.
- **1.4.10 Reflow** — content reflows at 320 px width without horizontal scroll, except for content requiring 2D layout (data tables, maps).
- **1.4.11 Non-Text Contrast** — UI components and graphical objects 3:1 against adjacent colors. Includes focus indicators.
- **2.4.7 Focus Visible** — focus is always visible on focusable elements. Removing default focus styles without replacement is a violation.
- **4.1.3 Status Messages** — dynamic status (success, error, loading completion) is announced to assistive tech via `aria-live` or `role="status"` / `role="alert"` without moving focus.

## Keyboard and focus

The keyboard is not "a fallback for power users." It is the only input device for many AT users (screen-reader users, switch-control users, voice-control users who proxy to keyboard). It is also a fast input device for sighted users.

### Keyboard rules

1. **Every interactive element is reachable by Tab.** Click handlers on non-interactive elements break this. Use `<button>` or `<a>`.
2. **Tab order matches reading order.** Don't use `tabindex` values greater than 0; they create unpredictable jumps.
3. **No keyboard traps.** A user who Tabs into a region must be able to Tab out. The exception is modal dialogs, which trap focus until dismissed (which is the correct behavior).
4. **Custom widgets implement APG keyboard behavior.** Tabs respond to arrow keys; comboboxes respond to arrow keys + Enter; listboxes respond to arrow keys + Home / End; trees respond to arrow keys including Right to expand and Left to collapse.
5. **Visible focus indicator** with at least 3:1 contrast against adjacent colors. Custom focus styles are encouraged for design coherence; removing them entirely is not.

### Focus management

- **On modal open:** focus moves to the modal's first focusable element (or to the dialog itself if no focusable child). On close, focus returns to the element that opened it.
- **On route change** (in SPAs): focus moves to the new page's main heading or main landmark. Without this, screen-reader users have no way to know the page changed.
- **On error:** focus moves to the error summary that lists the errors. The summary contains links to each erroring field.
- **On success:** focus often moves to a success message or to the next reasonable action. Don't leave focus on a now-disabled or now-removed element.
- **On expand/collapse:** focus stays on the toggle (don't yank it into the revealed content unless that's the user's clear next action).

## ARIA — when to use it

ARIA is appropriate when:

1. **Native HTML doesn't provide the semantic** (e.g., live regions for dynamic status, `aria-current` for the current page in a nav).
2. **You need to expose state that has no native attribute** (e.g., `aria-pressed` for toggle buttons, `aria-expanded` for disclosure widgets, `aria-checked` for tri-state checkboxes).
3. **You're labeling something** that has no visible label (`aria-label`, `aria-labelledby`).
4. **You're describing something** that needs additional context (`aria-describedby`).
5. **You're building a custom widget** that doesn't have a native equivalent (combobox, listbox, grid, tree, tabs) — and you're following APG patterns exactly.

ARIA is **not** appropriate when:

1. **The native element exists.** Use it.
2. **You're trying to fix a missing visible label by adding `aria-label`.** Add a real label first; AT users and sighted users both benefit.
3. **You're using it to "make this more accessible" without understanding what it does.** Most ARIA mistakes come from this.
4. **You're nesting roles** (`role="button"` inside `role="link"`, etc.). Nesting is almost always wrong.

## Reduced motion and other media queries

CSS media queries expose user accessibility preferences. Honor them.

- **`prefers-reduced-motion: reduce`** — disable or simplify motion. Replace movement with crossfades or instant transitions. Critical for users with vestibular disorders and for some cognitive contexts.
- **`prefers-reduced-data: reduce`** — serve smaller assets when present (still less broadly supported).
- **`prefers-contrast: more`** — increase contrast where possible.
- **`prefers-contrast: less`** — decrease contrast where possible (rare).
- **`prefers-color-scheme: light | dark`** — dark mode preference.
- **`forced-colors: active`** — Windows High Contrast Mode and similar. Don't override system colors with hardcoded values.

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

The above is a useful "all-off" baseline. Better is per-effect handling: replace movement with crossfade, replace parallax with static positioning, etc.

## Common accessibility anti-patterns

- **`<div onclick>` for buttons.** Not focusable, no keyboard activation, no role exposure.
- **Removing focus outline globally.** `*:focus { outline: none; }` without a replacement is a Critical violation.
- **`aria-label` on a `<div>` with no role.** No effect; the label has nothing to label.
- **`tabindex="0"` on every interactive element.** Use the right element (`<button>`, `<a>`); they get focus automatically.
- **`tabindex="-1"` to "fix focus order."** Removes the element from the keyboard path entirely.
- **Modal without focus trap.** User Tabs out of the modal and is now interacting with disabled background content they can't see.
- **Modal without focus restore.** User closes the modal and lands at the top of the document, having lost their place.
- **Status announcements via `alert()` or focus shifts.** Use `role="status"` / `role="alert"` or `aria-live` regions; don't disrupt focus.
- **Form validation that hides the field.** "This field is invalid" with no visual indication of which field, or a focus shift to a now-hidden region.
- **Color-only signaling.** Red text for errors with no icon, label, or pattern. Red-green colorblind users miss it.

## Bibliography

- Web Content Accessibility Guidelines (WCAG) 2.2 — W3C, October 2023.
- Accessible Rich Internet Applications (WAI-ARIA) 1.2 — W3C.
- WAI-ARIA Authoring Practices Guide — W3C.
- HTML Living Standard — WHATWG.
- "Inclusive Design Principles" — Microsoft.
- "Accessibility" — Apple Human Interface Guidelines.
- WebAIM articles on contrast, screen readers, and keyboard accessibility.
