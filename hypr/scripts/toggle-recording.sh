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

# Honour XDG_VIDEOS_DIR from ~/.config/user-dirs.dirs rather than hardcoding a
# path. Note xdg-user-dir exits 0 and prints $HOME when the entry is unset, so
# guard against dumping recordings straight into the home directory.
outdir="$(xdg-user-dir VIDEOS 2>/dev/null || true)"
if [ -z "$outdir" ] || [ "$outdir" = "$HOME" ]; then
    outdir="$HOME/Videos"
fi
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
