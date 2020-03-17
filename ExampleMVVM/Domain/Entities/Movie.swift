//
//  Movie.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

typealias MovieId = String

struct Movie: Equatable, Identifiable {
    let id: MovieId
    let title: String
    let posterPath: String?
    let overview: String
    let releaseDate: Date?
}

struct MoviesPage: Equatable {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
}
