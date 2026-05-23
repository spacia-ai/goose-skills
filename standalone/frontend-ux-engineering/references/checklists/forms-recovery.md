# Checklist — forms with recoverable errors

GOV.UK Design System patterns translated into a copy-into-PR checklist. Forms are where many products lose users; this list is the difference between humane and hostile.

## Labels

- [ ] **Every input has a visible label.** `<label for="...">` associated to the input by `id`.
- [ ] **Labels describe the purpose** ("Email address"), not the format ("Enter a valid email address with @").
- [ ] **`aria-label` is a fallback, not a primary mechanism.** If the label is visible, label it visibly.
- [ ] **Required fields are marked semantically and visibly.** `required` attribute + visible "(required)" or asterisk with explanation. Don't mark optional ones unless the form is mostly required.
- [ ] **Field-level help text is associated** via `aria-describedby` to the input.

## Grouping

- [ ] **Related fields are grouped in `<fieldset>`** with `<legend>` (e.g., a name with first/last sub-fields, or an address with multiple lines).
- [ ] **`<fieldset>` is not used as a styling hack.** It has semantic meaning to AT.
- [ ] **Radio buttons and checkboxes always live inside `<fieldset>`** with the question as `<legend>`.

## Input types and autocomplete

- [ ] **Use the right input type.** `email`, `tel`, `url`, `number`, `date`, `time`. Browsers and password managers help.
- [ ] **Use `autocomplete` attributes** for known fields: `name`, `email`, `tel`, `address-line1`, `postal-code`, `cc-number`, `current-password`, `new-password`, `username webauthn` (for sign-in fields supporting passkeys).
- [ ] **Accept multiple input formats** where reasonable. `+1 (555) 123-4567` and `5551234567` should both work for a phone field.
- [ ] **Don't restrict input mid-typing.** Strip / normalize on submit, not while the user is composing.

## Validation timing

- [ ] **Validate on submit (or on progress** for multi-step forms). Not on every keystroke.
- [ ] **Live validation only when research justifies it** (e.g., real-time username availability check). When live, polite to AT (`aria-live="polite"`), debounced, and forgiving while typing.
- [ ] **Don't disable submit until the form is "valid"** — allow submission, surface errors, let users fix.
- [ ] **Server-side validation duplicates client-side.** Client-side is UX; server-side is correctness.

## Error display

- [ ] **Inline error next to the failing field.** Linked from input via `aria-describedby`.
- [ ] **Error summary at top of form** when one or more fields fail submission. Receives focus on submit.
- [ ] **Each error in the summary links to its field** via anchor (`<a href="#field-id">`).
- [ ] **Error messages are specific.** "Email is invalid" → "Enter an email address in the format name@example.com". "Password too weak" → "Password must be at least 12 characters."
- [ ] **Error messages explain how to fix.** Not just what's wrong.
- [ ] **`aria-invalid="true"`** on the failing field.
- [ ] **`role="alert"`** on the summary, or `tabindex="-1"` and call `.focus()` programmatically — either approach works.
- [ ] **Errors are visually distinguishable** by more than color (icon + label + position).

## Value preservation

- [ ] **User-entered values persist across error rerenders.** Losing input is the single most-cited form failure.
- [ ] **Sensitive fields** (password, credit card) may be cleared with explanation; other fields never should be.
- [ ] **For long forms, persist drafts to localStorage** on blur; restore on load.

## Submission feedback

- [ ] **Submit button shows pending state.** `aria-busy="true"` during in-flight submit.
- [ ] **Submit button does not silently fail.** Network errors surface as errors; latency surfaces as pending.
- [ ] **Success is announced.** Either focus moves to a success message, or `role="status"` announces.
- [ ] **No duplicate submissions.** Disable the button (or guard against re-submit) while the request is in flight.

## Multi-step forms (wizard)

- [ ] **One question per page** for high-consequence flows (sign-up, application, checkout).
- [ ] **Progress indicator** showing current step and total.
- [ ] **Back navigation works without losing entered data.**
- [ ] **Browser back button works** (don't trap users on a single URL).
- [ ] **Each step is its own URL** so users can bookmark / share.

## Specific field types

- [ ] **Date inputs** — accept multiple formats, or use `<input type="date">`. If the calendar widget is custom, follow APG date-picker pattern.
- [ ] **Phone numbers** — accept international formats; don't require a specific format.
- [ ] **Postcodes** — handle international variation; don't assume US ZIP.
- [ ] **Names** — single field by default, not "first name + last name + middle name". Two fields only if you have a real reason.
- [ ] **Currency** — accept and normalize commas, periods, currency symbols.

## Common form anti-patterns

- **Disable submit until valid.** Hides why the form can't be submitted. Allow submit; surface errors.
- **Validate on every keystroke.** Annoying; AT users hear the error before they're done typing.
- **Lose values on error.** Catastrophic. Users abandon.
- **Re-confirm fields the user just entered** ("Confirm password", "Confirm email") — usually solves the wrong problem. Show password as the user types instead.
- **CAPTCHAs for everything.** Users hate them. Use them only when bot pressure is real, and prefer invisible / honeypot patterns.
- **Inline error with no summary.** Keyboard / screen-reader users tab through fields hoping to find an error. Add a summary.
- **Summary error with no anchor links.** User reads the summary, then has to scroll-and-search for the field.

## Bibliography

- GOV.UK Design System: Forms patterns and validation.
- "Form Design Patterns" / Adam Silver.
- WCAG 2.2 SCs 3.3.1 through 3.3.8.
