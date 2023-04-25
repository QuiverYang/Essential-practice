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
    
    //Helpers:
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy ) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
}
