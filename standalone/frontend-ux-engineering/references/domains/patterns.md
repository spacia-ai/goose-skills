# Domain — interaction patterns

The patterns that determine whether a serious web app feels usable, scalable, and trustworthy. Drawn from APG, GOV.UK Design System, Fluent, Apple HIG, Material, and NN/g convergent guidance.

## Why a pattern catalog matters

Interface patterns are the result of decades of compounded usability evidence. When a pattern shows up in APG, GOV.UK, Fluent, Apple HIG, and Material with substantively similar guidance, you are looking at human-cognition gravity, not a fashion. Reach for the well-known pattern unless you have specific user evidence that something else solves your problem better.

Inventing patterns is appropriate roughly 5% of the time. The other 95% of "we need something custom" is a misread of the user's job — usually trying to compress two unrelated tasks into one surface.

## Pattern taxonomy

### Navigation

| Pattern | Use when | Avoid when | Notes |
|---|---|---|---|
| Top app bar / global nav | Most web apps with 3-7 destinations | Complex hierarchies with many nested sections | Visible on larger screens. Don't collapse to hamburger on desktop. |
| Sidebar / nav rail | Multi-area products with frequent destination switching | Tiny apps with 1-3 destinations; very narrow layouts | The default for serious admin and dashboard products. Keep collapsible if real estate is tight. |
| Tab bar (bottom, mobile) | Mobile apps with 3-5 top-level destinations | More than 5 destinations | Apple HIG and Material agree on 3-5 max. |
| Tablist (in-page) | Sibling categories on a single surface | Primary global navigation; arbitrary actions; small layouts that force overflow | Use ARIA tabs pattern. Tabs are not "buttons that look like tabs". |
| Breadcrumbs | Deep hierarchies where "where am I?" is unclear | Flat apps; the path adds noise without orientation value | Provide as a nav landmark; don't rely on visual chevrons alone. |
| Search field | Apps with high recall needs and many destinations | As a substitute for bad IA | Place persistently in the global frame; provide keyboard shortcut (`/` or `Cmd-K`). |
| Command palette (`Cmd-K`) | Expert workflows; large apps; many destinations | Casual / consumer apps where users won't discover it | Pair with a search field for discoverability. Don't make it the *only* way to reach destinations. |
| Hamburger menu | Genuine mobile constraint | Desktop / tablet where space allows visible nav | Hamburger costs interaction even when icon is recognized. |

### Forms

| Pattern | Use when | Avoid when | Notes |
|---|---|---|---|
| Single-page form | Low-stakes, fast, all-related fields | High-consequence flows; long flows | Group fields with `<fieldset>` / `<legend>`. |
| Question-page wizard (one question per page) | High-consequence, regulated, transactional flows | Low-risk settings | GOV.UK pattern. Reduces cognitive load and improves error recovery. |
| Multi-step form with progress | Complex but related flow with logical chunks | Trivial flows where steps add overhead | Show progress; allow back without losing state. |
| Inline field validation + summary | Any form that can fail submission | Premature validation while user is still composing | Errors inline next to field; summary at top of form receives focus on submit. |
| Persisted draft | Long forms or anything where loss-of-input is painful | Simple forms; sensitive content (passwords) | Save to localStorage on blur; restore on load. |

Form rules:

- Label every input visibly. `aria-label` is a fallback, not a primary mechanism.
- Group related fields in `<fieldset>` with `<legend>`.
- Validate on progress / submit, not on every keystroke. Live validation is acceptable when research shows it helps (e.g., real-time username availability), and it must always be polite to AT.
- Preserve user-entered values across error rerenders. Losing input is the single most-cited form failure.
- Accept multiple input formats where reasonable. `+1 (555) 123-4567` and `5551234567` should both work.
- Don't disable submit until the form is "valid". Allow submission, surface errors, let users fix.

### Tables and dashboards

| Pattern | Use when | Avoid when | Notes |
|---|---|---|---|
| Data table | Users compare rows / columns, sort, filter, edit, take list actions | Mainly narrative content; each item has a unique rich layout | Use `<table>`. Sortable headers expose `aria-sort`. |
| Card grid | Items with rich, varied content; visual recognition matters | Dense comparable data — use a table | Don't cardify a spreadsheet. |
| Data grid (custom widget) | Spreadsheet-like editing, large datasets, complex selection | When a regular table suffices | APG grid pattern. Significant ARIA complexity; only when justified. |
| Dashboard overview | Users monitor changing metrics and need at-a-glance situational awareness | As a dump of every available KPI | Each chart should answer one question and suggest one action. |
| Metric card + trend | Small KPI block with current value and recent direction | Dashboards demanding deep analysis | Pair value with sparkline; show period explicitly. |

Table rules:

- Use `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>` — semantic markup gives screen readers row/column relationships for free.
- Sortable columns: `<th aria-sort="ascending|descending|none">`. Toggle on click; provide keyboard handlers.
- Row-level actions in a cell, not in a hover-revealed overlay (overlays break keyboard).
- Bulk actions: header checkbox toggles all visible rows; clear selection state.
- For very wide tables: provide horizontal scroll *or* responsive column hiding *or* a "compact / comfortable" density toggle.

Dashboard rules:

- Lead with the most important metric, not the most colorful chart.
- Charts should support comparison and trend recognition. Pie charts are usually wrong; bar charts comparing values are usually right.
- Every chart needs a title, units, and time range visible without hover.
- Provide an empty state when data is missing — don't show a chart with `0` values, which looks like real data.

