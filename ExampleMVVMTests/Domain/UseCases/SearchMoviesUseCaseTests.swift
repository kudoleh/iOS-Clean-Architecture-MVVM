//
//  SearchMoviesUseCaseTests.swift
//  CodeChallengeTests
//
//  Created by Oleh Kudinov on 01.10.18.
//

import XCTest

class SearchMoviesUseCaseTests: XCTestCase {
    
    static let moviesPages: [MoviesPage] = {
        let page1 = MoviesPage(page: 1, totalPages: 2, movies: [
            Movie.stub(id: "1", title: "title1", posterPath: "/1", overview: "overview1"),
            Movie.stub(id: "2", title: "title2", posterPath: "/2", overview: "overview2")])
        let page2 = MoviesPage(page: 2, totalPages: 2, movies: [
            Movie.stub(id: "3", title: "title3", posterPath: "/3", overview: "overview3")])
        return [page1, page2]
    }()
    
    enum MoviesRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    class MoviesQueriesRepositoryMock: MoviesQueriesRepository {
        var recentQueries: [MovieQuery] = []
        
        func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
            completion(.success(recentQueries))
        }
        func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {
            recentQueries.append(query)
        }
    }
    
    struct MoviesRepositoryMock: MoviesRepository {
        var result: Result<MoviesPage, Error>
        func fetchMoviesList(query: MovieQuery, page: Int, cached: @escaping (MoviesPage) -> Void, completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
            completion(result)
            return nil
        }
    }
    
    func testSearchMoviesUseCase_whenSuccessfullyFetchesMoviesForQuery_thenQueryIsSavedInRecentQueries() {
        // given
        let expectation = self.expectation(description: "Recent query saved")
        expectation.expectedFulfillmentCount = 2
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = DefaultSearchMoviesUseCase(moviesRepository: MoviesRepositoryMock(result: .success(SearchMoviesUseCaseTests.moviesPages[0])),
                                                 moviesQueriesRepository: moviesQueriesRepository)

        // when
        let requestValue = SearchMoviesUseCaseRequestValue(query: MovieQuery(query: "title1"),
                                                           page: 0)
        _ = useCase.execute(requestValue: requestValue, cached: { _ in }) { _ in
            expectation.fulfill()
        }
        // then
        var recents = [MovieQuery]()
        moviesQueriesRepository.fetchRecentsQueries(maxCount: 1) { result in
            recents = (try? result.get()) ?? []
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(recents.contains(MovieQuery(query: "title1")))
    }
    
    func testSearchMoviesUseCase_whenFailedFetchingMoviesForQuery_thenQueryIsNotSavedInRecentQueries() {
        // given
        let expectation = self.expectation(description: "Recent query should not be saved")
        expectation.expectedFulfillmentCount = 2
        let moviesQueriesRepository = MoviesQueriesRepositoryMock()
        let useCase = DefaultSearchMoviesUseCase(moviesRepository: MoviesRepositoryMock(result: .failure(MoviesRepositorySuccessTestError.failedFetching)),
                                                 moviesQueriesRepository: moviesQueriesRepository)
        
        // when
        let requestValue = SearchMoviesUseCaseRequestValue(query: MovieQuery(query: "title1"),
                                                           page: 0)
        _ = useCase.execute(requestValue: requestValue, cached: { _ in }) { _ in
            expectation.fulfill()
        }
        // then
        var recents = [MovieQuery]()
        moviesQueriesRepository.fetchRecentsQueries(maxCount: 1) { result in
            recents = (try? result.get()) ?? []
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(recents.isEmpty)
    }
}
