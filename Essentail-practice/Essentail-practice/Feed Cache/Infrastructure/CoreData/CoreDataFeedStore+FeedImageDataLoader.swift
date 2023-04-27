//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/25.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result{
//                let image = try ManagedFeedImage.first(with: url, in: context)
//                image?.data = data
//                try context.save()
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data}
                    .map(context.save)
            })
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            let result = Result {
                try ManagedFeedImage.first(with: url, in: context)?.data
            }
            completion(result)
        }
    }
    
}
