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
        let front = app.textFields["cardEditor.front"]
        XCTAssertTrue(front.waitForExistence(timeout: 5))
        front.typeText("hvala")
        // A new root folder starts on the Translation tile.
        let back = app.textFields["cardEditor.backText"]
        back.tap()
        back.typeText("thanks")
        app.buttons["cardEditor.save"].tap()

        let row = app.buttons["row.card.hvala"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        XCTAssertTrue(row.label.contains("thanks"))

        row.tap()
        XCTAssertTrue(back.waitForExistence(timeout: 5))
        back.tap()
        back.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: "thanks".count) + "thank you")
        app.buttons["cardEditor.save"].tap()

        XCTAssertTrue(row.waitForExistence(timeout: 5))
        let predicate = NSPredicate(format: "label CONTAINS %@", "thank you")
        XCTAssertEqual(XCTWaiter.wait(for: [expectation(for: predicate, evaluatedWith: row)], timeout: 5), .completed)
    }
}
