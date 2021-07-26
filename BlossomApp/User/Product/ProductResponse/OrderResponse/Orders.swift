/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Orders : Codable {
	let id : Int?
	let invoice_number : String?
	let tax_invoice : String?
	let created_at : String?
	let price : String?
	let paid : Bool?
	let shipping_fee : String?
	let send_bill : Bool?
	let shipping_type : String?
	let order_bank : String?
	let transferred_at : String?
	let transferred_date_field : String?
	let transferred_time_field : String?
	let closed_note : String?
	let shop_price : String?
	let payment_slip_url : String?
	let cost : String?
	let closed_at : String?
	let summary_text : String?
	let annotation : String?
	let payment_accepted : Bool?
	let payment_rejected : Bool?
	let ready_to_close : Bool?
	let closed : Bool?
	let printed : Bool?
	let stage : Int?
	let transferred : Bool?
	let taxable : Bool?
	let shippop : Bool?
	let shippop_ready_to_ship : Bool?
	let order_discount : String?
	let reseller_order_bank : String?
	let reselled : Bool?
	let customer_info_completed : Bool?
	let ready_to_pack : Bool?
	let can_close : Bool?
	let closed_cost : String?
	let closed_date_field : String?
	let closed_time_field : String?
	let packed : Bool?
	let shop_id : Int?
	let user_can_delete : Bool?
	let user_can_edit : Bool?
	let user_can_transfer : Bool?
	let user_can_close : Bool?
	let user_accept_reject : Bool?
	let reseller_id : String?
	let stock_id : Int?
	let user_pack : Bool?
	let shop_check_product_before_pack : Bool?
	let seller : String?
	let seller_email : String?
	let preorder : Bool?
	let discount_type : String?
	let slug : String?
	let name : String?
	let holding : Bool?
	let address : String?
	let address_without_zipcode : String?
	let postcode : String?
	let tel : String?
	let tax_id : String?
	let email : String?
	let contact_method : String?
	let tag : String?
	let duplicate_orders : [String]?
	let purchases : [Purchases]?
	let set_purchases : [String]?
	let order_payments : [String]?
	let customer : CustomerShipnity?
	let promo_code : String?
	let claimed_voucher : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case invoice_number = "invoice_number"
		case tax_invoice = "tax_invoice"
		case created_at = "created_at"
		case price = "price"
		case paid = "paid"
		case shipping_fee = "shipping_fee"
		case send_bill = "send_bill"
		case shipping_type = "shipping_type"
		case order_bank = "order_bank"
		case transferred_at = "transferred_at"
		case transferred_date_field = "transferred_date_field"
		case transferred_time_field = "transferred_time_field"
		case closed_note = "closed_note"
		case shop_price = "shop_price"
		case payment_slip_url = "payment_slip_url"
		case cost = "cost"
		case closed_at = "closed_at"
		case summary_text = "summary_text"
		case annotation = "annotation"
		case payment_accepted = "payment_accepted"
		case payment_rejected = "payment_rejected"
		case ready_to_close = "ready_to_close"
		case closed = "closed"
		case printed = "printed"
		case stage = "stage"
		case transferred = "transferred"
		case taxable = "taxable"
		case shippop = "shippop"
		case shippop_ready_to_ship = "shippop_ready_to_ship"
		case order_discount = "order_discount"
		case reseller_order_bank = "reseller_order_bank"
		case reselled = "reselled"
		case customer_info_completed = "customer_info_completed"
		case ready_to_pack = "ready_to_pack"
		case can_close = "can_close"
		case closed_cost = "closed_cost"
		case closed_date_field = "closed_date_field"
		case closed_time_field = "closed_time_field"
		case packed = "packed"
		case shop_id = "shop_id"
		case user_can_delete = "user_can_delete"
		case user_can_edit = "user_can_edit"
		case user_can_transfer = "user_can_transfer"
		case user_can_close = "user_can_close"
		case user_accept_reject = "user_accept_reject"
		case reseller_id = "reseller_id"
		case stock_id = "stock_id"
		case user_pack = "user_pack"
		case shop_check_product_before_pack = "shop_check_product_before_pack"
		case seller = "seller"
		case seller_email = "seller_email"
		case preorder = "preorder"
		case discount_type = "discount_type"
		case slug = "slug"
		case name = "name"
		case holding = "holding"
		case address = "address"
		case address_without_zipcode = "address_without_zipcode"
		case postcode = "postcode"
		case tel = "tel"
		case tax_id = "tax_id"
		case email = "email"
		case contact_method = "contact_method"
		case tag = "tag"
		case duplicate_orders = "duplicate_orders"
		case purchases = "purchases"
		case set_purchases = "set_purchases"
		case order_payments = "order_payments"
		case customer = "customer"
		case promo_code = "promo_code"
		case claimed_voucher = "claimed_voucher"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		invoice_number = try values.decodeIfPresent(String.self, forKey: .invoice_number)
		tax_invoice = try values.decodeIfPresent(String.self, forKey: .tax_invoice)
		created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
		price = try values.decodeIfPresent(String.self, forKey: .price)
		paid = try values.decodeIfPresent(Bool.self, forKey: .paid)
		shipping_fee = try values.decodeIfPresent(String.self, forKey: .shipping_fee)
		send_bill = try values.decodeIfPresent(Bool.self, forKey: .send_bill)
		shipping_type = try values.decodeIfPresent(String.self, forKey: .shipping_type)
		order_bank = try values.decodeIfPresent(String.self, forKey: .order_bank)
		transferred_at = try values.decodeIfPresent(String.self, forKey: .transferred_at)
		transferred_date_field = try values.decodeIfPresent(String.self, forKey: .transferred_date_field)
		transferred_time_field = try values.decodeIfPresent(String.self, forKey: .transferred_time_field)
		closed_note = try values.decodeIfPresent(String.self, forKey: .closed_note)
		shop_price = try values.decodeIfPresent(String.self, forKey: .shop_price)
		payment_slip_url = try values.decodeIfPresent(String.self, forKey: .payment_slip_url)
		cost = try values.decodeIfPresent(String.self, forKey: .cost)
		closed_at = try values.decodeIfPresent(String.self, forKey: .closed_at)
		summary_text = try values.decodeIfPresent(String.self, forKey: .summary_text)
		annotation = try values.decodeIfPresent(String.self, forKey: .annotation)
		payment_accepted = try values.decodeIfPresent(Bool.self, forKey: .payment_accepted)
		payment_rejected = try values.decodeIfPresent(Bool.self, forKey: .payment_rejected)
		ready_to_close = try values.decodeIfPresent(Bool.self, forKey: .ready_to_close)
		closed = try values.decodeIfPresent(Bool.self, forKey: .closed)
		printed = try values.decodeIfPresent(Bool.self, forKey: .printed)
		stage = try values.decodeIfPresent(Int.self, forKey: .stage)
		transferred = try values.decodeIfPresent(Bool.self, forKey: .transferred)
		taxable = try values.decodeIfPresent(Bool.self, forKey: .taxable)
		shippop = try values.decodeIfPresent(Bool.self, forKey: .shippop)
		shippop_ready_to_ship = try values.decodeIfPresent(Bool.self, forKey: .shippop_ready_to_ship)
		order_discount = try values.decodeIfPresent(String.self, forKey: .order_discount)
		reseller_order_bank = try values.decodeIfPresent(String.self, forKey: .reseller_order_bank)
		reselled = try values.decodeIfPresent(Bool.self, forKey: .reselled)
		customer_info_completed = try values.decodeIfPresent(Bool.self, forKey: .customer_info_completed)
		ready_to_pack = try values.decodeIfPresent(Bool.self, forKey: .ready_to_pack)
		can_close = try values.decodeIfPresent(Bool.self, forKey: .can_close)
		closed_cost = try values.decodeIfPresent(String.self, forKey: .closed_cost)
		closed_date_field = try values.decodeIfPresent(String.self, forKey: .closed_date_field)
		closed_time_field = try values.decodeIfPresent(String.self, forKey: .closed_time_field)
		packed = try values.decodeIfPresent(Bool.self, forKey: .packed)
		shop_id = try values.decodeIfPresent(Int.self, forKey: .shop_id)
		user_can_delete = try values.decodeIfPresent(Bool.self, forKey: .user_can_delete)
		user_can_edit = try values.decodeIfPresent(Bool.self, forKey: .user_can_edit)
		user_can_transfer = try values.decodeIfPresent(Bool.self, forKey: .user_can_transfer)
		user_can_close = try values.decodeIfPresent(Bool.self, forKey: .user_can_close)
		user_accept_reject = try values.decodeIfPresent(Bool.self, forKey: .user_accept_reject)
		reseller_id = try values.decodeIfPresent(String.self, forKey: .reseller_id)
		stock_id = try values.decodeIfPresent(Int.self, forKey: .stock_id)
		user_pack = try values.decodeIfPresent(Bool.self, forKey: .user_pack)
		shop_check_product_before_pack = try values.decodeIfPresent(Bool.self, forKey: .shop_check_product_before_pack)
		seller = try values.decodeIfPresent(String.self, forKey: .seller)
		seller_email = try values.decodeIfPresent(String.self, forKey: .seller_email)
		preorder = try values.decodeIfPresent(Bool.self, forKey: .preorder)
		discount_type = try values.decodeIfPresent(String.self, forKey: .discount_type)
		slug = try values.decodeIfPresent(String.self, forKey: .slug)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		holding = try values.decodeIfPresent(Bool.self, forKey: .holding)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		address_without_zipcode = try values.decodeIfPresent(String.self, forKey: .address_without_zipcode)
		postcode = try values.decodeIfPresent(String.self, forKey: .postcode)
		tel = try values.decodeIfPresent(String.self, forKey: .tel)
		tax_id = try values.decodeIfPresent(String.self, forKey: .tax_id)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		contact_method = try values.decodeIfPresent(String.self, forKey: .contact_method)
		tag = try values.decodeIfPresent(String.self, forKey: .tag)
		duplicate_orders = try values.decodeIfPresent([String].self, forKey: .duplicate_orders)
		purchases = try values.decodeIfPresent([Purchases].self, forKey: .purchases)
		set_purchases = try values.decodeIfPresent([String].self, forKey: .set_purchases)
		order_payments = try values.decodeIfPresent([String].self, forKey: .order_payments)
		customer = try values.decodeIfPresent(CustomerShipnity.self, forKey: .customer)
		promo_code = try values.decodeIfPresent(String.self, forKey: .promo_code)
		claimed_voucher = try values.decodeIfPresent(String.self, forKey: .claimed_voucher)
	}

}
