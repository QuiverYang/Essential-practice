//
//  FeedImageDataLoaderTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/21.
//

import Foundation
import XCTest
import Essentail_practice



final class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotPerfomAnyURLRequest() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.reuqestURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requstsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        
        _ = sut.loadImageData(from: url){ _ in }
        
        XCTAssertEqual(client.reuqestURLs, [url] )
        
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        
        _ = sut.loadImageData(from: url){ _ in }
        _ = sut.loadImageData(from: url){ _ in }
        
        XCTAssertEqual(client.reuqestURLs, [url, url] )
    }
    
    func test_loadImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        expect(sut, toCompelteWith: failure(.connectivity)) {
            client.complete(with: error)
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompelteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompelteWith: failure(.invalidData)) {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData, at: 0)
        }
        
    }
    
    func test_loadImageDataFromURL_deliversRecievedDataOn200HttpResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()
        
        expect(sut, toCompelteWith: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        var requestsResults = [FeedImageDataLoader.Result]()
        
        _ = sut?.loadImageData(from: anyURL()){ requestsResults.append($0)}
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(requestsResults.isEmpty)
    }
    
    func test_cancelLaodImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url, completion: { _ in })
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
        
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non empty data".utf8)
        let url = anyURL()
        var recievedResult = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: url) { recievedResult.append($0) }
        task.cancel()
        
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())
        
        XCTAssertTrue(recievedResult.isEmpty, "Expected no received results after cancelling task ,but got \(recievedResult.count) results back")
        
    }
    
    
    //Helpers:
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompelteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "https://a-url.com")!
        let exp = expectation(description: "wait for completion")

        
        _ = sut.loadImageData(from: url) { receivedResult in
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
    
    private final class HTTPClientSpy: HTTPClient{
        var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        var reuqestURLs: [URL] {
            return messages.map { $0.url }
        }
        
        private(set) var cancelledURLs = [URL]()
        private struct Task: HTTPClientTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task{ [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: reuqestURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
    
}
