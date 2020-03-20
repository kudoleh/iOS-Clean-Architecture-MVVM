//
//  DefaultMoviesQueriesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 15.02.19.
//

import Foundation

final class DefaultMoviesQueriesRepository {
    
    private let dataTransferService: DataTransferService
    private var moviesQueriesPersistentStorage: MoviesQueriesStorage
    
    init(dataTransferService: DataTransferService,
         moviesQueriesPersistentStorage: MoviesQueriesStorage) {
        self.dataTransferService = dataTransferService
        self.moviesQueriesPersistentStorage = moviesQueriesPersistentStorage
    }
}

extension DefaultMoviesQueriesRepository: MoviesQueriesRepository {
    
    func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        return moviesQueriesPersistentStorage.fetchRecentsQueries(maxCount: maxCount, completion: completion)
    }
    
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {
        moviesQueriesPersistentStorage.saveRecentQuery(query: query, completion: completion)
    }
}
