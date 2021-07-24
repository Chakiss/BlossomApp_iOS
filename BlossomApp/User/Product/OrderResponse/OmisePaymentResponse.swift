//
//  OmisePaymentResponse.swift
//  BlossomApp
//
//  Created by nim on 25/7/2564 BE.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let omisePaymentResponse = try? newJSONDecoder().decode(OmisePaymentResponse.self, from: jsonData)

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseOmisePaymentResponse { response in
//     if let omisePaymentResponse = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

// MARK: - OmisePaymentResponse
struct OmisePaymentResponse: Codable {
    var object, id, location: String?
    var amount, fundingAmount, refunded: Int?
    var authorized, capturable, capture, disputable: Bool?
    var livemode, refundable, reversed, reversible: Bool?
    var voided, paid, expired: Bool?
    var currency, fundingCurrency: String?
    var ip: String?
    var refunds: Refunds?
    var link, omisePaymentResponseDescription: String?
    var metadata: Metadata?
    var card: Card?
    var schedule, customer, dispute: String?
    var transaction: String?
    var failureCode, failureMessage: String?
    var status: String?
    var offline, offsite: String?
    var sourceOfFund: String?
    var reference, authorizeURI, returnURI: String?
    var created, paidAt, expiresAt: String?
    var expiredAt, reversedAt, branch, terminal: String?
    var device: String?

    enum CodingKeys: String, CodingKey {
        case object, id, location, amount
        case fundingAmount = "funding_amount"
        case refunded, authorized, capturable, capture, disputable, livemode, refundable, reversed, reversible, voided, paid, expired, currency
        case fundingCurrency = "funding_currency"
        case ip, refunds, link
        case omisePaymentResponseDescription = "description"
        case metadata, card, schedule, customer, dispute, transaction
        case failureCode = "failure_code"
        case failureMessage = "failure_message"
        case status, offline, offsite
        case sourceOfFund = "source_of_fund"
        case reference
        case authorizeURI = "authorize_uri"
        case returnURI = "return_uri"
        case created
        case paidAt = "paid_at"
        case expiresAt = "expires_at"
        case expiredAt = "expired_at"
        case reversedAt = "reversed_at"
        case branch, terminal, device
    }
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseCard { response in
//     if let card = response.result.value {
//       ...
//     }
//   }

// MARK: - Card
struct Card: Codable {
    var object, id: String?
    var livemode, securityCodeCheck: Bool?
    var expirationMonth, expirationYear: Int?
    var bank, brand: String?
    var city: String?
    var country, financing, fingerprint: String?
    var firstDigits: String?
    var lastDigits, name: String?
    var phoneNumber, postalCode, state, street1: String?
    var street2: String?
    var created: String?

    enum CodingKeys: String, CodingKey {
        case object, id, livemode
        case securityCodeCheck = "security_code_check"
        case expirationMonth = "expiration_month"
        case expirationYear = "expiration_year"
        case bank, brand, city, country, financing, fingerprint
        case firstDigits = "first_digits"
        case lastDigits = "last_digits"
        case name
        case phoneNumber = "phone_number"
        case postalCode = "postal_code"
        case state, street1, street2, created
    }
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseMetadata { response in
//     if let metadata = response.result.value {
//       ...
//     }
//   }

// MARK: - Metadata
struct Metadata: Codable {
}

//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseRefunds { response in
//     if let refunds = response.result.value {
//       ...
//     }
//   }

// MARK: - Refunds
struct Refunds: Codable {
    var object: String?
    var data: [JSONAny]?
    var limit, offset, total: Int?
    var location, order: String?
    var from, to: String?
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
