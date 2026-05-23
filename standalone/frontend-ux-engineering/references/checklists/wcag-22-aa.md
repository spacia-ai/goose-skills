# Checklist — WCAG 2.2 AA

Copy-into-PR-ready checklist. Each item: the criterion, what to check, how to check.

## Perceivable

### 1.1 Text alternatives
- [ ] **1.1.1 Non-text Content (A)** — every image, icon, and non-text content has a text alternative. Decorative images use `alt=""`. Functional icons (within buttons / links) have an accessible name (`aria-label` on the parent control or visually-hidden text).
  - *How:* run axe; manually check icon-only buttons.

### 1.2 Time-based media
- [ ] **1.2.1–1.2.5 (A/AA)** — audio / video has captions, transcripts, audio descriptions where required.
  - *How:* manual check; if no a/v content, mark N/A.

### 1.3 Adaptable
- [ ] **1.3.1 Info and Relationships (A)** — semantic HTML conveys structure (headings, lists, tables, fieldsets, labels). No `<div>`-as-heading or `<span>`-as-button.
  - *How:* axe + manual review of heading hierarchy.
- [ ] **1.3.2 Meaningful Sequence (A)** — DOM order matches visual reading order.
  - *How:* tab through; read screen-reader linearization.
- [ ] **1.3.3 Sensory Characteristics (A)** — instructions don't rely solely on shape, color, or position ("click the red button").
  - *How:* manual review of microcopy.
- [ ] **1.3.4 Orientation (AA)** — content not locked to portrait or landscape.
  - *How:* rotate device; check for orientation locks.
- [ ] **1.3.5 Identify Input Purpose (AA)** — inputs use `autocomplete` (`name`, `email`, `tel`, `address-line1`, etc.) where applicable.
  - *How:* axe; manual review of forms.

### 1.4 Distinguishable
- [ ] **1.4.1 Use of Color (A)** — color is not the only means of conveying information.
  - *How:* manual; common offender is form errors with red-only.
