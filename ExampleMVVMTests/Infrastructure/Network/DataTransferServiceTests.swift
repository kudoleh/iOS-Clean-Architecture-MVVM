import XCTest

private struct MockModel: Decodable {
    let name: String
}

final class DataTransferDispatchQueueMock: DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void) {
        work()
    }
}

class DataTransferServiceTests: XCTestCase {
    
    private enum DataTransferErrorMock: Error {
        case someError
    }
    
    func test_whenReceivedValidJsonInResponse_shouldDecodeResponseToDecodableObject() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let responseData = #"{"name": "Hello"}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: nil,
                data: responseData,
                error: nil
            )
        )
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get),
            on: DataTransferDispatchQueueMock()
        ) { result in
            do {
                let object = try result.get()
                XCTAssertEqual(object.name, "Hello")
                completionCallsCount += 1
            } catch {
                XCTFail("Failed decoding MockObject")
            }
        }
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenInvalidResponse_shouldNotDecodeObject() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let responseData = #"{"age": 20}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: nil,
                data: responseData,
                error: nil
            )
        )
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get),
            on: DataTransferDispatchQueueMock()
        ) { result in
            do {
                _ = try result.get()
                XCTFail("Should not happen")
            } catch {
                completionCallsCount += 1
            }
        }
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenBadRequestReceived_shouldRethrowNetworkError() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let responseData = #"{"invalidStructure": "Nothing"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 500,
                                       httpVersion: "1.1",
                                       headerFields: nil)
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: response,
                data: responseData,
                error: DataTransferErrorMock.someError
            )
        )
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get),
            on: DataTransferDispatchQueueMock()
        ) { result in
            do {
                _ = try result.get()
                XCTFail("Should not happen")
            } catch let error {
                
                if case DataTransferError.networkFailure(NetworkError.error(statusCode: 500, _)) = error {
                    completionCallsCount += 1
                } else {
                    XCTFail("Wrong error")
                }
            }
        }
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenNoDataReceived_shouldThrowNoDataError() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: [:])
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: response,
                data: nil,
                error: nil
            )
        )
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get),
            on: DataTransferDispatchQueueMock()
        ) { result in
            do {
                _ = try result.get()
                XCTFail("Should not happen")
            } catch let error {
                if case DataTransferError.noResponse = error {
                    completionCallsCount += 1
                } else {
                    XCTFail("Wrong error")
                }
            }
        }
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
}
