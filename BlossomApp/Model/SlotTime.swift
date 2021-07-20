//
//  SlotTime.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 20/7/2564 BE.
//

import Foundation

class SlotTime: Codable {
    
    var id: String?
    var isSelected: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id
    }

    init(id: String){
        self.id = id
    }
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
    }
}


