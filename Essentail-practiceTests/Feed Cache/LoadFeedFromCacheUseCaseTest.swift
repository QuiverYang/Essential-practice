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
    
    func test_load_deliversImagesOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldsTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeWithRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldsTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let sevenDaysOldsTimestamp = fixedCurrentDate.adding(days: -7)
        expect(sut, toCompleteWith: .success([])) {
            store.completeWithRetrieval(with: feed.local, timestamp: sevenDaysOldsTimestamp)
        }
    }
    
    func test_load_deliversNoImageOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let (sut, store) = makeSUT()
        let fixedCurrentDate = Date()
        let sevenDaysOldsTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        expect(sut, toCompleteWith: .success([])) {
            store.completeWithRetrieval(with: feed.local, timestamp: sevenDaysOldsTimestamp)
        }
    }
    
    func test_load_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieval,.deletionCacheFeed])
    }
    
    func test_load_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieval])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackFroMemoryLeaks(store, file: file, line: line)
        trackFroMemoryLeaks(sut, file: file, line: line)
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
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://some-url")!
    }
    
    private func uniqueImage() -> FeedImage{
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        
        let models = [uniqueImage(), uniqueImage()]
        let local = models.map { LocalFeedImage(id: $0.id,
                                               description: $0.description,
                                               location: $0.location,
                                               imageURL: $0.url)
        }
        return (models, local)

    }

}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
