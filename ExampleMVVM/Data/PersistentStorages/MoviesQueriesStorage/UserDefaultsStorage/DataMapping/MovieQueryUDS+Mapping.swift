//
//  MovieQueryUDS+Mapping.swift
//  Data
//
//  Created by Oleh Kudinov on 12.08.19.
//  Copyright © 2019 Oleh Kudinov. All rights reserved.
//

import Foundation

struct MovieQueriesListUDS: Codable {
    var list: [MovieQueryUDS]
}

struct MovieQueryUDS: Codable {
    let query: String
}

extension MovieQueryUDS {
    init(movieQuery: MovieQuery) {
        query = movieQuery.query
    }
}

extension MovieQueryUDS {
    func toDomain() -> MovieQuery {
        return .init(query: query)
    }
}
