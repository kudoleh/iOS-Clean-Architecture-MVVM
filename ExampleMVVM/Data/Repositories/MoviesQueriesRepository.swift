//
//  DefaultMoviesQueriesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 15.02.19.
//

import Foundation

final class DefaultMoviesQueriesRepository {
    
    private let dataTransferService: DataTransfer
    private var moviesQueriesPersistentStorage: MoviesQueriesStorage
    
    init(dataTransferService: DataTransfer,
         moviesQueriesPersistentStorage: MoviesQueriesStorage) {
        self.dataTransferService = dataTransferService
        self.moviesQueriesPersistentStorage = moviesQueriesPersistentStorage
    }
}

extension DefaultMoviesQueriesRepository: MoviesQueriesRepository {
    
    func recentsQueries(number: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        return moviesQueriesPersistentStorage.recentsQueries(number: number, completion: completion)
    }
    
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {
        moviesQueriesPersistentStorage.saveRecentQuery(query: query, completion: completion)
    }
}
