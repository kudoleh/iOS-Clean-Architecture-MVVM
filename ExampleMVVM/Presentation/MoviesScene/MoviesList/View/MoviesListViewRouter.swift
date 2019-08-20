//
//  MoviesListViewRouter.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05.03.19.
//

import Foundation
import UIKit

final class DefaultMoviesListViewRouter: MoviesListViewRouter {

    private weak var view: MoviesListViewController?
    private let moviesListViewControllersFactory: MoviesListViewControllersFactory
    
    var moviesQueriesSuggestionsView: UIViewController?
    
    init(view: MoviesListViewController,
         moviesListViewControllersFactory: MoviesListViewControllersFactory) {
        self.view = view
        self.moviesListViewControllersFactory = moviesListViewControllersFactory
    }
    
    func perform(_ route: MoviesListViewRoute) {
        switch route {
        case .showMovieDetail(let title, let overview, let posterPlaceholderImage, let posterPath):
            guard let view = view else { return }
            let vc = moviesQueriesSuggestionsView ?? moviesListViewControllersFactory.makeMoviesDetailsViewController(title: title,
                                                                                                                      overview: overview,
                                                                                                                      posterPlaceholderImage: posterPlaceholderImage,
                                                                                                                      posterPath: posterPath)
            view.navigationController?.pushViewController(vc, animated: true)
        case .showMovieQueriesSuggestions:
            guard let view = view else { return }
            let vc = moviesQueriesSuggestionsView ?? moviesListViewControllersFactory.makeMoviesQueriesSuggestionsListViewController(delegate: view.viewModel)
            view.add(child: vc, container: view.suggestionsListContainer)
            vc.view.frame = view.view.bounds
            moviesQueriesSuggestionsView = vc
            view.suggestionsListContainer.isHidden = false
        case .closeMovieQueriesSuggestions:
            guard let suggestionsListContainer = view?.suggestionsListContainer else { return }
            moviesQueriesSuggestionsView?.remove()
            moviesQueriesSuggestionsView = nil
            suggestionsListContainer.isHidden = true
        }
    }
}

fileprivate extension UIViewController {
    func add(child: UIViewController, container: UIView) {
        addChild(child)
        container.addSubview(child.view)
        child.didMove(toParent: self)
    }
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
