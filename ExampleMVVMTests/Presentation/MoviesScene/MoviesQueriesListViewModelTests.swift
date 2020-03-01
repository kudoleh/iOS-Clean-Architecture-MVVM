//
//  MoviesQueriesListViewModelTests.swift
//  ExampleMVVMTests
//
//  Created by Oleh Kudinov on 16.08.19.
//

import XCTest

class MoviesQueriesListViewModelTests: XCTestCase {
    
    private enum FetchRecentQueriedUseCase: Error {
        case someError
    }
    
    var movieQueries = [MovieQuery(query: "query1"),
                        MovieQuery(query: "query2"),
                        MovieQuery(query: "query3"),
                        MovieQuery(query: "query4"),
                        MovieQuery(query: "query5")]
    
    class MoviesQueryListViewModelDelegateMock: MoviesQueryListViewModelDelegate {
        var expectation: XCTestExpectation?
        var didNotifiedWithMovieQuery: MovieQuery?
        func moviesQueriesListDidSelect(movieQuery: MovieQuery) {
            didNotifiedWithMovieQuery = movieQuery
            expectation?.fulfill()
        }
    }

    class FetchRecentMovieQueriesUseCaseMock: UseCase {
        var expectation: XCTestExpectation?
        var error: Error?
        var movieQueries: [MovieQuery] = []
        var completion: (Result<[MovieQuery], Error>) -> Void = { _ in }

        func start() -> Cancellable? {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(movieQueries))
            }
            expectation?.fulfill()
            return nil
        }
    }

    func makeFetchRecentMovieQueriesUseCase(_ mock: FetchRecentMovieQueriesUseCaseMock) -> FetchRecentMovieQueriesUseCaseFactory {
        return { _, completion in
            mock.completion = completion
            return mock
        }
    }
    
    
    func test_whenFetchRecentMovieQueriesUseCaseReturnsQueries_thenShowTheseQueries() {
        // given
        let useCase = FetchRecentMovieQueriesUseCaseMock()
        useCase.expectation = self.expectation(description: "Recent query fetched")
        useCase.movieQueries = movieQueries
        let viewModel = DefaultMoviesQueryListViewModel(numberOfQueriesToShow: 3,
                                                        fetchRecentMovieQueriesUseCaseFactory: makeFetchRecentMovieQueriesUseCase(useCase))

        // when
        viewModel.viewWillAppear()
        
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(viewModel.items.value.map { $0.query }, movieQueries.map { $0.query })
    }
    
    func test_whenFetchRecentMovieQueriesUseCaseReturnsError_thenDontShowAnyQuery() {
        // given
        let useCase = FetchRecentMovieQueriesUseCaseMock()
        useCase.expectation = self.expectation(description: "Recent query fetched")
        useCase.error = FetchRecentQueriedUseCase.someError
        let viewModel = DefaultMoviesQueryListViewModel(numberOfQueriesToShow: 3,
                                                        fetchRecentMovieQueriesUseCaseFactory: makeFetchRecentMovieQueriesUseCase(useCase))
        
        // when
        viewModel.viewWillAppear()
        
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(viewModel.items.value.isEmpty)
    }
    
    func test_whenDidSelectQueryEventIsReceived_thenNotifyDelegate() {
        // given
        let selectedQueryItem = MovieQuery(query: "query1")
        let delegate = MoviesQueryListViewModelDelegateMock()
        delegate.expectation = self.expectation(description: "Delegate notified")
        
        let viewModel = DefaultMoviesQueryListViewModel(numberOfQueriesToShow: 3,
                                                        fetchRecentMovieQueriesUseCaseFactory: makeFetchRecentMovieQueriesUseCase(FetchRecentMovieQueriesUseCaseMock()),
                                                        delegate: delegate)
        
        // when
        viewModel.didSelect(item: DefaultMoviesQueryListItemViewModel(query: selectedQueryItem.query))
        
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(delegate.didNotifiedWithMovieQuery, selectedQueryItem)
    }
}
