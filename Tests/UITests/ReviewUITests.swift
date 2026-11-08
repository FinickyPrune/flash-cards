import XCTest

final class ReviewUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testReviewFolderThenAllCaughtUp() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()

        // Season 1 holds three sample cards, all due or new.
        for folder in ["English", "Breaking Bad", "Season 1"] {
            let row = app.buttons["row.folder.\(folder)"]
            XCTAssertTrue(row.waitForExistence(timeout: 5))
            row.tap()
        }
        let play = app.buttons["folder.play"]
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        play.tap()

        let card = app.buttons["review.card"]
        let good = app.buttons["review.rating.good"]
        for _ in 1 ... 3 {
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            XCTAssertFalse(good.exists)
            card.tap()
            XCTAssertTrue(good.waitForExistence(timeout: 5))
            good.tap()
        }

        let reviewed = app.staticTexts["review.reviewed"]
        XCTAssertTrue(reviewed.waitForExistence(timeout: 5))
        XCTAssertEqual(reviewed.label, "Reviewed 3")
        // Good never makes a card due again today, so Play would give no new session.
        XCTAssertFalse(app.buttons["review.more"].exists)
        app.buttons["review.done"].tap()

        XCTAssertTrue(play.waitForExistence(timeout: 5))
        play.tap()
        XCTAssertTrue(app.descendants(matching: .any)["review.allCaughtUp"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["review.practice"].exists)
    }

    @MainActor
    func testShowAnswerAndMoreAfterAgain() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()

        for folder in ["English", "Breaking Bad", "Season 1"] {
            let row = app.buttons["row.folder.\(folder)"]
            XCTAssertTrue(row.waitForExistence(timeout: 5))
            row.tap()
        }
        app.buttons["folder.play"].tap()

        // Two due cards, then a new one. Again on the new card brings it back at the end and
        // leaves it due today, so More is offered. (Again on a due card is a lapse: tomorrow.)
        let showAnswer = app.buttons["review.showAnswer"]
        for rating in ["good", "good", "again", "good"] {
            XCTAssertTrue(showAnswer.waitForExistence(timeout: 5))
            XCTAssertFalse(app.buttons["review.rating.good"].exists)
            showAnswer.tap()
            let button = app.buttons["review.rating.\(rating)"]
            XCTAssertTrue(button.waitForExistence(timeout: 5))
            XCTAssertFalse(showAnswer.exists)
            button.tap()
        }

        XCTAssertTrue(app.buttons["review.more"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["review.done"].exists)
    }

    @MainActor
    func testPlayFromFolderRowContextMenu() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()

        let english = app.buttons["row.folder.English"]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        english.press(forDuration: 1)
        app.buttons["folderAction.play"].tap()

        XCTAssertTrue(app.buttons["review.card"].waitForExistence(timeout: 5))
    }
}
