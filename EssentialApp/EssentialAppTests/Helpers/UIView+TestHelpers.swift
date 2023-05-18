//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Menglin Yang on 2023/5/18.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
