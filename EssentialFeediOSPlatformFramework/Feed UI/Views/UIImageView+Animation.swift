//
//  UIImageView+Animation.swift
//  EssentialFeediOSPlatformFramework
//
//  Created by Rjvi on 24/04/23.
//

import UIKit

extension UIImageView {
    func setImageAnimates(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else {
            return
        }
        
        alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
