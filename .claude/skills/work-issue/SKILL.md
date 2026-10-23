---
name: work-issue
description: End-to-end workflow to implement a GitHub issue — branch, plan, code + tests, verify, self-review, commit, push, open PR. Use when the user says to work on / implement / pick up an issue or task (e.g. "сделай #12", "take issue 12").
argument-hint: <issue-number>
---

# Implement issue #$ARGUMENTS

## 1. Understand
- `gh issue view $ARGUMENTS --comments`. If acceptance criteria are missing or ambiguous, ask the user (or run `write-spec`) before coding.
- Read the code it touches. Load `swift-conventions` and `ios-testing`.

## 2. Branch
```bash
git switch main && git pull --ff-only && git switch -c <type>/$ARGUMENTS-<short-slug>
```
`<type>` ∈ feat, fix, refactor, chore, test, docs.

## 3. Plan
If the diff can't be described in one sentence, write a short plan first: files to add/change, types and their responsibilities, tests per acceptance criterion. Show it to the user only if it changes architecture, adds a dependency, or deviates from the spec; otherwise proceed.

## 4. Implement in small verified steps
For each step: write/adjust tests → code → `make test ONLY=...` for the touched suite → commit.
- Commits: Conventional Commits, English, imperative (`feat(deck): add card editing`), with `Refs #$ARGUMENTS`.
- Keep each commit building. The PostToolUse hook formats and lints every Swift edit — fix what it reports immediately.
- Stay in scope. Unrelated problems you notice → note them for the PR description, don't fix them here.

## 5. Verify
- `make check` (lint + all unit + UI tests) must pass. Paste the summary lines, not "tests pass".
- UI changed → follow `run-ios-app`: screenshot each changed screen, light and dark, and check against the criteria.
- Walk through every acceptance criterion and name the test or screenshot that proves it.

## 6. Self-review
- Run `/code-review` on the branch diff and fix real findings.
- Then use the `pr-reviewer` subagent: it checks the diff against the issue's acceptance criteria in a fresh context. Fix correctness/requirement gaps; treat style nits as optional.
- Re-run `make check` if anything changed.

## 7. Ship
```bash
git push -u origin HEAD
gh pr create --title "<conventional title>" --body-file <tmp file>   # follows .github/pull_request_template.md, includes "Closes #$ARGUMENTS"
```
Upload screenshots with `scripts/upload-screenshot.sh <pr> <png>...` and put them in the body. Then `gh pr checks <pr> --watch` and fix CI failures.

## 8. Report (in Russian)
PR link, what was done, how it was verified, anything left out of scope or worth a follow-up issue. Never merge — the user merges.
