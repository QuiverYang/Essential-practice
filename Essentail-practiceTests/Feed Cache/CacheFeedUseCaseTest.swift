//
//  CacheFeedUseCaseTest.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/10/19.
//

import XCTest
import Essentail_practice



class CacheFeedUseCaseTest: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save(uniqueImageFeed().models){ _ in }
        
        XCTAssertEqual(store.recievedMessages, [.deletionCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        sut.save(uniqueImageFeed().models){ _ in }
        let deletionError = anyNSError()
        
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.recievedMessages, [.deletionCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = uniqueImageFeed()

        sut.save(items.models){ _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deletionCacheFeed,.insert(items.local, timestamp)])

    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)

        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var recievedResult = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models){recievedResult.append($0)}
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(recievedResult.isEmpty)
    }
    
    func test_savedoesNotDeleverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut : LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var recievedResult = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models){recievedResult.append($0)}
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(recievedResult.isEmpty)
    }
    
    
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackFroMemoryLeaks(store, file: file, line: line)
        trackFroMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let items = uniqueImageFeed().models
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save completion")
        
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    private func uniqueImage() -> FeedImage{
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        
        let models = [uniqueImage(), uniqueImage()]
        let local = models.map { LocalFeedImage(id: $0.id,
                                               description: $0.description,
                                               location: $0.location,
                                               imageURL: $0.url)
        }
        return (models, local)

    }
    
    private func anyURL() -> URL {
        URL(string: "https://some-url")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

    

}
