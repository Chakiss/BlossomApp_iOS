//
//  APIProduct.swift
//  BlossomApp
//
//  Created by nim on 24/7/2564 BE.
//

import Foundation
import Alamofire

private let headers: HTTPHeaders = [
    "Authorization": "Token token=Aq1p3BC8ZSyBb-IW2QEOxT_JppMvbjSB3DKWRC2E6ziaxgDeJRK00dSzkgcbCSS_AIpESUe-Rz47suWiX2MjqA, email=oaf@blossomclinic.com"
]

enum APIProduct {
        
    case list(completion: (ProductsResponse?)->Swift.Void)
    case createOrder(po: CreateOrderRequest, completion: (CreateOrderResponse?)->Swift.Void)
    case chargeCreditCard(orderID: Int, amountSatang: Int, token: String, completion: (OmisePaymentResponse?)->Swift.Void)
    case updateOrderNote(orderID: Int, note: String, completion: (UpdateOrderResponse?)->Swift.Void)
    case getChargeCreditCard(chargeID: String, completion: (OmisePaymentResponse?)->Swift.Void)
    case updateOrderPayment(orderID: Int, date: String, time: String, completion: (Bool)->Swift.Void)

    func endpoint() -> String {
        switch self {
        case .list:
            return "https://www.shipnity.pro/api/v2/products?per_page=50"
        case .createOrder:
            return "https://www.shipnity.pro/api/v2/orders"
        case .updateOrderNote(let orderID, _, _):
            return "https://www.shipnity.pro/api/v2/orders/\(orderID)"
        case .chargeCreditCard:
            return "https://api.omise.co/charges"
        case .getChargeCreditCard(let chargeID, _):
            return "https://api.omise.co/charges/\(chargeID)"
        case .updateOrderPayment(let orderID,_,_,_):
            return "https://www.shipnity.pro/api/v2/orders/\(orderID)/payment"
        }
    }
    
    func request() {
        switch self {
        
        case let .list(completion):
            AF.request(endpoint() ,method: .get ,headers: headers)
                .validate()
                .responseDecodable(of: ProductsResponse.self) { (response) in
                    guard let productsResponse = response.value else {
                        completion(nil)
                        return
                    }
                    completion(productsResponse)                    
                }
            
        case let .createOrder(po, completion):
            let parameters = JSONAble<CreateOrderRequest>.toJSON(object: po)
            debugPrint("\(endpoint()), \(parameters)")
            AF.request(endpoint(), method: .post, parameters: parameters, headers: headers)
                .validate()
                .responseDecodable(of: CreateOrderResponse.self) { (response) in
                    guard let orderResponse = response.value else {
                        completion(nil)
                        return
                    }
                    completion(orderResponse)
                }
            
        case let .updateOrderNote(_, note, completion):
            let parameters = ["order": ["annotation": note]]
            debugPrint("\(endpoint()), \(parameters)")
            AF.request(endpoint(), method: .patch, parameters: parameters, headers: headers)
                .validate()
                .responseDecodable(of: UpdateOrderResponse.self) { (response) in
                    guard let orderResponse = response.value else {
                        completion(nil)
                        return
                    }
                    completion(orderResponse)
                }
            
        case let .chargeCreditCard(orderID, amount, token, completion):
            let parameters: Parameters = [
                "amount": amount,
                "currency": "thb",
                "card": token,
                "return_uri": "https://www.blossomclinicthailand.com/omise/\(orderID)/complete"
            ]
            debugPrint("\(endpoint()), \(parameters)")

            AF.request(endpoint(), method: .post, parameters: parameters, headers: ["Authorization":"Basic c2tleV90ZXN0XzVuMHh6bjRrcHN2eGl6bGh2b3g6"])
                .validate()
                .responseDecodable(of: OmisePaymentResponse.self) { (response) in
                    guard let orderResponse = response.value else {
                        completion(nil)
                        return
                    }
                    completion(orderResponse)
                }
        case let .getChargeCreditCard(_, completion):
            AF.request(endpoint(), method: .get, headers: ["Authorization":"Basic c2tleV90ZXN0XzVuMHh6bjRrcHN2eGl6bGh2b3g6"])
                .validate()
                .responseDecodable(of: OmisePaymentResponse.self) { (response) in
                    guard let orderResponse = response.value else {
                        completion(nil)
                        return
                    }
                    completion(orderResponse)
                }
         
        case let .updateOrderPayment(_, date, time, completion):
            let parameters:Parameters = [
                "bank" : "omise",
                "date" : date,
                "time" : time
            ]
            debugPrint("\(endpoint()), \(parameters)")
            AF.request(endpoint(), method: .post, parameters: parameters, headers: headers)
                .validate()
                .responseJSON(completionHandler: { result in
                    completion(result.data != nil)
                })
        }
        
    }
    
}
