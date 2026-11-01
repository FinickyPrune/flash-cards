#!/usr/bin/env bash
# Usage: scripts/post-screenshots.sh <pr-number> <screenshots dir>
# Uploads the tour's <stop>-light.png / <stop>-dark.png to `pr-assets` and posts them as one PR
# comment, a light/dark table per stop; a later run edits that comment instead of adding one.
set -euo pipefail

pr=$1
dir=$2
marker="<!-- screenshot-tour -->"
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
# The PR's head commit on CI (HEAD there is a merge commit), else the checked-out one.
sha=$(git rev-parse --short "${HEAD_SHA:-HEAD}")
export ASSET_DIR="pr-$pr/$sha"

stops=$(find "$dir" -maxdepth 1 \( -name '*-light.png' -o -name '*-dark.png' \) -exec basename {} \; \
  | sed -E 's/-(light|dark)\.png$//' | sort -u)
[[ -n "$stops" ]] || { echo "No screenshots in $dir" >&2; exit 1; }

# One markdown image for <stop>-<mode>, or nothing when the tour has no such shot.
image() {
  local file="$dir/$1-$2.png"
  if [[ -f "$file" ]]; then
    scripts/upload-screenshot.sh "$pr" "$file"
  fi
}

body=$(mktemp)
trap 'rm -f "$body"' EXIT
{
  echo "$marker"
  echo "### Screenshot tour ($sha)"
  echo
  echo "| Stop | Light | Dark |"
  echo "|---|---|---|"
  for stop in $stops; do
    # Assignments, so a failed upload stops the script (set -e).
    light=$(image "$stop" light)
    dark=$(image "$stop" dark)
    echo "| \`$stop\` | $light | $dark |"
  done
} > "$body"

existing=$(gh api "repos/$repo/issues/$pr/comments" --paginate \
  -q ".[] | select(.body | startswith(\"$marker\")) | .id" | head -1)
if [[ -n "$existing" ]]; then
  jq -Rs '{body: .}' < "$body" | gh api -X PATCH "repos/$repo/issues/comments/$existing" --input - >/dev/null
else
  gh pr comment "$pr" --body-file "$body" >/dev/null
fi
echo "Posted the screenshot tour to PR #$pr"
