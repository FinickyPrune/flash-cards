---
name: swift-conventions
description: Swift 6 / SwiftUI conventions for this repo. Use before writing or changing any Swift code — new views, view models, models, persistence, concurrency, navigation, or when fixing Swift 6 concurrency errors.
---

# Swift conventions

Targets: iOS 18+, Swift 6 language mode, strict concurrency `complete`, warnings are errors.
Only rules that differ from "whatever Claude would do anyway" belong here — keep it short.

## State and architecture
- Observation only: `@Observable` classes, `@State` to own them in views, `@Bindable` to bind, `@Environment(Type.self)` to inject. No `ObservableObject` / `@Published` / `@StateObject` / `@EnvironmentObject`.
- View models and anything touching UI are `@MainActor`. Pure logic (models, algorithms like spaced repetition) is plain `struct`/`enum`, `Sendable`, and actor-agnostic so it is trivially unit-testable.
- Side effects (persistence, network, clock, randomness) sit behind a small protocol injected via init, so tests can pass a fake. No singletons reached from inside logic.
- `NavigationStack` with value-based `navigationDestination`; no `NavigationView`.
- One type per file; file name = type name. Views over ~150 lines get split into subviews.

## Concurrency
- `async/await` and structured concurrency. No `DispatchQueue`, no completion handlers in new code.
- Fix Swift 6 diagnostics properly: make types `Sendable`, isolate to `@MainActor`, or use an `actor`. `@unchecked Sendable` and `nonisolated(unsafe)` need a comment justifying why it is safe.
- Use `.task {}` on views for async work tied to view lifetime, not `Task {}` in `onAppear`.

## Safety
- No force unwraps (`!`) or `try!` outside tests (SwiftLint enforces `force_unwrapping`).
- Errors: typed `enum ...: Error` per feature; surface user-facing failures in UI state, don't swallow with `try?` silently.

## UI
- Every interactive or asserted element gets an `.accessibilityIdentifier` from the `AccessibilityID` namespace — UI tests rely on them.
- Strings shown to users go through `String(localized:)` / string literals in `Text` (String Catalog), never concatenated.
- Support Dynamic Type and dark mode: use semantic colors/fonts, no fixed font sizes.
- Add a `#Preview` for every screen and reusable component.

## Project mechanics
- Source folders are synced: just create files under `App/Sources/...` or `Tests/...`; no project regeneration needed.
- Target/setting changes go in `project.yml`, never in `FlashCards.xcodeproj` (generated, gitignored). Run `make generate` after editing `project.yml`.
- New SPM dependencies require the user's approval first.
