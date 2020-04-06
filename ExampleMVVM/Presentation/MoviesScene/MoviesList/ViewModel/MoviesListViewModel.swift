//
//  MoviesListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct MoviesListViewModelClosures {
    let showMovieDetails: (Movie) -> Void
    let showMovieQueriesSuggestions: (@escaping (_ didSelect: MovieQuery) -> Void) -> Void
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
}

protocol MoviesListViewModelOutput {
    var pageViewModels: Observable<[MoviesListPageViewModel]> { get }
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

    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }

    private var pages: [MoviesPage] = []
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    
    // MARK: - OUTPUT
    let pageViewModels: Observable<[MoviesListPageViewModel]> = Observable([])
    let loadingType: Observable<MoviesListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return pageViewModels.value.isEmpty }
    let screenTitle = NSLocalizedString("Movies", comment: "")
    let emptyDataTitle = NSLocalizedString("Search results", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder = NSLocalizedString("Search Movies", comment: "")

    init(searchMoviesUseCase: SearchMoviesUseCase,
         closures: MoviesListViewModelClosures? = nil) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.closures = closures
    }
    
    private func insertPage(moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages
        
        if moviesPage.page - 1 < pages.count {
            pages[moviesPage.page - 1] = moviesPage
            pageViewModels.value[moviesPage.page - 1] = .init(moviePage: moviesPage)
        } else {
            pages += [moviesPage]
            pageViewModels.value += [.init(moviePage: moviesPage)]
        }
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        pageViewModels.value.removeAll()
    }
    
    private func load(movieQuery: MovieQuery, loadingType: MoviesListViewModelLoading) {
        self.loadingType.value = loadingType
        query.value = movieQuery.query
        
        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery, page: nextPage),
            cached: { [weak self] cachedMoviesPage in
                guard let self = self, let cachedMoviesPage = cachedMoviesPage else { return }
                self.insertPage(moviesPage: cachedMoviesPage)
            },
            completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let moviesPage):
                    self.insertPage(moviesPage: moviesPage)
                case .failure(let error):
                    self.handle(error: error)
                }
                self.loadingType.value = .none
        })
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
        closures?.showMovieQueriesSuggestions(update(movieQuery:))
    }
    
    func closeQueriesSuggestions() {
        closures?.closeMovieQueriesSuggestions()
    }
    
    func didSelect(at indexPath: IndexPath) {
        let movie = pages[indexPath.section].movies[indexPath.row]
        closures?.showMovieDetails(movie)
    }
}
