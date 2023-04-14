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

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModelData)
}

final class FeedPresenter {
        
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView

    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    static var errorMessage: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "load error message")
    }
    
    
    
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModelData(isLoading: true))
        errorView.display(.noError())
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModelData(feed: feed))
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
    }
    
    func didFinsihLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
        errorView.display(.error(message: FeedPresenter.errorMessage))
    }
}
