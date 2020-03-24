//
//  MoviesListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct MoviesListViewModelClosures {
    let showMovieDetails: (Movie) -> Void
    let showMovieQueriesSuggestions: (MoviesListViewModelInput) -> Void
    let closeMovieQueriesSuggestions: () -> Void
}

enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}

protocol MoviesListViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func showQueriesSuggestions()
    func closeQueriesSuggestions()
    func didSelect(at indexPath: IndexPath)
    func didSelect(movieQuery: MovieQuery)
}

protocol MoviesListViewModelOutput {
    var items: Observable<[MoviesListItemViewModel]> { get }
    var loadingType: Observable<MoviesListViewModelLoading?> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
}

protocol MoviesListViewModel: MoviesListViewModelInput, MoviesListViewModelOutput {}

final class DefaultMoviesListViewModel: MoviesListViewModel {

    private let searchMoviesUseCase: SearchMoviesUseCase
    private let closures: MoviesListViewModelClosures?

    private(set) var currentPage: Int = 0
    private var totalPageCount: Int = 1
    var hasMorePages: Bool {
        return currentPage < totalPageCount
    }
    var nextPage: Int {
        guard hasMorePages else { return currentPage }
        return currentPage + 1
    }
    private var movies: [Movie] = []
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    
    // MARK: - OUTPUT
    let items: Observable<[MoviesListItemViewModel]> = Observable([])
    let loadingType: Observable<MoviesListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString("Movies", comment: "")
    let emptyDataTitle = NSLocalizedString("Search results", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder = NSLocalizedString("Search Movies", comment: "")

    init(searchMoviesUseCase: SearchMoviesUseCase,
         closures: MoviesListViewModelClosures? = nil) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.closures = closures
    }
    
    private func appendPage(moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages
        movies += moviesPage.movies
        items.value += moviesPage.movies.map(MoviesListItemViewModel.init)
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        movies.removeAll()
        items.value.removeAll()
    }
    
    private func load(movieQuery: MovieQuery, loadingType: MoviesListViewModelLoading) {
        self.loadingType.value = loadingType
        query.value = movieQuery.query
        
        let moviesRequest = SearchMoviesUseCaseRequestValue(query: movieQuery, page: nextPage)
        moviesLoadTask = searchMoviesUseCase.execute(requestValue: moviesRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let moviesPage):
                self.appendPage(moviesPage: moviesPage)
            case .failure(let error):
                self.handle(error: error)
            }
            self.loadingType.value = .none
        }
    }
    
    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: "")
    }

    private func update(movieQuery: MovieQuery) {
           resetPages()
           load(movieQuery: movieQuery, loadingType: .fullScreen)
    }
}

// MARK: - INPUT. View event methods
extension DefaultMoviesListViewModel {

    func viewDidLoad() { }
    
    func didLoadNextPage() {
        guard hasMorePages, loadingType.value == .none else { return }
        load(movieQuery: MovieQuery(query: query.value),
             loadingType: .nextPage)
    }
    
    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(movieQuery: MovieQuery(query: query))
    }
    
    func didCancelSearch() {
        moviesLoadTask?.cancel()
    }

    func showQueriesSuggestions() {
        closures?.showMovieQueriesSuggestions(self)
    }
    
    func closeQueriesSuggestions() {
        closures?.closeMovieQueriesSuggestions()
    }
    
    func didSelect(at indexPath: IndexPath) {
        closures?.showMovieDetails(movies[indexPath.row])
    }
}

// MARK: - INPUT. Events from other ViewModel
extension DefaultMoviesListViewModel {

    func didSelect(movieQuery: MovieQuery) {
        update(movieQuery: movieQuery)
    }
}
