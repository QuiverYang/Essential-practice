//
//  URLSessionHTTPClientTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/26.
//

import XCTest
import Essentail_practice

class URLSessionHTTPClient: HttpClient {
    init() {}
    
    struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse{
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}


class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptinRequests()
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
        let recievedError = resultErrorFor(data: nil, response: nil, error: error) as NSError?
                
        XCTAssertEqual(recievedError?.domain, error.domain)
        XCTAssertEqual(recievedError?.code, error.code)
        
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        
        XCTAssertNotNil(resultErrorFor(data:nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data:nil, response: anyNonHttpURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data:anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data:anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data:nil, response: anyNonHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data:nil, response: anyHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data:anyData(), response: anyNonHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data:anyData(), response: anyHttpURLResponse(), error: anyNSError()))

    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilDataRequest() {
        let response = anyHttpURLResponse()
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        let sut = makeSUT()
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: anyURL()) { result in
            switch result {
            case let .success(recievedData, recievedResponse):
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

        let recievedValue = resultValueFor(data: data, response: response, error: nil)
        XCTAssertEqual(recievedValue?.data, data)
        XCTAssertEqual(recievedValue?.response.url, response.url)
    }
    
    // Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HttpClient {
        let sut = URLSessionHTTPClient()
        trackFroMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse? ,error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error)

        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultValueFor(data: Data?, response: URLResponse? ,error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: URLResponse)? {
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
        
    }
    
    private func resultFor(data: Data?, response: URLResponse? ,error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        var recievedResult : HTTPClientResult!
        let exp = expectation(description: "wait for completion")
        
        makeSUT().get(from: anyURL()) { result in
            recievedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return recievedResult
    }
    
    private func anyURL() -> URL {
        URL(string: "https://some-url")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
    
    private func anyNonHttpURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHttpURLResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private class URLProtocolStub: URLProtocol {
        static private var stub : Stub?
        static var requestObserver : ((URLRequest) -> Void)?
        private struct Stub {
            let data : Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse? ,error: Error?) {
            
            stub = Stub(data: data, response: response,error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptinRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
         }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
    

}
