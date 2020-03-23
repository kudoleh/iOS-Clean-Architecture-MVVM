//
//  MoviesSearchFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit

protocol MoviesSearchFlowCoordinatorDependencies  {
    func makeMoviesListViewController(actions: MoviesListViewModelActions) -> MoviesListViewController
    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController
    func makeMoviesQueriesSuggestionsListViewController(actions: MoviesQueryListViewModelActions) -> UIViewController
}

class MoviesSearchFlowCoordinator {
    
    private let navigationController: UINavigationController
    private let dependencies: MoviesSearchFlowCoordinatorDependencies

    private weak var moviesListViewController: MoviesListViewController?
    private weak var moviesQueriesSuggestionsView: UIViewController?

    init(navigationController: UINavigationController,
         dependencies: MoviesSearchFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        // Note: here we keep strong reference with closures, this way this flow do not need to be strong referenced
        let actions = MoviesListViewModelActions(showMovieDetails: showMovieDetails,
                                                 showMovieQueriesSuggestions: showMovieQueriesSuggestions,
                                                 closeMovieQueriesSuggestions: closeMovieQueriesSuggestions)
        let vc = dependencies.makeMoviesListViewController(actions: actions)

        navigationController.pushViewController(vc, animated: false)
        moviesListViewController = vc
    }

    private func showMovieDetails(movie: Movie) {
        let vc = dependencies.makeMoviesDetailsViewController(movie: movie)
        navigationController.pushViewController(vc, animated: true)
    }

    private func showMovieQueriesSuggestions(selectMovieQuery: @escaping (MovieQuery) -> Void) {
        guard let moviesListViewController = moviesListViewController,
            let container = moviesListViewController.suggestionsListContainer else { return }
        let actions = MoviesQueryListViewModelActions(selectMovieQuery: selectMovieQuery)
        let vc = dependencies.makeMoviesQueriesSuggestionsListViewController(actions: actions)
        moviesListViewController.add(child: vc, container: container)
        vc.view.frame = moviesListViewController.view.bounds
        moviesQueriesSuggestionsView = vc
        container.isHidden = false
    }

    private func closeMovieQueriesSuggestions() {
        moviesQueriesSuggestionsView?.remove()
        moviesQueriesSuggestionsView = nil
        moviesListViewController?.suggestionsListContainer.isHidden = true
    }
}
