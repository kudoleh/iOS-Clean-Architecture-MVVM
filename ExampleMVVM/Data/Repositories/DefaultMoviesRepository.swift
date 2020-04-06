//
//  DefaultMoviesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

final class DefaultMoviesRepository {
    
    private let dataTransferService: DataTransferService
    private let moviesResponseCache: MoviesResponseStorage
    
    init(dataTransferService: DataTransferService, moviesResponseCache: MoviesResponseStorage) {
        self.dataTransferService = dataTransferService
        self.moviesResponseCache = moviesResponseCache
    }
}

extension DefaultMoviesRepository: MoviesRepository {
    
    public func fetchMoviesList(query: MovieQuery, page: Int,
                                cached: @escaping (MoviesPage?) -> Void,
                                completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {

        let requestDTO = MoviesRequestDTO(query: query.query, page: page)
        let task = RepositoryTask()
        
        moviesResponseCache.fetchMoviesResponse(for: requestDTO) { result in
            if case let .success(cachedResponse) = result {
                cached(cachedResponse?.mapToDomain())
            }
            guard !task.isCancelled else { return }

            let endpoint = APIEndpoints.getMovies(with: requestDTO)
            task.networkTask = self.dataTransferService.request(with: endpoint) { (response: Result<MoviesResponseDTO, Error>) in
                switch response {
                case .success(let moviesResponseDTO):
                    self.moviesResponseCache.saveMoviesResponse(moviesResponseDTO, for: requestDTO)
                    completion(.success(moviesResponseDTO.mapToDomain()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}
