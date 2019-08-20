//
//  MoviesSceneUITests.swift
//  MoviesSceneUITests
//
//  Created by Oleh Kudinov on 05.08.19.
//

import XCTest

class MoviesSceneUITests: XCTestCase {

    override func setUp() {

        continueAfterFailure = false
        XCUIApplication().launch()
    }

    // NOTE: for UI tests to work the keyboard of simulator must be on.
    // Keyboard shortcut COMMAND + SHIFT + K while simulator has focus
    func testOpenMovieDetails_whenSearchBatmanAndTapOnFirstResultRow_thenMovieDetailsViewOpensWithTitleBatman() {
        
        let app = XCUIApplication()
        
        // Search for Batman
        app.searchFields["Search Movies"].tap()
        if !app.keys["A"].waitForExistence(timeout: 5) {
            XCTFail("The simulator keyboard could not be found. Use keyboard shortcut COMMAND + SHIFT + K while simulator has focus on text input")
        }
        app.searchFields["Search Movies"].typeText("Batman Begins")
        app/*@START_MENU_TOKEN@*/.buttons["Search"]/*[[".keyboards.buttons[\"Search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Tap on first result row
        _ = app.cells[String(format: NSLocalizedString("Result row %d", comment: ""), 1)].waitForExistence(timeout: 10)
        app.cells[String(format: NSLocalizedString("Result row %d", comment: ""), 1)].tap()
        
        // Make sure movie details view
        XCTAssertTrue(app.otherElements[NSLocalizedString("Movie details view", comment: "")].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Batman Begins"].waitForExistence(timeout: 5))
    }
}
