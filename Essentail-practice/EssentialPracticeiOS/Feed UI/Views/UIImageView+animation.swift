//
//  UIImageView+animation.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/3/17.
//

import UIKit

extension UIImageView {
    func setAnimated(_ newImage: UIImage?) {
        image = newImage
        guard newImage != nil else {return}
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
        
    }
}
