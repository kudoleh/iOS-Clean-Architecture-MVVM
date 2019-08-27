//
//  MoviesListViewController.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation
import UIKit

final class MoviesListViewController: UIViewController, StoryboardInstantiable, Alertable {
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var moviesListContainer: UIView!
    @IBOutlet weak private(set) var suggestionsListContainer: UIView!
    @IBOutlet weak private var searchBarContainer: UIView!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    @IBOutlet weak private var emptyDataLabel: UILabel!
    
    private(set) var viewModel: MoviesListViewModel!
    private var moviesListViewControllersFactory: MoviesListViewControllersFactory!
    
    private var moviesQueriesSuggestionsView: UIViewController?
    private var moviesTableViewController: MoviesListTableViewController?
    private var searchController = UISearchController(searchResultsController: nil)
    
    final class func create(with viewModel: MoviesListViewModel,
                            moviesListViewControllersFactory: MoviesListViewControllersFactory) -> MoviesListViewController {
        let view = MoviesListViewController.instantiateViewController()
        view.viewModel = viewModel
        view.moviesListViewControllersFactory = moviesListViewControllersFactory
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Movies", comment: "")
        emptyDataLabel.text = NSLocalizedString("Search results ", comment: "")
        setupSearchController()
        
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    func bind(to viewModel: MoviesListViewModel) {
        viewModel.route.observe(on: self) { [weak self] route in
            self?.handle(route)
        }
        viewModel.items.observe(on: self) { [weak self] items in
            self?.moviesTableViewController?.items = items
            self?.updateViewsVisibility(model: viewModel)
        }
        viewModel.query.observe(on: self) { [weak self] query in
            self?.updateSearchController(query: query)
        }
        viewModel.error.observe(on: self) { [weak self] error in
            self?.showError(error)
        }
        viewModel.loadingType.observe(on: self) { [weak self] _ in
           self?.updateViewsVisibility(model: viewModel)
        }
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
        showAlert(title: NSLocalizedString("Error", comment: ""), message: error)
    }
    
    private func updateViewsVisibility(model: MoviesListViewModel?) {
        guard let model = model else { return }
        loadingView.isHidden = true
        emptyDataLabel.isHidden = true
        moviesListContainer.isHidden = true
        suggestionsListContainer.isHidden = true
        moviesTableViewController?.update(isLoadingNextPage: false)
        
        if model.loadingType.value == .fullScreen {
            loadingView.isHidden = false
        } else if model.loadingType.value == .nextPage {
            moviesTableViewController?.update(isLoadingNextPage: true)
            moviesListContainer.isHidden = false
        } else if model.isEmpty {
            emptyDataLabel.isHidden = false
        } else {
            moviesListContainer.isHidden = false
        }
        
        updateQueriesSuggestionsVisibility()
    }
    
    private func updateQueriesSuggestionsVisibility() {
        if searchController.searchBar.isFirstResponder {
            viewModel.showQueriesSuggestions()
        } else {
            viewModel.closeQueriesSuggestions()
        }
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
        searchController.searchBar.placeholder = NSLocalizedString("Search Movies", comment: "")
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            searchController.dimsBackgroundDuringPresentation = true
        }
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
        searchController.searchBar.barStyle = .black
        searchController.searchBar.frame = searchBarContainer.bounds
        searchController.searchBar.autoresizingMask = [.flexibleWidth]
        searchBarContainer.addSubview(searchController.searchBar)
        definesPresentationContext = true
        searchController.accessibilityLabel = NSLocalizedString("Search Movies", comment: "")
    }
}

// MARK: - Handle Routing

extension MoviesListViewController {
    func handle(_ route: MoviesListViewModelRoute?) {
        guard let route = route else { return }
        switch route {
        case .showMovieDetail(let title, let overview, let posterPlaceholderImage, let posterPath):
            let vc = moviesListViewControllersFactory.makeMoviesDetailsViewController(title: title,
                                                                                                                      overview: overview,
                                                                                                                      posterPlaceholderImage: posterPlaceholderImage,
                                                                                                                      posterPath: posterPath)
            navigationController?.pushViewController(vc, animated: true)
        case .showMovieQueriesSuggestions:
            guard let view = view else { return }
            let vc = moviesQueriesSuggestionsView ?? moviesListViewControllersFactory.makeMoviesQueriesSuggestionsListViewController(delegate: viewModel)
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

protocol MoviesListViewControllersFactory {
    
    func makeMoviesQueriesSuggestionsListViewController(delegate: MoviesQueryListViewModelDelegate) -> UIViewController
    
    func makeMoviesDetailsViewController(title: String,
                                         overview: String,
                                         posterPlaceholderImage: Data?,
                                         posterPath: String?) -> UIViewController
}
