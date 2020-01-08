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
        app.searchFields[AccessibilityIdentifier.searchField].forceTapElement()
        if !app.keys["A"].waitForExistence(timeout: 5) {
            XCTFail("The keyboard could not be found. Use keyboard shortcut COMMAND + SHIFT + K while simulator has focus on text input")
        }
        app.searchFields[AccessibilityIdentifier.searchField].typeText("Batman Begins")
        app.buttons["search"].forceTapElement()
        
        // Tap on first result row
        _ = app.cells[String(format: AccessibilityIdentifier.searchResultRow, 1)].waitForExistence(timeout: 10)
        app.cells[String(format: AccessibilityIdentifier.searchResultRow, 1)].forceTapElement()
        
        // Make sure movie details view
        XCTAssertTrue(app.otherElements[AccessibilityIdentifier.movieDetailsView].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Batman Begins"].waitForExistence(timeout: 5))
    }
}

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }
}
