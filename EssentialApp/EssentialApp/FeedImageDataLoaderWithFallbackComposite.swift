//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialAppTests
//
//  Created by Menglin Yang on 2023/4/28.
//

import Foundation
import Essentail_practice

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader

    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    
    private final class WrappedTask: FeedImageDataLoaderTask{
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = WrappedTask()
        task.wrapped = primary.loadImageData(from: url){[weak self] result in
            switch result{
            case .success:
                completion(result)
            case .failure:
                // should be changed on this line
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
    
}
