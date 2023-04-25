//
//  LocalFeedImageDataLoaderTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/25.
//

import Foundation
import XCTest
import Essentail_practice

protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    enum Error: Swift.Error {
        case fail
    }
    private var store: FeedImageDataStore
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> Essentail_practice.FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url){ _ in
            completion(.failure(Error.fail))
        }
        return Task()
    }
    

}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_initDoesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url){_ in}
        
        XCTAssertEqual(store.receivedMessages, [.retrieved(dataFor: url)])
        
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: fail(), when: {
            let retrivalError = anyNSError()
            store.complete(with: retrivalError)
        })
        
    }
    
    //Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy ) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func fail() -> LocalFeedImageDataLoader.Result {
        .failure(LocalFeedImageDataLoader.Error.fail)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: ()->Void,file: StaticString = #filePath, line: UInt = #line ) {
        let exp = expectation(description: "wait for load local image data")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(recievedError as LocalFeedImageDataLoader.Error), .failure(expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(recievedError, expectedError)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead ", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private class StoreSpy: FeedImageDataStore {

        
        enum Message: Equatable {
            case retrieved(dataFor: URL)
        }
        var receivedMessages = [Message]()
        private var completions = [(FeedImageDataLoader.Result) -> Void]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            receivedMessages.append(.retrieved(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
    }
}
