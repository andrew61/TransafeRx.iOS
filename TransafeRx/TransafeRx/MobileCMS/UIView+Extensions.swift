//
//  Extensions.swift
//  ios-swift-collapsible-table-section
//
//  Created by Yong Su on 9/28/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//

import UIKit

extension UIView {

    func rotate(toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(animation, forKey: nil)
    }
    
    func hideKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(_ sender: AnyObject) {
        self.endEditing(true)
    }

}
