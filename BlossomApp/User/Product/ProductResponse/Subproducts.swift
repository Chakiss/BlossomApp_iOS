/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Subproducts : Codable {
	let id : Int?
	let name : String?
	let code : String?
	let inventory : Int?
	let reserved : Int?
	let available : Int?
	let barcode : String?
	let price : String?
	let object_price : Double?
	let object_available : Int?
	let slug : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case code = "code"
		case inventory = "inventory"
		case reserved = "reserved"
		case available = "available"
		case barcode = "barcode"
		case price = "price"
		case object_price = "object_price"
		case object_available = "object_available"
		case slug = "slug"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		inventory = try values.decodeIfPresent(Int.self, forKey: .inventory)
		reserved = try values.decodeIfPresent(Int.self, forKey: .reserved)
		available = try values.decodeIfPresent(Int.self, forKey: .available)
		barcode = try values.decodeIfPresent(String.self, forKey: .barcode)
		price = try values.decodeIfPresent(String.self, forKey: .price)
		object_price = try values.decodeIfPresent(Double.self, forKey: .object_price)
		object_available = try values.decodeIfPresent(Int.self, forKey: .object_available)
		slug = try values.decodeIfPresent(String.self, forKey: .slug)
	}

    init(from purchase: Purchase) {
        id = purchase.subproductID
        name = purchase.name
        code = purchase.code
        inventory = nil
        reserved = nil
        available = nil
        barcode = nil
        price = purchase.price
        object_price = nil
        object_available = nil
        slug = nil
    }
    
}
