//
//  MovieQueryEntityMapping.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import CoreData

extension MovieQueryEntity {
    convenience init(movieQuery: MovieQuery, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        query = movieQuery.query
        createdAt = Date()
    }

    func mapToMovieQuery() -> MovieQuery {
        return MovieQuery(query: query ?? "")
    }
}
