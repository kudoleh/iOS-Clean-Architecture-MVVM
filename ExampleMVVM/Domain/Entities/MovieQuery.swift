//
//  MovieQuery.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

struct MovieQuery {
    let query: String
}

extension MovieQuery: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(query)
    }
}