### Dialogs, drawers, and modals

| Pattern | Use when | Avoid when | Notes |
|---|---|---|---|
| Modal dialog | Focused subtask, confirmation, temporary contextual work | Full primary flows; long forms; nested modal stacks; content that deserves its own URL and history | APG dialog pattern: focus trap, Escape to close, restore focus on close. |
| Drawer / panel | Secondary content alongside primary; keep context visible | Primary flows; main content | Same focus rules as modals when modal. Consider non-modal drawers for non-blocking work. |
| Confirmation dialog | Destructive or irreversible action | Trivial confirmations ("save changes") that are themselves trivial | Use clear destructive button labels ("Delete account", not "OK"). |
| Sheet (mobile bottom sheet) | Contextual actions; less disruptive than full modal | When the action deserves the full screen | iOS / Material pattern; ensure swipe-to-dismiss has a button alternative. |
| Inline disclosure / accordion | Secondary, optional, densely structured content | Core content users must compare side-by-side | Use `<details>` / `<summary>` or APG accordion. Don't hide must-read content. |

Dialog rules:

- One dialog at a time. Stacking dialogs is a UX failure mode.
- Don't put primary flows in dialogs. Long forms, multi-step processes, or anything the user might want to share via URL → use a real page.
- Escape always closes (unless the dialog is genuinely irreversibly committed, which is rare).
- The trigger that opened the dialog receives focus when it closes.
- Focus trap is mandatory — Tab cycles within the dialog, not behind it.

### Feedback (loading, status, errors)

The right feedback choice depends on the **shape of the wait** and the **importance of the message**.

| Pattern | Use when | Notes |
|---|---|---|
| Skeleton | Structure is known, wait is moderate (~400 ms - 2 s) | Skeleton matches the shape of the content. Don't skeleton-everything. |
| Spinner | Short indeterminate wait (< 1 s typically). | Don't show on imperceptible waits (< 200 ms); the flash itself is jarring. |
| Progress bar (determinate) | Wait is estimable (uploads, downloads, multi-step processing) | Always preferred over spinner when the system can know progress. |
| Progress bar (indeterminate) | Long indeterminate wait when spinner is too small | Distinct visual from determinate; don't lie about progress. |
| Message bar / banner | Persistent page-level state (e.g., "Connection lost", "Read-only mode", "Updates available") | Stays visible until state changes or user dismisses. Place at top of relevant scope. |
| Toast / snackbar | Transient secondary status ("Saved", "Item moved to trash") | Self-dismisses in 4-6 seconds. Don't put critical info in a toast. |
| Inline error | Field-level validation failure | Adjacent to the field, with a link from the summary. |
| Inline success | Field-level confirmation when the user needs reassurance | Don't toast every save; sometimes inline is calmer. |

Feedback rules:

- No spinner for waits under ~200 ms. The flash is worse than the silence.
- Skeletons should preserve layout (no shift on real content load).
- Toast for transient secondary; banner / message bar for persistent or important.
- Live status messages reach AT via `aria-live="polite"` or `role="status"`. Don't shift focus to announce.
- Errors must be specific. "Something went wrong" with no detail is a failure.

## Pattern selection process (for build mode)

For each surface, ask:

1. **What is the user's primary task here?** One sentence.
2. **What is the wait shape?** None / fast / moderate / long / async background.
3. **Where in the flow is this surface?** Entry / midpoint / decision / completion.
4. **What is the destination set?** How many destinations does the user reach from this surface?

The answers map onto the patterns above. If you find yourself unable to answer one of the four, stop and re-interview the user — you don't yet have enough to make pattern decisions.

## Common pattern anti-patterns

- **Tabs as global nav.** Tabs are sibling-views-on-one-surface, not site-wide navigation. Use a real nav.
- **Modal carrying a long form.** Long forms deserve their own page (URL, browser history, refreshable).
- **Cards for everything.** Cards work for narrative or unique-layout items; tables work for dense comparable data. Use both, in their right places.
- **Hover-only revealed actions.** Keyboard users can't hover. Touch users can't hover. Always-visible or click-revealed.
- **Toast for an error that needs action.** Errors with required action belong inline or in a persistent banner.
- **Skeleton everywhere.** Skeleton is for known-structure moderate waits. Use a spinner for short indeterminate; use a progress bar when you can estimate.
- **Two-tier navigation that disagree.** When a sidebar and a top nav cover overlapping destinations, users get confused about authority. Pick one.
- **Breadcrumbs in a flat app.** If your app is two levels deep, breadcrumbs add noise. Reserve for genuine hierarchies.
- **Sortable headers without aria-sort.** Sighted users see the arrow; AT users get nothing. Update `aria-sort` on click.
- **Bottom-sheet without a button to close.** Swipe-only is inaccessible. Always provide a close button.

## Bibliography

- WAI-ARIA Authoring Practices Guide (APG) — W3C.
- GOV.UK Design System — UK Government Digital Service.
- Fluent 2 Design — Microsoft.
- Human Interface Guidelines — Apple.
- Material Design 3 — Google.
- "Top 10 Application-Design Mistakes" — Nielsen Norman Group.
- "Designing Data Tables" — Andrew Coyle (also referenced by NN/g).
- "Wait Patterns" / "Skeleton Screens" / "Loading Indicators" — Fluent and Material.
