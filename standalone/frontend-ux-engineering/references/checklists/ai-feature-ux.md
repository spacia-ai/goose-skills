# Checklist — AI feature UX

The four-question test, expanded into a copy-into-PR checklist. If a planned AI feature can't pass this list, defer or rescope it.

## The four-question test

For every AI feature surface:

- [ ] **Capability legibility** — can the user predict what this AI does and doesn't do, in one sentence each, before trying it?
- [ ] **User control** — can the user stop, override, edit, and undo the AI's output?
- [ ] **Explanation** — can the user inspect the AI's sources, reasoning, or confidence?
- [ ] **Correction** — can the user fix wrong output, and does the system respect the correction?

A "yes" to all four is the minimum bar.

## Capability legibility

- [ ] **Feature name describes scope.** "Drafts a reply based on the original message" beats "Smart Reply".
- [ ] **Suggestive empty state** with example queries or use cases.
- [ ] **Limitations stated inline.** "Won't work for: handwritten documents, scanned PDFs without OCR, languages other than English."
- [ ] **Surface placement matches friction.** Refactor button on a code block, summarize button on a thread, draft button on a reply form. Not a global "AI assistant" sidebar that detaches from the task.
- [ ] **No vague hype words.** "Magic", "Genius", "AI-powered", "Smart" — replace with specific verbs.

## User control

- [ ] **Stop button** for long-running AI processes (image generation, multi-step agents, large summarizations).
- [ ] **Reject / dismiss** for AI suggestions that are auto-displayed.
- [ ] **Edit** the AI's output as a starting point.
- [ ] **Undo** any AI-driven change to user data or state.
- [ ] **Regenerate / try again** to see alternative outputs.
- [ ] **Opt out / disable.** A real off switch in settings, not "ignore the suggestion."
- [ ] **Don't auto-accept suggestions.** AI proposes; user accepts.

## Explanation

- [ ] **Sources** when the AI cites information. Link inline (RAG-based chat shows passages from the original documents).
- [ ] **Reasoning** when the AI makes a recommendation. "We recommend X because A, B, and C."
- [ ] **Confidence** when the AI is uncertain. "High / Medium / Low" or a calibrated percentage. Don't fake confidence.
- [ ] **Provenance** of inputs. "Based on your last 30 messages." "Based on your account history."
- [ ] **No silent behavior changes.** If the AI is doing something different today than yesterday (model swap, prompt change), users see this.

## Correction

- [ ] **Fix mechanism.** Edit text, choose alternative, retry with adjusted parameters.
- [ ] **Feedback persistence.** A typed correction or thumbs-down that the user can see and reference later.
- [ ] **System learns or respects.** If the user corrects "Dr. Sara Chen" to "Sarah Chen", subsequent outputs use "Sarah Chen."
- [ ] **Repeat-correction tracking.** Users correcting the same kind of error multiple times = system isn't learning. Surface this internally.

## Outcome metrics defined

Before shipping:

- [ ] **Resolution rate** — % of AI-initiated tasks that complete without escalation. Target depends on use case.
- [ ] **Acceptance rate** — % of AI suggestions accepted as-is.
- [ ] **Edit-after-accept rate** — % of accepted suggestions then edited. (High = AI is close but not right.)
- [ ] **Escalation rate** — % escalated to human / non-AI / abandoned.
- [ ] **Confidence-mismatch rate** — high-confidence outputs that are wrong, or low-confidence outputs that turn out right. Recalibrate when this drifts.
- [ ] **Time-to-acceptance** — long times suggest poor explanation.
- [ ] **Repeat-correction rate** — should trend down over weeks.
- [ ] **Opt-out rate** — should trend down over time. Rising = users actively rejecting.

## Failure mode

- [ ] **Defined non-AI path.** When the AI doesn't know, can't connect, or returns dangerously wrong output, the user has a defined non-AI flow.
- [ ] **AI feature is not load-bearing for the product to work.** When the AI is down or rate-limited, the product still works.
- [ ] **Explicit "I don't know."** Better than fabrication. The AI says when it doesn't have the data.
- [ ] **Refusal is graceful.** "I can't help with that, but here's what I can do" — not a generic error or a hostile refusal.

## Privacy and data

- [ ] **Just-in-time disclosure** of AI processing at the point of use. "Your message is processed by our AI to suggest replies. Replies are not stored beyond this session."
- [ ] **Opt-in to model training**, not opt-out. User content used for training requires affirmative consent.
- [ ] **Data retention** clear: how long inputs are stored, when deleted.
- [ ] **Third-party AI providers disclosed.** If the LLM is via OpenAI / Anthropic / Google, say so. Users have the right to know.
- [ ] **Sensitive data handling.** Specify what's sent to the AI: redaction, masking, or just the user's own content.

## Accessibility (AI-specific)

- [ ] **AI-generated UI is accessible** — same WCAG 2.2 AA standards apply.
- [ ] **Screen-reader announces AI output** via `aria-live="polite"` regions.
- [ ] **Voice and dictation users can drive the AI feature** with the keyboard equivalents — not just point-and-click.
- [ ] **Reduced-motion respected** for AI animations (typing dots, generative reveal, etc.).

## Common AI UX anti-patterns

- **Chatbot on every page.** Most tasks aren't conversational. Place AI where the friction is.
- **No way to stop a long-running AI process.**
- **AI suggestion auto-accepted.** User finds out only when something is wrong.
- **AI feature with no off switch.** Some users will never want it.
- **Confidence theatrics.** Random "78%" labels with no methodology.
- **Promotional language masking limitations.** "Magical", "knows what you need." Trust erodes.
- **No documented failure mode.** When the AI fails, the user is on their own.
- **AI is the only path.** When AI breaks, the product breaks.
- **No feedback mechanism.** User can't report bad output, and bad output keeps coming.
- **Personalization with no transparency.** "Recommended for you" with no "why" — especially wrong when the AI gets it wrong.

## Decision rule

If a planned AI feature fails any of:

- The four-question test.
- Outcome metrics defined.
- Failure mode defined.
- Privacy and data clarity.

…**defer or rescope** the feature. Shipping AI-incomplete features generates more user mistrust than not shipping AI at all.

## Bibliography

- "Guidelines for Human-AI Interaction" — Microsoft Research (the 18 guidelines).
- "People + AI Guidebook" — Google PAIR.
- See `domains/ai-ux.md` for the full reasoning behind these checks.
