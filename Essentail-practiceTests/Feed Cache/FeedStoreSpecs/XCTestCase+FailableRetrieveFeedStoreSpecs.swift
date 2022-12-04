//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/12/2.
//

import XCTest
import Essentail_practice

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
}
