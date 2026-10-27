#!/usr/bin/env bash
# Usage: export-screenshots.sh <result bundle> <appearance> <output dir>
# Copies the screenshot tour's named attachments to <output dir>/<name>-<appearance>.png,
# downscaled to 1000 px so they stay cheap to read and upload.
set -euo pipefail

bundle=$1
appearance=$2
out=$3
raw=$(mktemp -d)
trap 'rm -rf "$raw"' EXIT

xcrun xcresulttool export attachments --path "$bundle" --output-path "$raw" >/dev/null
mkdir -p "$out"
# Attachment files are named "<name>_<index>_<UUID>.png"; system screenshots aren't kept on success.
jq -r '.[].attachments[] | "\(.exportedFileName)\t\(.suggestedHumanReadableName)"' "$raw/manifest.json" |
  while IFS=$'\t' read -r file name; do
    stop=$(sed -E 's/_[0-9]+_[0-9A-F-]+\.png$//' <<<"$name")
    [[ "$stop" != "$name" ]] || continue
    cp "$raw/$file" "$out/$stop-$appearance.png"
    sips --resampleHeightWidthMax 1000 "$out/$stop-$appearance.png" >/dev/null
    echo "$out/$stop-$appearance.png"
  done
