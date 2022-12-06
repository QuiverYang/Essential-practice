//
//  CoreDataFeedStore.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/12/6.
//

import Foundation

public class CoreDataFeedStore : FeedStore {
    public init(){}
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        completion(.empty)
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    

    
    
}
