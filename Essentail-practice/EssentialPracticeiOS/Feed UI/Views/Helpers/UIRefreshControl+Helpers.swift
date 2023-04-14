//
//  UIRefreshControl+Helpers.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/4/14.
//

import UIKit

extension UIRefreshControl {
    // update refreshing
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
