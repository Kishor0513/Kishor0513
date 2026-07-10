#!/usr/bin/env bash
set -euo pipefail

# Generate a simple contributions report (per-author commit counts) and add a "Pac-Man" style indicator.
OUT=contributions.md
echo "# Pac-Man Contributions" > "$OUT"
echo >> "$OUT"
echo "Generated: $(date -u)" >> "$OUT"
echo >> "$OUT"
echo "Pac-Man contributions (commit counts in this repo):" >> "$OUT"
echo >> "$OUT"

# Ensure full history is available
git fetch --prune --unshallow 2>/dev/null || true

git shortlog -s -n --all | while read -r count name; do
  # compute a small indicator: one cherry per 10 commits, capped at 10
  n=$((count / 10))
  if [ "$n" -lt 1 ]; then n=1; fi
  if [ "$n" -gt 10 ]; then n=10; fi
  cherries=""
  i=0
  while [ $i -lt $n ]; do
    cherries+="🍒"
    i=$((i+1))
  done
  echo "- **$name**: $count commits $cherries" >> "$OUT"
done

echo "\nReport written to $OUT"
