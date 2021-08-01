//
//  Reviews.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 13/7/2564 BE.
//

import Foundation
import Firebase

struct Reviews: Codable {
    
    var id: String?
    //var appointmentReference: DocumentReference?
    var message: String?
    var createdAt: String?
    var doctorReference: DocumentReference?
    var score: Int?
    var type: String?
    var updatedAt: String?
    //var patientReference: DocumentReference?
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        //var appointmentReference: DocumentReference?
        case message
        case createdAt
        //case doctorReference
        case score
        case type
        case updatedAt
        //var patientReference: DocumentReference?
        
        
    }
    
    init(id: String, message: String, createdAt: String, doctorReference: DocumentReference, score: Int, type: String, updatedAt: String) {
        self.id = id
        //self.appointmentReference = appointmentReference
        self.message = message
        self.createdAt = createdAt
        self.doctorReference = doctorReference
        self.score = score
        self.type = type
        self.updatedAt = updatedAt
        //self.patientReference = patientReference
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        //appointmentReference = try values.decodeIfPresent(DocumentReference.self, forKey: .appointmentReference)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        //doctorReference = try values.decodeIfPresent(DocumentReference.self, forKey: .doctorReference)
        score = try values.decodeIfPresent(Int.self, forKey: .score)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        //patientReference = try values.decodeIfPresent(DocumentReference.self, forKey: .patientReference)
    }
}
