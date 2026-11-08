import XCTest

/// Walks the seeded app through its screens in light and then dark mode and attaches a screenshot
/// named `<stop>-<light|dark>` at each stop, for `make screenshots`. Skipped unless that target runs
/// it (it sets `TEST_RUNNER_SCREENSHOT_TOUR`). Add a stop when a PR changes a screen the tour
/// doesn't reach yet.
final class ScreenshotTour: XCTestCase {
    private var appearance = "light"

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["SCREENSHOT_TOUR"] == "1",
            "Runs only from make screenshots"
        )
        continueAfterFailure = false
    }

    @MainActor
    func testTour() {
        // The app takes its appearance from a launch argument; the simulator's setting is left alone.
        for name in ["light", "dark"] {
            appearance = name
            tour()
            largestText()
        }
    }

    /// Home and a folder at the largest accessibility text size, to catch clipping.
    @MainActor
    private func largestText() {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uitest-seed", "-uitest-\(appearance)",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
        ]
        app.launch()
        let english = app.buttons["row.folder.English"]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["English"].firstMatch.waitForExistence(timeout: 5))
        stop("home-largest-text", in: app)
        english.tap()
        XCTAssertTrue(app.buttons["row.folder.Breaking Bad"].waitForExistence(timeout: 5))
        stop("folder-largest-text", in: app)
        app.buttons["folder.newCard"].tap()
        XCTAssertTrue(app.textFields["cardEditor.front"].waitForExistence(timeout: 5))
        // Without the keyboard, so the form itself shows.
        app.buttons["cardEditor.keyboardDone"].tap()
        stop("card-editor-largest-text", in: app)
    }

    /// One pass; relaunching resets the in-memory seed, so both passes start from the same data.
    @MainActor
    private func tour() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed", "-uitest-\(appearance)"]
        app.launch()

        let english = app.buttons["row.folder.English"]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        assertAppearance(of: app)
        stop("home", in: app)
        newFolderSheet(in: app)
        english.tap()
        open("Breaking Bad", in: app)
        XCTAssertTrue(app.buttons["row.folder.Season 1"].waitForExistence(timeout: 5))
        stop("folder-subfolders", in: app)
        open("Season 1", in: app)
        XCTAssertTrue(app.buttons["folder.play"].waitForExistence(timeout: 5))
        stop("folder", in: app)

        cardEditor(in: app)
        reviewSeason1(in: app)
        playEmptyFolderFromContextMenu(in: app)
    }

    /// Season 1 holds three cards; the first has a context and a screenshot, the third is new.
    /// Again on the new one brings it back at the end and leaves it due today, so the summary
    /// offers More; the second session has no More.
    @MainActor
    private func reviewSeason1(in app: XCUIApplication) {
        let play = app.buttons["folder.play"]
        let card = app.buttons["review.card"]
        play.tap()
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        stop("review-front", in: app)
        for (index, rating) in ["good", "good", "again", "good"].enumerated() {
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            card.tap()
            let button = app.buttons["review.rating.\(rating)"]
            XCTAssertTrue(button.waitForExistence(timeout: 5))
            if index == 0 {
                stop("review-flipped", in: app)
            }
            button.tap()
        }
        let more = app.buttons["review.more"]
        XCTAssertTrue(more.waitForExistence(timeout: 5))
        stop("review-summary-more", in: app)
        more.tap()
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        card.tap()
        let good = app.buttons["review.rating.good"]
        XCTAssertTrue(good.waitForExistence(timeout: 5))
        good.tap()
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
        XCTAssertTrue(play.waitForExistence(timeout: 5))
    }

    @MainActor
    private func playEmptyFolderFromContextMenu(in app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let season2 = app.buttons["row.folder.Season 2"]
        XCTAssertTrue(season2.waitForExistence(timeout: 5))
        season2.tap()
        XCTAssertTrue(app.descendants(matching: .any)["folder.empty"].firstMatch.waitForExistence(timeout: 5))
        stop("folder-empty", in: app)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(season2.waitForExistence(timeout: 5))
        season2.press(forDuration: 1)
        let play = app.buttons["folderAction.play"]
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        stop("folder-context-menu", in: app)
        app.buttons["folderAction.appearance"].tap()
        let done = app.buttons["appearance.done"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        stop("appearance", in: app)
        done.tap()
        season2.press(forDuration: 1)
        app.buttons["folderAction.rename"].tap()
        let cancel = app.buttons["folderForm.cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        stop("rename", in: app)
        cancel.tap()
        season2.press(forDuration: 1)
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        play.tap()
        XCTAssertTrue(app.descendants(matching: .any)["review.empty"].firstMatch.waitForExistence(timeout: 5))
        stop("review-empty", in: app)
    }

    /// Season 1's card editor: a new card, then editing "cook" scrolled down to Delete Card.
    @MainActor
    private func cardEditor(in app: XCUIApplication) {
        app.buttons["folder.newCard"].tap()
        let cancel = app.buttons["cardEditor.cancel"]
        XCTAssertTrue(app.textFields["cardEditor.front"].waitForExistence(timeout: 5))
        stop("card-editor-new", in: app)
        cancel.tap()

        let cook = app.buttons["row.card.cook"]
        XCTAssertTrue(cook.waitForExistence(timeout: 5))
        cook.tap()
        let delete = app.buttons["cardEditor.delete"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        // Delete Card is the form's last row, below the fold on most screens.
        app.swipeUp()
        XCTAssertTrue(delete.waitForExistence(timeout: 5))
        stop("card-editor-edit", in: app)
        cancel.tap()
        XCTAssertTrue(app.buttons["folder.play"].waitForExistence(timeout: 5))
    }

    @MainActor
    private func newFolderSheet(in app: XCUIApplication) {
        app.buttons["home.newFolder"].tap()
        XCTAssertTrue(app.buttons["palette.lagoon"].waitForExistence(timeout: 5))
        stop("new-folder", in: app)
        app.buttons["folderForm.cancel"].tap()
        XCTAssertTrue(app.buttons["row.folder.English"].waitForExistence(timeout: 5))
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
        attachment.name = "\(name)-\(appearance)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Home is mostly background, so its mean brightness tells a light pass from a dark one; a
    /// dark pass that came out light once went unnoticed (#51).
    @MainActor
    private func assertAppearance(of app: XCUIApplication) {
        guard let image = app.screenshot().image.cgImage else {
            return XCTFail("No screenshot")
        }
        var pixel = [UInt8](repeating: 0, count: 4)
        let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.interpolationQuality = .high
        context?.draw(image, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        let brightness = (Int(pixel[0]) + Int(pixel[1]) + Int(pixel[2])) / 3
        XCTAssertEqual(
            brightness < 128,
            appearance == "dark",
            "Mean brightness \(brightness) in the \(appearance) pass"
        )
    }
}
