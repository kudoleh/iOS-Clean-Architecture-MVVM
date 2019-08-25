//
//  DefaultMoviesRecentQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

private struct MovieQueriesList: Codable {
    var list: [MovieQuery]
}

final class UserDefaultsStorage {
    private let maxStorageLimit: Int
    private let recentsMoviesQueriesKey = "recentsMoviesQueries"
    private var userDefaults: UserDefaults { return UserDefaults.standard }
    
    private var moviesQuries: [MovieQuery] {
        get {
            if let queriesData = userDefaults.object(forKey: recentsMoviesQueriesKey) as? Data {
                let decoder = JSONDecoder()
                if let movieQueryList = try? decoder.decode(MovieQueriesList.self, from: queriesData) {
                    return movieQueryList.list
                }
            }
            return []
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(MovieQueriesList(list: newValue)) {
                userDefaults.set(encoded, forKey: recentsMoviesQueriesKey)
            }
        }
    }
    
    init(maxStorageLimit: Int) {
        self.maxStorageLimit = maxStorageLimit
    }
    
    fileprivate func removeOldQueries(_ queries: [MovieQuery]) -> [MovieQuery] {
        return queries.count <= maxStorageLimit ? queries : Array(queries[0..<maxStorageLimit])
    }
}

extension UserDefaultsStorage: MoviesQueriesStorage {
    func recentsQueries(number: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            var queries = strongSelf.moviesQuries
            queries = queries.count < strongSelf.maxStorageLimit ? queries : Array(queries[0..<number])
            completion(.success(queries))
        }
    }
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            var queries = strongSelf.moviesQuries
            queries = queries.filter { $0 != query }
            queries.insert(query, at: 0)
            strongSelf.moviesQuries = strongSelf.removeOldQueries(queries)
            completion(.success(query))
        }
    }
}
