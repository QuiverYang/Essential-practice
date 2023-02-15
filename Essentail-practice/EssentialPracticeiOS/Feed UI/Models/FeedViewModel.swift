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
    
    private enum State {
        case pending
        case loading
        case loaded([FeedImage])
        case fail
    }
    private var state = State.pending {
        didSet{ onChange?(self) }
    }
    
    var isLoading: Bool {
        switch state {
        case .loading: return true
        case .pending, .loaded, .fail: return false
        }
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    
    var feed: [FeedImage]? {
        switch state {
        case let .loaded(feed): return feed
        case .pending, .loading, .fail: return nil
        }
    }
    
    func loadFeed() {
        state = .loading
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.state = .loaded(feed)
            } else {
                self?.state = .fail
            }
        }
    }
}
