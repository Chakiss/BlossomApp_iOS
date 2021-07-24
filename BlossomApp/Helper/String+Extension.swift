//
//  String+Extension.swift
//  BlossomApp
//
//  Created by nim on 24/7/2564 BE.
//

import Foundation

extension String {
    
    static func today() -> String {        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }
    
}
