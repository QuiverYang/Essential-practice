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

}
