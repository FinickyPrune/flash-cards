#!/usr/bin/env bash
# PreToolUse(Bash): enforce the repo's git etiquette. Exit 2 blocks the command
# and shows the reason to Claude.
set -uo pipefail

cmd=$(jq -r '.tool_input.command // empty')
[[ -n "$cmd" ]] || exit 0

block() {
    echo "Blocked by .claude/hooks/guard-bash.sh: $1" >&2
    exit 2
}

branch=$(git -C "$CLAUDE_PROJECT_DIR" branch --show-current 2>/dev/null)

if [[ "$cmd" =~ gh[[:space:]]+pr[[:space:]]+merge ]]; then
    block "the user merges PRs. Report that the PR is ready instead."
fi

if [[ "$cmd" =~ git[[:space:]]+push ]]; then
    if [[ "$cmd" =~ (--force([[:space:]]|$)|[[:space:]]-f([[:space:]]|$)) ]]; then
        block "plain force-push is not allowed. Use --force-with-lease on your own feature branch."
    fi
    if [[ "$branch" == "main" || "$cmd" =~ [[:space:]:]main([[:space:]\;\&\|]|$) ]]; then
        block "never push to main. Create a feature branch and open a PR."
    fi
fi

if [[ "$cmd" =~ git[[:space:]]+commit ]] && [[ "$branch" == "main" ]]; then
    block "do not commit on main. Run: git switch -c <type>/<short-name>"
fi

# Per line, so commit messages that merely mention the flag don't trip it.
if grep -qE 'git[[:space:]]+(commit|push).*--no-verify' <<<"$cmd"; then
    block "--no-verify skips the lint gate. Fix the reported issues instead."
fi

exit 0
