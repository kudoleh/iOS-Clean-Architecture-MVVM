//
//  SearchMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 22.02.19.
//

import Foundation

protocol SearchMoviesUseCase {
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable?
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {

    private let moviesRepository: MoviesRepository
    private let moviesQueriesRepository: MoviesQueriesRepository
    
    init(moviesRepository: MoviesRepository, moviesQueriesRepository: MoviesQueriesRepository) {
        self.moviesRepository = moviesRepository
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    func execute(requestValue: SearchMoviesUseCaseRequestValue,
                 completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
        return moviesRepository.fetchMoviesList(query: requestValue.query, page: requestValue.page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.moviesQueriesRepository.saveRecentQuery(query: requestValue.query) { _ in }
                completion(result)
            case .failure:
                completion(result)
            }
        }
    }
}

struct SearchMoviesUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}
