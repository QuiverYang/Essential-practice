//
//  URLSessionHTTPClientTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/26.
//

import XCTest
import Essentail_practice

class URLSessionHTTPClient {
    private let session : URLSession
    init(session : URLSession) {
        self.session = session
    }
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://some-url.com")!
        let task = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url){_ in}
        
        XCTAssertEqual(task.resumeCallCounter, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://some-url")!
        let error = NSError(domain: "test", code: 0)
        let session = URLSessionSpy()
        session.stub(url: url)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "wait for completion")
        sut.get(from: url){ result in
            switch result {
            case .failure(let recievedError as NSError) :
                XCTAssertEqual(recievedError, error)
            default:
                XCTFail("Expected failure with error:\(error), but got \(result) instead")
            }
            exp.fulfill()
            
        }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private class URLSessionSpy : URLSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task : URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            
            stubs[url] = Stub(task: task, error: error)
        }
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Could not find stub for \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCounter = 0
        override func resume() {
            resumeCallCounter += 1
        }
    }
    

}
