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
    }
            
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()

        
    private(set) var recievedMessages = [ReceivedMessage]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deletionCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](nil)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionCompletions[index](nil)
    }
    
    func insert(_ images: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insert(images, timestamp))
        
    }
    
}
