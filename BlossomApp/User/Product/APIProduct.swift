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
    
    func endpoint() -> String {
        switch self {
        case .list:
            return "https://www.shipnity.pro/api/v2/products?per_page=50"
        case .createOrder:
            return "https://www.shipnity.pro/api/v2/orders"
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
            
        }
    }
    
}
