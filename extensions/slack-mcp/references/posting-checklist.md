# Slack posting checklist

Lazy-load before any `slack__send_message` call. Every outbound post
requires user approval; this is the checklist to run *before* asking
for that approval.

## Pre-post checklist

Before composing a message, verify all five:

1. **Workspace** — which workspace are we posting to? Don't assume.
2. **Channel / DM** — `#general` vs `@username` vs a thread. Confirm
   the exact target.
3. **Thread vs top-level** — if continuing a discussion, post in the
   thread. New top-level posts interrupt the channel feed.
4. **Audience** — who will see this? Public channel = whole org. DM =
   two people. Think about it before drafting.
5. **Tone** — Slack is conversational. Long-form requirements docs
   belong elsewhere; link to them.

## Threading decision tree

```
Is there an existing message this is responding to?
├── Yes → post in that thread (use thread_ts).
└── No  → is this starting a new topic that warrants channel-wide
         visibility?
         ├── Yes → top-level message in the channel.
         └── No  → DM the relevant person directly.
```

When in doubt, thread. Top-level posts in busy channels cost more
attention than they're worth.

## Message structure

- **Lead with the ask or the answer.** Don't bury it under context.
- **One topic per message.** If you have three things, send three
  messages (or one message with three clearly-numbered sections).
- **Use code fences for code**, not bold. Bold for code is unreadable.
- **Link, don't paste.** Linking to a Notion doc / GitHub PR is shorter
  and stays current; pasting goes stale.
- **`@here` and `@channel` are pings.** Only use when the message is
  time-sensitive *and* relevant to that group. Default to no ping.

## When NOT to post

- **You're not sure of the channel.** Ask the user, don't guess.
- **The message contains anything sensitive** — credentials, customer
  data, security findings. Use a private channel or DM.
- **The user asked you to "summarize" not "send".** Default to drafting
  in chat and waiting for explicit "send it".

## Read tools (run freely)

These don't need approval:

- `slack__list_channels` / `slack__list_dms` — discover targets
- `slack__get_channel_history` — read the recent conversation
- `slack__get_thread_replies` — read a thread
- `slack__search_messages` — find prior discussion of a topic

Use these to build context before drafting an outbound post.

## After posting

If the post was wrong (typo, wrong channel), don't just delete —
acknowledge the correction in the same thread/channel. Silent deletes
confuse readers who already saw the original.
