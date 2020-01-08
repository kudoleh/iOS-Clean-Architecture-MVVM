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
        app.searchFields[localized("Search Movies")].forceTapElement()
        if !app.keys["A"].waitForExistence(timeout: 5) {
            XCTFail("The keyboard could not be found. Use keyboard shortcut COMMAND + SHIFT + K while simulator has focus on text input")
        }
        app.searchFields[localized("Search Movies")].typeText("Batman Begins")
        app.buttons["Search"].forceTapElement()
        
        // Tap on first result row
        _ = app.cells[String(format:localized("Result row %d"), 1)].waitForExistence(timeout: 10)
        app.cells[String(format: localized("Result row %d"), 1)].forceTapElement()
        
        // Make sure movie details view
        XCTAssertTrue(app.otherElements[localized("Movie details view")].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars[localized("Batman Begins")].waitForExistence(timeout: 5))
    }
    
    private func localized(_ key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle(for: Self.self), comment: "")
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
