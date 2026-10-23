---
name: incident-summary
description: Writes a short, clear incident summary that non-specialists can read, for a team channel, a handoff to the next on-call person, or the start of a post-incident review. Use when someone asks for a summary, an update, a handoff note, or a postmortem draft.
argument-hint: [audience: team | handoff | postmortem]
---

# Incident summary

Turn what was found during the investigation into a summary that **anyone on the team can understand in under a
minute**. Use plain words, explain any technical term the first time you use it, and keep it short.

## Rules

- Stick to facts gathered in this conversation. Mark anything uncertain as "suspected" or "unconfirmed".
- No secrets, keys, tokens, customer names, or personal data.
- Use times with a time zone.
- No blame. Describe what happened to systems, not who made a mistake.

## Formats

**Team update** (default)

```
Status: investigating | mitigated | resolved
What's happening: <1–2 sentences anyone can understand>
Impact: <who or what is affected, and how badly>
Since: <time, time zone>
What we know: <2–4 bullets>
Next step: <what happens next, and who is doing it>
```

**Handoff to the next on-call person**

Add: what was already tried (and the result), what to watch, and when to escalate.

**Post-incident review draft**

```
Summary, Timeline, Impact, Root cause (or "under investigation"),
What went well, What didn't, Follow-up actions (each with an owner placeholder)
```

When you finish, ask whether the person wants it shorter, more technical, or in another format.
