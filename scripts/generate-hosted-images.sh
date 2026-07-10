#!/usr/bin/env bash
set -euo pipefail

# Generates hosted images inside the repo's output/ directory:
# - output/github-contributions-calendar.svg (fetched from github.com/users/<user>/contributions)
# - output/top-langs.svg (generated from GitHub API /repos/:owner/:repo/languages)

USER=${1:-${GITHUB_REPOSITORY_OWNER:-Kishor0513}}
REPO=${2:-${GITHUB_REPOSITORY##*/}}

OUT_DIR=output
mkdir -p "$OUT_DIR"

echo "Fetching contributions calendar for user: $USER"
curl -sL "https://github.com/users/$USER/contributions" -o "$OUT_DIR/github-contributions-calendar.svg"

echo "Generating top-langs SVG for $USER/$REPO"

python3 - <<PY
import sys, json, urllib.request
owner = "$USER"
repo = "$REPO"
url = f"https://api.github.com/repos/{owner}/{repo}/languages"
req = urllib.request.Request(url, headers={"User-Agent":"github-comm-stats"})
with urllib.request.urlopen(req, timeout=15) as resp:
    data = json.load(resp)
total = sum(data.values())
items = sorted(data.items(), key=lambda x: x[1], reverse=True)[:8]

svg_parts = []
svg_parts.append('<?xml version="1.0" encoding="UTF-8"?>')
svg_parts.append('<svg xmlns="http://www.w3.org/2000/svg" width="320" height="' + str(40 + 24*len(items)) + '">')
svg_parts.append('<style>text{font-family:Inter, Helvetica, Arial, sans-serif; font-size:12px;}</style>')
svg_parts.append(f'<rect width="100%" height="100%" fill="#0b0c10" rx="8"/>')
svg_parts.append('<text x="16" y="20" fill="#fff" font-size="14">Top languages</text>')
for i,(lang,bytes_) in enumerate(items):
    pct = (bytes_ / total * 100) if total>0 else 0
    y = 40 + i*24
    svg_parts.append(f'<text x="16" y="{y}" fill="#c9d1d9">{lang}</text>')
    svg_parts.append(f'<rect x="110" y="{y-12}" width="180" height="10" fill="#21262d" rx="5"/>')
    bar_w = int(1.8 * pct)
    svg_parts.append(f'<rect x="110" y="{y-12}" width="{bar_w}" height="10" fill="#58a6ff" rx="5"/>')
    svg_parts.append(f'<text x="300" y="{y}" fill="#8b949e">{pct:.1f}%</text>')

svg_parts.append('</svg>')
open('output/top-langs.svg','w').write('\n'.join(svg_parts))
print('WROTE output/top-langs.svg')
PY

echo "Wrote images to $OUT_DIR/"
