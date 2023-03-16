//
//  FeedRefreshViewController.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/6.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshController: NSObject, FeedLoadingView {

    @IBOutlet var view: UIRefreshControl?

    var delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModelData) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
