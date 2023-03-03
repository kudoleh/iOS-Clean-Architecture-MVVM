import Foundation

final class DefaultMoviesQueriesRepository {
    
    private let dataTransferService: DataTransferService
    private var moviesQueriesPersistentStorage: MoviesQueriesStorage
    
    init(
        dataTransferService: DataTransferService,
        moviesQueriesPersistentStorage: MoviesQueriesStorage
    ) {
        self.dataTransferService = dataTransferService
        self.moviesQueriesPersistentStorage = moviesQueriesPersistentStorage
    }
}

extension DefaultMoviesQueriesRepository: MoviesQueriesRepository {
    
    func fetchRecentsQueries(
        maxCount: Int,
        completion: @escaping (Result<[MovieQuery], Error>) -> Void
    ) {
        return moviesQueriesPersistentStorage.fetchRecentsQueries(
            maxCount: maxCount,
            completion: completion
        )
    }
    
    func saveRecentQuery(
        query: MovieQuery,
        completion: @escaping (Result<MovieQuery, Error>) -> Void
    ) {
        moviesQueriesPersistentStorage.saveRecentQuery(
            query: query,
            completion: completion
        )
    }
}
