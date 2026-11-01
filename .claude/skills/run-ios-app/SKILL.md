---
name: run-ios-app
description: Launch the FlashCards app in the iOS Simulator and visually verify a change with screenshots. Use to run/start/screenshot the app, after any UI change before opening a PR, or when the user asks to see how something looks.
---

# Run and visually verify

PR screenshots come from CI (below). For a quick look at one screen:

1. `make run` — builds, boots the simulator (iPhone 17 on iOS 26, as on CI; override with `SIM_NAME="iPhone Duo" SIM_OS=`), installs and launches. The simulator runs headless; no window needed.
2. Wait ~2s for the UI to settle, then `NAME=<short-name> make screenshot`. It prints the path (`build/screenshots/<name>.png`, downscaled to 1000px).
3. Read the PNG and check it against the acceptance criteria / design. List concrete differences and fix them; repeat.

Useful extras:
- Dark mode: `xcrun simctl ui $(scripts/sim.sh) appearance dark` (reset with `light`).
- Large text: `xcrun simctl ui $(scripts/sim.sh) content_size extra-extra-large` (reset with `large`).
- Deep state (e.g. a specific screen) is reached via launch arguments: `xcrun simctl launch --terminate-running-process $(scripts/sim.sh) dev.finickyprune.FlashCards -uitest-reset` — add support for the argument in the app if needed.
- App logs: `xcrun simctl spawn $(scripts/sim.sh) log stream --level debug --predicate 'subsystem == "dev.finickyprune.FlashCards"'` (run in background, stop when done).

## Screenshot tour
`make screenshots` runs `Tests/UITests/ScreenshotTour.swift` on seeded data in light and dark and writes
`build/screenshots/<stop>-<light|dark>.png` (downscaled to 1000 px). The tour is skipped in normal UI runs.
A screen the tour doesn't reach yet → add a stop (`stop("<name>", in: app)`) in the same PR; never write a
throwaway tour. Locally it is heavy: run it only when `make run` + `make screenshot` can't reach the state.

## For the PR
Every UI change needs light + dark screenshots of each changed screen in the PR. The `Screenshots` workflow
(`.github/workflows/screenshots.yml`) runs the tour on every PR touching `App/` or `Tests/UITests/`, stores
the images on the `pr-assets` branch (never merged, one folder per commit) and posts or updates one PR comment
with a light/dark table per stop (`scripts/post-screenshots.sh`). Read the changed screens from there
(download the image URLs) and check them against the criteria. For a shot the tour can't take,
`scripts/upload-screenshot.sh <pr-number> <png>...` uploads a local PNG and prints a markdown image line.
