---
name: incident-triage
description: Start here when an alert fires. Reads a PagerDuty incident, works out which system is affected, checks what changed recently and whether the app is healthy, then reports findings. Use when someone says "triage", gives a PagerDuty incident ID or link, or asks "what is this alert about?".
argument-hint: <pagerduty-incident-id-or-url>
---

# Incident triage

Goal: in a few minutes, turn an alert into a short, evidence-backed picture of **what is broken, since when, and
the most likely cause**. You investigate and explain. You never change anything.

## Ground rules

- **Read-only.** Never acknowledge, resolve, or reassign the incident, and never run commands that modify systems.
  If a fix seems obvious, *suggest* it and let the human decide.
- **Evidence over guesses.** Every claim in your report should point to what you looked at (an alert field, a
  PR, a deployment, a command output). Say "unknown" when you don't know.
- **Timestamps matter.** Always note the time zone, and compare everything against the incident's start time.

## Steps

1. **Read the incident (PagerDuty).**
   - Get the incident: title, service, urgency, status, start time, and the alert details.
   - Look at past and related incidents for the same service. Has this fired before? How was it resolved?
   - Note who is on call for the service.

2. **Name the affected system.** From the alert, write down the service, environment, and (if present) the
   cluster, namespace, or cloud resource. If it's unclear, say so and list the candidates.

3. **Check what changed.** Use the `what-changed` skill for a window of about 6 hours before the incident start:
   merged code changes (GitHub) and infrastructure deployments (env0).

4. **Check health.** If the system runs on Kubernetes, use the `kubernetes-health` skill for the affected
   namespace. If it involves IBM Cloud networking or storage, look up the relevant VPC, subnet, security group,
   or volume.

5. **Report.** Reply with this structure:

   ```
   What's happening:   one or two plain sentences
   Since:              <start time, with time zone>
   Affected:           <service / environment / resource>
   Most likely cause:  <your best explanation> (confidence: low / medium / high)
   Evidence:           bullet list of what you checked and what you found
   Recent changes:     bullet list, or "none found in the window"
   Suggested next step: one concrete, safe action for a human to take
   Still unknown:      what you could not confirm
   ```

6. **Offer a summary.** Ask whether the person wants an `incident-summary` for the team channel.
