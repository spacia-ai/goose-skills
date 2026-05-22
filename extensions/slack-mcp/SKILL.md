---
name: slack-mcp
description: Operator's manual for the Slack MCP — sending messages, fetching context, threads. Approval rules for outbound posts.
extensions:
  - slack
requires:
  - slack
tags:
  - slack
  - communication
  - extension-skill
min_goose_version: "1.33.0"
---

# Slack MCP Operator's Manual

The Slack MCP exposes channel / DM / thread operations. Tools are prefixed
`slack__*`.

## Cardinal rules

1. **Every outbound post requires user approval.** Don't `slack__send_message`
   without the user explicitly asking you to send the exact message text you
   intend to send.
2. **Confirm the channel before posting.** "Send to general" is ambiguous —
   `#general` in which workspace? Ask if unclear.
3. **Default to threading.** If continuing a discussion, post in the existing
   thread, not a new top-level message.

## Read tools (run freely)

```
list_channels(types?)                      → discover what's available
get_channel_history(channel, limit?)       → recent messages
get_thread_replies(channel, thread_ts)     → drill into one conversation
search_messages(query, filters?)           → full-text across what you can see
get_user_info(user_id)                     → resolve a mention
```

## Write tools (always require approval)

```
send_message(channel, text)                       → top-level post
reply_in_thread(channel, thread_ts, text)         → preferred for conversations
react_to_message(channel, ts, emoji)              → small ack
update_message(channel, ts, text)                 → edit your own prior post
```

## Drafting pattern

When the user asks "tell the team that X":

1. **Draft the message body in chat first.** Don't call `send_message`.
2. **Show the draft.** Mention the target channel + thread (if any) + the
   exact text.
3. **Wait for explicit go-ahead.** "Ship it", "yes", "looks good", etc.
4. **Then call `send_message`.** Surface the confirmation.

## Anti-patterns

- **Don't paraphrase a user's request into the actual message.** If they
  said "ack this", they probably want a 👍 reaction, not a paragraph.
- **Don't @-mention people unless instructed.** Pings are expensive.
- **Don't repost the same content in multiple channels** to "reach more
  people" without explicit instruction. That's spam.
