---
name: write-spec
description: Turn a feature idea into a GitHub issue with a self-contained spec, by interviewing the user first. Use when the user describes a new feature or change that isn't an issue yet, or asks to plan/spec/break down work.
argument-hint: <feature idea>
---

# Write a spec as a GitHub issue

Idea: $ARGUMENTS

1. Read what's relevant in the codebase so questions are grounded (keep it scoped; use an Explore subagent for wide sweeps).
2. Interview the user with `AskUserQuestion`: behavior, UI/UX, edge cases, data, what's out of scope. Skip what's obvious or has a sensible default — state the default instead. Dig into the hard parts. Communicate in Russian.
3. If the feature is bigger than ~1 day / ~400 lines of diff, split it into several issues that each ship independently, and say how they depend on each other.
4. Create each issue with the template in `.github/ISSUE_TEMPLATE/feature.md` (English):
   ```bash
   gh issue create --title "<imperative title>" --label feature --body-file <tmp file>
   ```
   Acceptance criteria must be checkable: each maps to a unit test, a UI test, or a screenshot.
5. Reply with the issue link(s) and the proposed order. Do not start implementing — wait for the user to say go (then use `work-issue`).
