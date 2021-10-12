//
//  Channel.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 7/10/2564 BE.
//

import Foundation

import Firebase

struct Channel: Codable {
    
    var id: String?
    var createdAt: Timestamp?
    var doctorReference: DocumentReference?
    var customerReference: DocumentReference?
    var updateAt: Timestamp?
    var message: [Message]?

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
    
    init(id: String ){ //},customerReference: DocumentReference, doctorReference: DocumentReference ){
        self.id = id
        //self.customerReference = customerReference
        //self.doctorReference = doctorReference
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
       
    }
    
}
