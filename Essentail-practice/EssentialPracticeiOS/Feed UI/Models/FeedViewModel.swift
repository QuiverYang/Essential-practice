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
    
    typealias Observer<T> = (T) -> Void
    
    var feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
        
    var onLoaded: Observer<[FeedImage]>?
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onLoaded?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
