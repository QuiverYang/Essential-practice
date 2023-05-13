//
//  FeedLoaderPresentationAdapter.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/4/10.
//

import Foundation
import Essentail_practice
import EssentialPracticeiOS

final class FeedLoaderPresentationAdaptor: FeedViewControllerDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinsihLoadingFeed(with: error)
            }
        }
    }
}
