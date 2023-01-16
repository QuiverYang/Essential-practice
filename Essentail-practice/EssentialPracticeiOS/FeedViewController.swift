//
//  FeedViewController.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/1/16.
//

import UIKit
import Essentail_practice

public final class FeedViewController: UITableViewController {
    private var loader : FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }

    }
}
