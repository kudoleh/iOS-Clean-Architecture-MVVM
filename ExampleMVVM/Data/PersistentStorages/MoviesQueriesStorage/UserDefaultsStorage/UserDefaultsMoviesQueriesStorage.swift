//
//  UserDefaultsMoviesQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

final class UserDefaultsMoviesQueriesStorage {
    private let maxStorageLimit: Int
    private let recentsMoviesQueriesKey = "recentsMoviesQueries"
    private var userDefaults: UserDefaults
    
    init(maxStorageLimit: Int, userDefaults: UserDefaults = UserDefaults.standard) {
        self.maxStorageLimit = maxStorageLimit
        self.userDefaults = userDefaults
    }

    private func fetchMoviesQuries() -> [MovieQuery] {
        if let queriesData = userDefaults.object(forKey: recentsMoviesQueriesKey) as? Data {
            if let movieQueryList = try? JSONDecoder().decode(MovieQueriesListUDS.self, from: queriesData) {
                return movieQueryList.list.map { $0.toDomain() }
            }
        }
        return []
    }

    private func persist(moviesQuries: [MovieQuery]) {
        let encoder = JSONEncoder()
        let movieQueryUDSs = moviesQuries.map(MovieQueryUDS.init)
        if let encoded = try? encoder.encode(MovieQueriesListUDS(list: movieQueryUDSs)) {
            userDefaults.set(encoded, forKey: recentsMoviesQueriesKey)
        }
    }

    private func removeOldQueries(_ queries: [MovieQuery]) -> [MovieQuery] {
        return queries.count <= maxStorageLimit ? queries : Array(queries[0..<maxStorageLimit])
    }
}

extension UserDefaultsMoviesQueriesStorage: MoviesQueriesStorage {
    func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var queries = self.fetchMoviesQuries()
            queries = queries.count < self.maxStorageLimit ? queries : Array(queries[0..<maxCount])
            completion(.success(queries))
        }
    }
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var queries = self.fetchMoviesQuries()
            queries = queries.filter { $0 != query }
            queries.insert(query, at: 0)
            self.persist(moviesQuries: self.removeOldQueries(queries))
            completion(.success(query))
        }
    }
}
