#!/usr/bin/env bash
# Usage: scripts/upload-screenshot.sh <pr-number> <file.png>...
# Stores screenshots on the `pr-assets` branch (via the GitHub API, the working tree
# is untouched) and prints a markdown image line for each one.
set -euo pipefail

[[ $# -ge 2 ]] || { echo "usage: $0 <pr-number> <file.png>..." >&2; exit 1; }
pr="$1"; shift

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
branch=pr-assets

if ! gh api "repos/$repo/branches/$branch" >/dev/null 2>&1; then
    base=$(gh api "repos/$repo/git/ref/heads/main" -q .object.sha)
    gh api "repos/$repo/git/refs" -f ref="refs/heads/$branch" -f sha="$base" >/dev/null
fi

for file in "$@"; do
    name=$(basename "$file")
    path="pr-$pr/$name"
    # Overwrite if it already exists (re-uploading after a fix).
    sha=$(gh api "repos/$repo/contents/$path?ref=$branch" -q .sha 2>/dev/null || true)
    gh api -X PUT "repos/$repo/contents/$path" \
        -f message="PR #$pr: $name" \
        -f branch="$branch" \
        -f content="$(base64 < "$file")" \
        ${sha:+-f sha="$sha"} >/dev/null
    echo "![${name%.*}](https://github.com/$repo/blob/$branch/$path?raw=true)"
done
