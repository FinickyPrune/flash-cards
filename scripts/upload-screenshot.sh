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
    path="pr-$pr/$(jq -rn --arg n "$name" '$n | @uri')"
    # Overwrite if it already exists (re-uploading after a fix).
    sha=$(gh api "repos/$repo/contents/$path?ref=$branch" -q .sha 2>/dev/null || true)
    # Body goes through stdin: a base64 PNG can exceed the argv size limit.
    base64 < "$file" | tr -d '\n' \
        | jq -Rs --arg msg "PR #$pr: $name" --arg branch "$branch" --arg sha "$sha" \
            '{message: $msg, branch: $branch, content: .} + (if $sha == "" then {} else {sha: $sha} end)' \
        | gh api -X PUT "repos/$repo/contents/$path" --input - >/dev/null
    echo "![${name%.*}](https://github.com/$repo/blob/$branch/$path?raw=true)"
done
