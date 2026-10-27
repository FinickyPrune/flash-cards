# FlashCards

Native iOS flash-card app (SwiftUI, iOS 26+, Swift 6).

## Setup
```bash
make bootstrap   # installs xcodegen, swiftlint, swiftformat, xcbeautify, jq; git hooks; generates the project
open FlashCards.xcodeproj
```

## Everyday commands
```bash
make build       # build for the simulator
make test        # unit tests (Swift Testing)
make test-ui     # UI tests (ONLY=FlashCardsUITests/<Class> to narrow)
make check       # everything CI runs: lint + all tests (manual full run)
make screenshots # screenshot tour, light + dark, into build/screenshots
make run         # launch in the simulator
make sim-stop    # shut down simulators when done
make help        # everything else
```

The Xcode project is generated from `project.yml` and not committed.
Development is agent-driven; see `CLAUDE.md` and `.claude/` for the workflow.
