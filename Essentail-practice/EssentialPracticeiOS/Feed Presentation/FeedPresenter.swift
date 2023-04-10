//
//  FeedPresenter.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/16.
//

import Foundation
import Essentail_practice

protocol FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModelData)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModelData)
}

final class FeedPresenter {
        
    private let feedView: FeedView
    private let loadingView: FeedLoadingView

    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    
    
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in
                self?.didStartLoadingFeed()
            }
        }
        
        loadingView.display(FeedLoadingViewModelData(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in
                self?.didFinishLoadingFeed(with: feed)
            }
        }
        
        
        feedView.display(FeedViewModelData(feed: feed))
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
    }
    
    func didFinsihLoadingFeed(with error: Error) {
        
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in
                self?.didFinsihLoadingFeed(with: error)
            }
        }
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
    }
}
