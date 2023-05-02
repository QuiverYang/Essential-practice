//
//  PrimaryLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Menglin Yang on 2023/4/28.
//

import Foundation
import Essentail_practice

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    var primary: FeedLoader
    var fallback: FeedLoader
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result{
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
