//
//  UIFont+Extension.swift
//  BlossomApp
//
//  Created by nim on 24/7/2564 BE.
//

import UIKit

fileprivate let SukhumvitBold : String = "SukhumvitSet-Bold"
fileprivate let SukhumvitRegular : String = "SukhumvitSet-Text"
fileprivate let SukhumvitLight : String = "SukhumvitSet-Light"
fileprivate let SukhumvitThin : String = "SukhumvitSet-Thin"

enum FontSize: CGFloat {
    
    case h1 = 22.0
    case h2 = 20.0

    case title = 18.0

    case body = 16.0
    case body2 = 14.0
    case small = 12.0
    
    func bold() -> UIFont {
        return UIFont(name: SukhumvitBold, size: self.rawValue)!
    }
    
    func regular() -> UIFont {
        return UIFont(name: SukhumvitBold, size: self.rawValue)!
    }
    
    func light() -> UIFont {
        return UIFont(name: SukhumvitBold, size: self.rawValue)!
    }
    
}

extension UIFont {
    
    static func bold(size: CGFloat) -> UIFont {
        return UIFont(name: SukhumvitBold, size: size)!
    }
    
    static func regular(size: CGFloat) -> UIFont {
        return UIFont(name: SukhumvitBold, size: size)!
    }
    
    static func light(size: CGFloat) -> UIFont {
        return UIFont(name: SukhumvitBold, size: size)!
    }
    
}
