//
//  FeedViewModel.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/15.
//

import Foundation
import UIKit
import Essentail_practice

final class FeedViewModel {
    
    var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var isLoading: Bool = false {
        didSet{ onChange?(self) }
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    
    var onLoaded:(([FeedImage]) -> Void)?
    
    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onLoaded?(feed)
            }
            self?.isLoading = false
        }
    }
}
