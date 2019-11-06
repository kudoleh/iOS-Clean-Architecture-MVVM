//
//  Movie.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct MoviesPage {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
}

struct Movie {
    typealias Id = String
    
    let id: Id
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
