//
//  MoviesSceneDIContainer.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 03.03.19.
//

import UIKit
// SwiftUI
//import SwiftUI

final class MoviesSceneDIContainer {
    
    struct Dependencies {
        let apiDataTransferService: DataTransfer
        let imageDataTransferService: DataTransfer
    }
    
    private let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var moviesQueriesStorage: MoviesQueriesStorage = CoreDataStorage(maxStorageLimit: 10)
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies        
    }
    
    // MARK: - Use Cases
    func makeSearchMoviesUseCase() -> SearchMoviesUseCase {
        return DefaultSearchMoviesUseCase(moviesRepository: makeMoviesRepository(),
                                          moviesQueriesRepository: makeMoviesQueriesRepository())
    }
    
    func makeFetchMoviesRecentQueriesUseCase() -> FetchMoviesRecentQueriesUseCase {
        return DefaultFetchMoviesRecentQueriesUseCase(moviesQueriesRepository: makeMoviesQueriesRepository())
    }
    
    // MARK: - Repositories
    func makeMoviesRepository() -> MoviesRepository {
        return DefaultMoviesRepository(dataTransferService: dependencies.apiDataTransferService)
    }
    func makeMoviesQueriesRepository() -> MoviesQueriesRepository {
        return DefaultMoviesQueriesRepository(dataTransferService: dependencies.apiDataTransferService,
                                              moviesQueriesPersistentStorage: moviesQueriesStorage)
    }
    func makePosterImagesRepository() -> PosterImagesRepository {
        return DefaultPosterImagesRepository(dataTransferService: dependencies.imageDataTransferService,
                                             imageNotFoundData: UIImage(named: "image_not_found")?.pngData())
    }
    
    // MARK: - Movies List
    func makeMoviesListViewController() -> UIViewController {
        return MoviesListViewController.create(with: makeMoviesListViewModel(), moviesListViewControllersFactory: self)
    }
    
    func makeMoviesListViewModel() -> MoviesListViewModel {
        return DefaultMoviesListViewModel(searchMoviesUseCase: makeSearchMoviesUseCase(),
                                          posterImagesRepository: makePosterImagesRepository())
    }
    
    // MARK: - Movie Details
    func makeMoviesDetailsViewController(title: String,
                                         overview: String,
                                         posterPlaceholderImage: Data?,
                                         posterPath: String?) -> UIViewController {
        return MovieDetailsViewController.create(with: makeMoviesDetailsViewModel(title: title,
                                                                                  overview: overview,
                                                                                  posterPlaceholderImage: posterPlaceholderImage,
                                                                                  posterPath: posterPath))
    }
    
    func makeMoviesDetailsViewModel(title: String,
                                    overview: String,
                                    posterPlaceholderImage: Data?,
                                    posterPath: String?) -> MovieDetailsViewModel {
        return DefaultMovieDetailsViewModel(title: title,
                                            overview: overview,
                                            posterPlaceholderImage: posterPlaceholderImage,
                                            posterPath: posterPath,
                                            posterImagesRepository: makePosterImagesRepository())
    }
    
    // MARK: - Movies Queries Suggestions List
    func makeMoviesQueriesSuggestionsListViewController(delegate: MoviesQueryListViewModelDelegate) -> UIViewController {
//        if #available(iOS 13.0, *) { // SwiftUI
//
//            return UIHostingController(rootView: MoviesQueryListView(viewModel: makeMoviesQueryListViewModelWrapper(delegate: delegate)))
//        } else { // UIKit
            return MoviesQueriesTableViewController.create(with: makeMoviesQueryListViewModel(delegate: delegate))
//        }
    }
    
    func makeMoviesQueryListViewModel(delegate: MoviesQueryListViewModelDelegate) -> MoviesQueryListViewModel {
        return DefaultMoviesQueryListViewModel(numberOfQueriesToShow: 10,
                                               fetchMoviesRecentQueriesUseCase: makeFetchMoviesRecentQueriesUseCase(),
                                               delegate: delegate)
    }
// SwiftUI
//    @available(iOS 13.0, *)
//    func makeMoviesQueryListViewModelWrapper(delegate: MoviesQueryListViewModelDelegate) -> MoviesQueryListViewModelWrapper {
//        return MoviesQueryListViewModelWrapper(numberOfQueriesToShow: 10,
//                                        fetchMoviesRecentQueriesUseCase: makeFetchMoviesRecentQueriesUseCase(),
//                                        delegate: delegate)
//    }
}

extension MoviesSceneDIContainer: MoviesListViewControllersFactory {}
