//
//  MoviesResponseStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05/04/2020.
//

import Foundation

protocol MoviesResponseStorage {
    func fetchMoviesResponse(for request: MoviesRequestDTO, completion: @escaping (Result<MoviesResponseDTO?, CoreDataStorageError>) -> Void)
    func saveMoviesResponse(_ responseDto: MoviesResponseDTO, for requestDto: MoviesRequestDTO)
}
