/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Purchases : Codable {
	let id : Int?
	let code : String?
	let name : String?
	let quantity : Int?
	let discount : String?
	let price : String?
	let subproduct_id : Int?
	let thumb : String?
	let object_available : Int?
	let total_value : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case code = "code"
		case name = "name"
		case quantity = "quantity"
		case discount = "discount"
		case price = "price"
		case subproduct_id = "subproduct_id"
		case thumb = "thumb"
		case object_available = "object_available"
		case total_value = "total_value"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		quantity = try values.decodeIfPresent(Int.self, forKey: .quantity)
		discount = try values.decodeIfPresent(String.self, forKey: .discount)
		price = try values.decodeIfPresent(String.self, forKey: .price)
		subproduct_id = try values.decodeIfPresent(Int.self, forKey: .subproduct_id)
		thumb = try values.decodeIfPresent(String.self, forKey: .thumb)
		object_available = try values.decodeIfPresent(Int.self, forKey: .object_available)
		total_value = try values.decodeIfPresent(String.self, forKey: .total_value)
	}

}