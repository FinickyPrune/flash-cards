import XCTest

final class CatalogUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testCreateRenameAndDeleteSubfolder() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-reset"]
        app.launch()

        app.buttons["home.newFolder"].tap()
        let name = app.textFields["folderForm.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText("English")
        app.buttons["folderForm.save"].tap()

        app.buttons["row.folder.English"].tap()
        app.buttons["folder.newSubfolder"].tap()
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText("Season 1")
        app.buttons["folderForm.save"].tap()

        app.buttons["row.folder.Season 1"].press(forDuration: 1)
        app.buttons["folderAction.rename"].tap()
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: "Season 1".count) + "Pilot")
        app.buttons["folderForm.save"].tap()
        let renamed = app.buttons["row.folder.Pilot"]
        XCTAssertTrue(renamed.waitForExistence(timeout: 5))

        renamed.press(forDuration: 1)
        app.buttons["folderAction.delete"].tap()
        // The dialog action matches more than one element in the iOS 26 accessibility tree.
        app.buttons["folderAction.confirmDelete"].firstMatch.tap()
        XCTAssertTrue(app.descendants(matching: .any)["folder.empty"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(renamed.exists)
    }
}
