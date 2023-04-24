//
//  URLSessionHTTPClientTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/26.
//

import XCTest
import Essentail_practice




class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for request")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = anyNSError()
        let recievedError = resultErrorFor((data: nil, response: nil, error: error)) as NSError?
                
        XCTAssertEqual(recievedError?.domain, error.domain)
        XCTAssertEqual(recievedError?.code, error.code)
        
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        
        XCTAssertNotNil(resultErrorFor((data:nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data:nil, response: anyNonHttpURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data:anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data:anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data:nil, response: anyNonHttpURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data:nil, response: anyHttpURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data:anyData(), response: anyNonHttpURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data:anyData(), response: anyHttpURLResponse(), error: anyNSError())))

    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilDataRequest() {
        let response = anyHttpURLResponse()
        URLProtocolStub.stub(data: nil, response: response, error: nil,requestObserver: nil)
        
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: anyURL()) { result in
            switch result {
            case let .success((recievedData, recievedResponse)):
                let emptyData = Data()
                XCTAssertEqual(recievedData, emptyData)
                XCTAssertEqual(recievedResponse.url, response.url)
                XCTAssertEqual(recievedResponse.statusCode, response.statusCode)
            default:
                XCTFail("Expceted success, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        
    }
    
    func test_getFromURL_succeedsOnHTTPResponseWithData() {
        let data = anyData()
        let response = anyHttpURLResponse()

        let recievedValue = resultValueFor((data: data, response: response, error: nil))
        XCTAssertEqual(recievedValue?.data, data)
        XCTAssertEqual(recievedValue?.response.url, response.url)
    }
    
    func test_cancelGetFromURLTask_cancelURLRequest() {
        
        let recievedError = resultErrorFor(taskHandler: {$0.cancel()}) as? NSError
        
        XCTAssertEqual(recievedError?.code, URLError.cancelled.rawValue)
    }
    
    // Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse? ,error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)

        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValueFor(_ values: (data: Data?, response: URLResponse? ,error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: URLResponse)? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)

        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
        
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse? ,error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        values.map {
            URLProtocolStub.stub(data: $0, response: $1, error: $2, requestObserver: nil)
        }
        var recievedResult : HTTPClient.Result!
        let exp = expectation(description: "wait for completion")
        
        let task = makeSUT().get(from: anyURL()) { result in
            recievedResult = result
            exp.fulfill()
        }
        taskHandler(task)
        wait(for: [exp], timeout: 1.0)
        return recievedResult
    }
    
    private func anyURL() -> URL {
        URL(string: "https://some-url")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyNonHttpURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHttpURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    
    
    

}
