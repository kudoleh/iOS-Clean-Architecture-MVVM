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
        app.searchFields[localized("Search Movies")].tap()
        if !app.keys["A"].waitForExistence(timeout: 5) {
            XCTFail("The keyboard could not be found. Use keyboard shortcut COMMAND + SHIFT + K while simulator has focus on text input")
        }
        app.searchFields[localized("Search Movies")].typeText("Batman Begins")
        app.buttons["Search"].tap()
        
        // Tap on first result row
        _ = app.cells[String(format:localized("Result row %d"), 1)].waitForExistence(timeout: 10)
        app.cells[String(format: localized("Result row %d"), 1)].tap()
        
        // Make sure movie details view
        XCTAssertTrue(app.otherElements[localized("Movie details view")].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars[localized("Batman Begins")].waitForExistence(timeout: 5))
    }
    
    private func localized(_ key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle(for: Self.self), comment: "")
    }
}
