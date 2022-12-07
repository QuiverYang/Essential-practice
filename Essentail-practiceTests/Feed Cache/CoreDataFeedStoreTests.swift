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
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
        
    }
    
    func test_retrieveA_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetriveDeliversFoundValuesOnNonEmptyCache(on: sut)
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertionDeleversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertionDeleversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertionValues() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviewslyInsertedCacheValue(on: sut)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache(){
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache(){
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertThateDeleteEmptyiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    //MARK: helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(sotreURL: storeURL, bundle: storeBundle)
        trackFroMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
}
