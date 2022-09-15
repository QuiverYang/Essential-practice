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
        HttpClient.shared.requestURL = URL(string: "https://some-url.com")
    }
}

class HttpClient {
    static let shared = HttpClient()
    private init() {}
    var requestURL : URL?
}

class Essentail_practiceTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestURL)
    }
    func test_load_requestDataFromURL() {
        let client = HttpClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        XCTAssertNotNil(client.requestURL)
    }

}
