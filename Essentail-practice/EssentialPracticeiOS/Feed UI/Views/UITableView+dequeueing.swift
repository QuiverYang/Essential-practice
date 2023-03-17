//
//  UITableView+dequeueing.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/3/17.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
