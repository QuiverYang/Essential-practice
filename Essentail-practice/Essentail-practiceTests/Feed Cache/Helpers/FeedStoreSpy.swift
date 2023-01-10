//
//  FeedStoreSpy.swift
//  Essentail-practiceTests
//
//  Created by Menglin Yang on 2022/10/26.
//

import Foundation
import Essentail_practice

class FeedStoreSpy : FeedStore {

    enum ReceivedMessage : Equatable{
        case deletionCacheFeed
        case insert([LocalFeedImage], Date)
        case retrieval
    }
            
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievenCompletions = [RetrieveCompletion]()


        
    private(set) var recievedMessages = [ReceivedMessage]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deletionCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](.success(()))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionCompletions[index](.success(()))
    }
    
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insert(images, timestamp))
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        recievedMessages.append(.retrieval)
        retrievenCompletions.append(completion)
    }
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievenCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievenCompletions[index](.success(.none))
    }
    
    func completeWithRetrieval(with images: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievenCompletions[index](.success(CachedFeed(feed: images, timestamp: timestamp)))
    }
    
    
}
