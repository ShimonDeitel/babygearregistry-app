import XCTest

final class BabygearRegistryUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddFlow() {
        app.buttons["addButton"].tap()
        let field1 = app.textFields["field1TextField"]
        XCTAssertTrue(field1.waitForExistence(timeout: 2))
        field1.tap()
        field1.typeText("New Entry")
        app.buttons["saveButton"].tap()
        XCTAssertTrue(app.staticTexts["New Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<(13) {
            app.buttons["addButton"].tap()
            let field1 = app.textFields["field1TextField"]
            if field1.waitForExistence(timeout: 2) {
                field1.tap()
                field1.typeText("Item \(i)")
                app.buttons["saveButton"].tap()
            }
        }
        app.buttons["addButton"].tap()
        XCTAssertTrue(app.buttons["paywallUpgradeButton"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addButton"].tap()
        let field1 = app.textFields["field1TextField"]
        XCTAssertTrue(field1.waitForExistence(timeout: 2))
        field1.tap()
        field1.typeText("Dismiss test")
        app.navigationBars.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testSettingsOpens() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
    }
}
