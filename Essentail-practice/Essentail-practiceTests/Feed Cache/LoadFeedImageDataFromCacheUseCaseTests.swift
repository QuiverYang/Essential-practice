//
//  LocalFeedImageDataLoaderTests.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2023/4/25.
//

import XCTest
import Essentail_practice


final class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_initDoesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url){_ in}
        
        XCTAssertEqual(store.receivedMessages, [.retrieved(dataFor: url)])
        
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: fail(), when: {
            let retrivalError = anyNSError()
            store.completeRetrieval(with: retrivalError)
        })
        
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrieval(with: .none)
        })
        
    }
    
    func test_loadImageDataFromURL_deliversStoreDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        expect(sut, toCompleteWith: .success(foundData), when: {
            store.completeRetrieval(with: foundData)
        })
        
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let foundData = anyData()
        
        var recievedResults = [FeedImageDataStore.RetrievalResult]()
        let task = sut.loadImageData(from: url){recievedResults.append($0)}
        task.cancel()
        
        
        store.completeRetrieval(with: foundData)
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: anyNSError())
        
        
        XCTAssertTrue(recievedResults.isEmpty, "expected empty result coming back but got \(recievedResults) instead")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var recievedResults = [FeedImageDataStore.RetrievalResult]()
        _ = sut?.loadImageData(from: anyURL()){recievedResults.append($0)}
        
        sut = nil
        store.completeRetrieval(with: anyData())
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertTrue(recievedResults.isEmpty, "expected empty result coming back but got \(recievedResults) instead")

    }
    
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
    
    private func fail() -> FeedImageDataStore.RetrievalResult {
        .failure(LocalFeedImageDataLoader.LoadError.fail)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: ()->Void,file: StaticString = #filePath, line: UInt = #line ) {
        let exp = expectation(description: "wait for load local image data")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(recievedError as LocalFeedImageDataLoader.LoadError), .failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(recievedError, expectedError, file: file, line: line)
            case let (.success(recievedData), .success(expectedData)):
                XCTAssertEqual(recievedData, expectedData)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead ", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    
}
