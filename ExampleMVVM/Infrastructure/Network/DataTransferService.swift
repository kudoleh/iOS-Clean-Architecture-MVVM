//
//  DataTransfer.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

public enum DataTransferError: Error {
    case noResponse
    case parsingJSON
    case networkFailure(NetworkError)
}

final public class DataEndpoint<T: Any>: Endpoint { }

public protocol DataTransfer {
    @discardableResult
    func request<T: Decodable>(with endpoint: DataEndpoint<T>, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable?
    @discardableResult
    func request(with endpoint: DataEndpoint<Data>, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable?
    @discardableResult
    func request<T: Decodable>(with endpoint: DataEndpoint<T>, respondOnQueue: DispatchQueue, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable?
    @discardableResult
    func request(with endpoint: DataEndpoint<Data>, respondOnQueue: DispatchQueue, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable?
}

public final class DefaultDataTransferService {
    
    private let networkService: NetworkService
    
    public init(with networkService: NetworkService) {
        self.networkService = networkService
    }
}

extension DefaultDataTransferService: DataTransfer {
    
    public func request<T>(with endpoint: DataEndpoint<T>, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? where T: Decodable {
        return request(with: endpoint, respondOnQueue: .main, completion: completion)
    }
    
    public func request(with endpoint: DataEndpoint<Data>, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        return request(with: endpoint, respondOnQueue: .main, completion: completion)
    }
    
    public func request<T: Decodable>(with endpoint: DataEndpoint<T>, respondOnQueue: DispatchQueue, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? {
        
        let task = self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let responseData):
                guard let responseData = responseData else {
                    respondOnQueue.async { completion(Result.failure(DataTransferError.noResponse)) }
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = endpoint.keyDecodingStrategy
                    let result = try decoder.decode(T.self, from: responseData)
                    respondOnQueue.async { completion(.success(result)) }
                } catch {
                    respondOnQueue.async { completion(Result.failure(DataTransferError.parsingJSON)) }
                }
            case .failure(let error):
                respondOnQueue.async { completion(Result.failure(DataTransferError.networkFailure(error))) }
            }
        }
        
        return task
    }
    
    public func request(with endpoint: DataEndpoint<Data>, respondOnQueue: DispatchQueue, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        let task = self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let responseData):
                guard let responseData = responseData
                    else {
                        respondOnQueue.async { completion(Result.failure(DataTransferError.noResponse)) }
                        return
                }
                respondOnQueue.async { completion(Result.success(responseData)) }
            case .failure(let error):
                respondOnQueue.async { completion(Result.failure(DataTransferError.networkFailure(error))) }
            }
        }
        
        return task
    }
}
