//
//  CoreDataFeedStore+FeedStore.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/27.
//

import Foundation


extension CoreDataFeedStore: FeedStore {
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        perform { context in
            
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result{
                let managedCache = try ManagedCache.newQuniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result{
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
}




