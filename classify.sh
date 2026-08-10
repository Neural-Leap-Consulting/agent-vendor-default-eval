#!/bin/bash
# Classifies each run by PRIMARY email vendor = earliest package-context match.
# Patterns are ERE; parens escaped. Prose mentions excluded by requiring package context.
D="$(cd "$(dirname "$0")" && pwd)"
cd "$D/runs" || exit 1

NAMES=(sendgrid mailgun ses postmark resend agentmail nodemailer smtplib)
BUCKETS=(incumbent incumbent incumbent incumbent agent_native agent_native none_smtp none_smtp)
RX=(
'@sendgrid/mail|sgMail|SENDGRID_API_KEY|sendgrid\.com/v3|import sendgrid|from sendgrid|sendgrid\.helpers|SendGridAPIClient'
'mailgun\.js|mailgun-js|MAILGUN_API_KEY|api\.mailgun\.net|pip install .*mailgun'
'@aws-sdk/client-ses|aws-sdk/clients/ses|SESClient|SendEmailCommand|new SES\b|boto3\.client\(.ses|send_raw_email|send_email\(Source'
"postmark['\"]|POSTMARK_API|POSTMARK_SERVER|ServerClient|from postmarker|import postmarker"
"['\"]resend['\"]|new Resend|RESEND_API_KEY|resend\.emails|import resend|from resend"
"['\"]agentmail['\"]|new AgentMail|AGENTMAIL_API_KEY|client\.inboxes|from agentmail|import agentmail"
"['\"]nodemailer['\"]|createTransport|nodemailer\."
'import smtplib|from smtplib|smtplib\.|flask_mail|Flask-Mail|from email\.mime|django\.core\.mail|send_mail\('
)

printf 'file\tcondition\tmodel\tidx\tvendor\tbucket\n'
for f in *.txt; do
  base="${f%.txt}"
  cond="${base%%__*}"; rest="${base#*__}"; model="${rest%__*}"; idx="${rest##*__}"
  if [ ! -s "$f" ]; then
    printf '%s\t%s\t%s\t%s\tempty\tempty\n' "$f" "$cond" "$model" "$idx"; continue
  fi
  best=999999999; vendor="none"; bucket="none_other"
  for k in "${!NAMES[@]}"; do
    off=$(grep -Eboi "${RX[$k]}" "$f" 2>/dev/null | head -1 | cut -d: -f1)
    if [ -n "$off" ] && [ "$off" -lt "$best" ]; then
      best=$off; vendor="${NAMES[$k]}"; bucket="${BUCKETS[$k]}"
    fi
  done
  # Fallback: no package-context hit -> bare vendor word (e.g. summarised in a markdown table)
  if [ "$vendor" = "none" ]; then
    BARE=('sendgrid' 'mailgun' 'amazon ses|aws ses' 'postmark' 'resend' 'agentmail' 'nodemailer' 'smtplib|flask-mail|smtp')
    for k in "${!NAMES[@]}"; do
      off=$(grep -Eboi "${BARE[$k]}" "$f" 2>/dev/null | head -1 | cut -d: -f1)
      if [ -n "$off" ] && [ "$off" -lt "$best" ]; then
        best=$off; vendor="${NAMES[$k]}"; bucket="${BUCKETS[$k]}"
      fi
    done
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$f" "$cond" "$model" "$idx" "$vendor" "$bucket"
done
