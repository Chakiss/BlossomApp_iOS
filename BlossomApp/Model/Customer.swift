//
//  Customer.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 13/7/2564 BE.
//

import Foundation
import FirebaseFirestore
import Firebase


class Customer: Codable {
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
    
    var gender: String?
    var birthDate: String?
    var birthDayString: String?
    var birthDayDisplayString: String?
    var address: Address?
    
    var displayPhoto: String?
    
    var genderString: String?
    
    var skinType: String?
    var acneType: String?
    var acneCaredDescription: String?
    var allergicDrug: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case createdAt
        case displayName
        case email
        case firstName
        case isEmailVerified
        case isPhoneVerified
        case lastName
        case phoneNumber
        case platform
        case referenceConnectyCubeID
        case referenceShipnityID
        case updatedAt
        
        case gender
        case birthDate
        case address
        
        case displayPhoto
        
        case skinType
        case acneType
        case acneCaredDescription
        case allergicDrug
    }

    
    init(id: String, createdAt: String, displayName: String, email: String, firstName: String, isEmailVerified: Bool, isPhoneVerified: Bool, lastName: String, phoneNumber: String, platform: String, referenceConnectyCubeID: String, referenceShipnityID: String, updatedAt: String, gender: String, genderString: String, birthDate: String, birthDayDisplayString:String, birthDayString: String, address: Address,displayPhoto: String, skinType: String, acneType: String, acneCaredDescription: String, allergicDrug: String   ) {
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
        
        self.gender = gender
        self.birthDate = birthDate
        self.birthDayString = birthDayString
        self.birthDayDisplayString = birthDayDisplayString
        self.address = address
        
        self.displayPhoto = displayPhoto
        
        self.skinType = skinType
        self.acneType = acneType
        self.acneCaredDescription = acneCaredDescription
        self.allergicDrug = allergicDrug
        
    }
    
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try values.decode(String.self, forKey: .createdAt)
        displayName = try values.decode(String.self, forKey: .displayName)
        email = try values.decode(String.self, forKey: .email)
        firstName = try values.decode(String.self, forKey: .firstName)
        isEmailVerified = try values.decode(Bool.self, forKey: .isEmailVerified)
        isPhoneVerified = try values.decode(Bool.self, forKey: .isPhoneVerified)
        lastName = try values.decode(String.self, forKey: .lastName)
        phoneNumber = try values.decode(String.self, forKey: .phoneNumber)
        platform = try values.decode(String.self, forKey: .platform)
        referenceConnectyCubeID = try values.decode(String.self, forKey: .referenceConnectyCubeID)
        referenceShipnityID = try values.decode(String.self, forKey: .referenceShipnityID)
        updatedAt = try values.decode(String.self, forKey: .updatedAt)
        
        gender = try values.decode(String.self, forKey: .gender)
        birthDate = try values.decode(String.self, forKey: .birthDate)
        address =  try values.decode(Address.self, forKey: .address)
        
        displayPhoto = try values.decode(String.self, forKey: .displayPhoto)
        
        skinType = try values.decode(String.self, forKey: .skinType)
        acneType = try values.decode(String.self, forKey: .acneType)
        acneCaredDescription = try values.decode(String.self, forKey: .acneCaredDescription)
        allergicDrug = try values.decode(String.self, forKey: .allergicDrug)
    }
}


struct Address: Codable  {
    var address: String?
    var districtID: Int?
    var formattedAddress: Int?
    var provinceID: Int?
    var subDistrictID: Int?
    var zipcodeID: Int?
    
    enum CodingKeys: String, CodingKey {
        case address
        case districtID
        case formattedAddress
        case provinceID
        case subDistrictID
        case zipcodeID
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(districtID, forKey: .districtID)
        try container.encode(formattedAddress, forKey: .formattedAddress)
        try container.encode(provinceID, forKey: .provinceID)
        try container.encode(subDistrictID, forKey: .subDistrictID)
        try container.encode(zipcodeID, forKey: .zipcodeID)

    }
}
