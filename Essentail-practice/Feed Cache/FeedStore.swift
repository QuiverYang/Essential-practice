//
//  FeedStore.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2022/10/24.
//

import Foundation
public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)




public protocol FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    typealias InsertionCompletion = (Error?)->Void
    
    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrieveCompletion = (RetrievalResult)->Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrieveCompletion)
}


