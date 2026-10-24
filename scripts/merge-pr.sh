#!/usr/bin/env bash
# Usage: scripts/merge-pr.sh <pr-number>
# The only way Claude merges. Refuses unless the PR is cleared for self-merge:
# no `needs-review` label, the review checklist was filled in, CI is green, and it's mergeable.
set -euo pipefail

[[ $# -eq 1 ]] || { echo "usage: $0 <pr-number>" >&2; exit 1; }
pr="$1"

refuse() { echo "merge-pr: refusing to merge #$pr: $1" >&2; exit 1; }

info=$(gh pr view "$pr" --json state,isDraft,labels,body,mergeable,baseRefName)

[[ $(jq -r .state <<<"$info") == OPEN ]] || refuse "PR is not open."
[[ $(jq -r .isDraft <<<"$info") == false ]] || refuse "PR is a draft."
[[ $(jq -r .baseRefName <<<"$info") == main ]] || refuse "base branch is not main."

if jq -e '.labels[] | select(.name == "needs-review")' <<<"$info" >/dev/null; then
    refuse "it has the needs-review label. The user reviews and merges it."
fi

# The PR template's checklist must be explicitly cleared.
grep -q '\[x\] None of the above' <<<"$(jq -r .body <<<"$info")" \
    || refuse "the 'Review flags' section is not marked '[x] None of the above'."

[[ $(jq -r .mergeable <<<"$info") == MERGEABLE ]] || refuse "not mergeable (conflicts or still computing)."

echo "Waiting for CI on #$pr..."
gh pr checks "$pr" --watch --fail-fast >/dev/null || refuse "CI checks are not green (gh pr checks $pr)."

gh pr merge "$pr" --squash --delete-branch
echo "Merged #$pr."
