import Foundation

struct MoviesListViewModelActions {
    /// Note: if you would need to edit movie inside Details screen and update this Movies List screen with updated movie then you would need this closure:
    /// showMovieDetails: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
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
    func didSelectItem(at index: Int)
}

protocol MoviesListViewModelOutput {
    var items: Observable<[MoviesListItemViewModel]> { get } /// Also we can calculate view model items on demand:  https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/pull/10/files
    var loading: Observable<MoviesListViewModelLoading?> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
    var emptySearchTitle: String { get }
    var emptySearchSubtitle: String { get }
    var noResultsTitle: String { get }
    func noResultsSubtitle(forQuery query: String) -> String
}

typealias MoviesListViewModel = MoviesListViewModelInput & MoviesListViewModelOutput

final class DefaultMoviesListViewModel: MoviesListViewModel {

    private let searchMoviesUseCase: SearchMoviesUseCase
    private let actions: MoviesListViewModelActions?

    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }

    private var pages: [MoviesPage] = []
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    private let mainQueue: DispatchQueueType

    /// Bumped on every load() / cancel, so a response from a superseded request can be told apart
    /// from the latest one and ignored even if cancellation of the old task isn't honored in time.
    private var latestRequestID = 0

    // MARK: - OUTPUT

    let items: Observable<[MoviesListItemViewModel]> = Observable([])
    let loading: Observable<MoviesListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString("Movies", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder = NSLocalizedString("Search Movies", comment: "")
    let emptySearchTitle = NSLocalizedString("Search Movies", comment: "")
    let emptySearchSubtitle = NSLocalizedString("Type a title above and results will appear as you type.", comment: "")
    let noResultsTitle = NSLocalizedString("No Results", comment: "")

    func noResultsSubtitle(forQuery query: String) -> String {
        let format = NSLocalizedString("No movies found for \u{201c}%@\u{201d}. Try another title.", comment: "")
        return String(format: format, query)
    }

    // MARK: - Init
    
    init(
        searchMoviesUseCase: SearchMoviesUseCase,
        actions: MoviesListViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }

    // MARK: - Private

    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages

        pages = pages
            .filter { $0.page != moviesPage.page }
            + [moviesPage]

        items.value = pages.movies.map(MoviesListItemViewModel.init)
    }

    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.value.removeAll()
    }

    private func load(movieQuery: MovieQuery, loading: MoviesListViewModelLoading) {
        latestRequestID += 1
        let requestID = latestRequestID

        self.loading.value = loading
        query.value = movieQuery.query

        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery, page: nextPage),
            cached: { [weak self] page in
                self?.mainQueue.async {
                    guard let self, requestID == self.latestRequestID else { return }
                    self.appendPage(page)
                }
            },
            completion: { [weak self] result in
                self?.mainQueue.async {
                    // Ignore responses from a request that's been superseded by a newer search,
                    // in case this one is slower and would otherwise overwrite fresher results.
                    guard let self, requestID == self.latestRequestID else { return }
                    switch result {
                    case .success(let page):
                        self.appendPage(page)
                    case .failure(let error):
                        self.handle(error: error)
                    }
                    self.loading.value = .none
                }
        })
    }

    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: "")
    }

    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loading: .fullScreen)
    }
}

// MARK: - INPUT. View event methods

extension DefaultMoviesListViewModel {

    func viewDidLoad() { }

    func didLoadNextPage() {
        guard hasMorePages, loading.value == .none else { return }
        load(movieQuery: .init(query: query.value),
             loading: .nextPage)
    }

    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(movieQuery: MovieQuery(query: query))
    }

    func didCancelSearch() {
        latestRequestID += 1
        moviesLoadTask?.cancel()
        resetPages()
        query.value = ""
        loading.value = .none
    }

    func showQueriesSuggestions() {
        actions?.showMovieQueriesSuggestions(update(movieQuery:))
    }

    func closeQueriesSuggestions() {
        actions?.closeMovieQueriesSuggestions()
    }

    func didSelectItem(at index: Int) {
        actions?.showMovieDetails(pages.movies[index])
    }
}

// MARK: - Private

private extension Array where Element == MoviesPage {
    var movies: [Movie] { flatMap { $0.movies } }
}
