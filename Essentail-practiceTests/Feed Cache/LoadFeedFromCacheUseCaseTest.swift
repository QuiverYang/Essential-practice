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
        var recievedError : Error?
        let exp = expectation(description: "wait for loaded")
        let retrieveError = anyNSError()
        
        sut.load(){ result in
            switch result {
            case let .failure(error):
                recievedError = error
            default:
                fatalError("should get error but get \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: retrieveError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(recievedError as NSError?, retrieveError)
        
    }
    
    //MARK: - Helpers
    
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

}
