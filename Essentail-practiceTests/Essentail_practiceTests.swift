//
//  Essentail_practiceTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/7.
//

import XCTest
@testable import Essentail_practice

class RemoteFeedLoader {
    let client : HttpClient
    let url : URL
    init(url: URL, client: HttpClient) {
        self.client = client
        self.url = url
    }
    func load(){
        client.get(from:url)
    }
}

protocol HttpClient {
    func get(from url: URL)
}


class Essentail_practiceTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestURL)
    }
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://some-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        XCTAssertEqual(client.requestURL, url)
    }
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https://some-url.com")!) -> (sut : RemoteFeedLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HttpClientSpy : HttpClient {
        func get(from url: URL) {
            requestURL = url
        }
        var requestURL : URL?

    }


}
