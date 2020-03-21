//
//  MoviesListFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit

protocol MoviesListFlowCoordinatorDependencies  {
    func makeMoviesListViewController() -> MoviesListViewController
    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController
    func makeMoviesQueriesSuggestionsListViewController(delegate: MoviesQueryListViewModelDelegate) -> UIViewController
}

class MoviesListFlowCoordinator {
    
    var navigationController: UINavigationController
    
    private let dependencies: MoviesListFlowCoordinatorDependencies
    
    private weak var moviesListViewController: MoviesListViewController?
    private var moviesQueriesSuggestionsView: UIViewController?

    init(navigationController: UINavigationController,
         dependencies: MoviesListFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let vc = dependencies.makeMoviesListViewController()
        // Note: here we use strong reference to self, because this flow can be created without strong reference to it.
        vc.viewModel.route.observe(on: self, observerBlock: handle(_:))

        navigationController.pushViewController(vc, animated: false)
        moviesListViewController = vc
    }

    func handle(_ route: MoviesListViewModelRoute) {
        switch route {
        case .initial: break

        case .showMovieDetails(let movie):
            let vc = dependencies.makeMoviesDetailsViewController(movie: movie)
            navigationController.pushViewController(vc, animated: true)

        case .showMovieQueriesSuggestions(let delegate):
            guard let moviesListViewController = moviesListViewController,
                let container = moviesListViewController.suggestionsListContainer else { return }
            let vc = dependencies.makeMoviesQueriesSuggestionsListViewController(delegate: delegate)
            moviesListViewController.add(child: vc, container: container)
            vc.view.frame = moviesListViewController.view.bounds
            moviesQueriesSuggestionsView = vc
            container.isHidden = false

        case .closeMovieQueriesSuggestions:
            moviesQueriesSuggestionsView?.remove()
            moviesQueriesSuggestionsView = nil
            moviesListViewController?.suggestionsListContainer.isHidden = true
        }
    }
}
