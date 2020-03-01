//
//  MoviesQueryListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

protocol MoviesQueryListViewModelInput {
    func viewWillAppear()
    func didSelect(item: MoviesQueryListItemViewModel)
}

protocol MoviesQueryListViewModelOutput {
    var items: Observable<[MoviesQueryListItemViewModel]> { get }
}

protocol MoviesQueryListViewModel: MoviesQueryListViewModelInput, MoviesQueryListViewModelOutput { }

protocol MoviesQueryListViewModelDelegate: class {
    
    func moviesQueriesListDidSelect(movieQuery: MovieQuery)
}

typealias FetchRecentMovieQueriesUseCaseFactory = (
    FetchRecentMovieQueriesUseCase.RequestValue,
    @escaping (FetchRecentMovieQueriesUseCase.ResultValue) -> Void
    ) -> UseCase

final class DefaultMoviesQueryListViewModel: MoviesQueryListViewModel {

    private let numberOfQueriesToShow: Int
    private let fetchRecentMovieQueriesUseCaseFactory: FetchRecentMovieQueriesUseCaseFactory
    private weak var delegate: MoviesQueryListViewModelDelegate?
    
    // MARK: - OUTPUT
    let items: Observable<[MoviesQueryListItemViewModel]> = Observable([])
    
    init(numberOfQueriesToShow: Int,
         fetchRecentMovieQueriesUseCaseFactory: @escaping FetchRecentMovieQueriesUseCaseFactory,
         delegate: MoviesQueryListViewModelDelegate? = nil) {
        self.numberOfQueriesToShow = numberOfQueriesToShow
        self.fetchRecentMovieQueriesUseCaseFactory = fetchRecentMovieQueriesUseCaseFactory
        self.delegate = delegate
    }
    
    private func updateMoviesQueries() {
        let request = FetchRecentMovieQueriesUseCase.RequestValue(number: numberOfQueriesToShow)
        let completion: (FetchRecentMovieQueriesUseCase.ResultValue) -> Void = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let items):
                self.items.value = items.map { $0.query }.map ( DefaultMoviesQueryListItemViewModel.init )
            case .failure: break
            }
        }
        let useCase = fetchRecentMovieQueriesUseCaseFactory(request, completion)
        useCase.start()
    }
}

// MARK: - INPUT. View event methods
extension DefaultMoviesQueryListViewModel {
        
    func viewWillAppear() {
        updateMoviesQueries()
    }
    
    func didSelect(item: MoviesQueryListItemViewModel) {
        delegate?.moviesQueriesListDidSelect(movieQuery: MovieQuery(query: item.query))
    }
}
