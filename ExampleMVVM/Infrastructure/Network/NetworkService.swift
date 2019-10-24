//
//  NetworkService.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

public protocol NetworkService {
    
    func request(endpoint: Requestable, completion: @escaping (Result<Data?, NetworkError>) -> Void) -> Cancellable?
}

public enum NetworkError: Error {
    case error(statusCode: Int, responseData: Data?)
    case notConnected
    case cancelled
    case urlGeneration
    case requestError(Error?)
}

extension NetworkError {
    public var isNotFoundError: Bool { return hasStatusCode(404) }
    
    public func hasStatusCode(_ codeError: Int) -> Bool {
        switch self {
        case let .error(code, _):
            return code == codeError
        default: return false
        }
    }
}

public protocol NetworkSession {
    func loadData(from request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Cancellable
}

extension URLSessionTask: Cancellable { }

extension URLSession: NetworkSession {
    public func loadData(from request: URLRequest,
                         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Cancellable {
        let task = dataTask(with: request) { data, response, error in
            completionHandler(data, response, error)
        }
        task.resume()
        return task
    }
}

// MARK: - Implementation

final public class DefaultNetworkService {
    
    private let session: NetworkSession
    private let config: NetworkConfigurable
    private let logger: NetworkErrorLogger
    
    public init(session: NetworkSession,
                config: NetworkConfigurable,
                logger: NetworkErrorLogger = DefaultNetworkErrorLogger()) {
        self.session = session
        self.config = config
        self.logger = logger
    }
    
    private func request(request: URLRequest, completion: @escaping (Result<Data?, NetworkError>) -> Void) -> Cancellable {
        
        let sessionDataTask = session.loadData(from: request) { [weak self] data, response, requestError in
            var error: NetworkError
            if let requestError = requestError {
                
                if let response = response as? HTTPURLResponse, (400..<600).contains(response.statusCode) {
                    error = .error(statusCode: response.statusCode, responseData: data)
                    self?.logger.log(statusCode: response.statusCode)
                } else if requestError._code == NSURLErrorNotConnectedToInternet {
                    error = .notConnected
                } else if requestError._code == NSURLErrorCancelled {
                    error = .cancelled
                } else {
                    error = .requestError(requestError)
                }
                self?.logger.log(error: requestError)
                
                completion(.failure(error))
            } else {
                self?.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }
        
        logger.log(request: request)
        
        return sessionDataTask
    }
}

extension DefaultNetworkService: NetworkService {
    
    public func request(endpoint: Requestable, completion: @escaping (Result<Data?, NetworkError>) -> Void) -> Cancellable? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(NetworkError.urlGeneration))
            return nil
        }
    }
}

// MARK: - Log
public protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
    func log(statusCode: Int)
}

final public class DefaultNetworkErrorLogger: NetworkErrorLogger {
    public init() { }
    
    public func log(request: URLRequest) {
        #if DEBUG
        print("-------------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            print("body: \(String(describing: result))")
        }
        if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            print("body: \(String(describing: resultString))")
        }
        #endif
    }
    
    public func log(responseData data: Data?, response: URLResponse?) {
        #if DEBUG
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("responseData: \(String(describing: dataDict))")
        }
        #endif
    }
    
    public func log(error: Error) {
        #if DEBUG
        print("error: \(error)")
        #endif
    }
    
    public func log(statusCode: Int) {
        #if DEBUG
        print("status code: \(statusCode)")
        #endif
    }
}
