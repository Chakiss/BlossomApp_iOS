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
    case updateOrder(orderID: Int, po: UpdateOrderRequest, completion: (UpdateOrderResponse?)->Swift.Void)
    case chargeCreditCard(orderID: String, amountSatang: Int, token: String, ref: String, completion: (OmisePaymentResponse?)->Swift.Void)
    case updateOrderNote(orderID: Int, note: String, completion: (UpdateOrderResponse?)->Swift.Void)
    case getChargeCreditCard(chargeID: String, completion: (OmisePaymentResponse?)->Swift.Void)
    case updateOrderPayment(bank: String, orderID: Int, completion: (Bool)->Swift.Void)
    case getOrder(term: String, page: Int, completion: (OrderResponse?)->Swift.Void)
    case getOrderByID(shipnityID: String, completion: (OrderResponse?)->Swift.Void)
    case calculateShipping(items: [PurchasesAttribute], completion: ([ShippingFee]?)->Swift.Void)
    
    func endpoint() -> String {
        switch self {
        case .list:
            return "https://www.shipnity.pro/api/v2/products?per_page=50"
        case .createOrder:
            return "https://www.shipnity.pro/api/v2/orders"
        case .updateOrder(let orderID, _, _), .updateOrderNote(let orderID, _, _):
            return "https://www.shipnity.pro/api/v2/orders/\(orderID)"
        case .chargeCreditCard:
            return "https://api.omise.co/charges"
        case .getChargeCreditCard(let chargeID, _):
            return "https://api.omise.co/charges/\(chargeID)"
        case .updateOrderPayment(_, let orderID,_):
            return "https://www.shipnity.pro/api/v2/orders/\(orderID)/payment"
        case .getOrder:
            return "https://www.shipnity.pro/api/v2/orders"
        case .getOrderByID(let shipnityID, _):
            return "https://www.shipnity.pro/api/v2/customers/\(shipnityID)/orders"
        case .calculateShipping:
            return "https://www.shipnity.pro/api/v2/shipping_calculators/calculate_shipping_fee"
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

        case let .updateOrder(_, po, completion):
            let parameters = JSONAble<UpdateOrderRequest>.toJSON(object: po)
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
            
        case let .chargeCreditCard(orderID, amount, token, ref, completion):
            let parameters: Parameters = [
                "amount": amount,
                "currency": "thb",
                "card": token,
                "metadata": [ "ref1": ref ],
                "return_uri": "https://www.blossomclinicthailand.com/omise/\(orderID)/complete"
            ]
            debugPrint("\(endpoint()), \(parameters)")

            AF.request(endpoint(), method: .post, parameters: parameters, headers: ["Authorization":"Basic c2tleV81bmdsbTNqYnpyb2dpcnRkdGY3Og=="])
                .validate()
                .responseDecodable(of: OmisePaymentResponse.self) { (response) in
                    guard let orderResponse = response.value else {
                        completion(nil)
                        return
                    }
                    completion(orderResponse)
                }
        case let .getChargeCreditCard(_, completion):
            AF.request(endpoint(), method: .get, headers: ["Authorization":"Basic c2tleV81bmdsbTNqYnpyb2dpcnRkdGY3Og=="])
                .validate()
                .responseDecodable(of: OmisePaymentResponse.self) { (response) in
                    guard let orderResponse = response.value else {
                        completion(nil)
                        return
                    }
                    completion(orderResponse)
                }
         
        case let .updateOrderPayment(bankName, _, completion):
            let parameters: Parameters = [
                "bank" : bankName,//"creditcard",
                "transferred_date": "yyyy-mm-dd",
                "transferred_time": "hh:mm"
            ]
            debugPrint("\(endpoint()), \(parameters)")
            AF.request(endpoint(), method: .post, parameters: parameters, headers: headers)
                .validate()
                .responseJSON(completionHandler: { result in
                    completion(result.data != nil)
                })
            
        case let .getOrder(phoneNumber, page, completion):
            let param: Parameters = [
                "terms": phoneNumber.replacingOccurrences(of: "+", with: ""),
                "page": page
            ]
            debugPrint("\(endpoint()), \(param)")
            AF.request(endpoint(), method: .get, parameters: param, headers: headers)
                .validate()
                .responseDecodable(of: OrderResponse.self) { (response) in
                    guard let orderResponse = response.value else {
                        completion(nil)
                        return
                    }
                    completion(orderResponse)
                }
            
        case let .getOrderByID(_, completion: completion):
            
            debugPrint("getOrderByID :: \(endpoint())")
            AF.request(endpoint(), method: .get, parameters: nil, headers: headers)
                .validate()
                .responseDecodable(of: OrderResponse.self) { (response) in
                    guard let orderResponse = response.value else {
                        completion(nil)
                        return
                    }
                    completion(orderResponse)
                }
            
        case let .calculateShipping(items: items, completion):
            
            debugPrint("calculateShipping :: \(items)")
            var itemArray:[Any] = []
            for item in items {
                var tmp: [String:Any] = [:]
                tmp["quantity"] = item.quantity
                tmp["price"] = item.price
                tmp["subproduct_id"] = item.subproductID
                itemArray.append(tmp)
            }
            let parameter: Parameters = [
                "items" : itemArray
            ]
            AF.request(endpoint(), method: .post, parameters: parameter, headers: headers)
                .validate()
                .responseJSON(completionHandler: { response in
                    guard let shippingFeeResponse = response.value else {
                        completion(nil)
                        return
                    }
                    //let shippingFeeResponse = JSONDecoder().decode([ShippingFeeResponse].self, from: response.value as! Data)
                    // completion(shippingFeeResponse)completion(shippingFeeResponse)
                    
                    let decoder = JSONDecoder()
                    do {
                        
                        let shippingFee = try decoder.decode([ShippingFee].self, from: response.data!)
                        //print(decodedData.zero[0].content)
    
                        completion(shippingFee)
                    } catch {
                        print(error)
                    }
                })
                
            
            
        }
        
        
        
        
        
        
    }
    
}
