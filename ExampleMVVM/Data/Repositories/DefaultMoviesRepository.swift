//
//  DefaultMoviesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

final class DefaultMoviesRepository {
    
    private let dataTransferService: DataTransferService
    
    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
}

extension DefaultMoviesRepository: MoviesRepository {
    
    public func fetchMoviesList(query: MovieQuery, page: Int, completion: @escaping (Result<MoviesPage, Error>) -> Void) -> Cancellable? {

        let endpoint = APIEndpoints.getMovies(moviesRequestDTO: .init(query: query.query,
                                                                      page: page))
        let networkTask = dataTransferService.request(with: endpoint) { (response: Result<MoviesResponseDTO, Error>) in
            switch response {
            case .success(let moviesResponseDTO):
                completion(.success(moviesResponseDTO.mapToDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return RepositoryTask(networkTask: networkTask)
    }
}
