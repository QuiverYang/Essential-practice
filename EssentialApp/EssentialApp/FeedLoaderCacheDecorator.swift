//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Menglin Yang on 2023/5/9.
//

import Foundation
import Essentail_practice

public class FeedLoaderCacheDecorator: FeedLoader {
    var decoratee: FeedLoader?
    var cache: FeedCache?

    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        
        decoratee?.load{[weak self] result in
            if let feed = try? result.get() {
                self?.cache?.saveIgnoringResult(feed)
            }
            completion(result)
            
            // 另一種使用map的寫法
//            completion(result.map { feed in
//                self?.cache.save(feed) { _ in }
//                return feed
//            })
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
