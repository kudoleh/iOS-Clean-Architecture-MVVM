import Foundation

enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

enum BodyEncoding {
    case jsonSerializationData
    case stringEncodingAscii
}

class Endpoint<R>: ResponseRequestable {
    
    typealias Response = R
    
    let path: String
    let isFullPath: Bool
    let method: HTTPMethodType
    let headerParameters: [String: String]
    let queryParametersEncodable: Encodable?
    let queryParameters: [String: Any]
    let bodyParametersEncodable: Encodable?
    let bodyParameters: [String: Any]
    let bodyEncoding: BodyEncoding
    let responseDecoder: ResponseDecoder
    
    init(path: String,
         isFullPath: Bool = false,
         method: HTTPMethodType,
         headerParameters: [String: String] = [:],
         queryParametersEncodable: Encodable? = nil,
         queryParameters: [String: Any] = [:],
         bodyParametersEncodable: Encodable? = nil,
         bodyParameters: [String: Any] = [:],
         bodyEncoding: BodyEncoding = .jsonSerializationData,
         responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoding = bodyEncoding
        self.responseDecoder = responseDecoder
    }
}

protocol Requestable {
    var path: String { get }
    var isFullPath: Bool { get }
    var method: HTTPMethodType { get }
    var headerParameters: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParametersEncodable: Encodable? { get }
    var bodyParameters: [String: Any] { get }
    var bodyEncoding: BodyEncoding { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

protocol ResponseRequestable: Requestable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}

enum RequestGenerationError: Error {
    case components
}

extension Requestable {
    
    func url(with config: NetworkConfigurable) throws -> URL {

        let baseURL = config.baseURL.absoluteString.last != "/"
        ? config.baseURL.absoluteString + "/"
        : config.baseURL.absoluteString
        let endpoint = isFullPath ? path : baseURL.appending(path)
        
        guard var urlComponents = URLComponents(
            string: endpoint
        ) else { throw RequestGenerationError.components }
        var urlQueryItems = [URLQueryItem]()

        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        return url
    }
    
    func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {
        
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        headerParameters.forEach { allHeaders.updateValue($1, forKey: $0) }

        let bodyParameters = try bodyParametersEncodable?.toDictionary() ?? self.bodyParameters
        if !bodyParameters.isEmpty {
            urlRequest.httpBody = encodeBody(bodyParameters: bodyParameters, bodyEncoding: bodyEncoding)
        }
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        return urlRequest
    }
    
    private func encodeBody(bodyParameters: [String: Any], bodyEncoding: BodyEncoding) -> Data? {
        switch bodyEncoding {
        case .jsonSerializationData:
            return try? JSONSerialization.data(withJSONObject: bodyParameters)
        case .stringEncodingAscii:
            return bodyParameters.queryString.data(
                using: String.Encoding.ascii,
                allowLossyConversion: true
            )
        }
    }
}

private extension Dictionary {
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}

private extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String : Any]
    }
}
