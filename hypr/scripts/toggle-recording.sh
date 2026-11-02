#!/usr/bin/env bash
# Toggle wf-recorder: start if not already running, stop (and finalize
# the file) if it is. Bound to Super+R (region) / Super+Shift+R (full).
#
# Usage: toggle-recording.sh <region|full>

set -euo pipefail

mode="$1"

if pgrep -x wf-recorder > /dev/null; then
    pkill -INT -x wf-recorder
    exit 0
fi

outdir="$HOME/Videos"
mkdir -p "$outdir"
outfile="$outdir/recording-$(date +%Y%m%d-%H%M%S).mp4"

if [ "$mode" = "region" ]; then
    geometry=$(slurp)
    [ -z "$geometry" ] && exit 0
    wf-recorder -g "$geometry" -f "$outfile" &
    disown
else
    wf-recorder -f "$outfile" &
    disown
fi
