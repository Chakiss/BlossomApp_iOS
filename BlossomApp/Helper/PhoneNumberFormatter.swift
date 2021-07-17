//
//  PhoneNumberFormatter.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 18/7/2564 BE.
//

import Foundation

extension String {
    func addCountryCode() -> String {
        var phoneNumber = self
        phoneNumber = self.replacingCharacters(in: ...self.startIndex, with: "+66")
        return phoneNumber
    }
    
    func phonenumberformat() -> String {
        let replaced = self.replacingOccurrences(of: "+66", with: "0")
        return replaced
    }
}
