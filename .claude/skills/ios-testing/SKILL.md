---
name: ios-testing
description: How to write, run and debug tests in this repo (Swift Testing unit tests, XCUITest smoke tests). Use when adding tests, when a test fails, when `make test`/`make test-ui` output is unclear, or when deciding what to test for a change.
---

# Testing

## What to test
- Every behavior change ships with tests in the same PR.
- Unit tests (`Tests/UnitTests`, Swift Testing) cover models, logic and view models — this is where most coverage lives. Mirror the source path: `App/Sources/Deck/DeckStore.swift` → `Tests/UnitTests/Deck/DeckStoreTests.swift`.
- UI tests (`Tests/UITests`, XCTest/XCUITest) are a few smoke flows per screen: it opens, the main action works. Not pixel or edge-case testing.
- Bug fix: write the failing test first, see it fail, then fix.

## Swift Testing style
```swift
import Testing
@testable import FlashCards

@Suite("DeckStore")
struct DeckStoreTests {
    @Test("Adding a card increases the count")
    func addCard() throws {
        var store = DeckStore(storage: InMemoryStorage())
        try store.add(Card(front: "a", back: "b"))
        #expect(store.cards.count == 1)
    }

    @Test(arguments: [0, 1, 5])
    func intervals(reviews: Int) { ... }
}
```
- `#expect` for checks, `#require` to unwrap or stop early. No XCTest assertions in unit tests.
- `@MainActor` on the suite or test when testing main-actor view models.
- Inject fakes (in-memory storage, fixed clock `Date`) through init. No sleeps; await the async API directly.
- Parameterized `@Test(arguments:)` instead of copy-pasted tests.

## UI test style
- Find elements by `AccessibilityID` values only, never by visible text.
- Put the app in a known state with launch arguments (e.g. `app.launchArguments = ["-uitest-reset"]`) that the app reads at startup to use in-memory storage / seed data.
- `waitForExistence(timeout:)` instead of sleeps.

## Running
| Need | Command |
|---|---|
| All unit tests | `make test` |
| One suite / test | `make test ONLY=FlashCardsTests/DeckStoreTests` or `.../DeckStoreTests/addCard()` |
| UI tests | `make test-ui` |
| Everything + lint (pre-PR gate) | `make check` |

Output is filtered by xcbeautify to errors and test results. If a failure isn't clear from it, inspect the result bundle:
```bash
xcrun xcresulttool get test-results summary --path build/results/unit.xcresult
xcrun xcresulttool get test-results tests --path build/results/unit.xcresult
```
For a UI test failure, the bundle in `build/results/ui.xcresult` also holds the failure screenshot:
`xcrun xcresulttool export attachments --path build/results/ui.xcresult --output-path build/results/attachments`.

## Rules
- Never delete, skip (`.disabled`) or weaken an assertion to make a test pass; fix the code or explain to the user why the test is wrong.
- Flaky test → fix the cause (missing wait, shared state), don't retry-loop it.
