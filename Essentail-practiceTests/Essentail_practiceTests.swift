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

class HttpClientSpy : HttpClient {
    func get(from url: URL) {
        requestURL = url
    }
    
    var requestURL : URL?

}

class Essentail_practiceTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClientSpy()
        let url = URL(string: "https://some-url.com")!
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestURL)
    }
    func test_load_requestDataFromURL() {
        let client = HttpClientSpy()
        let url = URL(string: "https://some-given-url.com")!
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        XCTAssertEqual(client.requestURL, url)
    }

}
