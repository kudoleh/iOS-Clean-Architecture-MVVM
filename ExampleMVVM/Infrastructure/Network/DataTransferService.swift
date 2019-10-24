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
    case networkDecodedError(code: Int, Decodable)
}
extension DataTransferError: ConnectionError {
    public var isInternetConnectionError: Bool {
        guard case let DataTransferError.networkFailure(networkError) = self,
              case .notConnected = networkError else {
            return false
        }
        return true
    }
}

final public class DataEndpoint<T: Decodable>: Endpoint { }
final public class DataEndpointErrorable<T: Decodable, E: Decodable>: Endpoint { }

public protocol DataTransfer {
    @discardableResult
    func request<T: Decodable>(with endpoint: DataEndpoint<T>, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable?
    @discardableResult
    func request(with endpoint: DataEndpoint<Data>, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable?
    @discardableResult
    func request<T: Decodable, E: Decodable>(with endpoint: DataEndpointErrorable<T, E>, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable?
}

public final class DefaultDataTransferService {
    
    private let networkService: NetworkService
    
    public init(with networkService: NetworkService) {
        self.networkService = networkService
    }
}

extension DefaultDataTransferService: DataTransfer {
    
    public func request<T: Decodable>(with endpoint: DataEndpoint<T>, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? {
        
        let task = self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let responseData):
                guard let responseData = responseData else {
                    DispatchQueue.main.async { completion(Result.failure(DataTransferError.noResponse)) }
                    return
                }
                self.decode(responseData: responseData, completion: completion)
            case .failure(let error):
                DispatchQueue.main.async { completion(Result.failure(DataTransferError.networkFailure(error))) }
            }
        }
        
        return task
    }
    
    public func request(with endpoint: DataEndpoint<Data>, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        let task = self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let responseData):
                guard let responseData = responseData else {
                    DispatchQueue.main.async { completion(Result.failure(DataTransferError.noResponse)) }
                        return
                }
                DispatchQueue.main.async { completion(Result.success(responseData)) }
            case .failure(let error):
                DispatchQueue.main.async { completion(Result.failure(DataTransferError.networkFailure(error))) }
            }
        }
        
        return task
    }
    
    public func request<T: Decodable, E: Decodable>(with endpoint: DataEndpointErrorable<T, E>, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable? {
        
        let task = self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let responseData):
                guard let responseData = responseData else {
                    DispatchQueue.main.async { completion(Result.failure(DataTransferError.noResponse)) }
                    return
                }
                self.decode(responseData: responseData, completion: completion)
            case .failure(let error):
                guard case let NetworkError.error(statusCode, data) = error,
                    let errorResponseData = data else {
                        DispatchQueue.main.async { completion(Result.failure(DataTransferError.networkFailure(error))) }
                        return
                }
                self.decode(errorResponseData: errorResponseData,
                            errorType: E.self,
                            statusCode: statusCode,
                            completion: completion)
            }
        }
        
        return task
    }
    
    private func decode<T: Decodable>(responseData: Data,
                                      completion: @escaping (Result<T, Error>) -> Void) {
        do {
            let result: T = try decode(data: responseData)
            DispatchQueue.main.async { completion(.success(result)) }
        } catch {
            DispatchQueue.main.async { completion(Result.failure(DataTransferError.parsingJSON)) }
        }
    }
    
    private func decode<T, E: Decodable>(errorResponseData: Data,
                                      errorType: E.Type,
                                      statusCode: Int,
                                      completion: @escaping (Result<T, Error>) -> Void) {
        do {
            let result: E = try decode(data: errorResponseData)
            DispatchQueue.main.async { completion(Result.failure(DataTransferError.networkDecodedError(code: statusCode, result))) }
        } catch {
            DispatchQueue.main.async { completion(Result.failure(DataTransferError.parsingJSON)) }
        }
    }
    
    private func decode<T: Decodable>(data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
}
