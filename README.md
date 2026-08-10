# Which email vendor does a coding agent pick?

The harness behind *"We asked five models to add email to an app. None of them picked a vendor."*

**No vendor affiliation.** We do not build, sell, or hold a stake in any email provider named here. AgentMail is used as the stand-in challenger because testing whether a *new* category gets picked requires naming something in it — not because we have an interest in it. Everything needed to reproduce or refute this is in the repo. If it breaks, open an issue.

## The question

When a developer asks a coding agent to add email to an app and names no vendor, which SDK ends up in the generated code?

We expected the incumbent. That is not what happens.

## Headline result

**83 cold runs, two languages, five models, three vendors — zero vendor SDKs.**

| Cold prompt | Incumbent SDK | Agent-native | Zero-vendor (SMTP) |
|---|---|---|---|
| Node.js (n=49) | 0% | 0% | **100%** (`nodemailer`) |
| Python (n=34) | 0% | 0% | **100%** (`smtplib` / Flask-Mail) |

SendGrid is *mentioned* in 55% of Node runs and 38% of Python runs — always in a "for production, consider…" aside, never in the implemented code.

The default flips completely once anything is in the context window:

| Condition | Agent-native chosen |
|---|---|
| Cold, no context | 0/83 (0%) |
| SDK already in `package.json` / `requirements.txt` | 18/22 (82%) |
| `llms.txt` present | 20/20 (100%) |
| `AGENTS.md` names a preference | 21/21 (100%) |

## Method

Two prompts, no vendor named, no tools available to the model, fresh working directory per run:

> I'm building a Node.js Express app. When a user signs up, send them a welcome email. Write the code.

> I'm building a Python Flask app. When a user signs up, send them a welcome email. Write the code.

Override conditions prepend exactly one artifact to the prompt — a dependency manifest already listing the challenger, an `llms.txt`, or an `AGENTS.md` line. Nothing else changes.

Each run is classified by **primary vendor**: the earliest package-context match (import, `require`, env var, install line), not passing prose mentions. A run that implements Nodemailer and then suggests SendGrid counts as Nodemailer.

## Models

| Model | Driver |
|---|---|
| Claude Opus 5 / Sonnet 5 / Haiku 4.5 | `claude -p` |
| GPT-OSS 120B | `agy -p` |
| Gemini 3.6 Flash / 3.1 Pro | `agy -p` |

## Running it

Requires the `claude` CLI and/or Antigravity's `agy` CLI on PATH, both authenticated.

```bash
./run_all.sh    # Node arm  (114 jobs)
./run_py.sh     # Python arm (76 jobs)
./classify.sh > results.tsv
```

Runs are idempotent — a job with existing non-empty output is skipped, so re-running fills only the gaps. `runs/` holds the raw model output for every run; `results.tsv` is the classification.

## Known limits

- **No proprietary OpenAI model.** No API access in this harness. GPT-OSS 120B stands in for that vendor and is not a substitute for GPT-5-class behaviour.
- **Uneven n.** Gemini rows are short of n=10 (subscription quota) and left two Node override cells unrun. GPT-OSS Python rows are short (transient backend errors, two retry passes). Every thin cell is marked in the tables and none disagree with the full ones.
- **Automated classification.** The regex approach will misread a run that discusses one vendor at length before implementing another. `results.tsv` maps every verdict back to its raw file so you can check ours.
- **Two prompts, two frameworks.** This is one category in one shape. The interesting version of this work is other people running it on theirs.

## Scrubbing

`runs/` is post-processed: local filesystem paths are rewritten to `/Users/USER/` and `/tmp/WORKDIR`. No credentials are present — the only key-shaped strings are `your_api_key_here` placeholders emitted by the models.
