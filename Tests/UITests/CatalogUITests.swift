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

        let english = app.buttons["row.folder.English"]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        english.tap()
        app.buttons["folder.newSubfolder"].tap()
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText("Season 1")
        app.buttons["folderForm.save"].tap()

        let season = app.buttons["row.folder.Season 1"]
        XCTAssertTrue(season.waitForExistence(timeout: 5))
        season.press(forDuration: 1)
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

    @MainActor
    func testPaletteForNewFolderAndSubfolderAppearance() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-reset"]
        app.launch()

        app.buttons["home.newFolder"].tap()
        let name = app.textFields["folderForm.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText("English")
        app.buttons["palette.mint"].tap()
        app.buttons["folderForm.save"].tap()

        let english = app.buttons["row.folder.English"]
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        english.press(forDuration: 1)
        app.buttons["folderAction.appearance"].tap()
        let mint = app.buttons["palette.mint"]
        XCTAssertTrue(mint.waitForExistence(timeout: 5))
        XCTAssertTrue(mint.isSelected)
        app.buttons["appearance.done"].tap()

        english.tap()
        app.buttons["folder.newSubfolder"].tap()
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText("Season 1")
        app.buttons["folderForm.save"].tap()
        let season = app.buttons["row.folder.Season 1"]
        XCTAssertTrue(season.waitForExistence(timeout: 5))

        season.press(forDuration: 1)
        app.buttons["folderAction.appearance"].tap()
        let sameAsParent = app.switches["appearance.sameAsParent"]
        XCTAssertTrue(sameAsParent.waitForExistence(timeout: 5))
        XCTAssertEqual(sameAsParent.value as? String, "1")
        app.buttons["palette.rose"].tap()
        XCTAssertEqual(sameAsParent.value as? String, "0")
        app.buttons["appearance.done"].tap()

        season.press(forDuration: 1)
        app.buttons["folderAction.appearance"].tap()
        XCTAssertTrue(sameAsParent.waitForExistence(timeout: 5))
        XCTAssertEqual(sameAsParent.value as? String, "0")
        XCTAssertTrue(app.buttons["palette.rose"].isSelected)
    }

    @MainActor
    func testNewFolderPreviewShowsName() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-reset"]
        app.launch()

        app.buttons["home.newFolder"].tap()
        let name = app.textFields["folderForm.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText("Serbian")
        XCTAssertEqual(app.staticTexts["folderForm.previewName"].label, "Serbian")
    }

    /// The folder screen's More menu acts on the folder itself; deleting it leaves the screen.
    @MainActor
    func testFolderMoreMenu() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-reset"]
        app.launch()

        let english = createFolder("English", with: "home.newFolder", in: app)
        english.tap()
        createFolder("Season 1", with: "folder.newSubfolder", in: app).tap()

        let name = app.textFields["folderForm.name"]
        let more = app.buttons["folder.more"]
        let title = app.staticTexts["folder.title"]
        XCTAssertTrue(more.waitForExistence(timeout: 5))
        more.tap()
        app.buttons["folderAction.rename"].tap()
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: "Season 1".count) + "Pilot")
        app.buttons["folderForm.save"].tap()
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertEqual(title.label, "Pilot")

        more.tap()
        app.buttons["folderAction.appearance"].tap()
        XCTAssertTrue(app.switches["appearance.sameAsParent"].waitForExistence(timeout: 5))
        app.buttons["palette.rose"].tap()
        app.buttons["appearance.done"].tap()

        more.tap()
        app.buttons["folderAction.move"].tap()
        let topLevel = app.buttons["move.topLevel"]
        XCTAssertTrue(topLevel.waitForExistence(timeout: 5))
        topLevel.tap()
        // A root folder has no parent to follow.
        more.tap()
        app.buttons["folderAction.appearance"].tap()
        XCTAssertTrue(app.buttons["palette.rose"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.switches["appearance.sameAsParent"].exists)
        XCTAssertTrue(app.buttons["palette.rose"].isSelected)
        app.buttons["appearance.done"].tap()

        more.tap()
        app.buttons["folderAction.delete"].tap()
        app.buttons["folderAction.confirmDelete"].firstMatch.tap()
        // Back on English, now empty: Pilot moved out before it was deleted.
        XCTAssertTrue(app.descendants(matching: .any)["folder.empty"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(title.label, "English")
        // The empty state's buttons sit in a list row; only the tapped one may act.
        app.buttons["folder.emptyNewSubfolder"].tap()
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        app.buttons["folderForm.cancel"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(english.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["row.folder.Pilot"].exists)
    }

    /// Creates a folder through the form `button` opens; returns its row.
    @MainActor
    @discardableResult
    private func createFolder(_ folderName: String, with button: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons[button].tap()
        let name = app.textFields["folderForm.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.typeText(folderName)
        app.buttons["folderForm.save"].tap()
        let row = app.buttons["row.folder.\(folderName)"]
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        return row
    }
}
