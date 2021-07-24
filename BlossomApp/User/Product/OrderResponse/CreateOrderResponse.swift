//
//  CreateOrderResponse.swift
//  BlossomApp
//
//  Created by nim on 24/7/2564 BE.
//

import Foundation

// MARK: - CreateOrderResponse
struct CreateOrderResponse: Codable {
    var order: Order?
}

// MARK: - Order
struct Order: Codable {
    var id: Int?
    var invoiceNumber, taxInvoice: String?
    var createdAt: Date?
    var price: String?
    var paid: Bool?
    var shippingFee: String?
    var sendBill: Bool?
    var shippingType: String?
    var orderBank, transferredAt, transferredDateField, transferredTimeField: JSONNull?
    var closedNote, shopPrice, paymentSlipURL, cost: JSONNull?
    var closedAt: JSONNull?
    var summaryText, annotation: String?
    var paymentAccepted, paymentRejected, readyToClose, closed: Bool?
    var printed: Bool?
    var stage: Int?
    var transferred, taxable, shippop, shippopReadyToShip: Bool?
    var orderDiscount: String?
    var resellerOrderBank: JSONNull?
    var reselled, customerInfoCompleted, readyToPack, canClose: Bool?
    var closedCost: String?
    var closedDateField, closedTimeField: JSONNull?
    var packed: Bool?
    var shopID: Int?
    var userCanDelete, userCanEdit, userCanTransfer, userCanClose: Bool?
    var userAcceptReject: Bool?
    var resellerID: JSONNull?
    var stockID: Int?
    var userPack, shopCheckProductBeforePack: Bool?
    var seller, sellerEmail: String?
    var preorder: Bool?
    var discountType, slug, name: String?
    var holding: Bool?
    var address, addressWithoutZipcode: String?
    var postcode: JSONNull?
    var tel, taxID, email, contactMethod: String?
    var tag: String?
    var duplicateOrders: [JSONAny]?
    var purchases: [Purchase]?
    var setPurchases, orderPayments: [JSONAny]?
    var customer: OrderCustomer?
    var promoCode, claimedVoucher: JSONNull?

    enum CodingKeys: String, CodingKey {
        case id
        case invoiceNumber = "invoice_number"
        case taxInvoice = "tax_invoice"
        case createdAt = "created_at"
        case price, paid
        case shippingFee = "shipping_fee"
        case sendBill = "send_bill"
        case shippingType = "shipping_type"
        case orderBank = "order_bank"
        case transferredAt = "transferred_at"
        case transferredDateField = "transferred_date_field"
        case transferredTimeField = "transferred_time_field"
        case closedNote = "closed_note"
        case shopPrice = "shop_price"
        case paymentSlipURL = "payment_slip_url"
        case cost
        case closedAt = "closed_at"
        case summaryText = "summary_text"
        case annotation
        case paymentAccepted = "payment_accepted"
        case paymentRejected = "payment_rejected"
        case readyToClose = "ready_to_close"
        case closed, printed, stage, transferred, taxable, shippop
        case shippopReadyToShip = "shippop_ready_to_ship"
        case orderDiscount = "order_discount"
        case resellerOrderBank = "reseller_order_bank"
        case reselled
        case customerInfoCompleted = "customer_info_completed"
        case readyToPack = "ready_to_pack"
        case canClose = "can_close"
        case closedCost = "closed_cost"
        case closedDateField = "closed_date_field"
        case closedTimeField = "closed_time_field"
        case packed
        case shopID = "shop_id"
        case userCanDelete = "user_can_delete"
        case userCanEdit = "user_can_edit"
        case userCanTransfer = "user_can_transfer"
        case userCanClose = "user_can_close"
        case userAcceptReject = "user_accept_reject"
        case resellerID = "reseller_id"
        case stockID = "stock_id"
        case userPack = "user_pack"
        case shopCheckProductBeforePack = "shop_check_product_before_pack"
        case seller
        case sellerEmail = "seller_email"
        case preorder
        case discountType = "discount_type"
        case slug, name, holding, address
        case addressWithoutZipcode = "address_without_zipcode"
        case postcode, tel
        case taxID = "tax_id"
        case email
        case contactMethod = "contact_method"
        case tag
        case duplicateOrders = "duplicate_orders"
        case purchases
        case setPurchases = "set_purchases"
        case orderPayments = "order_payments"
        case customer
        case promoCode = "promo_code"
        case claimedVoucher = "claimed_voucher"
    }
}

// MARK: - OrderCustomer
struct OrderCustomer: Codable {
    var id: Int?
    var name, tag, address, addressWithoutZipcode: String?
    var postcode: JSONNull?
    var contactMethod, tel, email: String?
    var taxID, customerCategoryID: JSONNull?
    var tags, tagsWithColor: [JSONAny]?
    var facebookThreadID, facebookPageID, facebookID, facebookReadAt: JSONNull?
    var orderStatus: Int?
    var rewardLink: String?
    var rewardValue, customerNumber: String?

    enum CodingKeys: String, CodingKey {
        case id, name, tag, address
        case addressWithoutZipcode = "address_without_zipcode"
        case postcode
        case contactMethod = "contact_method"
        case tel, email
        case taxID = "tax_id"
        case customerCategoryID = "customer_category_id"
        case tags
        case tagsWithColor = "tags_with_color"
        case facebookThreadID = "facebook_thread_id"
        case facebookPageID = "facebook_page_id"
        case facebookID = "facebook_id"
        case facebookReadAt = "facebook_read_at"
        case orderStatus = "order_status"
        case rewardLink = "reward_link"
        case rewardValue = "reward_value"
        case customerNumber = "customer_number"
    }
}

// MARK: - Purchase
struct Purchase: Codable {
    var id: Int?
    var code, name: String?
    var quantity: Int?
    var discount, price: String?
    var subproductID: Int?
    var thumb: String?
    var objectAvailable: Int?
    var totalValue: String?

    enum CodingKeys: String, CodingKey {
        case id, code, name, quantity, discount, price
        case subproductID = "subproduct_id"
        case thumb
        case objectAvailable = "object_available"
        case totalValue = "total_value"
    }
}
