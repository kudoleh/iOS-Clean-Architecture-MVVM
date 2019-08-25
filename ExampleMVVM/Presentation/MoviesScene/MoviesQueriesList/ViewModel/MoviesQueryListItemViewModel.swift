//
//  MoviesQueryListItemViewModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 25.08.19.
//

import Foundation

protocol MoviesQueryListItemViewModelInput { }

protocol MoviesQueryListItemViewModelOutput {
    var query: String { get }
}

protocol MoviesQueryListItemViewModel: MoviesQueryListItemViewModelInput, MoviesQueryListItemViewModelOutput { }

final class DefaultMoviesQueryListItemViewModel: MoviesQueryListItemViewModel, Equatable {
    let query: String
    init(query: String) {
        self.query = query
    }
}

func == (lhs: DefaultMoviesQueryListItemViewModel, rhs: DefaultMoviesQueryListItemViewModel) -> Bool {
    return (lhs.query == rhs.query)
}
