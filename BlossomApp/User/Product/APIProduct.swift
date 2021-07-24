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
    case chargeCreditCard(amountSatang: Int, token: String, completion: (OmisePaymentResponse?)->Swift.Void)
    case updateOrderPayment(orderID: Int, omiseID: String, date: String, time: String, completion: (Bool)->Swift.Void)

    func endpoint() -> String {
        switch self {
        case .list:
            return "https://www.shipnity.pro/api/v2/products?per_page=50"
        case .createOrder:
            return "https://www.shipnity.pro/api/v2/orders"
        case .chargeCreditCard:
            return "https://api.omise.co/charges"
        case .updateOrderPayment(let orderID,_,_,_,_):
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
            
        case let .chargeCreditCard(amount, token, completion):
            let parameters: Parameters = ["amount": amount, "currency": "thb", "card": token]
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
         
        case let .updateOrderPayment(_, omiseID, date, time, completion):
            let parameters:Parameters = [
                "bank" : "omise_\(omiseID)",
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
