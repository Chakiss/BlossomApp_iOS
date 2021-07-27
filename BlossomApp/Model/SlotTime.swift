//
//  SlotTime.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 20/7/2564 BE.
//

import Foundation
import Firebase

class SlotTime: Codable {
    
    var id: String?
    var isBooked: Bool?
    var isCompleted: Bool?
    var isLocked: Bool?
    var isPaid: Bool?
    var period: Int?
    var salePrice: Int?
    var start: Timestamp?
    var end: Timestamp?
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        case isBooked
        case isCompleted
        case isLocked
        case isPaid
        case period
        case salePrice
        //case start
        //case end
    }

    init(id: String, isBooked: Bool, isCompleted: Bool, isLocked: Bool, isPaid: Bool, period: Int, salePrice: Int,start: Timestamp, end: Timestamp){
        self.id = id
        self.isBooked = isBooked
        self.isCompleted = isCompleted
        self.isLocked = isLocked
        self.isPaid = isPaid
        self.period = period
        self.salePrice = salePrice
        self.start = start
        self.end = end
        
    }
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        isBooked = try values.decode(Bool.self, forKey: .isBooked)
        isCompleted = try values.decode(Bool.self, forKey: .isCompleted)
        isLocked = try values.decode(Bool.self, forKey: .isLocked)
        isPaid = try values.decode(Bool.self, forKey: .isPaid)
        period = try values.decode(Int.self, forKey: .period)
        salePrice = try values.decode(Int.self, forKey: .salePrice)
        
        //start =  try values.decode(Timestamp.self, forKey: .start)
        //end =  try values.decode(Timestamp.self, forKey: .end)
    }
}


