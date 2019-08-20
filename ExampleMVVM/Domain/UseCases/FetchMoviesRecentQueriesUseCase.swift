//
//  FetchMoviesRecentQueriesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 11.08.19.
//

import Foundation

protocol FetchMoviesRecentQueriesUseCase {
    func execute(requestValue: FetchMoviesRecentQueriesUseCaseRequestValue,
                 completion: @escaping (Result<[MovieQuery], Error>) -> Void) -> Cancellable?
}

final class DefaultFetchMoviesRecentQueriesUseCase: FetchMoviesRecentQueriesUseCase {
    
    private let moviesQueriesRepository: MoviesQueriesRepository
    
    init(moviesQueriesRepository: MoviesQueriesRepository) {
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    func execute(requestValue: FetchMoviesRecentQueriesUseCaseRequestValue,
                 completion: @escaping (Result<[MovieQuery], Error>) -> Void) -> Cancellable? {
        moviesQueriesRepository.recentsQueries(number: requestValue.number, completion: completion)
        return nil
    }
}

struct FetchMoviesRecentQueriesUseCaseRequestValue {
    let number: Int
}
