//
//  FeedImageDataLoaderTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/21.
//

import Foundation
import XCTest
import Essentail_practice

final class RemoteFeedImageDataLoader {
    let client: HttpClient
    init(client: HttpClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Any) -> Void) {
        client.get(from: url) { _ in }
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerfomAnyURLRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.reuqestURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requstsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        
        sut.loadImageData(from: url){ _ in }
        
        XCTAssertEqual(client.reuqestURLs, [url] )
        
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        
        sut.loadImageData(from: url){ _ in }
        sut.loadImageData(from: url){ _ in }
        
        XCTAssertEqual(client.reuqestURLs, [url, url] )
    }
    
    //Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    final class HTTPClientSpy: HttpClient{
        var reuqestURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) {
            reuqestURLs.append(url)
        }
        
        
    }
    
    
}
