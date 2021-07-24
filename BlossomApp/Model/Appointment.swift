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
    var timeReference: DocumentReference?
    var preForm: [String: Any]?
    var postForm: [String: Any]?
    
    var sessionStart: Timestamp?
    var sessionEnd: Timestamp?
    
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
    
    init(id: String,customerReference: DocumentReference, doctorReference: DocumentReference,timeReference: DocumentReference, sessionStart: Timestamp, sessionEnd: Timestamp ){
        self.id = id
        self.customerReference = customerReference
        self.doctorReference = doctorReference
        self.timeReference = timeReference
        self.sessionStart = sessionStart
        self.sessionEnd = sessionEnd
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
       
    }
    
}
