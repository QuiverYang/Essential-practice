//
//  UIRefreshControl+TestHelpers.swift
//  EssentialPracticeiOSTests
//
//  Created by Menglin Yang on 2023/2/6.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        })

    }
}
