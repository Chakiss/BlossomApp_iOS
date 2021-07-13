//
//  Customer.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 13/7/2564 BE.
//

import Foundation


struct Customer: Codable {
    var id: String?
    var createdAt: String?
    var displayName: String?
    var email: String?
    var firstName: String?
    var isEmailVerified: Bool?
    var isPhoneVerified: Bool?
    var lastName: String?
    var phoneNumber: String?
    var platform: String?
    var referenceConnectyCubeID: String?
    var referenceShipnityID: String?
    var updatedAt: String?
    
    init(id: String, createdAt: String, displayName: String, email: String, firstName: String, isEmailVerified: Bool, isPhoneVerified: Bool, lastName: String, phoneNumber: String, platform: String, referenceConnectyCubeID: String, referenceShipnityID: String, updatedAt: String ) {
        self.id = id
        self.createdAt = createdAt
        self.displayName = displayName
        self.email = email
        self.firstName = firstName
        self.isEmailVerified = isEmailVerified
        self.isPhoneVerified = isPhoneVerified
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.platform = platform
        self.referenceConnectyCubeID = referenceConnectyCubeID
        self.referenceShipnityID = referenceShipnityID
        self.updatedAt = updatedAt
        
    }
    
}
