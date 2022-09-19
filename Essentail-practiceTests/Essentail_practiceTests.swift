//
//  Essentail_practiceTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/7.
//

import XCTest
import Essentail_practice


class Essentail_practiceTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://some-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }
    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL(string: "https://some-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url,url])


    }
    func test_loadDeliversErrorOnClientError(){
        let (sut, client) = makeSUT()
        
        let clientError = NSError(domain: "test", code: 0)
        client.error = clientError
        
        var capturedError : RemoteFeedLoader.Error?
        sut.load { capturedError = $0 }
        
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> (sut : RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HttpClientSpy : HttpClient {
        var requestedURLs = [URL]()
        var error : Error?
        func get(from url: URL, completion : @escaping (Error) -> Void) {
            requestedURLs.append(url)
            if let error = error {
                completion(error)
            }
        }
    }


}
