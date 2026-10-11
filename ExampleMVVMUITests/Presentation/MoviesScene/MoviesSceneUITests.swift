import XCTest

class MoviesSceneUITests: XCTestCase {

    override func setUp() {

        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testOpenMovieDetails_whenSearchBatmanAndTapOnFirstResultRow_thenMovieDetailsViewOpensWithTitleBatman() {

        let app = XCUIApplication()

        // Search for Batman
        let searchText = "Batman Begins"
        let searchField = app.searchFields[AccessibilityIdentifier.searchField]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))
        searchField.tap()
        // Appending "\n" submits the search the same way the keyboard's search key does,
        // without depending on the on-screen keyboard being rendered/tappable.
        searchField.typeText(searchText + "\n")

        // Tap on first result row
        app.tables.cells.staticTexts[searchText].tap()
        
        // Make sure movie details view
        XCTAssertTrue(app.otherElements[AccessibilityIdentifier.movieDetailsView].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars[searchText].waitForExistence(timeout: 5))
    }
}
