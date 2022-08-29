/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Promo_codes : Codable {
	let id : Int?
	let code : String?
	let end_date : String?
	let start_date : String?
	let discount_type : String?
	let discount_value : String?
	let expired : Bool?
	let claimed_vouchers_count : Int?
	let max_claimed : Int?
	let min_redeem_value : String?
	let min_redeem_type : String?
	let claimable : Bool?
	let orders_count : Int?
	let point_used : String?
	let min_redeem_type_name : String?
	let prerequisite_code : String?
	let prerequisite_name : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case code = "code"
		case end_date = "end_date"
		case start_date = "start_date"
		case discount_type = "discount_type"
		case discount_value = "discount_value"
		case expired = "expired"
		case claimed_vouchers_count = "claimed_vouchers_count"
		case max_claimed = "max_claimed"
		case min_redeem_value = "min_redeem_value"
		case min_redeem_type = "min_redeem_type"
		case claimable = "claimable"
		case orders_count = "orders_count"
		case point_used = "point_used"
		case min_redeem_type_name = "min_redeem_type_name"
		case prerequisite_code = "prerequisite_code"
		case prerequisite_name = "prerequisite_name"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		code = try values.decodeIfPresent(String.self, forKey: .code)
		end_date = try values.decodeIfPresent(String.self, forKey: .end_date)
		start_date = try values.decodeIfPresent(String.self, forKey: .start_date)
		discount_type = try values.decodeIfPresent(String.self, forKey: .discount_type)
		discount_value = try values.decodeIfPresent(String.self, forKey: .discount_value)
		expired = try values.decodeIfPresent(Bool.self, forKey: .expired)
		claimed_vouchers_count = try values.decodeIfPresent(Int.self, forKey: .claimed_vouchers_count)
		max_claimed = try values.decodeIfPresent(Int.self, forKey: .max_claimed)
		min_redeem_value = try values.decodeIfPresent(String.self, forKey: .min_redeem_value)
		min_redeem_type = try values.decodeIfPresent(String.self, forKey: .min_redeem_type)
		claimable = try values.decodeIfPresent(Bool.self, forKey: .claimable)
		orders_count = try values.decodeIfPresent(Int.self, forKey: .orders_count)
		point_used = try values.decodeIfPresent(String.self, forKey: .point_used)
		min_redeem_type_name = try values.decodeIfPresent(String.self, forKey: .min_redeem_type_name)
		prerequisite_code = try values.decodeIfPresent(String.self, forKey: .prerequisite_code)
		prerequisite_name = try values.decodeIfPresent(String.self, forKey: .prerequisite_name)
	}
    
    init() {
        id = 0
        code = ""
        end_date = ""
        start_date = ""
        discount_type = ""
        discount_value = ""
        expired = false
        claimed_vouchers_count = 0
        max_claimed = 0
        min_redeem_value = ""
        min_redeem_type = ""
        claimable = false
        orders_count = 0
        point_used = ""
        min_redeem_type_name = ""
        prerequisite_code = ""
        prerequisite_name = ""
    }

}
