#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): format the edited Swift file, then lint it.
# Remaining lint violations are fed back to Claude (exit 2) so they get fixed right away.
set -uo pipefail

file=$(jq -r '.tool_input.file_path // empty')
[[ "$file" == *.swift && -f "$file" ]] || exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0

swiftformat --quiet "$file" 2>/dev/null

violations=$(swiftlint lint --quiet --strict "$file" 2>/dev/null)
if [[ -n "$violations" ]]; then
    echo "SwiftLint violations in $file (file was auto-formatted first):" >&2
    echo "$violations" >&2
    exit 2
fi
