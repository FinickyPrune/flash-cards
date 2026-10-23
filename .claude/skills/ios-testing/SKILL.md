---
name: ios-testing
description: Mechanics of tests in this repo — where test files go, Swift Testing / XCUITest style, how to run, narrow and debug them. Use when writing or running tests, when a test fails, or when `make test`/`make test-ui` output is unclear. Whether to write a test, what it asserts and which double to use is decided by `pragmatic-testing`; load both.
---

# Testing mechanics

Deciding **whether** to test, **what** to assert, **which double**, and **how many** tests →
`pragmatic-testing`. This skill only covers how that's done here.

## Where tests go
- Unit tests: `Tests/UnitTests`, Swift Testing. Mirror the source path:
  `App/Sources/Deck/DeckStore.swift` → `Tests/UnitTests/Deck/DeckStoreTests.swift`.
- Shared fakes: `Tests/UnitTests/Support/Fake<Protocol>.swift`.
- UI tests: `Tests/UITests`, XCTest/XCUITest. A few smoke flows per screen (it opens, the
  main action works). Rules and edge cases are covered by unit tests, not UI tests.

## Swift Testing style
```swift
import Testing
@testable import FlashCards

@Suite("DeckStore")
struct DeckStoreTests {
    // Catches: add() appending to a copy instead of the stored deck.
    @Test("Adding a card stores it in the deck")
    func addCard() throws {
        var store = DeckStore(storage: FakeStorage())
        try store.add(Card(front: "a", back: "b"))
        #expect(store.cards == [Card(front: "a", back: "b")])
    }

    // Boundaries of the review interval rule; one parameterized test, not three.
    @Test(arguments: [(0, 1), (1, 3), (5, 30)])
    func nextInterval(reviews: Int, expectedDays: Int) { ... }
}
```
- `#expect` for checks, `#require` to unwrap or stop early. No XCTest assertions in unit tests.
- `@MainActor` on the suite or test when testing main-actor view models.
- Inject fakes and a fixed clock through init. No sleeps: await the async API, or park the
  call in a fake and resume it from the test.

## UI test style
- Find elements by `AccessibilityID` values only, never by visible text.
- Put the app in a known state with launch arguments (e.g. `app.launchArguments = ["-uitest-reset"]`)
  that the app reads at startup to use in-memory storage or seed data.
- `waitForExistence(timeout:)` instead of sleeps.

## Running
| Need | Command |
|---|---|
| All unit tests | `make test` |
| One suite / test | `make test ONLY=FlashCardsTests/DeckStoreTests` or `.../DeckStoreTests/addCard()` |
| UI tests | `make test-ui` |
| Everything + lint (pre-PR gate) | `make check` |
| Coverage per function | see `pragmatic-testing` → "In this repo" |

`make` exits non-zero when a test fails. Output is filtered by xcbeautify to errors and test
results. If a failure isn't clear from it, inspect the result bundle:
```bash
xcrun xcresulttool get test-results summary --path build/results/unit.xcresult
xcrun xcresulttool get test-results tests --path build/results/unit.xcresult
```
For a UI test failure, `build/results/ui.xcresult` also holds the failure screenshot:
`xcrun xcresulttool export attachments --path build/results/ui.xcresult --output-path build/results/attachments`.

## Rules
- Never skip (`.disabled`) or weaken an assertion to make a test pass. Fix the code, or explain
  to the user why the test is wrong. Deleting or merging tests goes through `pragmatic-testing`
  → Audit mode, with "Prove the prune".
- Flaky test → fix the cause (missing wait, shared state), don't retry-loop it.
