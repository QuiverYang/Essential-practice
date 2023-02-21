//
//  FeedPresenter.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/16.
//

import Foundation
import Essentail_practice

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModelData {
    let feed: [FeedImage]
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
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModelData(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinsihLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
