#!/bin/bash
# dispatch.sh "<engine>\t<model>\t<condition>\t<idx>"
D="$(cd "$(dirname "$0")" && pwd)"
IFS=$'\t' read -r e m c i <<< "$1"
exec "$D/run_one.sh" "$e" "$m" "$c" "$i"
