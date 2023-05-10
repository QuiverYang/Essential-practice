//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Menglin Yang on 2023/5/10.
//

import Foundation
import Essentail_practice

public class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    
    private var decoratee: FeedImageDataLoader
    private var cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> Essentail_practice.FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.save(data, for: url) { _ in }
            }
            completion(result)
        }
    }
    
}
