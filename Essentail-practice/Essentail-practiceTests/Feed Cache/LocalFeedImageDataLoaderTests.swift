//
//  LocalFeedImageDataLoaderTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/25.
//

import Foundation
import XCTest

final class LocalFeedImageDataLoader {
    init(store: Any) {
        
    }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_initDoesNotMessageStoreOnCreation() {
        let(_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    //Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy ) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private class FeedStoreSpy {
        var receivedMessages = [Any]()
        
    }
}
