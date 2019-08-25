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

class DefaultMoviesQueryListViewModel: MoviesQueryListViewModel {

    private let numberOfQueriesToShow: Int
    private let fetchMoviesRecentQueriesUseCase: FetchMoviesRecentQueriesUseCase
    private weak var delegate: MoviesQueryListViewModelDelegate?
    
    // MARK: - OUTPUT
    private(set) var items: Observable<[MoviesQueryListItemViewModel]> = Observable([MoviesQueryListItemViewModel]())
    
    init(numberOfQueriesToShow: Int,
         fetchMoviesRecentQueriesUseCase: FetchMoviesRecentQueriesUseCase,
         delegate: MoviesQueryListViewModelDelegate? = nil) {
        self.numberOfQueriesToShow = numberOfQueriesToShow
        self.fetchMoviesRecentQueriesUseCase = fetchMoviesRecentQueriesUseCase
        self.delegate = delegate
    }
    
    private func updateMoviesQueries() {
        let request = FetchMoviesRecentQueriesUseCaseRequestValue(number: numberOfQueriesToShow)
        _ = fetchMoviesRecentQueriesUseCase.execute(requestValue: request) { [weak self] result in
            switch result {
            case .success(let items):
                self?.items.value = items.map { DefaultMoviesQueryListItemViewModel(query: $0.query) }
            case .failure: break
            }
        }
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
