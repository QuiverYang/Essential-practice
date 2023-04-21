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
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result{
            case let .failure(error):
                completion(.failure(error))
            default: break
            }
        }
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
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        expect(sut, toCompelteWith: .failure(error)) {
            client.complete(with: error)
        }

    }
    
    //Helpers:
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompelteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "https://a-url.com")!
        let exp = expectation(description: "wait for completion")

        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("out of behavior")
                    
            }
            exp.fulfill()

        }
        action()

        wait(for: [exp], timeout: 1)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client)
        trackForMemoryLeaks(sut)
        return (sut, client)
    }
    
    private final class HTTPClientSpy: HttpClient{
        var messages = [(url: URL, completion: (HttpClient.Result) -> Void)]()
        
        var reuqestURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HttpClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        
    }
    
    
}
