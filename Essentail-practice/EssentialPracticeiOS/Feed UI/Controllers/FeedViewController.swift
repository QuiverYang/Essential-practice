//
//  FeedViewController.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/1/16.
//

import UIKit
import Essentail_practice

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}


public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {

    public var delegate: FeedViewControllerDelegate?
    
    @IBOutlet private(set) public var errorView: ErrorView!
    
    private var loadingControllers = [IndexPath: FeedImageCellController]()
    
    public required init?(coder: NSCoder, delegate: FeedViewControllerDelegate) {
        super.init(coder: coder)
        self.delegate = delegate
    }
        
    private var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    public func display(_ controllers: [FeedImageCellController]) {
        tableModel = controllers
        loadingControllers = [:]
    }
    
    public func display(_ viewModel: FeedLoadingViewModelData) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: FeedErrorViewModelData) {
        errorView?.message = viewModel.message
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        startTask(forRowAt: indexPath)
    }
    
    private func startTask(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).preload()
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(startTask)
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
    
}

