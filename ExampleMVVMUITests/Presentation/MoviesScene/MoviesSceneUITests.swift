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
        let searchText = "Batman Begins"
        app.searchFields[AccessibilityIdentifier.searchField].tap()
        if !app.keys["A"].waitForExistence(timeout: 5) {
            XCTFail("The keyboard could not be found. Use keyboard shortcut COMMAND + SHIFT + K while simulator has focus on text input")
        }
        _ = app.searchFields[AccessibilityIdentifier.searchField].waitForExistence(timeout: 10)
        app.searchFields[AccessibilityIdentifier.searchField].typeText(searchText)
        app.buttons["search"].tap()
        
        // Tap on first result row
        app.tables.cells.staticTexts[searchText].tap()
        
        // Make sure movie details view
        XCTAssertTrue(app.otherElements[AccessibilityIdentifier.movieDetailsView].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars[searchText].waitForExistence(timeout: 5))
    }
}
