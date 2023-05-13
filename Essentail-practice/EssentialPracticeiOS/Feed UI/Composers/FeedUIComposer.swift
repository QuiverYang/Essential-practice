//
//  FeedUIComposer.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/6.
//

import Foundation
import Essentail_practice
import UIKit
import EssentialPracticeiOS

public final class FeedUIComposer {
    
    private init(){}
    
    public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdaptor = FeedLoaderPresentationAdaptor(feedLoader: MainThreadDispatchDecorator(decoratee: feedLoader))
        
        let feedController = makeFeedViewController(delegate: presentationAdaptor, title: FeedPresenter.title)
        
        presentationAdaptor.presenter =
        FeedPresenter(feedView: FeedViewAdaptor(controller: feedController,
                                                imageLoader: MainThreadDispatchDecorator(decoratee: imageLoader)),
                      loadingView: WeakRefVirtualProxy(feedController),
                      errorView: WeakRefVirtualProxy(feedController))
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }

    // 在ios 13之後可以使用init(coder: NSCoder?...)這個方式，所以可以使用constructor injectio
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate?, title: String) -> FeedViewController{
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





