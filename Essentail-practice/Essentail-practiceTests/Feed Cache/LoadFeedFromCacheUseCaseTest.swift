//
//  LoadFeedFromCacheUseCaseTest.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/10/26.
//

import XCTest
import Essentail_practice

final class LoadFeedFromCacheUseCaseTest: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_load_requestCacheRetreival() {
        let (sut, store) = makeSUT()
        
        sut.load(){ _ in }
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_load_failsOnRetrieveFail(){
        let (sut, store) = makeSUT()
        let retrieveError = anyNSError()
        expect(sut, toCompleteWith: .failure(retrieveError)) {
            store.completeRetrieval(with: retrieveError)

        }
        
    }
    
    func test_load_deliversNoImageOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversImagesOnNoExpiredCache() {
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeWithRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        expect(sut, toCompleteWith: .success([])) {
            store.completeWithRetrieval(with: feed.local, timestamp: expirationTimeStamp)
        }
    }
    
    func test_load_deliversNoImageOnExpiredCache() {
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        expect(sut, toCompleteWith: .success([])) {
            store.completeWithRetrieval(with: feed.local, timestamp: expiredTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectsCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()

        sut.load { _ in }
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        store.completeWithRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_load_hasNoSideEffectOnExpirationCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()

        sut.load { _ in }
        let fixedCurrentDate = Date()
        let expirationTimeStamp = fixedCurrentDate.minusFeedCacheMaxAge()
        store.completeWithRetrieval(with: feed.local, timestamp: expirationTimeStamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        let (sut, store) = makeSUT()
        let feed = uniqueImageFeed()

        sut.load { _ in }
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        store.completeWithRetrieval(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedReseult = [LocalFeedLoader.LoadResult]()
        sut?.load(completion: { receivedReseult.append($0) })
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedReseult.isEmpty);
        
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: ()->Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for loaded")
        sut.load(){ recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedFeeds), .success(expectedFeeds)):
                XCTAssertEqual(recievedFeeds, expectedFeeds, file: file, line: line)
            case let (.failure(recievedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(recievedError, expectedError, file: file, line: line)
            default:
                fatalError("expected rsult \(expectedResult) but got \(recievedResult) instead")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }

}
