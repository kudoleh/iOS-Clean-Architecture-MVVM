//
//  MovieDetailsViewModelTests.swift
//  ExampleMVVMTests
//
//  Created by Oleh Kudinov on 17.08.19.
//

import XCTest

class MovieDetailsViewModelTests: XCTestCase {
    
    private enum PosterImageDowloadError: Error {
        case someError
    }
    
    func test_updatePosterImageWithWidthEventReceived_thenImageWithThisWidthIsDownloaded() {
        // given
        let posterImagesRepository = PosterImagesRepositoryMock()
        posterImagesRepository.expectation = self.expectation(description: "Image with download")
        let expectedImage = "image data".data(using: .utf8)!
        posterImagesRepository.image = expectedImage

        let viewModel = DefaultMovieDetailsViewModel(movie: Movie.stub(posterPath: "posterPath"),
                                                     posterImagesRepository: posterImagesRepository)
        
        posterImagesRepository.validateInput = { (imagePath: String, width: Int) in
            XCTAssertEqual(imagePath, "posterPath")
            XCTAssertEqual(width, 200)
        }
        
        // when
        viewModel.updatePosterImage(width: 200)
        
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(viewModel.posterImage.value, expectedImage)
    }
}
