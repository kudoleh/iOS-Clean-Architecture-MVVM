//
//  MoviesQueryListViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

protocol MoviesQueryListViewModelDelegate: class {
    
    func moviesQueriesListDidSelect(movieQuery: MovieQuery)
}

class MoviesQueryListViewModel {

    class Item: Equatable {
        let query: String
        init(query: String) {
            self.query = query
        }
    }
    
    private let numberOfQueriesToShow: Int
    private let fetchMoviesRecentQueriesUseCase: FetchMoviesRecentQueriesUseCase
    private weak var delegate: MoviesQueryListViewModelDelegate?
    
    // MARK: - OUTPUT
    private(set) var items: Observable<[Item]> = Observable([Item]())
    
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
                self?.items.value = items.map { Item(query: $0.query) }
            case .failure: break
            }
        }
    }
}

// MARK: - INPUT. View event methods
extension MoviesQueryListViewModel {
    
    func viewDidLoad() {}
    
    func viewWillAppear() {
        updateMoviesQueries()
    }
    
    func didSelect(item: MoviesQueryListViewModel.Item) {
        delegate?.moviesQueriesListDidSelect(movieQuery: MovieQuery(query: item.query))
    }
}

func == (lhs: MoviesQueryListViewModel.Item, rhs: MoviesQueryListViewModel.Item) -> Bool {
    return (lhs.query == rhs.query)
}
