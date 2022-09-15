//
//  Essentail_practiceTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/9/7.
//

import XCTest
@testable import Essentail_practice

class RemoteFeedLoader {
    func load(){
        HttpClient.shared.get(from:URL(string: "https://some-url.com")!)
    }
}

class HttpClient {
    static var shared = HttpClient()
    func get(from url: URL) {}
}

class HttpClientSpy : HttpClient {
    override func get(from url: URL) {
        requestURL = url
    }
    
    var requestURL : URL?

}

class Essentail_practiceTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClientSpy()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestURL)
    }
    func test_load_requestDataFromURL() {
        let client = HttpClientSpy()
        HttpClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        XCTAssertNotNil(client.requestURL)
    }

}
