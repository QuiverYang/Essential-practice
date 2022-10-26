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
        
        sut.load()
        
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

}
