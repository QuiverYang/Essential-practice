//
//  CacheFeedUseCaseTest.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/10/19.
//

import XCTest
import Essentail_practice

class LocalFeedLoader {
    private let store : FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    
    enum ReceivedMessage : Equatable{
        case deletionCacheFeed
        case insert([FeedItem], Date)
    }
            
    private var deletionCompletions = [DeletionCompletion]()
        
    private(set) var recievedMessages = [ReceivedMessage]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deletionCacheFeed)
    }
    
    func completeDeletionWith(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        recievedMessages.append(.insert(items, timestamp))
    }
    
}

class CacheFeedUseCaseTest: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.recievedMessages, [.deletionCacheFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        let deletionError = anyNSError()
        
        store.completeDeletionWith(deletionError)
        
        XCTAssertEqual(store.recievedMessages, [.deletionCacheFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deletionCacheFeed,.insert(items, timestamp)])

    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackFroMemoryLeaks(store, file: file, line: line)
        trackFroMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem{
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "https://some-url")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

    

}
