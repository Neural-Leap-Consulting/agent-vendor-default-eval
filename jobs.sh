#!/bin/bash
# Emits the job list: engine<TAB>model<TAB>condition<TAB>idx
N_COLD=10
N_COND=6

COLD_MODELS=(
"claude	opus"
"claude	sonnet"
"claude	haiku"
"agy	Gemini 3.1 Pro (Low)"
"agy	Gemini 3.6 Flash (Medium)"
"agy	GPT-OSS 120B (Medium)"
)

# One model per vendor for the override conditions
COND_MODELS=(
"claude	sonnet"
"agy	Gemini 3.1 Pro (Low)"
"agy	GPT-OSS 120B (Medium)"
)

for m in "${COLD_MODELS[@]}"; do
  for i in $(seq 1 $N_COLD); do printf '%s\tcold\t%s\n' "$m" "$i"; done
done

for c in pkgjson llmstxt agentsmd; do
  for m in "${COND_MODELS[@]}"; do
    for i in $(seq 1 $N_COND); do printf '%s\t%s\t%s\n' "$m" "$c" "$i"; done
  done
done
