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
    init(client : HttpClient) {
        self.client = client
    }
    func load(){
        client.get(from:URL(string: "https://some-url.com")!)
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
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestURL)
    }
    func test_load_requestDataFromURL() {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        XCTAssertNotNil(client.requestURL)
    }

}
