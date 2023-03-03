import XCTest

class MoviesListViewModelTests: XCTestCase {
    
    private enum SearchMoviesUseCaseError: Error {
        case someError
    }
    
    let moviesPages: [MoviesPage] = {
        let page1 = MoviesPage(page: 1, totalPages: 2, movies: [
            Movie.stub(id: "1", title: "title1", posterPath: "/1", overview: "overview1"),
            Movie.stub(id: "2", title: "title2", posterPath: "/2", overview: "overview2")])
        let page2 = MoviesPage(page: 2, totalPages: 2, movies: [
            Movie.stub(id: "3", title: "title3", posterPath: "/3", overview: "overview3")])
        return [page1, page2]
    }()
    
    class SearchMoviesUseCaseMock: SearchMoviesUseCase {
        var executeCallCount: Int = 0
        var error: Error?
        var page = MoviesPage(page: 0, totalPages: 0, movies: [])
        
        func execute(requestValue: SearchMoviesUseCaseRequestValue,
                     cached: @escaping (MoviesPage) -> Void,
                     completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(page))
            }
            executeCallCount += 1
            return nil
        }
    }
    
    func test_whenSearchMoviesUseCaseRetrievesFirstPage_thenViewModelContainsOnlyFirstPage() {
        // given
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        searchMoviesUseCaseMock.page = MoviesPage(page: 1, totalPages: 2, movies: moviesPages[0].movies)
        let viewModel = DefaultMoviesListViewModel(searchMoviesUseCase: searchMoviesUseCaseMock)
        // when
        viewModel.didSearch(query: "query")
        
        // then
        XCTAssertEqual(viewModel.currentPage, 1)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
    }
    
    func test_whenSearchMoviesUseCaseRetrievesFirstAndSecondPage_thenViewModelContainsTwoPages() {
        // given
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        searchMoviesUseCaseMock.page = MoviesPage(page: 1, totalPages: 2, movies: moviesPages[0].movies)
        let viewModel = DefaultMoviesListViewModel(searchMoviesUseCase: searchMoviesUseCaseMock)
        // when
        viewModel.didSearch(query: "query")
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
        
        searchMoviesUseCaseMock.page = MoviesPage(page: 2, totalPages: 2, movies: moviesPages[1].movies)
        
        viewModel.didLoadNextPage()
        
        // then
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 2)
    }
    
    func test_whenSearchMoviesUseCaseReturnsError_thenViewModelContainsError() {
        // given
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        searchMoviesUseCaseMock.error = SearchMoviesUseCaseError.someError
        let viewModel = DefaultMoviesListViewModel(searchMoviesUseCase: searchMoviesUseCaseMock)
        // when
        viewModel.didSearch(query: "query")
        
        // then
        XCTAssertNotNil(viewModel.error)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
    }
    
    func test_whenLastPage_thenHasNoPageIsTrue() {
        // given
        let searchMoviesUseCaseMock = SearchMoviesUseCaseMock()
        searchMoviesUseCaseMock.page = MoviesPage(page: 1, totalPages: 2, movies: moviesPages[0].movies)
        let viewModel = DefaultMoviesListViewModel(searchMoviesUseCase: searchMoviesUseCaseMock)
        // when
        viewModel.didSearch(query: "query")
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 1)
        
        searchMoviesUseCaseMock.page = MoviesPage(page: 2, totalPages: 2, movies: moviesPages[1].movies)

        viewModel.didLoadNextPage()
        
        // then
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertEqual(searchMoviesUseCaseMock.executeCallCount, 2)
    }
}
