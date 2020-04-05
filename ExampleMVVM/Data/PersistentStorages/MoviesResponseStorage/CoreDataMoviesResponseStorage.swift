//
//  CoreDataMoviesResponseStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05/04/2020.
//

import Foundation
import CoreData

final class CoreDataMoviesResponseStorage {

    private let coreDataStorage: CoreDataStorage

    init(coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.coreDataStorage = coreDataStorage
    }

    // MARK: - Private

    private func fetchRequest(for requestDto: MoviesRequestDTO) -> NSFetchRequest<MoviesRequestEntity> {
        let request: NSFetchRequest = MoviesRequestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "query = %@ AND page = %d", requestDto.query, requestDto.page)
        return request
    }

    private func deleteResponse(for requestDto: MoviesRequestDTO, in context: NSManagedObjectContext) {
        let request = fetchRequest(for: requestDto)

        do {
            if let result = try context.fetch(request).first {
                context.delete(result)
            }
        } catch {
            print(error)
        }
    }
}

extension CoreDataMoviesResponseStorage: MoviesResponseStorage {

    func fetchMoviesResponse(for requestDto: MoviesRequestDTO, completion: @escaping (Result<MoviesResponseDTO?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let request = self.fetchRequest(for: requestDto)

                let result = try context.fetch(request).first

                completion(.success(result?.response?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
                print(error)
            }
        }
    }

    func saveMoviesResponse(_ responseDto: MoviesResponseDTO, for requestDto: MoviesRequestDTO) {
        coreDataStorage.performBackgroundTask { context in
            do {
                self.deleteResponse(for: requestDto, in: context)

                let requestEntity = requestDto.toEntity(in: context)
                requestEntity.response = responseDto.toEntity(in: context)

                try context.save()
            } catch {
                print(error)
            }
        }
    }
}
