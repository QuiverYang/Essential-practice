//
//  ErrorView.swift
//  EssentialPracticeiOS
//
//  Created by Menglin Yang on 2023/4/14.
//

import UIKit

public class ErrorView: UIView {
    @IBOutlet private var label: UILabel!
    
    public var message: String? {
        get { return label.text }
        set { label.text = newValue}
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        label.text = nil
    }
}
