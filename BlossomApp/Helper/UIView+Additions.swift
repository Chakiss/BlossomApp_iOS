//
//  UIView+Assitions.swift
//  dtacapp
//
//  Created by sopana on 14/9/2562 BE.
//  Copyright © 2562 Sopana. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundCorner(radius:CGFloat, with borderColor:UIColor? = nil) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
        
        if let border = borderColor {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = border.cgColor
        }
    }
    
    func addView(_ subView:UIView, snapToSuperView: Bool = false, inset: UIEdgeInsets = .zero) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subView)
        
        guard snapToSuperView else {
            return
        }
    
        subView.topAnchor.constraint(equalTo: topAnchor, constant: inset.top).isActive = true
        subView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left).isActive = true
        subView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset.right).isActive = true
        subView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset.bottom).isActive = true        
    }
    
    func asImage(in rect: CGRect? = nil) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        if let rect = rect {
            drawHierarchy(in: rect, afterScreenUpdates: true)
        } else {
            drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let frame = rect else {
            return UIImage(cgImage: image!.cgImage!)
        }
        
        var cropFrame = frame
        cropFrame.origin.x *= UIScreen.main.scale
        cropFrame.origin.y *= UIScreen.main.scale
        cropFrame.size.width *= UIScreen.main.scale
        cropFrame.size.height *= UIScreen.main.scale
        
        guard let cropped = image!.cgImage!.cropping(to: cropFrame) else {
            return UIImage(cgImage: image!.cgImage!)
        }
        
        return UIImage(cgImage: cropped)

    }
    
}

extension UIStackView {
    
    func arragedView(_ subView:UIView) {
        subView.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(subView)
    }
    
}
