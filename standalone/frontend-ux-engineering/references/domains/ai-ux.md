# Domain — AI UX

AI features change the surface of UX without changing its fundamentals. The strongest pattern is not "add a chatbot." It is: use AI only where it compresses real friction, make capabilities legible, preserve user control, support explanation and correction, and measure outcomes.

## Why AI UX deserves its own domain

In the wave of "let's add AI to the product", a lot of teams ship features that:

- Solve no real friction.
- Hide their capabilities (user doesn't know what to ask).
- Don't respect user control (no stop, no override, no edit).
- Don't explain themselves (sources, reasoning, confidence invisible).
- Don't accept correction (user fixes a wrong answer, the same wrong answer comes back next time).
- Aren't measured (resolution rate, edit-after-accept rate, escalation rate are unknown).

These ship-and-pray AI features generate user mistrust faster than any other UX failure. They turn AI from a value-multiplier into a tax on every user interaction.

This domain is about avoiding that.

## The four-question test

Before adding any AI feature, the user-facing answer to these four questions must exist:

1. **Capability legibility.** What does this AI do? What does it not do? In one sentence each, in the user's mental model. If you can't write this without 200 words of caveat, the feature is not ready.
2. **User control.** Can the user stop, override, edit, or undo what the AI does? Always yes, or the feature is not ready.
3. **Explanation.** When the AI makes a claim, can the user inspect the reasoning, sources, or confidence? "Trust me" is not a UX.
4. **Correction.** When the AI is wrong, can the user fix it? What does the system do with that correction (learn, persist, ignore)?

A "yes" to all four is the minimum bar. A "no" or a hand-wave to any of them is a Critical UX issue.

## When to add AI

Real-friction triggers (good reasons):

- The user has to do tedious comprehension work that the AI can compress (summarize a long thread, extract key dates from an email).
- The user has to translate or transcribe (between languages, between formats, between styles).
- The user has to fill in repetitive boilerplate (emails, forms with predictable fields, code).
- The user has a fuzzy goal that's hard to express in current UI (find products like this one but cheaper, refactor this code without breaking tests).
- The user is overwhelmed with choices and needs guidance (which template, which configuration, which path through a flow).

Bad reasons:

- "AI is the trend, we need an AI feature."
- "Our competitors have it."
- "We have an LLM budget."
- "Add a chatbot." (Chat is rarely the right surface.)

## Designing AI surfaces

### Capability legibility

The user must know — without trying — what the AI can and can't do.

Patterns that work:

- **Contextual placement.** The AI feature lives where the relevant friction is, not in a global "AI assistant" sidebar. Refactor button on a code block, summarize button on a thread, draft button on a reply form.
- **Suggestive empty states.** "Try: 'Summarize my unread'", "Try: 'Find images with my dog from last summer'", "Try: 'Refactor this to use async/await'". Give users specific examples that reveal capability.
- **Clear scope labels.** "Drafts a response based on the original message" — not "Smart Reply".
- **Failure modes documented inline.** "This won't work for: handwritten documents, scanned PDFs without OCR, languages other than English." Set expectations honestly.

Patterns that fail:

- **Free-text chatbox in a dedicated tab** with no example queries. Users don't know what to ask.
- **Vague names.** "Magic", "Genius", "AI Assistant", "Copilot" without scope.
- **Full-page takeovers** that interrupt the actual task.

### User control

The user must always have control. Specifically:

- **Stop.** Long-running AI work (image generation, multi-step agent) needs a stop button that actually stops.
- **Override.** AI suggestion accepted by default? User must be able to reject.
- **Edit.** AI output is a starting point, not a verdict. Users edit text, regenerate alternatives, refine.
- **Undo.** Any AI-driven change is undoable.
- **Opt out.** A user can disable AI features they don't want. Not "you can ignore the suggestion"; an actual off switch.

### Explanation

Without explanation, AI is magic. Magic doesn't earn trust.

Patterns that work:

- **Sources.** When the AI cites information, show the source inline. RAG-based chat shows passages from the original documents.
- **Reasoning.** When the AI makes a recommendation, show why. "We recommend X because A, B, and C."
- **Confidence.** When the AI is uncertain, say so. "High confidence" / "Medium" / "Low" or a percentage. Don't fake confidence.
- **Provenance.** "Based on your last 30 messages" or "Based on your account history". The user knows what data informed the output.

Patterns that fail:

- **Confident fabrication.** AI states things as fact that it cannot verify. The user can't tell true from false.
- **Black-box trust.** "The AI knows best." No, the AI does not.
- **Confidence theatrics.** Random "78%" labels with no methodology. Users see through this fast.

### Correction

When the AI is wrong (it will be), the user must be able to:

- **Fix it.** Edit the output, choose an alternative, retry with different parameters.
- **Inform the system.** A thumbs-down or a typed correction. Persist this where the user can see what they reported.
- **Persist the fix.** If the user corrects a name spelling, the system uses the corrected spelling next time. If the user always rejects a suggestion, the system stops suggesting it.

## Outcome metrics

Measure AI features differently from regular features. The standard product metrics (engagement, retention) are necessary but insufficient.

| Metric | What it measures |
|---|---|
| **Resolution rate** | What % of AI-initiated tasks complete without escalation to a human or to a non-AI flow? |
| **Acceptance rate** | What % of AI suggestions are accepted as-is? |
| **Edit-after-accept rate** | What % of accepted suggestions are then edited? (High edit rate = AI is close but not right.) |
| **Escalation rate** | What % of AI tasks are escalated to a human, a non-AI flow, or abandoned? |
| **Confidence-mismatch rate** | What % of high-confidence AI outputs are wrong? Or low-confidence outputs that turn out right? |
| **Time-to-acceptance** | How long does the user spend evaluating AI output before accepting / rejecting? Long times suggest poor explanation. |
| **Repeat-correction rate** | What % of users correct the same kind of error multiple times? (System isn't learning.) |
| **Opt-out rate** | What % of users who tried the AI feature subsequently disabled it? |

A successful AI feature shows: high resolution, high acceptance, low edit-after-accept, low escalation, calibrated confidence, low repeat-correction. Vanity acceptance numbers without low edit rates mean users accept then re-do.

## Generative UI (GenUI)

Emerging pattern: AI generates the interface, not just content. A chat surface that responds with a custom form, table, or chart depending on the user's question. A dashboard that reflows based on what the user is currently focused on.

Current state (2026): early research showing co-creative iterative design space. Not yet a stable production pattern. Treat as experimental: prototype in low-stakes contexts (educational tools, exploratory dashboards), evaluate with the same rigor as any UI (task completion, accessibility, performance), and don't ship as the only path through a critical flow.

If shipping GenUI, the four-question test still applies. The interface itself becomes a hypothesis the user can edit.

## Common AI UX anti-patterns

- **Chatbot on every page.** Most tasks aren't conversational. Place AI where the friction is.
- **AI suggestion auto-accepted with no review.** The user finds out only when something is wrong.
- **No way to stop a long-running AI process.** "It's been generating for two minutes, why won't it stop?"
- **AI that hides errors.** "Sorry, something went wrong" with no detail. Show what failed and let the user retry.
- **AI evaluation by gut feel.** "It feels good." Without resolution / acceptance / edit-after-accept rates, you don't know.
- **AI feature without an off switch.** Some users will never want it. They should not have to look at it.
- **AI feature that requires the AI to work for the product to work.** When the AI is down or rate-limited, the product breaks. Always have a non-AI path.
- **Personalization with no transparency.** "Recommended for you" with no explanation. Especially wrong when the AI gets it wrong; the user can't correct what they don't see.
- **Confidence theatrics.** "98% confident" on outputs that are obviously fabricated.
- **Promotional language masking limitations.** "Magical", "intelligent", "knows what you need." Set honest expectations or lose trust.

## Common AI research anti-patterns

AI accelerates research; it doesn't replace it.

- **Using AI to summarize user interviews without listening to them.** Subtle signals get lost. AI-extracted themes have a known bias toward what the AI thinks should be there.
- **AI-moderated user testing for diagnostic studies.** AI moderation works for throughput, not for diagnosis. Use AI for unmoderated at scale; humans for moderated when nuance matters.
- **Treating AI synthesis as ground truth.** Always have a human review the AI's clusters and themes before reporting them.
- **Skipping accessibility testing because the AI says it's fine.** AI accessibility checks miss many real issues. Run real keyboard and screen-reader tests.

## Bibliography

- "Guidelines for Human-AI Interaction" — Microsoft Research (the 18 guidelines remain a strong baseline).
- "People + AI Guidebook" — Google PAIR.
- "Generative AI for UX Design" / "Designing AI Experiences" — research and practitioner work, 2024-2026.
- CHI / DIS conference proceedings on generative UI and AI-assisted UX evaluation, 2024-2026.
- "Generative UI" — primary research from HCI venues; treat as emerging.
- "Trust in AI" — Nielsen Norman Group articles, 2024-2026.
