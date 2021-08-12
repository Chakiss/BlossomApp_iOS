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
    var purchaseID: String?
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        #warning("Currently, we use unique from 1st item subproduct_id, but we need to update in the future to support product variant")
        return lhs.product.subproducts?.first?.id == rhs.product.subproducts?.first?.id
    }
    
}

struct CartError: LocalizedError {
    
    var errorMessage: String = ""
    
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        return errorMessage
    }

    /// A localized message describing the reason for the failure.
    var failureReason: String? {
        return errorMessage
    }

    /// A localized message describing how one might recover from the failure.
    var recoverySuggestion: String? {
        return errorMessage
    }

    /// A localized message providing "help" text if the user requests help.
    var helpAnchor: String? {
        return errorMessage
    }
    
}

class Cart {
    
    let id: String = UUID().uuidString
    private(set) var items: [CartItem] = []
    private(set) var purchaseOrder: Order?
    var shippingFee: Int = 0
    public func addItem(_ product: Product, quantity: Int = 1, purchaseID: String? = nil) {
        
        let item: CartItem = CartItem(product: product, quantity: quantity, purchaseID: purchaseID)
        guard items.contains(item) else {
            items.append(item)
            return
        }
        
        guard let ind = items.firstIndex(of: item) else {
            return
        }

        let currentItem = items[ind]
        let newItem: CartItem = CartItem(product: product, quantity: currentItem.quantity+quantity, purchaseID: currentItem.purchaseID)
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
            let newItem: CartItem = CartItem(product: product, quantity: remaining, purchaseID: currentItem.purchaseID)
            items.replaceSubrange(ind..<ind+1, with: [newItem])
        } else {
            removeItemFromCart(product)
        }

    }
    
    public func calculateTotalPriceInSatang() -> Int {
        return items.map({ $0.product.priceInSatang() * $0.quantity }).reduce(0, +) + (shippingFee * 100)
    }
    
    public func getPurcahseAttributes() -> [PurchasesAttribute] {
        var attributes: [PurchasesAttribute] = items.map({ PurchasesAttribute(purchaseID: Int($0.purchaseID ?? ""), deleted: $0.quantity == 0,subproductID: $0.product.subproducts?.first?.id ?? 0, quantity: $0.quantity, price: Double($0.product.priceInSatang()) / 100.0, discount: 0) })
        
        let cartItems = attributes.map({ $0.subproductID })
        let deletedItemIDs = purchaseOrder?.purchases?.compactMap({ $0.subproductID }).filter({ cartItems.contains($0) == false }) ?? []
        let deletedItems = purchaseOrder?.purchases?.filter({ deletedItemIDs.contains($0.subproductID ?? 0) })
        attributes.append(contentsOf: deletedItems?.map({ PurchasesAttribute(purchaseID: $0.id, deleted: true, subproductID: $0.subproductID ?? 0, quantity: 1, price: Double($0.price ?? "") ?? 0, discount: 0) }) ?? [])
        
        return attributes
    }
    
    public func updatePO(_ purchaseOrder: Order) {
        self.purchaseOrder = purchaseOrder
    }
    
    func checkInventory() -> CartError? {
        
        let outOfStockItems = items.filter({ $0.product.inventory != nil && ($0.product.inventory! == 0) })
        guard outOfStockItems.isEmpty else {
            return CartError(errorMessage: "\(outOfStockItems.first?.product.name ?? "สินค้า") มีไม่เพียงพอ")
        }
        
        guard let insufficientProduct = items.first(where: { $0.product.inventory != nil && ($0.product.inventory! < $0.quantity) }) else {
            return nil
        }
        
        return CartError(errorMessage: "\(insufficientProduct.product.name ?? "สินค้า") มีไม่เพียงพอ")
        
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
        let cart = Cart()
        cart.updatePO(order)
        order.purchases?.forEach({ item in
            let product = Product(from: item)
            cart.addItem(product, quantity: item.quantity ?? 0, purchaseID: "\(item.id ?? 0)")
        })        
        return cart
    }
    
}
