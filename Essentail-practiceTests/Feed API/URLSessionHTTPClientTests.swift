//
//  URLSessionHTTPClientTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/26.
//

import XCTest
import Essentail_practice

class URLSessionHTTPClient {
    init() {
    }
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        URLSession.shared.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}


class URLSessionHTTPClientTests: XCTestCase {

    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "https://some-url")!
        let error = NSError(domain: "test", code: 0)
        URLProtocolStub.stub(url: url,data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case .failure(let recievedError as NSError) :
                XCTAssertEqual(recievedError.domain, error.domain)
                XCTAssertEqual(recievedError.code, error.code)
            default:
                XCTFail("Expected failure with error:\(error), but got \(result) instead")
            }
            exp.fulfill()
            
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptinRequests()
        
    }
    
    private class URLProtocolStub: URLProtocol {
        static private var stubs = [URL: Stub]()
        
        private struct Stub {
            let data : Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse? ,error: Error? = nil) {
            
            stubs[url] = Stub(data: data, response: response,error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptinRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {return false}
            
            return URLProtocolStub.stubs[url] != nil
         }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {return}
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
    

}
