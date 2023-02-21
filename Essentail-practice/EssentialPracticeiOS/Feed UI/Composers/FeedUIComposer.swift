//
//  FeedUIComposer.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/6.
//

import Foundation
import Essentail_practice
import UIKit

public final class FeedUIComposer {
    
    private init(){}
    
    public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter()
        let presentationAdaptor = FeedLoaderPresentationAdaptor(feedLoader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshController(loadFeed: presentationAdaptor.loadFeed)
        let feedController = FeedViewController(refreshController: refreshController)
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdaptor(controller: feedController, imageLoader: imageLoader)
        return feedController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return {[weak controller] feed in
            controller?.tableModel = feed.map { model in
                let viewModel = FeedImageViewModel(imageLoader: loader, model: model, imageTransformer: UIImage.init)
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}

private final class FeedLoaderPresentationAdaptor {
    private let feedLoader: FeedLoader
    private let presenter: FeedPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func loadFeed() {
        presenter.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter.didFinsihLoadingFeed(with: error)
            }
        }
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdaptor: FeedView {
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModelData) {
        controller?.tableModel = viewModel.feed.map { model in
            let viewModel = FeedImageViewModel(imageLoader: imageLoader, model: model, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
    
    
}
