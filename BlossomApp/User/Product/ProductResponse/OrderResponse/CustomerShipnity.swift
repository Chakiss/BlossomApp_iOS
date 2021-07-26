/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct CustomerShipnity : Codable {
	let id : Int?
	let name : String?
	let tag : String?
	let address : String?
	let address_without_zipcode : String?
	let postcode : String?
	let contact_method : String?
	let tel : String?
	let email : String?
	let tax_id : String?
	let customer_category_id : String?
	let tags : [String]?
	let tags_with_color : [String]?
	let facebook_thread_id : String?
	let facebook_page_id : String?
	let facebook_id : String?
	let facebook_read_at : String?
	let order_status : Int?
	let reward_link : String?
	let reward_value : String?
	let customer_number : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case tag = "tag"
		case address = "address"
		case address_without_zipcode = "address_without_zipcode"
		case postcode = "postcode"
		case contact_method = "contact_method"
		case tel = "tel"
		case email = "email"
		case tax_id = "tax_id"
		case customer_category_id = "customer_category_id"
		case tags = "tags"
		case tags_with_color = "tags_with_color"
		case facebook_thread_id = "facebook_thread_id"
		case facebook_page_id = "facebook_page_id"
		case facebook_id = "facebook_id"
		case facebook_read_at = "facebook_read_at"
		case order_status = "order_status"
		case reward_link = "reward_link"
		case reward_value = "reward_value"
		case customer_number = "customer_number"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		tag = try values.decodeIfPresent(String.self, forKey: .tag)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		address_without_zipcode = try values.decodeIfPresent(String.self, forKey: .address_without_zipcode)
		postcode = try values.decodeIfPresent(String.self, forKey: .postcode)
		contact_method = try values.decodeIfPresent(String.self, forKey: .contact_method)
		tel = try values.decodeIfPresent(String.self, forKey: .tel)
		email = try values.decodeIfPresent(String.self, forKey: .email)
		tax_id = try values.decodeIfPresent(String.self, forKey: .tax_id)
		customer_category_id = try values.decodeIfPresent(String.self, forKey: .customer_category_id)
		tags = try values.decodeIfPresent([String].self, forKey: .tags)
		tags_with_color = try values.decodeIfPresent([String].self, forKey: .tags_with_color)
		facebook_thread_id = try values.decodeIfPresent(String.self, forKey: .facebook_thread_id)
		facebook_page_id = try values.decodeIfPresent(String.self, forKey: .facebook_page_id)
		facebook_id = try values.decodeIfPresent(String.self, forKey: .facebook_id)
		facebook_read_at = try values.decodeIfPresent(String.self, forKey: .facebook_read_at)
		order_status = try values.decodeIfPresent(Int.self, forKey: .order_status)
		reward_link = try values.decodeIfPresent(String.self, forKey: .reward_link)
		reward_value = try values.decodeIfPresent(String.self, forKey: .reward_value)
		customer_number = try values.decodeIfPresent(String.self, forKey: .customer_number)
	}

}
