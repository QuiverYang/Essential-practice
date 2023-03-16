//
//  FeedViewModel.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/15.
//

import Foundation
import Essentail_practice

// MVVM中 ViewModel管理著state
// 例如這裡的loading的狀態
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
