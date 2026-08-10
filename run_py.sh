#!/bin/bash
D="$(cd "$(dirname "$0")" && pwd)"
cd "$D" || exit 1
find runs -size 0 -name '*.txt' -delete
./jobs_py.sh | tr '\n' '\0' | xargs -0 -P 6 -I{} ./dispatch.sh {}
echo "PY DONE $(find runs -name '*py__*.txt' -size +0 | wc -l) populated"