- [ ] **1.4.2 Audio Control (A)** — auto-playing audio over 3 s has pause/stop. (Best practice: don't autoplay.)
- [ ] **1.4.3 Contrast (Minimum) (AA)** — text contrast 4.5:1; large text (18pt or 14pt bold) 3:1.
  - *How:* axe; spot-check with contrast checker on borderline values.
- [ ] **1.4.4 Resize Text (AA)** — text scales to 200% without loss of content or functionality.
  - *How:* zoom browser to 200%.
- [ ] **1.4.5 Images of Text (AA)** — no images of text except logos.
  - *How:* manual review.
- [ ] **1.4.10 Reflow (AA)** — content reflows at 320 CSS px width without horizontal scroll. Exceptions: tables, maps, complex media.
  - *How:* set viewport to 320 px; check.
- [ ] **1.4.11 Non-Text Contrast (AA)** — UI components and graphical objects 3:1 against adjacent colors. Includes focus indicators, form borders.
  - *How:* axe (limited); manual check on focus rings, custom controls.
- [ ] **1.4.12 Text Spacing (AA)** — content remains usable when line height, paragraph spacing, letter spacing, word spacing are adjusted (per the 1.4.12 formula).
  - *How:* manual or via bookmarklet.
- [ ] **1.4.13 Content on Hover or Focus (AA)** — hover/focus-revealed content is dismissible (via Esc), hoverable (no auto-dismiss while pointer is over it), persistent (stays until dismissed or focus moves).
  - *How:* manual review of tooltips and popovers.

## Operable

### 2.1 Keyboard accessible
- [ ] **2.1.1 Keyboard (A)** — all functionality available via keyboard.
  - *How:* unplug mouse; complete every flow.
- [ ] **2.1.2 No Keyboard Trap (A)** — keyboard focus can move out of any region (except modals).
  - *How:* manual.
- [ ] **2.1.4 Character Key Shortcuts (A)** — single-key shortcuts can be turned off, remapped, or are active only on focus.
  - *How:* manual.

### 2.2 Enough time
- [ ] **2.2.1 Timing Adjustable (A)** — time limits can be turned off, adjusted, or extended.
  - *How:* manual.
- [ ] **2.2.2 Pause, Stop, Hide (A)** — moving / blinking / scrolling content has pause / stop / hide.
  - *How:* manual.

### 2.3 Seizures and physical reactions
- [ ] **2.3.1 Three Flashes or Below Threshold (A)** — no content flashes more than 3 times per second.
  - *How:* manual; rare in well-designed apps.

### 2.4 Navigable
- [ ] **2.4.1 Bypass Blocks (A)** — skip-to-content link or equivalent.
  - *How:* tab from address bar; first interactive element should be a skip link.
- [ ] **2.4.2 Page Titled (A)** — every page has a unique, descriptive `<title>`.
  - *How:* manual review.
- [ ] **2.4.3 Focus Order (A)** — focus order is meaningful.
  - *How:* tab through.
- [ ] **2.4.4 Link Purpose (In Context) (A)** — link text describes purpose (no "click here").
  - *How:* manual + screen reader's link list.
- [ ] **2.4.5 Multiple Ways (AA)** — pages reachable through more than one mechanism (nav, search, sitemap, etc.).
  - *How:* manual.
- [ ] **2.4.6 Headings and Labels (AA)** — headings and labels describe topic or purpose.
  - *How:* manual.
- [ ] **2.4.7 Focus Visible (AA)** — focus indicator visible on all focusable elements.
  - *How:* tab through; check no `outline: none` without replacement.
- [ ] **2.4.11 Focus Not Obscured (Minimum) (AA)** — focused element is not entirely hidden by sticky headers / footers / floating components.
  - *How:* tab through long page with sticky elements.

### 2.5 Input modalities
- [ ] **2.5.1 Pointer Gestures (A)** — multi-point or path-based gestures have single-pointer alternatives.
  - *How:* manual review of any custom gesture.
- [ ] **2.5.2 Pointer Cancellation (A)** — single-pointer activation can be aborted.
  - *How:* `mousedown` triggers actions only on `click` / `pointerup`.
- [ ] **2.5.3 Label in Name (A)** — accessible name contains visible label.
  - *How:* axe.
- [ ] **2.5.4 Motion Actuation (A)** — features triggered by device motion (shake, tilt) have alternatives.
  - *How:* manual; rare on web.
- [ ] **2.5.7 Dragging Movements (AA)** — drag-and-drop has single-pointer alternative.
  - *How:* manual review of any drag interaction.
- [ ] **2.5.8 Target Size (Minimum) (AA)** — interactive targets 24×24 CSS px or have sufficient spacing.
  - *How:* axe (limited); manual measurement.

## Understandable

### 3.1 Readable
- [ ] **3.1.1 Language of Page (A)** — `<html lang="...">` set.
- [ ] **3.1.2 Language of Parts (AA)** — `lang` attribute on inline content in different languages.

### 3.2 Predictable
- [ ] **3.2.1 On Focus (A)** — receiving focus does not cause context change.
- [ ] **3.2.2 On Input (A)** — changing a control does not cause context change unless user is warned.
- [ ] **3.2.3 Consistent Navigation (AA)** — repeated nav appears in same relative order across pages.
- [ ] **3.2.4 Consistent Identification (AA)** — same component identified consistently.
- [ ] **3.2.6 Consistent Help (A)** — help mechanism appears in same location across pages.

### 3.3 Input assistance
- [ ] **3.3.1 Error Identification (A)** — errors are described in text.
- [ ] **3.3.2 Labels or Instructions (A)** — labels or instructions provided where input is required.
- [ ] **3.3.3 Error Suggestion (AA)** — error messages suggest a correction.
- [ ] **3.3.4 Error Prevention (Legal, Financial, Data) (AA)** — reversible / checked / confirmed for high-stakes submissions.
- [ ] **3.3.7 Redundant Entry (A)** — don't ask for data already provided in the same session unless essential.
- [ ] **3.3.8 Accessible Authentication (Minimum) (AA)** — auth doesn't require cognitive function tests (memorize, transcribe) without alternatives.

## Robust

### 4.1 Compatible
- [ ] **4.1.1 Parsing — REMOVED in WCAG 2.2.** Browsers now handle parse errors. No action.
- [ ] **4.1.2 Name, Role, Value (A)** — every UI component exposes name, role, value to AT.
- [ ] **4.1.3 Status Messages (AA)** — dynamic status reachable via AT (`role="status"`, `role="alert"`, `aria-live`).

## Quick-run process

1. Run axe-cli or `scripts/run_audit.sh`. Fix all Critical and Serious findings before manual review.
2. Tab through every primary flow without a mouse. Note any interactive element that can't receive focus or has no visible focus.
3. Use a screen reader on the primary flow (VoiceOver, NVDA, or JAWS). Note any control without accessible name or with confusing announcement.
4. Resize viewport to 320 px width and to 200% browser zoom. Note any reflow or text-cutoff issue.
5. Test with `prefers-reduced-motion: reduce` enabled. Note any motion that still plays.
6. Test with high-contrast / forced-colors mode. Note any element that disappears or becomes illegible.

## Bibliography

- WCAG 2.2 — W3C Recommendation, October 2023.
- "Understanding WCAG 2.2" — W3C Working Group Note.
