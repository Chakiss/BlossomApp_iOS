//
//  UIView+Assitions.swift
//  
//
//  Created by sopana on 14/9/2562 BE.
//  Copyright © 2562 Sopana. All rights reserved.
//

import UIKit

extension UIView {
    
    func addConerRadiusAndShadow(){
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blossomLightGray.cgColor
         
         // shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 4.0
    }
    
    func addShadow()  {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 4.0
    }
    
    func removeShadow()  {
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.0
        self.layer.shadowRadius = 0.0
    }
    
    func circleView()  {
        self.layer.cornerRadius = self.bounds.height/2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blossomLightGray.cgColor
    }
    
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

extension UIView{
    func animationZoom(scaleX: CGFloat, y: CGFloat) {
        self.transform = CGAffineTransform(scaleX: scaleX, y: y)
    }
    
    func animationRotated(by angle : CGFloat) {
        self.transform = self.transform.rotated(by: angle)
    }
}
