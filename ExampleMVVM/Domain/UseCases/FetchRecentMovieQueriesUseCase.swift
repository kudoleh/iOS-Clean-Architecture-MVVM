//
//  FetchRecentMovieQueriesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 11.08.19.
//

import Foundation

protocol FetchRecentMovieQueriesUseCase {
    func execute(requestValue: FetchRecentMovieQueriesUseCaseRequestValue,
                 completion: @escaping (Result<[MovieQuery], Error>) -> Void) -> Cancellable?
}

final class DefaultFetchRecentMovieQueriesUseCase: FetchRecentMovieQueriesUseCase {
    
    private let moviesQueriesRepository: MoviesQueriesRepository
    
    init(moviesQueriesRepository: MoviesQueriesRepository) {
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    func execute(requestValue: FetchRecentMovieQueriesUseCaseRequestValue,
                 completion: @escaping (Result<[MovieQuery], Error>) -> Void) -> Cancellable? {
        moviesQueriesRepository.recentsQueries(number: requestValue.number, completion: completion)
        return nil
    }
}

struct FetchRecentMovieQueriesUseCaseRequestValue {
    let number: Int
}
