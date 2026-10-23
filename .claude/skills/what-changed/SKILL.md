---
name: what-changed
description: Finds recent code and infrastructure changes that could explain a problem. Looks at merged pull requests in GitHub and deployments in env0 within a time window. Use when someone asks "what changed?", "did anyone deploy?", or during incident triage.
argument-hint: [repo or service] [time window, e.g. "last 6h"]
---

# What changed?

Most incidents start with a change. Your job is to list the changes that happened **shortly before the problem
started** and point out which ones are most likely related.

## Steps

1. **Agree on the window.** Default to the 6 hours before the incident started. If no start time is given, use
   the last 6 hours and say so.

2. **Code changes (GitHub).**
   - For the repositories involved, list pull requests **merged** in the window: title, author, merge time, link.
   - Note recent releases or tags.
   - Flag changes that touch configuration, dependencies, infrastructure, or the failing component.

3. **Infrastructure changes (env0).**
   - List deployments in the window for the related projects and environments: what was deployed, by whom, when,
     and whether it succeeded.
   - For failed or suspicious deployments, read the plan or deployment logs and summarize the error in plain words.

4. **Rank the suspects.** Order changes from most to least likely to be related, and explain why in one line each
   (timing, what they touched, error messages).

## Output

```
Window: <from> → <to> (<time zone>)

Most likely related:
- <change> — <why>

Other changes in the window:
- <change>

Nothing found in: <tools or repos you checked that had no changes>
```

Never revert, re-run, approve, or cancel anything. If rolling back looks right, recommend it to the human.
