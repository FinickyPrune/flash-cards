# FlashCards

Native iOS flash-card app. SwiftUI, iOS 18+, Swift 6 strict concurrency, warnings are errors.
Claude does most of the work (code, tests, review, push); the user sets direction, reviews PRs and merges.

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
Issue → branch → plan → code + tests → `make check` → screenshots (UI) → `/code-review` + `pr-reviewer` subagent → push → PR → user merges.
- New idea without an issue → `write-spec` skill. Implementing an issue → `work-issue` skill.
- Branches: `<type>/<issue>-<slug>`. Commits: Conventional Commits with `Refs #<issue>`.
- Show evidence (test summary, screenshot), not "it works".

## Ask the user first
- Merging anything (never run `gh pr merge`; a hook blocks it), pushing to `main`.
- Adding an SPM dependency.
- Changing CI, signing, bundle ID or deployment target.
- Architecture that deviates from the issue's spec.

## Gotchas
- Hooks in `.claude/settings.json` auto-format and lint every Swift edit and block unsafe git commands. If a hook blocks you, fix the cause; don't work around it.
- Simulator is picked by `scripts/sim.sh` (newest iOS runtime, first iPhone). `SIM_NAME="iPhone 17"` to override.
- SourceKit diagnostics in the editor may show false "No such module" errors; trust `make build`.
