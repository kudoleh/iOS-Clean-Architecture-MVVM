//
//  MoviesListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

enum MoviesListViewModelRoute {
    case initial
    case showMovieDetail(title: String, overview: String, posterPlaceholderImage: Data?, posterPath: String?)
    case showMovieQueriesSuggestions
    case closeMovieQueriesSuggestions
}

enum MoviesListViewModelLoading {
    case none
    case fullScreen
    case nextPage
}

protocol MoviesListViewModelInput: MoviesQueryListViewModelDelegate {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func showQueriesSuggestions()
    func closeQueriesSuggestions()
    func didSelect(item: MoviesListItemViewModel)
}

protocol MoviesListViewModelOutput {
    var route: Observable<MoviesListViewModelRoute> { get }
    var items: Observable<[MoviesListItemViewModel]> { get }
    var isEmpty: Bool { get }
    var loadingType: Observable<MoviesListViewModelLoading> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isLoading: Observable<Bool> { get }
}

protocol MoviesListViewModel: MoviesListViewModelInput, MoviesListViewModelOutput {}

final class DefaultMoviesListViewModel: MoviesListViewModel {
    
    private(set) var currentPage: Int = 0
    private var totalPageCount: Int = 1
    
    var hasMorePages: Bool {
        return currentPage < totalPageCount
    }
    var nextPage: Int {
        guard hasMorePages else { return currentPage }
        return currentPage + 1
    }
    
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let posterImagesRepository: PosterImagesRepository
    
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    
    // MARK: - OUTPUT
    private(set) var route: Observable<MoviesListViewModelRoute> = Observable(.initial)
    private(set) var items: Observable<[MoviesListItemViewModel]> = Observable([MoviesListItemViewModel]())
    var isEmpty: Bool { return items.value.isEmpty }
    private(set) var loadingType: Observable<MoviesListViewModelLoading> = Observable(.none) { didSet { isLoading.value = loadingType.value != .none } }
    private(set) var query: Observable<String> = Observable("")
    private(set) var error: Observable<String> = Observable("")
    private(set) var isLoading: Observable<Bool> = Observable(false)
    
    @discardableResult
    init(searchMoviesUseCase: SearchMoviesUseCase,
         posterImagesRepository: PosterImagesRepository) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.posterImagesRepository = posterImagesRepository
    }
    
    private func appendPage(moviesPage: MoviesPage) {
        self.currentPage = moviesPage.page
        self.totalPageCount = moviesPage.totalPages
        self.items.value = items.value + moviesPage.movies.map { DefaultMoviesListItemViewModel(movie: $0,
                                                                                                posterImagesRepository: posterImagesRepository) }
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        items.value.removeAll()
    }
    
    private func load(movieQuery: MovieQuery, loadingType: MoviesListViewModelLoading) {
        self.loadingType.value = loadingType
        self.query.value = movieQuery.query
        
        let moviesRequest = SearchMoviesUseCaseRequestValue(query: movieQuery, page: nextPage)
        moviesLoadTask = searchMoviesUseCase.execute(requestValue: moviesRequest) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let moviesPage):
                strongSelf.appendPage(moviesPage: moviesPage)
            case .failure(let error):
                strongSelf.handle(error: error)
            }
            strongSelf.loadingType.value = .none
        }
    }
    
    private func handle(error: Error) {
        self.error.value = NSLocalizedString("Failed loading movies", comment: "")
    }
    
    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loadingType: .fullScreen)
    }
}

// MARK: - INPUT. View event methods
extension DefaultMoviesListViewModel {

    func viewDidLoad() {
        loadingType.value = .none
    }
    
    func didLoadNextPage() {
        guard hasMorePages, !isLoading.value else { return }
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
        route.value = .showMovieQueriesSuggestions
    }
    
    func closeQueriesSuggestions() {
        route.value = .closeMovieQueriesSuggestions
    }
    
    func didSelect(item: MoviesListItemViewModel) {
        route.value = .showMovieDetail(title: item.title,
                                       overview: item.overview,
                                       posterPlaceholderImage: item.posterImage.value,
                                       posterPath: item.posterPath)
    }
}

// MARK: - Delegate method from another model views
extension DefaultMoviesListViewModel {
    func moviesQueriesListDidSelect(movieQuery: MovieQuery) {
        update(movieQuery: movieQuery)
    }
}
