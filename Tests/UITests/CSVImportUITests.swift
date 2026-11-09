import XCTest

final class CSVImportUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// The seeded Serbian folder already has `kuća`; the file's last row has no front.
    @MainActor
    func testImportIntoFolder() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launchEnvironment["UITEST_CSV"] = "front;back;context\nkuća;дом\nmačka;кошка;Mačka spava.\n;prazno\n"
        app.launch()

        let serbian = app.buttons["row.folder.Serbian"]
        XCTAssertTrue(serbian.waitForExistence(timeout: 5))
        serbian.tap()
        app.buttons["folder.more"].tap()
        app.buttons["folder.importCSV"].tap()

        let count = app.staticTexts["csvImport.count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))
        XCTAssertEqual(count.label, "1")
        XCTAssertEqual(app.staticTexts["csvImport.duplicates"].label, "1")
        XCTAssertEqual(app.staticTexts["csvImport.skipped"].label, "1")

        app.buttons["csvImport.confirm"].tap()
        XCTAssertTrue(app.buttons["row.card.mačka"].waitForExistence(timeout: 5))
    }

    /// No folders yet: Import CSV from the empty state, and the folder is created from the
    /// import's folder picker. The toolbar's Import CSV is on the screenshot tour.
    @MainActor
    func testImportFromHomeIntoNewFolder() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-reset"]
        app.launchEnvironment["UITEST_CSV"] = "kuća;дом\npas;собака\n"
        app.launch()

        app.buttons["home.emptyImportCSV"].tap()
        let confirm = app.buttons["csvImport.confirm"]
        XCTAssertTrue(app.staticTexts["csvImport.count"].waitForExistence(timeout: 5))
        XCTAssertFalse(confirm.isEnabled)

        app.buttons["csvImport.folder"].tap()
        let newFolder = app.buttons["folderPicker.newFolder"]
        XCTAssertTrue(newFolder.waitForExistence(timeout: 5))
        newFolder.tap()
        let name = app.textFields["folderForm.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        // Over the picker the sheet's focus can land after the first keystroke on a slow CI runner.
        name.tap()
        name.typeText("Serbian")
        app.buttons["folderForm.save"].tap()

        let enabled = expectation(for: NSPredicate(format: "isEnabled == true"), evaluatedWith: confirm)
        wait(for: [enabled], timeout: 5)
        confirm.tap()
        let serbian = app.buttons["row.folder.Serbian"]
        XCTAssertTrue(serbian.waitForExistence(timeout: 5))
        XCTAssertTrue(serbian.label.contains("2 due"), serbian.label)
    }
}
