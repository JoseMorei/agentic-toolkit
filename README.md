# Agentic Toolkit for On-Call

A helper kit that lets an AI assistant (Claude Code) **look into an incident for you** when something breaks in
production, so the person on call starts from a clear summary instead of a blank screen.

> **In one sentence:** when an alert wakes someone up at 3 a.m., this kit lets the AI quickly gather the facts
> (what is broken, what changed recently, and where to look first) without being able to change anything.

---

## Why this exists

Being "on call" means you are the person who gets paged when a system has a problem. The first 15 minutes are
usually the hardest: you have to open five different tools, remember where everything lives, and piece the story
together while under pressure.

This kit gives the AI assistant **safe, read-only access** to those same tools and a set of written checklists
(called *skills*) for how to investigate. You ask a question in plain English, and it does the legwork:

- "What is this alert about?"
- "Did anyone change something in the last few hours?"
- "Is the app crashing, and why?"
- "Write me a short summary I can share with my team."

You stay in charge. The AI collects and explains; **people make the decisions.**

---

## What it can look at

The AI connects to each tool through a small connector called an **MCP server**. Think of it as a plug that lets
the AI read from one tool in a controlled way.

| Tool | What it is (simply) | What the AI uses it for |
|---|---|---|
| **PagerDuty** | The alarm system that pages the on-call person | Read the alert, its history, and who is on call |
| **GitHub** | Where the code and its changes live | See recent code changes that might have caused the problem |
| **env0** | The system that applies infrastructure changes | See recent infrastructure deployments and their logs |
| **IBM Cloud** | The cloud where some systems run | Look at networks, servers, and storage settings |

It can also run **read-only Kubernetes commands** (Kubernetes is the system that runs the applications) to check
whether apps are healthy, but only commands that *look*, never commands that *change*.

---

## Safety first: it can look, but it cannot touch

This is the most important part of the design. The kit is **read-only on purpose**:

- **PagerDuty:** it can read incidents, but it is blocked from acknowledging, resolving, or creating anything.
- **GitHub:** it runs in GitHub's official *read-only mode*, so it cannot open, merge, or edit anything.
- **env0:** it can read deployments and logs, but it is blocked from deploying, approving, aborting, or cancelling.
- **IBM Cloud:** the connector used here only has "list" and "show" abilities.
- **Kubernetes:** only commands like `get`, `describe`, and `logs` are allowed. Commands like `delete`, `apply`,
  `edit`, `scale`, or `restart` are blocked.

These rules live in one file, [`.claude/settings.json`](.claude/settings.json), so anyone can read exactly what
is allowed and what is not.

---

## What is inside

```
agentic-toolkit/
├── README.md                  ← you are here
├── .mcp.json                  ← the four connectors (PagerDuty, GitHub, env0, IBM Cloud)
├── .claude/
│   ├── settings.json          ← the safety rules (what the AI may and may not do)
│   └── skills/                ← the investigation checklists
│       ├── incident-triage/   ← "start here" when an alert fires
│       ├── what-changed/      ← find recent code and infrastructure changes
│       ├── kubernetes-health/ ← check whether apps are running properly
│       └── incident-summary/  ← write a clear, shareable summary
├── .env.example               ← the list of keys you need (no real secrets in here)
└── scripts/
    ├── check-setup.sh         ← checks that everything is installed and ready
    └── build-ibm-vpc-mcp.sh   ← builds the IBM Cloud connector on your computer
```

---

## What you need before you start

1. **Claude Code** installed on your computer.
2. **Docker** installed and running (the GitHub, env0, and IBM Cloud connectors run inside Docker).
3. **kubectl**, if you want the Kubernetes checks.
4. An **access key for each tool** you want to connect. Create keys with the smallest permissions possible,
   ideally read-only:
   - PagerDuty: a *User API key*
   - GitHub: a *fine-grained personal access token* with read-only permissions
   - env0: an *API key and secret*, plus your *organization ID*
   - IBM Cloud: an *API key* with viewer access to VPC

You don't need all four. Any connector without a key simply won't work, and the others carry on.

---

## Setup, step by step

**1. Download the project**

```bash
git clone https://github.com/JoseMorei/agentic-toolkit.git
cd agentic-toolkit
```

**2. Add your keys**

Copy the example file and fill in your own keys. This file stays on your computer and is never uploaded
(it is listed in `.gitignore`).

```bash
cp .env.example .env
# open .env in any text editor and paste your keys
```

**3. Build the IBM Cloud connector** (only if you use IBM Cloud)

```bash
./scripts/build-ibm-vpc-mcp.sh
```

**4. Check that everything is ready**

```bash
./scripts/check-setup.sh
```

It tells you, in plain words, what is installed, what is missing, and which keys are set. It never prints the keys
themselves.

**5. Start Claude Code with your keys loaded**

```bash
set -a; source .env; set +a
claude
```

The first time, Claude Code asks whether you trust the connectors in this folder. Say yes.

---

## How to use it

Just ask, in your own words. A few examples:

- *"Triage PagerDuty incident Q1ABC2DEF3."*
- *"What changed in the last 6 hours on the `checkout-service` repo and in env0?"*
- *"Check the health of the pods in the `payments` namespace."*
- *"Write an incident summary for the team channel."*

The AI picks the right checklist (skill) on its own, or you can call one directly, for example
`/incident-triage`.

A typical flow:

1. **Triage**: read the alert and figure out which system is affected.
2. **What changed**: look for recent code merges and infrastructure deployments around that time.
3. **Health check**: see whether the app is crashing, out of memory, or stuck.
4. **Summary**: a short write-up of what happened, what was checked, and what to try next.

---

## Frequently asked questions

**Can the AI fix the problem by itself?**
No, and that is deliberate. It investigates and suggests. A person reviews the suggestion and makes any change
through the normal process.

**Is my data sent anywhere?**
The connectors talk directly to PagerDuty, GitHub, env0, and IBM Cloud using your own keys. Claude Code sends what
it reads to the AI model to reason about it, as with any use of Claude Code. Follow your company's rules on what
data may be shared with AI tools.

**What if I only use some of these tools?**
That's fine. Fill in only the keys you have.

**Can I add more checklists?**
Yes. Each skill is a plain text file in `.claude/skills/<name>/SKILL.md`. Copy one, rename it, and describe the
steps in plain English.

---

## Credits

The connectors are built and maintained by their owners:

- [GitHub MCP Server](https://github.com/github/github-mcp-server) (official, by GitHub)
- [PagerDuty MCP Server](https://support.pagerduty.com/main/docs/pagerduty-mcp-server) (official, hosted by PagerDuty)
- [env0 MCP Server](https://github.com/env0/mcp-server) (official, by env0)
- [IBM Cloud VPC MCP Server](https://github.com/greyhoundforty/ibmcloud-vpc-mcp) (community project, listed in
  [IBM's MCP catalog](https://github.com/IBM/mcp); not an official IBM product)

## Disclaimer

This is an independent personal project, written from scratch. It is not affiliated with, endorsed by, or derived
from any employer's internal tools. Use it at your own risk, and always follow your organization's security and
change-management policies.
