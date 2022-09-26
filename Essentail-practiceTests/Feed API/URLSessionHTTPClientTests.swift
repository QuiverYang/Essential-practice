//
//  URLSessionHTTPClientTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/26.
//

import XCTest

class URLSessionHTTPClient {
    let session : URLSession
    init(session : URLSession) {
        self.session = session
    }
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in
            
        }
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createDataTaskWithURL() {
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let url = URL(string: "https://some-url.com")!
        
        sut.get(from: url)
        
        XCTAssertEqual(session.recievedURLs, [url])
    }
    
    private class URLSessionSpy : URLSession {
        var recievedURLs = [URL]()
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            recievedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    private class FakeURLSessionDataTask: URLSessionDataTask {}
    

}
