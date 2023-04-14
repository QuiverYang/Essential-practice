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
    
    private var isVisable: Bool {
        return alpha > 0
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        label.text = nil
        alpha = 0
    }
    
    private func showAnimated(_ message: String?) {
        label.text = message
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @IBAction private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25,
                       animations: {self.alpha = 0},
                       completion: { completed in
            if completed { self.label.text = nil }
            
        })
    }
    
    
}
