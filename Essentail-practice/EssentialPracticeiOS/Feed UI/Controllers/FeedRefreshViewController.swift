//
//  FeedRefreshViewController.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/6.
//

import UIKit
import Essentail_practice


final class FeedRefreshController: NSObject {
    
    private(set) lazy var view = binded(UIRefreshControl())
    
    var viewModel: FeedViewModel
    
    init(feedLoader: FeedLoader) {
        self.viewModel = FeedViewModel(feedLoader: feedLoader)
    }
    
    var onRefresh:(([FeedImage]) -> Void)?
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl{
        // bind viewModel to view
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
            if let feed = viewModel.feed {
                self?.onRefresh?(feed)
            }
        }
        
        // bind view to viewModel by Selector
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)

        return view
    }
}
