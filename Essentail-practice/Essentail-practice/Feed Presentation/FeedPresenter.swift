//
//  FeedPresenter.swift
//  Essentail-practice
//
//  Created by Menglin Yang on 2023/4/17.
//

import Foundation

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModelData)
}

public protocol FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModelData)
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModelData)
}

public final class FeedPresenter  {
    public init(feedView: FeedView,  loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
        
    }
    
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let feedView: FeedView
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    public static var errorMessage: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "load error message")
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError())
        loadingView.display(FeedLoadingViewModelData(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModelData(feed: feed))
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
    }
    
    public func didFinsihLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
        errorView.display(.error(message: FeedPresenter.errorMessage))
    }
}
