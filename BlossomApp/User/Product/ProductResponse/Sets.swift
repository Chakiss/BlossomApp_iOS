/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Sets : Codable {
    var id : Int?
    var name : String?
    var code : String?
    var object_available : Int?
    var price : String?
    var slug : String?
    var product_set_items : [Product_set_items]?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case code = "code"
		case object_available = "object_available"
		case price = "price"
		case slug = "slug"
		case product_set_items = "product_set_items"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		object_available = try values.decodeIfPresent(Int.self, forKey: .object_available)
		price = try values.decodeIfPresent(String.self, forKey: .price)
		slug = try values.decodeIfPresent(String.self, forKey: .slug)
		product_set_items = try values.decodeIfPresent([Product_set_items].self, forKey: .product_set_items)
	}
    
    init() {
        id = 0
        name = ""
        code = ""
        object_available = 0
        price = ""
        slug = ""
        product_set_items = []
    }
    

}
