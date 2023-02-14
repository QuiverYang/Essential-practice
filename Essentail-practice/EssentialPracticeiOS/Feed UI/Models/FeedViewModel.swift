//
//  FeedViewModel.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/14.
//

import Foundation
import Essentail_practice

final class FeedViewModel {
    
    typealias Observer<T> = (T) -> Void
    let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onFeedLoad: Observer<[FeedImage]>?
    
    var onLoadingStateChanged:Observer<Bool>?
    
    func loadFeed() {
        onLoadingStateChanged?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChanged?(false)
        }
    }
}
