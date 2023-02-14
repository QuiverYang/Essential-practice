//
//  FeedViewModel.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/14.
//

import Foundation
import Essentail_practice

final class FeedViewModel {
    let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    var onLoadingStateChanged:((FeedViewModel) -> Void)?
    
    private(set) var isLoading: Bool = false {
        didSet { onLoadingStateChanged?(self) }
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
