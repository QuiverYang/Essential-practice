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
        let presentationAdaptor = FeedLoaderPresentationAdaptor(feedLoader: MainThreadDispatchDecorator(decoratee: feedLoader))
        let feedController = FeedViewController.makeWith(delegate: presentationAdaptor, title: FeedPresenter.title)
        
        
        presentationAdaptor.presenter = FeedPresenter(feedView: FeedViewAdaptor(controller: feedController, imageLoader: MainThreadDispatchDecorator(decoratee: imageLoader)),
                                                      loadingView: WeakRefVirtualProxy(feedController))
        return feedController
    }
}

extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
    
    // 在ios 13之後可以使用init(coder: NSCoder?...)這個方式，所以可以使用constructor injectio
    static func makeWith(delegate: FeedViewControllerDelegate?, title: String) -> FeedViewController{
        var feedController: FeedViewController?
        let bundle = Bundle(for: FeedViewController.self)
        if #available(iOS 13.0, *) {
            feedController = UIStoryboard(name: "Feed", bundle: bundle).instantiateInitialViewController{ coder in
                return FeedViewController(coder: coder, delegate: delegate!)
            }
        } else {
            feedController = (UIStoryboard(name: "Feed", bundle: bundle).instantiateInitialViewController() as! FeedViewController)
            feedController?.delegate = delegate
        }
        feedController!.title = title
        return feedController!
    }
}

private final class FeedLoaderPresentationAdaptor: FeedViewControllerDelegate {
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

private final class FeedViewAdaptor: FeedView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModelData) {
        controller?.tableModel = viewModel.feed.map { model in
            let adpator = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adpator)
            adpator.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        }
    }
    
    
}

