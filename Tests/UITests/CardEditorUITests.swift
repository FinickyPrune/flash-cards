import XCTest

final class CardEditorUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAddCardThenEditItsBack() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-reset"]
        app.launch()

        app.buttons["home.newFolder"].tap()
        let name = app.textFields["folderForm.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText("Serbian")
        app.buttons["folderForm.save"].tap()
        let folder = app.buttons["row.folder.Serbian"]
        XCTAssertTrue(folder.waitForExistence(timeout: 5))
        folder.tap()

        app.buttons["folder.newCard"].tap()
        let save = app.buttons["cardEditor.save"]
        let front = app.textFields["cardEditor.front"]
        XCTAssertTrue(front.waitForExistence(timeout: 5))
        front.typeText("hvala")
        // A new root folder starts on the Translation tile.
        let back = app.textFields["cardEditor.backText"]
        back.tap()
        back.typeText("thanks")
        tapSave(save, in: app)

        let row = app.buttons["row.card.hvala"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertTrue(row.label.contains("thanks"))

        // Edit: switch the back to the Custom text tile.
        row.tap()
        let custom = app.buttons["cardEditor.tile.custom"]
        XCTAssertTrue(custom.waitForExistence(timeout: 5))
        custom.tap()
        // The new tile's field gets focus on its own; wait for it rather than tapping it.
        let focused = expectation(for: NSPredicate(format: "hasKeyboardFocus == true"), evaluatedWith: back)
        wait(for: [focused], timeout: 5)
        back.typeText("thank you")
        tapSave(save, in: app)

        XCTAssertTrue(row.waitForExistence(timeout: 5))
        let predicate = NSPredicate(format: "label CONTAINS %@", "thank you")
        XCTAssertEqual(XCTWaiter.wait(for: [expectation(for: predicate, evaluatedWith: row)], timeout: 5), .completed)

        // Delete from the editor.
        row.tap()
        let delete = app.buttons["cardEditor.delete"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        // The form is a lazy list: on short screens Delete Card is only built once scrolled to.
        for _ in 0 ..< 3 where !delete.exists {
            app.swipeUp()
        }
        XCTAssertTrue(delete.waitForExistence(timeout: 5))
        delete.tap()
        app.buttons["cardEditor.confirmDelete"].firstMatch.tap()
        XCTAssertTrue(app.descendants(matching: .any)["folder.empty"].firstMatch.waitForExistence(timeout: 5))
    }

    /// Folder progress (`catalog.md`): a card added deep in the tree shows up on its own row and
    /// on its parent's, without a restart. Sample data: Breaking Bad holds Season 1 (1 learned of 3)
    /// and an empty Season 2.
    @MainActor
    func testNewCardInSubfolderUpdatesProgress() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()

        app.buttons["row.folder.English"].tap()
        let show = app.buttons["row.folder.Breaking Bad"]
        XCTAssertTrue(show.waitForExistence(timeout: 5))
        XCTAssertTrue(show.label.contains("1 / 3"))
        show.tap()
        let season = app.buttons["row.folder.Season 2"]
        XCTAssertTrue(season.waitForExistence(timeout: 5))
        XCTAssertFalse(season.label.contains("/"))
        season.tap()

        app.buttons["folder.newCard"].tap()
        let front = app.textFields["cardEditor.front"]
        XCTAssertTrue(front.waitForExistence(timeout: 5))
        front.typeText("pilot")
        let back = app.textFields["cardEditor.backText"]
        back.tap()
        back.typeText("пилот")
        tapSave(app.buttons["cardEditor.save"], in: app)
        XCTAssertTrue(app.buttons["row.card.pilot"].waitForExistence(timeout: 5))

        // The system back button has no identifier; it is the first button in the bar.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        waitForLabel(of: season, toContain: "0 / 1")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        waitForLabel(of: show, toContain: "1 / 4")
    }

    @MainActor
    private func waitForLabel(of element: XCUIElement, toContain text: String) {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        XCTAssertEqual(
            XCTWaiter.wait(for: [expectation(for: predicate, evaluatedWith: element)], timeout: 5),
            .completed
        )
    }

    /// Like a user on a short screen (the CI simulator): put the keyboard away, and if the
    /// navigation bar is still hidden by the scrolled form, scroll back to the top.
    @MainActor
    private func tapSave(_ save: XCUIElement, in app: XCUIApplication) {
        app.buttons["cardEditor.keyboardDone"].tap()
        for _ in 0 ..< 3 where !save.waitForExistence(timeout: 2) {
            app.swipeDown()
        }
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        save.tap()
    }
}
