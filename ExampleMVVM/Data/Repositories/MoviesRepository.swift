//
//  DefaultMoviesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

final class DefaultMoviesRepository {
    
    private let dataTransferService: DataTransfer
    
    init(dataTransferService: DataTransfer) {
        self.dataTransferService = dataTransferService
    }
}

extension DefaultMoviesRepository: MoviesRepository {
    
    public func moviesList(query: MovieQuery, page: Int, completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {
        
        let endpoint = APIEndpoints.movies(query: query.query, page: page)
        return self.dataTransferService.request(with: endpoint, completion: completion)
    }
}
