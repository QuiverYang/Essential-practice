//
//  UIButton+TestHelpers.swift
//  EssentialPracticeiOSTests
//
//  Created by Menglin Yang on 2023/2/6.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        }
    }
}
