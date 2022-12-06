//
//  CoreDataFeedStoreTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/12/6.
//

import XCTest
import Essentail_practice

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_retrieveA_deliversFoundValuesOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertionValues() {
        
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectOnNonEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    //MARK: helpers
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CoreDataFeedStore()
        trackFroMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}
