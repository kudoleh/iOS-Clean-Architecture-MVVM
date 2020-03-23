//
//  MoviesSearchFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit

protocol MoviesSearchFlowCoordinatorDependencies  {
    func makeMoviesListViewController(closures: MoviesListViewModelClosures) -> MoviesListViewController
    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController
    func makeMoviesQueriesSuggestionsListViewController(closures: MoviesQueryListViewModelClosures) -> UIViewController
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
        let closures = MoviesListViewModelClosures(showMovieDetails: showMovieDetails,
                                                   showMovieQueriesSuggestions: showMovieQueriesSuggestions,
                                                   closeMovieQueriesSuggestions: closeMovieQueriesSuggestions)
        let vc = dependencies.makeMoviesListViewController(closures: closures)

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
        let closures = MoviesQueryListViewModelClosures(selectMovieQuery: selectMovieQuery)
        let vc = dependencies.makeMoviesQueriesSuggestionsListViewController(closures: closures)
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
