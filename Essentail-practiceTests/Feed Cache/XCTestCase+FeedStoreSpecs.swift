//
//  XCTestCase+FeedStoreSpecs.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/12/2.
//

import XCTest
import Essentail_practice

extension FeedStoreSpecs where Self : XCTestCase {
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetriveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.empty, .empty): break
            case (.failure, .failure): break
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) result but got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetriveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error?{
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp, completion: { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func delete(from sut : FeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCacheFeed { recievedError in
            deletionError = recievedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
        return deletionError
    }
}
