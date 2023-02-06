//
//  FeedUIComposer.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/6.
//

import Foundation
import Essentail_practice

public final class FeedUIComposer {
    
    private init(){}
    
    public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = {[weak feedController] feed in
            feedController?.tableModel = feed.map { model in
                FeedImageCellController(model: model, imageLoader: imageLoader)
            }
        }
        return feedController
    }
}
