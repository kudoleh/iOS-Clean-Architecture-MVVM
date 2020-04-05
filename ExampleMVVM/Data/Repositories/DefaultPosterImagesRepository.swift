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
    
    func fetchImage(with imagePath: String, width: Int, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        
        let endpoint = APIEndpoints.getMoviePoster(path: imagePath, width: width)
        let task = RepositoryTask()
        task.networkTask = dataTransferService.request(with: endpoint) { [weak self] (result: Result<Data, Error>) in
            guard let self = self else { return }

            if case .failure(let error) = result,
                case let DataTransferError.networkFailure(networkError) = error,
                let imageNotFoundData = self.imageNotFoundData,
                networkError.isNotFoundError {
                DispatchQueue.main.async { completion(.success(imageNotFoundData)) }
            } else {
                DispatchQueue.main.async { completion(result) }
            }
        }
        return task
    }
}
