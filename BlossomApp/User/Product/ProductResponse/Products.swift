/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Products : Codable {
	let id : Int?
	let product_id : Int?
	let name : String?
	let code : String?
	let tags : [String]?
	let object_price : Double?
	let inventory : Int?
	let description_long : String?
	let description_short : String?
	let reserved : Int?
	let object_available : Int?
	let image : String?
	let image_thumb : String?
	let brand : String?
	let price : String?
	let slug : String?
	let subproducts : [Subproducts]?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case product_id = "product_id"
		case name = "name"
		case code = "code"
		case tags = "tags"
		case object_price = "object_price"
		case inventory = "inventory"
		case description_long = "description_long"
		case description_short = "description_short"
		case reserved = "reserved"
		case object_available = "object_available"
		case image = "image"
		case image_thumb = "image_thumb"
		case brand = "brand"
		case price = "price"
		case slug = "slug"
		case subproducts = "subproducts"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		product_id = try values.decodeIfPresent(Int.self, forKey: .product_id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		tags = try values.decodeIfPresent([String].self, forKey: .tags)
		object_price = try values.decodeIfPresent(Double.self, forKey: .object_price)
		inventory = try values.decodeIfPresent(Int.self, forKey: .inventory)
		description_long = try values.decodeIfPresent(String.self, forKey: .description_long)
		description_short = try values.decodeIfPresent(String.self, forKey: .description_short)
		reserved = try values.decodeIfPresent(Int.self, forKey: .reserved)
		object_available = try values.decodeIfPresent(Int.self, forKey: .object_available)
		image = try values.decodeIfPresent(String.self, forKey: .image)
		image_thumb = try values.decodeIfPresent(String.self, forKey: .image_thumb)
		brand = try values.decodeIfPresent(String.self, forKey: .brand)
		price = try values.decodeIfPresent(String.self, forKey: .price)
		slug = try values.decodeIfPresent(String.self, forKey: .slug)
		subproducts = try values.decodeIfPresent([Subproducts].self, forKey: .subproducts)
	}

}