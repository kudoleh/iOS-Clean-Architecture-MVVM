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
    private let fetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase
    private weak var delegate: MoviesQueryListViewModelDelegate?
    
    // MARK: - OUTPUT
    let items: Observable<[MoviesQueryListItemViewModel]> = Observable([MoviesQueryListItemViewModel]())
    
    init(numberOfQueriesToShow: Int,
         fetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase,
         delegate: MoviesQueryListViewModelDelegate? = nil) {
        self.numberOfQueriesToShow = numberOfQueriesToShow
        self.fetchRecentMovieQueriesUseCase = fetchRecentMovieQueriesUseCase
        self.delegate = delegate
    }
    
    private func updateMoviesQueries() {
        let request = FetchRecentMovieQueriesUseCaseRequestValue(number: numberOfQueriesToShow)
        _ = fetchRecentMovieQueriesUseCase.execute(requestValue: request) { [weak self] result in
            switch result {
            case .success(let items):
                self?.items.value = items.map { $0.query }.map ( DefaultMoviesQueryListItemViewModel.init )
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
