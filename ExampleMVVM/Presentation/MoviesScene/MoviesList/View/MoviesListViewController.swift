//
//  MoviesListViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import UIKit

protocol MoviesListViewControllersFactory {
    func makeMoviesQueriesSuggestionsListViewController(delegate: MoviesQueryListViewModelDelegate) -> UIViewController
    func makeMoviesDetailsViewController(title: String,
                                         overview: String,
                                         posterPlaceholderImage: Data?,
                                         posterPath: String?) -> UIViewController
}

final class MoviesListViewController: UIViewController, StoryboardInstantiable, Alertable {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var moviesListContainer: UIView!
    @IBOutlet private var suggestionsListContainer: UIView!
    @IBOutlet private var searchBarContainer: UIView!
    @IBOutlet private var loadingView: UIActivityIndicatorView!
    @IBOutlet private var emptyDataLabel: UILabel!
    
    private(set) var viewModel: MoviesListViewModel!
    private var moviesListViewControllersFactory: MoviesListViewControllersFactory!
    
    private var moviesQueriesSuggestionsView: UIViewController?
    private var moviesTableViewController: MoviesListTableViewController?
    private var searchController = UISearchController(searchResultsController: nil)
    
    static func create(with viewModel: MoviesListViewModel,
                            moviesListViewControllersFactory: MoviesListViewControllersFactory) -> MoviesListViewController {
        let view = MoviesListViewController.instantiateViewController()
        view.viewModel = viewModel
        view.moviesListViewControllersFactory = moviesListViewControllersFactory
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.screenTitle
        emptyDataLabel.text = viewModel.emptyDataTitle
        setupSearchController()
        
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    private func bind(to viewModel: MoviesListViewModel) {
        viewModel.route.observe(on: self) { [weak self] in self?.handle($0) }
        viewModel.items.observe(on: self) { [weak self] in self?.moviesTableViewController?.items = $0 }
        viewModel.query.observe(on: self) { [weak self] in self?.updateSearchController(query: $0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
        viewModel.loadingType.observe(on: self) { [weak self] _ in self?.updateViewsVisibility() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }
    
    private func updateSearchController(query: String) {
        searchController.isActive = false
        searchController.searchBar.text = query
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: MoviesListTableViewController.self),
            let destinationVC = segue.destination as? MoviesListTableViewController {
            moviesTableViewController = destinationVC
            moviesTableViewController?.viewModel = viewModel
        }
    }

    func showError(_ error: String) {
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
    }
    
    private func updateViewsVisibility() {
        loadingView.isHidden = true
        emptyDataLabel.isHidden = true
        moviesListContainer.isHidden = true
        suggestionsListContainer.isHidden = true
        
        switch viewModel.loadingType.value {
        case .none: updateMoviesListVisibility()
        case .fullScreen: loadingView.isHidden = false
        case .nextPage: moviesListContainer.isHidden = false
        }
        updateQueriesSuggestionsVisibility()
    }
    
    private func updateMoviesListVisibility() {
        guard !viewModel.isEmpty else {
            emptyDataLabel.isHidden = false
            return
        }
        moviesListContainer.isHidden = false
    }

    private func updateQueriesSuggestionsVisibility() {
        guard searchController.searchBar.isFirstResponder else {
            viewModel.closeQueriesSuggestions()
            return
        }
        viewModel.showQueriesSuggestions()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchController.isActive = false
        moviesTableViewController?.tableView.setContentOffset(CGPoint.zero, animated: false)
        viewModel.didSearch(query: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.didCancelSearch()
    }
}

extension MoviesListViewController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestionsVisibility()
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestionsVisibility()
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestionsVisibility()
    }
}

// MARK: - Setup Search Controller

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
        searchController.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifier.searchField
    }
}

// MARK: - Handle Routing

extension MoviesListViewController {
    func handle(_ route: MoviesListViewModelRoute) {
        switch route {
        case .initial: break
        case .showMovieDetail(let title, let overview, let posterPlaceholderImage, let posterPath):
            let vc = moviesListViewControllersFactory.makeMoviesDetailsViewController(title: title,
                                                                                      overview: overview,
                                                                                      posterPlaceholderImage: posterPlaceholderImage,
                                                                                      posterPath: posterPath)
            navigationController?.pushViewController(vc, animated: true)
        case .showMovieQueriesSuggestions(let delegate):
            guard let view = view else { return }
            let vc = moviesQueriesSuggestionsView ?? moviesListViewControllersFactory.makeMoviesQueriesSuggestionsListViewController(delegate: delegate)
            add(child: vc, container: suggestionsListContainer)
            vc.view.frame = view.bounds
            moviesQueriesSuggestionsView = vc
            suggestionsListContainer.isHidden = false
        case .closeMovieQueriesSuggestions:
            guard let suggestionsListContainer = suggestionsListContainer else { return }
            moviesQueriesSuggestionsView?.remove()
            moviesQueriesSuggestionsView = nil
            suggestionsListContainer.isHidden = true
        }
    }
}
