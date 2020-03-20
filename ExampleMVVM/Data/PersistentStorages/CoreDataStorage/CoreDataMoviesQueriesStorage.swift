//
//  CoreDataMoviesQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import CoreData

enum CoreDataMoviesQueriesStorageError: Error {
    case readError(Error)
    case writeError(Error)
    case deleteError(Error)
}

final class CoreDataMoviesQueriesStorage {

    private let maxStorageLimit: Int

    init(maxStorageLimit: Int) {
        self.maxStorageLimit = maxStorageLimit
    }
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataStorage")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Core Data Saving support
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Private
    private func cleanUpQueries(for query: MovieQuery, inContext context: NSManagedObjectContext) throws {

        let request: NSFetchRequest<MovieQueryEntity> = MovieQueryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MovieQueryEntity.createdAt),
                                                    ascending: false)]
        let resut = try context.fetch(request)
        resut.filter { $0.query == query.query }.forEach { context.delete($0) }
        if resut.count > maxStorageLimit - 1 {
            Array(resut[maxStorageLimit - 1..<resut.count]).forEach { context.delete($0) }
        }
    }
}

extension CoreDataMoviesQueriesStorage: MoviesQueriesStorage {
    
    func recentsQueries(number: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        
        persistentContainer.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<MovieQueryEntity> = MovieQueryEntity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MovieQueryEntity.createdAt),
                                                            ascending: false)]
                request.fetchLimit = number
                let resut = try context.fetch(request).map(MovieQuery.init)

                completion(.success(resut))
            } catch {
                completion(.failure(CoreDataMoviesQueriesStorageError.readError(error)))
                print(error)
            }
        }
    }
    
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {

        persistentContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            do {
                try self.cleanUpQueries(for: query, inContext: context)
                let entity = MovieQueryEntity(movieQuery: query, insertInto: context)
                try context.save()

                completion(.success(MovieQuery(movieQueryEntity: entity)))
            } catch {
                completion(.failure(CoreDataMoviesQueriesStorageError.writeError(error)))
                print(error)
            }
        }
    }
}
