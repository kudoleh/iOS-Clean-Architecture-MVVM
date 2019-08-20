//
//  MoviesListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

enum MoviesListViewRoute {
    case showMovieDetail(title: String, overview: String, posterPlaceholderImage: Data?, posterPath: String?)
    case showMovieQueriesSuggestions
    case closeMovieQueriesSuggestions
}

protocol MoviesListViewRouter {
    func perform(_ segue: MoviesListViewRoute)
}

final class MoviesListViewModel {
    
    enum LoadingType {
        case none
        case fullScreen
        case nextPage
    }
    
    private(set) var currentPage: Int = 0
    private var totalPageCount: Int = 1
    
    var isEmpty: Bool { return items.value.isEmpty }
    var hasMorePages: Bool {
        return currentPage < totalPageCount
    }
    var nextPage: Int {
        guard hasMorePages else { return currentPage }
        return currentPage + 1
    }
    
    var router: MoviesListViewRouter?
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let posterImagesRepository: PosterImagesRepository
    
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    
    // MARK: - OUTPUT
    var items: Observable<[Item]> = Observable([Item]())
    private(set) var loadingType: Observable<LoadingType> = Observable(.none) { didSet { isLoading.value = loadingType.value != .none } }
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
        self.items.value = items.value + moviesPage.movies.map { MoviesListViewModel.Item(movie: $0,
                                                                                          posterImagesRepository: posterImagesRepository) }
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        items.value.removeAll()
    }
    
    private func load(movieQuery: MovieQuery, loadingType: LoadingType) {
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
    
    // MARK: - INPUT. View event methods
    func viewDidLoad() {
        loadingType.value = .none
    }
}

// MARK: - INPUT. View event methods
extension MoviesListViewModel {

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
        router?.perform(.showMovieQueriesSuggestions)
    }
    
    func closeQueriesSuggestions() {
        router?.perform(.closeMovieQueriesSuggestions)
    }
    
    func didSelect(item: MoviesListViewModel.Item) {
        router?.perform(.showMovieDetail(title: item.title,
                                         overview: item.overview,
                                         posterPlaceholderImage: item.posterImage.value,
                                         posterPath: item.posterPath))
    }
}

// MARK: - Delegate method from another model views
extension MoviesListViewModel: MoviesQueryListViewModelDelegate {
    func moviesQueriesListDidSelect(movieQuery: MovieQuery) {
        update(movieQuery: movieQuery)
    }
}
