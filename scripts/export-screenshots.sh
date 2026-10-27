#!/usr/bin/env bash
# Usage: export-screenshots.sh <result bundle> <output dir>
# Copies the screenshot tour's named attachments to <output dir>/<name>.png (names end in
# -light or -dark), downscaled to 1000 px so they stay cheap to read and upload.
set -euo pipefail

bundle=$1
out=$2
raw=$(mktemp -d)
trap 'rm -rf "$raw"' EXIT

xcrun xcresulttool export attachments --path "$bundle" --output-path "$raw" >/dev/null
mkdir -p "$out"
# Attachment files are named "<name>_<index>_<UUID>.png"; system screenshots aren't kept on success.
count=0
while IFS=$'\t' read -r file name; do
  stop=$(sed -E 's/_[0-9]+_[0-9A-Fa-f-]+\.png$//' <<<"$name")
  [[ "$stop" != "$name" ]] || continue
  cp "$raw/$file" "$out/$stop.png"
  sips --resampleHeightWidthMax 1000 "$out/$stop.png" >/dev/null
  echo "$out/$stop.png"
  count=$((count + 1))
done < <(jq -r '.[].attachments[] | "\(.exportedFileName)\t\(.suggestedHumanReadableName)"' "$raw/manifest.json")
# A skipped tour exits 0 with no attachments; never let old PNGs pass for new ones.
(( count > 0 )) || { echo "No tour screenshots in $bundle (was the tour skipped?)" >&2; exit 1; }
