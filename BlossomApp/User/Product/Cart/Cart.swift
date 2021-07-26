//
//  Cart.swift
//  BlossomApp
//
//  Created by nim on 11/7/2564 BE.
//

import Foundation

struct CartItem: Equatable {
    
    let product: Product
    var quantity: Int = 0
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        #warning("Currently, we use unique product_id, but we need to use subproduct in the future to support product variant")
        return lhs.product.product_id == rhs.product.product_id
    }
    
}

class Cart {
    
    let id: String = UUID().uuidString
    private(set) var items: [CartItem] = []
    private(set) var purchaseOrder: Order?
    
    public func addItem(_ product: Product, quantity: Int = 1) {
        
        let item: CartItem = CartItem(product: product, quantity: quantity)
        guard items.contains(item) else {
            items.append(item)
            return
        }
        
        guard let ind = items.firstIndex(of: item) else {
            return
        }

        let currentItem = items[ind]
        let newItem: CartItem = CartItem(product: product, quantity: currentItem.quantity+quantity)
        items.replaceSubrange(ind..<ind+1, with: [newItem])

    }
    
    public func removeItemFromCart(_ product: Product) {
        
        let item: CartItem = CartItem(product: product, quantity: 1)
        guard let ind = items.firstIndex(of: item) else {
            return
        }

        items.remove(at: ind)

    }

    public func removeItem(_ product: Product, quantity: Int = 1) {
        
        let item: CartItem = CartItem(product: product, quantity: quantity)
        guard let ind = items.firstIndex(of: item) else {
            return
        }

        let currentItem: CartItem = items[ind]
        let remaining: Int = currentItem.quantity-quantity
        
        if remaining > 0 {
            let newItem: CartItem = CartItem(product: product, quantity: remaining)
            items.replaceSubrange(ind..<ind+1, with: [newItem])
        } else {
            removeItemFromCart(product)
        }

    }
    
    public func calculateTotalPriceInSatang() -> Int {
        return items.map({ $0.product.priceInSatang() * $0.quantity }).reduce(0, +)
    }
    
    public func getPurcahseAttributes() -> [PurchasesAttribute] {
        return items.map({ PurchasesAttribute(subproductID: $0.product.subproducts?.first?.id ?? 0, quantity: $0.quantity, price: Double($0.product.priceInSatang()) / 100.0, discount: 0) })
    }
    
    public func updatePO(_ purchaseOrder: Order) {
        self.purchaseOrder = purchaseOrder
    }
    
}

extension Int {
    
    func satangToBaht() -> Double {
        return Double(self)/100.0
    }
    
}

extension Double {
    
    func toAmountText() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self))?.replacingOccurrences(of: ".00", with: "") ?? ""
    }
    
}

class CartManager {
    
    static let shared: CartManager = CartManager()
    
    private(set) var currentCart: Cart?
    
    private init() { }
    
    public func newCart() {
        self.currentCart = Cart()
    }
    
    public func clearCart() {
        self.currentCart = nil
    }
    
    public func addItem(_ product: Product, quantity: Int = 1) {
        if currentCart == nil {
            newCart()
        }
        self.currentCart?.addItem(product, quantity: quantity)
    }
    
    public func convertOrder(_ order: Order) -> Cart {
        return Cart()
    }
    
}
