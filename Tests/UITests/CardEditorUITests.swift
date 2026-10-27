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
        // No cards yet: the row shows no progress.
        XCTAssertFalse(folder.label.contains("/"))
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

        // Back home, the folder row now shows its progress.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let progress = NSPredicate(format: "label CONTAINS %@", "0 / 1")
        XCTAssertEqual(XCTWaiter.wait(for: [expectation(for: progress, evaluatedWith: folder)], timeout: 5), .completed)
        folder.tap()
        XCTAssertTrue(row.waitForExistence(timeout: 5))

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
