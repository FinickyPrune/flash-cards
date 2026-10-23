#!/usr/bin/env bash
# PreToolUse(Bash): enforce the repo's git etiquette. Exit 2 blocks the command
# and shows the reason to Claude. A guardrail against mistakes, not a security
# boundary — branch protection on GitHub is the real gate for main.
set -o pipefail

block() {
    echo "Blocked by .claude/hooks/guard-bash.sh: $1" >&2
    exit 2
}

command -v jq >/dev/null || block "jq is missing, run 'make bootstrap'."

cmd=$(jq -r '.tool_input.command // empty')
[[ -n "$cmd" ]] || exit 0

# Checks run per line so heredoc bodies (commit messages) don't trip them.
has() { grep -qE "$1" <<<"$cmd"; }

if has 'gh[[:space:]]+pr[[:space:]]+merge'; then
    block "the user merges PRs. Report that the PR is ready instead."
fi

if has 'git[[:space:]]+push'; then
    if has 'git[[:space:]]+push.*([[:space:]]--force([[:space:]]|$)|[[:space:]]-[a-zA-Z]*f|[[:space:]]\+[^[:space:]])'; then
        block "plain force-push is not allowed. Use --force-with-lease on your own feature branch."
    fi
    if has 'git[[:space:]]+push.*([[:space:]:]|refs/heads/)main([[:space:]&;|]|$)'; then
        block "never push to main. Create a feature branch and open a PR."
    fi
fi

if has 'git[[:space:]]+(commit|push).*[[:space:]]--no-verify' || has 'git[[:space:]]+commit.*[[:space:]]-[a-zA-Z]*n' \
    || has 'core\.hooksPath='; then
    block "skipping git hooks bypasses the lint gate. Fix the reported issues instead."
fi

# The current branch only tells us something if the command doesn't switch branches itself.
if ! has 'git[[:space:]]+(switch|checkout)'; then
    branch=$(git -C "${CLAUDE_PROJECT_DIR:-.}" branch --show-current 2>/dev/null)
    if [[ "$branch" == "main" ]] && has 'git[[:space:]]+(commit|push)'; then
        block "do not commit or push on main. Run: git switch -c <type>/<issue>-<slug>"
    fi
elif has 'git[[:space:]]+(switch|checkout)[[:space:]]+main.*git[[:space:]]+commit'; then
    block "do not commit on main. Run: git switch -c <type>/<issue>-<slug>"
fi

exit 0
