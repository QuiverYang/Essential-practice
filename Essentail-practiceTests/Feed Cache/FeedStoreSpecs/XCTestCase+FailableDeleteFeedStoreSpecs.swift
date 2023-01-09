//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/12/4.
//

import XCTest
import Essentail_practice

extension FailabelDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = delete(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        delete(from: sut)
        
        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
