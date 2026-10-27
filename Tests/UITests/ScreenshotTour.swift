import XCTest

/// Walks the seeded app through its screens and attaches a named screenshot at each stop, for
/// `make screenshots`. Skipped unless that target runs it (it sets `TEST_RUNNER_SCREENSHOT_TOUR`).
/// Add a stop when a PR changes a screen the tour doesn't reach yet.
final class ScreenshotTour: XCTestCase {
    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["SCREENSHOT_TOUR"] == "1",
            "Runs only from make screenshots"
        )
        continueAfterFailure = false
    }

    @MainActor
    func testTour() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()

        let english = app.buttons["row.folder.English"]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        stop("home", in: app)
        english.tap()
        open("Breaking Bad", in: app)
        open("Season 1", in: app)
        XCTAssertTrue(app.buttons["folder.play"].waitForExistence(timeout: 5))
        stop("folder", in: app)

        reviewSeason1(in: app)
        playEmptyFolderFromContextMenu(in: app)
    }

    /// Season 1 holds three cards; the first has a context and a screenshot.
    @MainActor
    private func reviewSeason1(in app: XCUIApplication) {
        let play = app.buttons["folder.play"]
        let card = app.buttons["review.card"]
        let good = app.buttons["review.rating.good"]
        play.tap()
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        stop("review-front", in: app)
        for index in 0 ..< 3 {
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            card.tap()
            XCTAssertTrue(good.waitForExistence(timeout: 5))
            if index == 0 {
                stop("review-flipped", in: app)
            }
            good.tap()
        }
        let done = app.buttons["review.done"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        stop("review-summary", in: app)

        done.tap()
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        play.tap()
        let practice = app.buttons["review.practice"]
        XCTAssertTrue(practice.waitForExistence(timeout: 5))
        stop("review-caught-up", in: app)
        practice.tap()
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        card.tap()
        XCTAssertTrue(good.waitForExistence(timeout: 5))
        stop("review-practice", in: app)
        app.buttons["review.close"].tap()
    }

    @MainActor
    private func playEmptyFolderFromContextMenu(in app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let season2 = app.buttons["row.folder.Season 2"]
        XCTAssertTrue(season2.waitForExistence(timeout: 5))
        season2.press(forDuration: 1)
        let play = app.buttons["folderAction.play"]
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        stop("folder-context-menu", in: app)
        play.tap()
        XCTAssertTrue(app.descendants(matching: .any)["review.empty"].firstMatch.waitForExistence(timeout: 5))
        stop("review-empty", in: app)
    }

    @MainActor
    private func open(_ folder: String, in app: XCUIApplication) {
        let row = app.buttons["row.folder.\(folder)"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()
    }

    /// The attachment name becomes the file name: `build/screenshots/<name>-<appearance>.png`.
    @MainActor
    private func stop(_ name: String, in app: XCUIApplication) {
        // The stop's element already exists; this lets its transition finish so the frame is settled.
        Thread.sleep(forTimeInterval: 0.7)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
