//
//  Appointment.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 24/7/2564 BE.
//

import Foundation

import Firebase

struct Appointment: Codable {
    
    var id: String?
    var createdAt: Timestamp?
    var doctorReference: DocumentReference?
    var customerReference: DocumentReference?
    var orderReference: DocumentReference?
    var isComplete: Bool?
    var sessionStart: Timestamp?
    var sessionEnd: Timestamp?
    var timeReference: DocumentReference?
    var preForm: [String: Any]?
    var postForm: [String: Any]?
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        //case createdAt
        //case doctorReference
        //var customerReference: DocumentReference?
        //var orderReference: DocumentReference?
        //case isComplete
        //case sessionStart
        //case sessionEnd
        //var timeReference: DocumentReference?
        //case preForm
        //case postForm
        
        
    }
    
    init(id: String,createdAt: Timestamp, doctorReference: DocumentReference){
        self.id = id
        self.createdAt = createdAt
        self.doctorReference = doctorReference
       
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        //doctorReference = try values.decodeIfPresent(DocumentReference.self, forKey: .doctorReference)
        //createdAt = try values.decodeIfPresent(Timestamp.self, forKey: .createdAt)
        //appointmentReference = try values.decodeIfPresent(DocumentReference.self, forKey: .appointmentReference)
        //comment = try values.decodeIfPresent(String.self, forKey: .comment)
        
        //doctorReference = try values.decodeIfPresent(DocumentReference.self, forKey: .doctorReference)
        //score = try values.decodeIfPresent(Int.self, forKey: .score)
        //type = try values.decodeIfPresent(String.self, forKey: .type)
        //updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        //patientReference = try values.decodeIfPresent(DocumentReference.self, forKey: .patientReference)
    }
    
}
