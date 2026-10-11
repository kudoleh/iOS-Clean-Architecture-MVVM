import UIKit

final class MoviesListViewController: UIViewController, StoryboardInstantiable, Alertable {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var moviesListContainer: UIView!
    @IBOutlet private(set) var suggestionsListContainer: UIView!
    @IBOutlet private var searchBarContainer: UIView!
    @IBOutlet private var emptyStateStackView: UIStackView!
    @IBOutlet private var emptyStateIconImageView: UIImageView!
    @IBOutlet private var emptyStateTitleLabel: UILabel!
    @IBOutlet private var emptyStateSubtitleLabel: UILabel!
    
    private var viewModel: MoviesListViewModel!
    private var posterImagesRepository: PosterImagesRepository?

    private var moviesTableViewController: MoviesListTableViewController?
    private var searchController = UISearchController(searchResultsController: nil)
    private let searchDebouncer: Debouncer = DefaultDebouncer(delay: 0.4)

    // MARK: - Lifecycle

    static func create(
        with viewModel: MoviesListViewModel,
        posterImagesRepository: PosterImagesRepository?
    ) -> MoviesListViewController {
        let view = MoviesListViewController.instantiateViewController()
        view.viewModel = viewModel
        view.posterImagesRepository = posterImagesRepository
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBehaviours()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }

    private func bind(to viewModel: MoviesListViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        viewModel.loading.observe(on: self) { [weak self] in self?.updateLoading($0) }
        viewModel.query.observe(on: self) { [weak self] in self?.updateSearchQuery($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchDebouncer.cancel()
        searchController.isActive = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: MoviesListTableViewController.self),
            let destinationVC = segue.destination as? MoviesListTableViewController {
            moviesTableViewController = destinationVC
            moviesTableViewController?.viewModel = viewModel
            moviesTableViewController?.posterImagesRepository = posterImagesRepository
        }
    }

    // MARK: - Private

    private func setupViews() {
        title = viewModel.screenTitle
        setupSearchController()
    }

    private func updateEmptyState() {
        let query = viewModel.query.value
        if query.isEmpty {
            emptyStateIconImageView.image = UIImage(systemName: "magnifyingglass")
            emptyStateTitleLabel.text = viewModel.emptySearchTitle
            emptyStateSubtitleLabel.text = viewModel.emptySearchSubtitle
        } else {
            emptyStateIconImageView.image = UIImage(systemName: "film")
            emptyStateTitleLabel.text = viewModel.noResultsTitle
            emptyStateSubtitleLabel.text = viewModel.noResultsSubtitle(forQuery: query)
        }
    }

    private func setupBehaviours() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }

    private func updateItems() {
        moviesTableViewController?.reload()
    }

    private func updateLoading(_ loading: MoviesListViewModelLoading?) {
        emptyStateStackView.isHidden = true
        moviesListContainer.isHidden = true
        suggestionsListContainer.isHidden = true
        LoadingView.hide()

        switch loading {
        case .fullScreen: LoadingView.show()
        case .nextPage: moviesListContainer.isHidden = false
        case .none:
            moviesListContainer.isHidden = viewModel.isEmpty
            emptyStateStackView.isHidden = !viewModel.isEmpty
            if viewModel.isEmpty { updateEmptyState() }
        }

        moviesTableViewController?.updateLoading(loading)
        updateQueriesSuggestions()
    }

    private func updateQueriesSuggestions() {
        let searchText = searchController.searchBar.text ?? ""
        guard searchController.searchBar.isFirstResponder, searchText.isEmpty else {
            viewModel.closeQueriesSuggestions()
            return
        }
        viewModel.showQueriesSuggestions()
    }

    private func updateSearchQuery(_ query: String) {
        // Live search already keeps the search bar's text in sync with `query` as the user types,
        // so only force-sync (and dismiss search) when the query changed from elsewhere, e.g. a selected suggestion.
        guard searchController.searchBar.text != query else { return }
        searchController.isActive = false
        searchController.searchBar.text = query
    }

    private func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
    }

    @IBAction private func startSearchButtonTapped(_ sender: UIButton) {
        searchController.searchBar.becomeFirstResponder()
    }
}

// MARK: - Search Controller

extension MoviesListViewController {
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
        searchController.searchBar.barStyle = .black
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = searchBarContainer.bounds
        searchController.searchBar.autoresizingMask = [.flexibleWidth]
        searchBarContainer.addSubview(searchController.searchBar)
        definesPresentationContext = true
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifier.searchField
        }
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDebouncer.cancel()
        updateQueriesSuggestions()

        guard !searchText.isEmpty else {
            viewModel.didCancelSearch()
            return
        }

        searchDebouncer.execute { [weak self] in
            self?.viewModel.didSearch(query: searchText)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchDebouncer.cancel()
        searchController.isActive = false
        viewModel.didSearch(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchDebouncer.cancel()
        viewModel.didCancelSearch()
    }
}

extension MoviesListViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }
}
