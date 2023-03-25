import XCTest

class MovieDetailsViewModelTests: XCTestCase {
    
    private enum PosterImageDownloadError: Error {
        case someError
    }
    
    func test_updatePosterImageWithWidthEventReceived_thenImageWithThisWidthIsDownloaded() {
        // given
        let posterImagesRepository = PosterImagesRepositoryMock()

        let expectedImage = "image data".data(using: .utf8)!
        posterImagesRepository.image = expectedImage

        let viewModel = DefaultMovieDetailsViewModel(
            movie: Movie.stub(posterPath: "posterPath"),
            posterImagesRepository: posterImagesRepository,
            mainQueue: DispatchQueueTypeMock()
        )
        
        posterImagesRepository.validateInput = { (imagePath: String, width: Int) in
            XCTAssertEqual(imagePath, "posterPath")
            XCTAssertEqual(width, 200)
        }
        
        // when
        viewModel.updatePosterImage(width: 200)
        
        // then
        XCTAssertEqual(viewModel.posterImage.value, expectedImage)
        XCTAssertEqual(posterImagesRepository.completionCalls, 1)
    }
}
