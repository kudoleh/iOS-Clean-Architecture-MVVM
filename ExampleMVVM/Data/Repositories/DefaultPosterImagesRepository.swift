//
//  DefaultPosterImagesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

final class DefaultPosterImagesRepository {
    
    private let dataTransferService: DataTransferService
    private let imageNotFoundData: Data?
    
    init(dataTransferService: DataTransferService,
         imageNotFoundData: Data?) {
        self.dataTransferService = dataTransferService
        self.imageNotFoundData = imageNotFoundData
    }
}

extension DefaultPosterImagesRepository: PosterImagesRepository {
    
    func image(with imagePath: String, width: Int, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        
        let endpoint = APIEndpoints.moviePoster(path: imagePath, width: width)
        let networkTask = dataTransferService.request(with: endpoint) { [weak self] (response: Result<Data, Error>) in
            guard let self = self else { return }
            
            switch response {
            case .success(let data):
                completion(.success(data))
                return
            case .failure(let error):
                if case let DataTransferError.networkFailure(networkError) = error, networkError.isNotFoundError,
                    let imageNotFoundData = self.imageNotFoundData {
                    completion(.success(imageNotFoundData))
                    return
                }
                completion(.failure(error))
                return
            }
        }
        return RepositoryTask(networkTask: networkTask)
    }
}
