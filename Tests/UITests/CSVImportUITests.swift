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
}
