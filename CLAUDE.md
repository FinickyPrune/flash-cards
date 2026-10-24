# FlashCards

Native iOS flash-card app. SwiftUI, iOS 26+, Swift 6 strict concurrency, warnings are errors.
Claude does most of the work (code, tests, review, push, routine merges); the user sets direction and reviews flagged PRs.

## Product
Flash-card app; vision not written yet. Product knowledge lives in `docs/product/` and is read on demand: start at `docs/product/README.md`, open only what the task touches. Where facts go and when to update them: `product-docs` skill.

## Language
- Talk to the user in Russian.
- Code, comments, commits, PRs, issues, docs: English.

## Commands
`make help` lists everything. Main ones:
- `make build` · `make test` (unit; `ONLY=FlashCardsTests/Suite[/test()]` to narrow) · `make test-ui` · `make lint` · `make format`
- `make check` — lint + all tests; must pass before any PR
- `make run` then `NAME=x make screenshot` — launch in simulator and capture `build/screenshots/x.png`
- Fresh clone / missing tools: `make bootstrap`

## Project layout
- `project.yml` is the source of truth (XcodeGen). `FlashCards.xcodeproj` is generated and gitignored — never edit it; change `project.yml` and run `make generate`.
- `App/Sources`, `Tests/UnitTests`, `Tests/UITests` are synced folders: new files are picked up without regenerating.

## Workflow
Issue → branch → plan → code + tests → `make check` → screenshots (UI) → `/code-review` + `pr-reviewer` subagent → push → PR → merge (self or user, see below).
- New idea without an issue → `write-spec` skill. Implementing an issue → `work-issue` skill.
- Branches: `<type>/<issue>-<slug>`. Commits: Conventional Commits with `Refs #<issue>`.
- Show evidence (test summary, screenshot), not "it works".

## Who merges
IMPORTANT: fill the PR template's **Review flags** honestly. If the PR does or touches any of these, check it, explain where, add the `needs-review` label, and leave the merge to the user:
- **Spec / plan** — ambiguous requirements I interpreted, or a plan that deviates from the spec (solving the wrong problem is the most expensive mistake)
- **Tests** — existing tests changed/removed, or assertions encode non-obvious logic (green tests on wrong logic prove nothing)
- **Sensitive** — auth, payments, secrets, permissions/access rights, other people's data, privacy entitlements
- **Irreversible** — data migrations / persisted schema changes, deleting user data, releases
- **Architecture** — new dependencies, new or changed public interfaces, CI / hooks / `.claude/` / `project.yml` config
- **Scope** — the diff touches anything outside the issue

When in doubt, flag it. Otherwise check "None of the above" and merge with `scripts/merge-pr.sh <n>` (waits for green CI, refuses flagged PRs; squash + delete branch). Never `gh pr merge` directly; never push to `main`.
`main` is protected on GitHub (PR required, `lint` + `test` must pass, no force-push; applies to admins too), so a red PR can't merge even by mistake.

## Gotchas
- Hooks in `.claude/settings.json` auto-format and lint every Swift edit and block unsafe git commands. If a hook blocks you, fix the cause; don't work around it.
- Simulator is picked by `scripts/sim.sh` (newest iOS runtime, first iPhone). `SIM_NAME="iPhone 17"` to override.
- SourceKit diagnostics in the editor may show false "No such module" errors; trust `make build`.
