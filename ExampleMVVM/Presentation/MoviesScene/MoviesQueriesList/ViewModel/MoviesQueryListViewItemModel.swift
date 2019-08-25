//
//  MoviesQueryListViewItemModel.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 25.08.19.
//

import Foundation

protocol MoviesQueryListViewItemModelInput { }

protocol MoviesQueryListViewItemModelOutput {
    var query: String { get }
}

protocol MoviesQueryListViewItemModel: MoviesQueryListViewItemModelInput, MoviesQueryListViewItemModelOutput { }

final class DefaultMoviesQueryListViewItemModel: MoviesQueryListViewItemModel, Equatable {
    let query: String
    init(query: String) {
        self.query = query
    }
}

func == (lhs: DefaultMoviesQueryListViewItemModel, rhs: DefaultMoviesQueryListViewItemModel) -> Bool {
    return (lhs.query == rhs.query)
}
