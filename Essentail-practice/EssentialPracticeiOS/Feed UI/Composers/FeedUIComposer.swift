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
        let viewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshController(viewModel: viewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        viewModel.onLoaded = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
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
