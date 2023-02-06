//
//  UIImage+TestHelpers.swift
//  EssentialPracticeiOSTests
//
//  Created by Menglin Yang on 2023/2/6.
//

import UIKit

extension UIImage {
    static func make(withColor color : UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        UIGraphicsBeginImageContext(rect.size)
//        let context = UIGraphicsGetCurrentContext()
//        context?.setFillColor(color.cgColor)
//        context?.fill(rect)
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return img!
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image{ renderedContext in
            color.setFill()
            renderedContext.fill(rect)
        }
    }
}
