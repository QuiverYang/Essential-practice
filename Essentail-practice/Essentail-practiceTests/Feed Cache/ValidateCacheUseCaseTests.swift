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
    
    // Helpers:
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://some-url")!
    }
}



