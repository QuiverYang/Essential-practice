//
//  EssentialPracticeCacheIntegrationTests.swift
//  EssentialPracticeCacheIntegrationTests
//
//  Created by Menglin Yang on 2022/12/17.
//

import XCTest
import Essentail_practice

final class EssentialPracticeCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        deleteStoreArtifacts()
    }
    override func tearDown() {
        deleteStoreArtifacts()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for loading")
        sut.load { result in
            switch result {
            case let .success(imageFeed):`
                XCTAssertEqual(imageFeed, [], "expected empty Feed")
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
    }
    func test_load_deliversItemsSavedOnASeparateInstance(){
            let sutToPerformSave = makeSUT()
            let sutToPerformLoad = makeSUT()
            let feed = uniqueImageFeed().models
            
            let saveExp = expectation(description: "Wait to save")
            sutToPerformSave.save(feed) { savedError in
                XCTAssertNil(savedError, "Expected to save feed successfully")
                saveExp.fulfill()
            }
            wait(for: [saveExp], timeout: 1.0)
            
            let loadExp = expectation(description: "Wait for load completion")
            sutToPerformLoad.load { result in
                switch result {
                case let .success(imageFeed):
                    XCTAssertEqual(imageFeed, feed, "expected empty Feed")
                case let .failure(error):
                    XCTFail("Expected successful feed result, got \(error) instead")
                }
                loadExp.fulfill()
            }
            wait(for: [loadExp], timeout: 1.0)
            
        }


    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
