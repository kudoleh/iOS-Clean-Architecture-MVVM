//
//  CoreDataMoviesQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import CoreData

final class CoreDataMoviesQueriesStorage {

    private let maxStorageLimit: Int
    private let coreDataStorage: CoreDataStorage

    init(maxStorageLimit: Int, coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.maxStorageLimit = maxStorageLimit
        self.coreDataStorage = coreDataStorage
    }

    // MARK: - Private
    private func cleanUpQueries(for query: MovieQuery, inContext context: NSManagedObjectContext) throws {

        let request: NSFetchRequest = MovieQueryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MovieQueryEntity.createdAt),
                                                    ascending: false)]
        let result = try context.fetch(request)
        result.filter { $0.query == query.query }.forEach { context.delete($0) }
        if result.count > maxStorageLimit - 1 {
            Array(result[maxStorageLimit - 1..<result.count]).forEach { context.delete($0) }
        }
    }
}

extension CoreDataMoviesQueriesStorage: MoviesQueriesStorage {
    
    func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        
        coreDataStorage.performBackgroundTask { context in
            do {
                let request: NSFetchRequest = MovieQueryEntity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MovieQueryEntity.createdAt),
                                                            ascending: false)]
                request.fetchLimit = maxCount
                let result = try context.fetch(request).map { $0.toDomain() }

                completion(.success(result))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
                print(error)
            }
        }
    }
    
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {

        coreDataStorage.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                try self.cleanUpQueries(for: query, inContext: context)
                let entity = MovieQueryEntity(movieQuery: query, insertInto: context)
                try context.save()

                completion(.success(entity.toDomain()))
            } catch {
                completion(.failure(CoreDataStorageError.saveError(error)))
                print(error)
            }
        }
    }
}
