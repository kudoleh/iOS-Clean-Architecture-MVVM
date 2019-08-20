//
//  MovieQueryEntityMapping.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import CoreData

extension MovieQuery {
    init(movieQueryEntity: MovieQueryEntity) {
        self.query = movieQueryEntity.query ?? ""
    }
}

extension MovieQueryEntity {
    convenience init(movieQuery: MovieQuery, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        query = movieQuery.query
        createdAt = Date()
    }
    func map(movieQuery: MovieQuery) {
        self.query = movieQuery.query
        self.createdAt = Date()
    }
}
