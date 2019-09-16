//
//  CoreDataStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import CoreData

enum CoreDataStorageError: Error {
    case readError(Error)
    case writeError(Error)
    case deleteError(Error)
}

final class CoreDataStorage {

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
}

extension CoreDataStorage: MoviesQueriesStorage {
    
    func recentsQueries(number: Int, completion: @escaping (Result<[MovieQuery], Error>) -> Void) {
        
        persistentContainer.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<MovieQueryEntity> = MovieQueryEntity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: #keyPath(MovieQueryEntity.createdAt),
                                                            ascending: false)]
                request.fetchLimit = number
                let resut = try context.fetch(request).map { $0.mapToMovieQuery() }
                DispatchQueue.global(qos: .background).async {
                    completion(.success(resut))
                }
            } catch {
                DispatchQueue.global(qos: .background).async {
                    completion(.failure(CoreDataStorageError.readError(error)))
                }
                print(error)
            }
        }
    }
    
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, Error>) -> Void) {

        persistentContainer.performBackgroundTask { [weak self] context in
            guard let strongSelf = self else { return }
            do {
                try strongSelf.cleanUpQueries(for: query, inContext: context)
                let entity = MovieQueryEntity(movieQuery: query, insertInto: context)
                try context.save()
                DispatchQueue.global(qos: .background).async {
                    completion(.success(entity.mapToMovieQuery()))
                }
            } catch {
                DispatchQueue.global(qos: .background).async {
                    completion(.failure(CoreDataStorageError.writeError(error)))
                }
                print(error)
            }
        }
    }
    
    fileprivate func cleanUpQueries(for query: MovieQuery, inContext context: NSManagedObjectContext) throws {
    
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
