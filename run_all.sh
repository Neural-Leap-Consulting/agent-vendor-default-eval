#!/bin/bash
D="$(cd "$(dirname "$0")" && pwd)"
cd "$D" || exit 1
: > errors.log
./jobs.sh | tr '\n' '\0' | xargs -0 -P 6 -I{} ./dispatch.sh {}
echo "DONE $(ls runs | wc -l) files"
