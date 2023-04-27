//
//  ValidateCacheUseCaseTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/11/15.
//

import XCTest
import Essentail_practice

final class ValidateCacheUseCaseTest : XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache{ _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieval, .deletionCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache{ _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_validateCache_doesNotDeleteOnNoExpiredCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()

        sut.validateCache{ _ in }
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        store.completeWithRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_validateCache_deletesOnOnCacheExpiration() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()

        sut.validateCache{ _ in }
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        store.completeWithRetrieval(with: feed.local, timestamp: expirationTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieval, .deletionCacheFeed])
    }
    
    func test_validateCache_deleteOnExpiredCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()

        sut.validateCache{ _ in }
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        store.completeWithRetrieval(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieval,.deletionCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        sut?.validateCache{ _ in }
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletion(with: deletionError)
        })
    }
    
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeWithRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        })
    }
    
    // Helpers:
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://some-url")!
    }
}



