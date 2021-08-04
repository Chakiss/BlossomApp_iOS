//
//  Doctor.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 13/7/2564 BE.
//

import Foundation
import Firebase

class Doctor: Codable {
    var id: String?
    var displayName: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var referenceConnectyCubeID: UInt?
    var story: String?
    var createdAt: String?
    var updatedAt: String?
    var displayPhoto: String?
    
    var score: Double?
    var appointment: Int?
    var review: Int?
    
    var documentReference: DocumentReference?
    
    var isHaveSlotToday: Bool = false
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case email
        case firstName
        case lastName
        case phoneNumber
        case referenceConnectyCubeID
        case story
        case createdAt
        case updatedAt
        case displayPhoto
        case score
        
        
    }

    
    
    init(id: String, displayName: String, email: String, firstName: String, lastName: String, phonenumber: String, connectyCubeID: UInt, story: String, createdAt: String, updatedAt: String, displayPhoto: String, score: Double,documentReference: DocumentReference ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phonenumber
        self.referenceConnectyCubeID = connectyCubeID
        self.story = story
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.displayPhoto = displayPhoto
        self.score = score
        
        self.documentReference = documentReference
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
        referenceConnectyCubeID = try values.decodeIfPresent(UInt.self, forKey: .referenceConnectyCubeID)
        story = try values.decodeIfPresent(String.self, forKey: .story)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        displayPhoto = try values.decodeIfPresent(String.self, forKey: .displayPhoto)
        score = try values.decodeIfPresent(Double.self, forKey: .score)
        
        
    }

    
}
