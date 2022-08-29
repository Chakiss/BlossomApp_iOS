//
//  CreateOrderRequest.swift
//  BlossomApp
//
//  Created by nim on 24/7/2564 BE.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let createOrderRequest = try? newJSONDecoder().decode(CreateOrderRequest.self, from: jsonData)

import Foundation

// MARK: - CreateOrderRequest
struct CreateOrderRequest: Codable {
    let order: PurchaseOrder
}

struct UpdateOrderRequest: Codable {
    let order: PurchaseOrder
}

// MARK: - Order
struct PurchaseOrder: Codable {
    let customer: Int
    let name, address, tel, contactMethod: String
    let email, annotation, tag, shippingType: String
    let shippingFee: Int
    let preorder: Bool = false
    let taxable: Bool = false
    let orderDiscount: Int
    let purchasesAttributes: [PurchasesAttribute]
    let promo_code_id: Int

    enum CodingKeys: String, CodingKey {
        case customer, name, address, tel
        case contactMethod = "contact_method"
        case email, annotation, tag
        case shippingType = "shipping_type"
        case shippingFee = "shipping_fee"
        case preorder, taxable
        case orderDiscount = "order_discount"
        case purchasesAttributes = "purchases_attributes"
        case promo_code_id = "promo_code_id"
        
    }
}

// MARK: - PurchasesAttribute
struct PurchasesAttribute: Codable {
    let purchaseID: Int?
    let deleted: Bool
    let subproductID, quantity: Int
    let price, discount: Double

    enum CodingKeys: String, CodingKey {
        case purchaseID = "id"
        case deleted = "_destroy"
        case subproductID = "subproduct_id"
        case quantity, price, discount
    }
}
