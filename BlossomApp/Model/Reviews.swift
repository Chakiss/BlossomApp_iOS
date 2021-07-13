//
//  Reviews.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 13/7/2564 BE.
//

import Foundation

struct Reviews: Codable {
    
    var id: String?
    var appointmentReference: String?
    var comment: String?
    var createdAt: String?
    var doctorReference: String?
    var score: String?
    var type: String?
    var updatedAt: String?
    var patientReference: String?
    
    init(id: String, appointmentReference: String, comment: String, createdAt: String, doctorReference: String, score: String, type: String, updatedAt: String, patientReference: String) {
        self.id = id
        self.appointmentReference = appointmentReference
        self.comment = comment
        self.createdAt = createdAt
        self.doctorReference = doctorReference
        self.score = score
        self.type = type
        self.updatedAt = updatedAt
        self.patientReference = patientReference
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        appointmentReference = try values.decodeIfPresent(String.self, forKey: .appointmentReference)
        comment = try values.decodeIfPresent(String.self, forKey: .comment)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        doctorReference = try values.decodeIfPresent(String.self, forKey: .doctorReference)
        score = try values.decodeIfPresent(String.self, forKey: .score)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        patientReference = try values.decodeIfPresent(String.self, forKey: .patientReference)
    }
}
