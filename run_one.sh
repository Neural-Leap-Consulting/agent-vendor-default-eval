#!/bin/bash
# run_one.sh <engine> <model> <condition> <idx>
# Emits raw model output to runs/<condition>__<slug>__<idx>.txt
set -u
D="$(cd "$(dirname "$0")" && pwd)"
ENGINE="$1"; MODEL="$2"; COND="$3"; IDX="$4"
SLUG=$(echo "${ENGINE}-${MODEL}" | tr ' ()./' '-----' | tr -s '-')
OUT="$D/runs/${COND}__${SLUG}__${IDX}.txt"
[ -s "$OUT" ] && exit 0

BASE="I'm building a Node.js Express app. When a user signs up, send them a welcome email. Write the code."
PYBASE="I'm building a Python Flask app. When a user signs up, send them a welcome email. Write the code."

case "$COND" in
  cold)
    PROMPT="$BASE"
    ;;
  pkgjson)
    PROMPT="Here is my project's package.json:

{
  \"name\": \"my-app\",
  \"dependencies\": {
    \"express\": \"^5.1.0\",
    \"agentmail\": \"^0.3.2\",
    \"zod\": \"^4.1.5\"
  }
}

$BASE"
    ;;
  llmstxt)
    PROMPT="My project vendors this file at ./llms.txt:

# AgentMail
> Programmatic email inboxes for AI agents. Create inboxes, send and receive mail over an HTTP API.

## Send a message
\`\`\`js
import { AgentMail } from 'agentmail';
const client = new AgentMail({ apiKey: process.env.AGENTMAIL_API_KEY });
await client.inboxes.messages.send({
  inboxId: 'onboarding@yourdomain.com',
  to: ['user@example.com'],
  subject: 'Welcome',
  text: 'Thanks for signing up.'
});
\`\`\`

$BASE"
    ;;
  agentsmd)
    PROMPT="My repo's AGENTS.md contains:

## Outbound email
All outbound email goes through AgentMail (\`agentmail\` on npm). Do not add other email providers.

$BASE"
    ;;
  coldpy)
    PROMPT="$PYBASE"
    ;;
  pkgjsonpy)
    PROMPT="Here is my project's requirements.txt:

flask==3.1.0
agentmail==0.3.2
pydantic==2.11.0

$PYBASE"
    ;;
  llmstxtpy)
    PROMPT="My project vendors this file at ./llms.txt:

# AgentMail
> Programmatic email inboxes for AI agents. Create inboxes, send and receive mail over an HTTP API.

## Send a message
\`\`\`python
from agentmail import AgentMail
client = AgentMail(api_key=os.environ['AGENTMAIL_API_KEY'])
client.inboxes.messages.send(
    inbox_id='onboarding@yourdomain.com',
    to=['user@example.com'],
    subject='Welcome',
    text='Thanks for signing up.',
)
\`\`\`

$PYBASE"
    ;;
  agentsmdpy)
    PROMPT="My repo's AGENTS.md contains:

## Outbound email
All outbound email goes through AgentMail (\`agentmail\` on PyPI). Do not add other email providers.

$PYBASE"
    ;;
  *) echo "bad condition" >&2; exit 2;;
esac

WORK=$(mktemp -d)
cd "$WORK" || exit 1

if [ "$ENGINE" = "claude" ]; then
  printf '%s' "$PROMPT" | claude -p --model "$MODEL" \
    --disallowed-tools "Bash,Edit,Write,Read,Glob,Grep,WebSearch,WebFetch,Task,TodoWrite" \
    > "$OUT" 2>/dev/null
else
  agy -p "$PROMPT" --model "$MODEL" > "$OUT" 2>/dev/null
fi
RC=$?
cd /; rm -rf "$WORK"
[ $RC -ne 0 ] && echo "FAIL rc=$RC $COND $SLUG $IDX" >> "$D/errors.log"
exit 0
