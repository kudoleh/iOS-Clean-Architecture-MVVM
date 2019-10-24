//
//  DataTransferServiceTests.swift
//  ExampleMVVMTests
//
//  Created by Oleh Kudinov on 16.08.19.
//

import XCTest

private struct MockModel: Decodable {
    let name: String
}

private struct MockErrorModel: Error & Decodable {
    let errorName: String
}

class DataTransferServiceTests: XCTestCase {
    
    private enum DataTransferErrorMock: Error {
        case someError
    }
    
    func test_whenReceivedValidJsonInResponse_shouldDecodeResponseToDecodableObject() {
        //given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should decode mock object")
        
        let responseData = #"{"name": "Hello"}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(session: NetworkSessionMock(response: nil,
                                                                               data: responseData,
                                                                               error: nil),
                                                   config: config)
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(with: DataEndpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)) { result in
            do {
                let object = try result.get()
                XCTAssertEqual(object.name, "Hello")
                expectation.fulfill()
            } catch {
                XCTFail("Failed decoding MockObject")
            }
        }
        //then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_whenReceivedValidErrorJsonInResponse_shouldDecodeErrorResponseToDecodableErrorObject() {
        //given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should decode mock object")
        
        let responseData = #"{"errorName": "fieldErrorName"}"#.data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 400,
                                       httpVersion: "1.1",
                                       headerFields: nil)
        let networkService = DefaultNetworkService(session: NetworkSessionMock(response: response,
                                                                               data: responseData,
                                                                               error: NSError(domain:"Test", code: 400,
                                                                                              userInfo: nil)),
                                                   config: config)
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(with: DataEndpointErrorable<MockModel, MockErrorModel>(path: "http://mock.endpoint.com", method: .get)) { result in
            switch result {
            case .success: XCTFail("Should decode MockErrorModel")
            case .failure(let error):
                guard case let DataTransferError.networkDecodedError(_, error) = error,
                    let decodedError = error as? MockErrorModel else  {
                        XCTFail("Failed decoding MockErrorModel")
                        return
                }
                XCTAssertEqual(decodedError.errorName, "fieldErrorName")
                expectation.fulfill()
            }
        }
        //then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_whenInvalidResponse_shouldNotDecodeObject() {
        //given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should not decode mock object")
        
        let responseData = #"{"age": 20}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(session: NetworkSessionMock(response: nil,
                                                                               data: responseData,
                                                                               error: nil),
                                                   config: config)
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(with: DataEndpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)) { result in
            do {
                _ = try result.get()
                XCTFail("Should not happen")
            } catch {
                expectation.fulfill()
            }
        }
        //then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_whenBadRequestReceived_shouldRethrowNetworkError() {
        //given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should throw network error")
        
        let responseData = #"{"invalidStructure": "Nothing"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 500,
                                       httpVersion: "1.1",
                                       headerFields: nil)
        let networkService = DefaultNetworkService(session: NetworkSessionMock(response: response,
                                                                               data: responseData,
                                                                               error: DataTransferErrorMock.someError),
                                                   config: config)
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(with: DataEndpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)) { result in
            do {
                _ = try result.get()
                XCTFail("Should not happen")
            } catch let error {
                
                if case DataTransferError.networkFailure(NetworkError.error(statusCode: 500, _)) = error {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong error")
                }
            }
        }
        //then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_whenNoDataReceived_shouldThrowNoDataError() {
        //given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should throw no data error")
        
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: [:])
        let networkService = DefaultNetworkService(session: NetworkSessionMock(response: response,
                                                                               data: nil,
                                                                               error: nil),
                                                   config: config)
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(with: DataEndpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)) { result in
            do {
                _ = try result.get()
                XCTFail("Should not happen")
            } catch let error {
                if case DataTransferError.noResponse = error {
                    expectation.fulfill()
                } else {
                    XCTFail("Wrong error")
                }
            }
        }
        //then
        wait(for: [expectation], timeout: 0.1)
    }
}
