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
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieval, .deletionCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_validateCache_doesNotDeleteOnLessThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()

        sut.validateCache()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldsTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        store.completeWithRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldsTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_validateCache_deletesOnOnSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()

        sut.validateCache()
        let fixedCurrentDate = Date()
        let sevenDaysOldsTimestamp = fixedCurrentDate.adding(days: -7)
        store.completeWithRetrieval(with: feed.local, timestamp: sevenDaysOldsTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieval, .deletionCacheFeed])
    }
    
    func test_validateCache_deleteOnMoreThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()

        sut.validateCache()
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        store.completeWithRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieval,.deletionCacheFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        sut?.validateCache()
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    // Helpers:
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackFroMemoryLeaks(store, file: file, line: line)
        trackFroMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://some-url")!
    }
}



