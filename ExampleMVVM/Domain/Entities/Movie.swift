//
//  Movie.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

typealias MovieId = String

struct MoviesPage {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
}

struct Movie {
    let id: MovieId
    let title: String
    let posterPath: String?
    let overview: String
    let releaseDate: Date?
}

extension Movie: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
