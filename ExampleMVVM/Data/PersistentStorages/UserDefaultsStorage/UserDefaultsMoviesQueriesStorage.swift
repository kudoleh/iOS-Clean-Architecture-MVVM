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
    private var userDefaults: UserDefaults { return UserDefaults.standard }
    
    init(maxStorageLimit: Int) {
        self.maxStorageLimit = maxStorageLimit
    }

    private func fetchMoviesQuries() -> [MovieQuery] {
        if let queriesData = userDefaults.object(forKey: recentsMoviesQueriesKey) as? Data {
            let decoder = JSONDecoder()
            if let movieQueryList = try? decoder.decode(MovieQueriesListUDS.self, from: queriesData) {
                return movieQueryList.list.map(MovieQuery.init)
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
    func recentsQueries(number: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var queries = self.fetchMoviesQuries()
            queries = queries.count < self.maxStorageLimit ? queries : Array(queries[0..<number])
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
