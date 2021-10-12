//
//  Message.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 9/10/2564 BE.
//

import Foundation

import Firebase

struct Message: Codable {
    
    var id: String?
    var createdAt: Timestamp?
    var updateAt: Timestamp?
    var isRead: Bool?
    var message: String?
    var sendFrom: DocumentReference?
    var sendTo: DocumentReference?
    var images: [String]?
    
    

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
    
    init(id: String ){
        self.id = id
        //self.customerReference = customerReference
        //self.doctorReference = doctorReference
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
       
    }
    
}
