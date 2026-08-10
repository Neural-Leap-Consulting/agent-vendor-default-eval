#!/bin/bash
# Python arm. Gemini omitted — weekly quota exhausted until ~2026-08-17.
N_COLD=10
N_COND=6

COLD_MODELS=(
"claude	opus"
"claude	sonnet"
"claude	haiku"
"agy	GPT-OSS 120B (Medium)"
)

COND_MODELS=(
"claude	sonnet"
"agy	GPT-OSS 120B (Medium)"
)

for m in "${COLD_MODELS[@]}"; do
  for i in $(seq 1 $N_COLD); do printf '%s\tcoldpy\t%s\n' "$m" "$i"; done
done

for c in pkgjsonpy llmstxtpy agentsmdpy; do
  for m in "${COND_MODELS[@]}"; do
    for i in $(seq 1 $N_COND); do printf '%s\t%s\t%s\n' "$m" "$c" "$i"; done
  done
done
