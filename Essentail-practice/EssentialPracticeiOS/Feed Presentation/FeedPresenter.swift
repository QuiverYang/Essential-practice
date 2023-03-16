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
    
    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModelData(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModelData(feed: feed))
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
    }
    
    func didFinsihLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModelData(isLoading: false))
    }
}
