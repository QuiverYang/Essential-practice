//
//  FeedRefreshViewController.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/2/6.
//

import UIKit


final class FeedRefreshController: NSObject {
    
    private(set) lazy var view = binded(UIRefreshControl())
    
    var viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
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
        }
        
        // bind view to viewModel by Selector
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)

        return view
    }
}
