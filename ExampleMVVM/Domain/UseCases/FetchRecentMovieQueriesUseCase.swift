//
//  FetchRecentMovieQueriesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 11.08.19.
//

import Foundation

// This is another option to create Use Case using more generic way
final class FetchRecentMovieQueriesUseCase: UseCase {

    struct RequestValue {
        let number: Int
    }
    typealias ResultValue = (Result<[MovieQuery], Error>)

    private let requestValue: RequestValue
    private let completion: (ResultValue) -> Void
    private let moviesQueriesRepository: MoviesQueriesRepository

    init(requestValue: RequestValue,
         completion: @escaping (ResultValue) -> Void,
         moviesQueriesRepository: MoviesQueriesRepository) {
        self.requestValue = requestValue
        self.completion = completion
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    func start() -> Cancellable? {
        moviesQueriesRepository.recentsQueries(number: requestValue.number) { result in
            // Note: here self must be strong because we will create use case every time we use it, without holding reference to it
            switch result {
            case .success(let movieQueries):
                self.completion(.success(movieQueries))
            case .failure(let error):
                self.completion(.failure(error))
            }
        }
        return nil
    }
}
