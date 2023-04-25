//
//  CacheFeedImageDataUseCaseTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/25.
//

import Foundation
import XCTest
import Essentail_practice

final class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_saveImageDataFromURL_requestImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, url: url)])
    }
    
    func test_saveImageDataFromURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let insertionError = anyNSError()
            store.completeInsertion(with: insertionError)
        })
        
    }
    
    func test_saveImageDataFromURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_saveImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var recievedResults = [LocalFeedImageDataLoader.SaveResult]()
        _ = sut?.save(anyData(), for: anyURL()){recievedResults.append($0)}
        
        sut = nil
        store.completeInsertion(with: anyNSError())
        store.completeInsertionSuccessfully()
        
        XCTAssertTrue(recievedResults.isEmpty, "expected empty result coming back but got \(recievedResults) instead")

    }
    
    
    //Helpers:
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: ()->Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        let data = anyData()
        
        let exp = expectation(description: "wait for saving")
        sut.save(data, for: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
            case let (.failure(receivedError as LocalFeedImageDataLoader.SaveError),
                      .failure(expectedError as LocalFeedImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy ) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.fail)
    }
}
