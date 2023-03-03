import Foundation

final class UserDefaultsMoviesQueriesStorage {
    private let maxStorageLimit: Int
    private let recentsMoviesQueriesKey = "recentsMoviesQueries"
    private var userDefaults: UserDefaults
    private let backgroundQueue: DispatchQueue = .global(qos: .userInitiated)
    
    init(
        maxStorageLimit: Int,
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.maxStorageLimit = maxStorageLimit
        self.userDefaults = userDefaults
    }

    private func fetchMoviesQueries() -> [MovieQuery] {
        if let queriesData = userDefaults.object(forKey: recentsMoviesQueriesKey) as? Data {
            if let movieQueryList = try? JSONDecoder().decode(MovieQueriesListUDS.self, from: queriesData) {
                return movieQueryList.list.map { $0.toDomain() }
            }
        }
        return []
    }

    private func persist(moviesQueries: [MovieQuery]) {
        let encoder = JSONEncoder()
        let movieQueryUDSs = moviesQueries.map(MovieQueryUDS.init)
        if let encoded = try? encoder.encode(MovieQueriesListUDS(list: movieQueryUDSs)) {
            userDefaults.set(encoded, forKey: recentsMoviesQueriesKey)
        }
    }
}

extension UserDefaultsMoviesQueriesStorage: MoviesQueriesStorage {

    func fetchRecentsQueries(
        maxCount: Int,
        completion: @escaping (Result<[MovieQuery], Error>) -> Void
    ) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }

            var queries = self.fetchMoviesQueries()
            queries = queries.count < self.maxStorageLimit ? queries : Array(queries[0..<maxCount])
            completion(.success(queries))
        }
    }

    func saveRecentQuery(
        query: MovieQuery,
        completion: @escaping (Result<MovieQuery, Error>) -> Void
    ) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }

            var queries = self.fetchMoviesQueries()
            self.cleanUpQueries(for: query, in: &queries)
            queries.insert(query, at: 0)
            self.persist(moviesQueries: queries)

            completion(.success(query))
        }
    }
}


// MARK: - Private
extension UserDefaultsMoviesQueriesStorage {

    private func cleanUpQueries(for query: MovieQuery, in queries: inout [MovieQuery]) {
        removeDuplicates(for: query, in: &queries)
        removeQueries(limit: maxStorageLimit - 1, in: &queries)
    }

    private func removeDuplicates(for query: MovieQuery, in queries: inout [MovieQuery]) {
        queries = queries.filter { $0 != query }
    }

    private func removeQueries(limit: Int, in queries: inout [MovieQuery]) {
        queries = queries.count <= limit ? queries : Array(queries[0..<limit])
    }
}
