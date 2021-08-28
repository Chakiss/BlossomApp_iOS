/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct ZipCode : Codable {
	let zIPCODE_ID : Int?
	let sUB_DISTRICT_CODE : String?
	let pROVINCE_ID : String?
	let dISTRICT_ID : String?
	let sUB_DISTRICT_ID : String?
	let zIPCODE : String?

	enum CodingKeys: String, CodingKey {

		case zIPCODE_ID = "ZIPCODE_ID"
		case sUB_DISTRICT_CODE = "SUB_DISTRICT_CODE"
		case pROVINCE_ID = "PROVINCE_ID"
		case dISTRICT_ID = "DISTRICT_ID"
		case sUB_DISTRICT_ID = "SUB_DISTRICT_ID"
		case zIPCODE = "ZIPCODE"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		zIPCODE_ID = try values.decodeIfPresent(Int.self, forKey: .zIPCODE_ID)
		sUB_DISTRICT_CODE = try values.decodeIfPresent(String.self, forKey: .sUB_DISTRICT_CODE)
		pROVINCE_ID = try values.decodeIfPresent(String.self, forKey: .pROVINCE_ID)
		dISTRICT_ID = try values.decodeIfPresent(String.self, forKey: .dISTRICT_ID)
		sUB_DISTRICT_ID = try values.decodeIfPresent(String.self, forKey: .sUB_DISTRICT_ID)
		zIPCODE = try values.decodeIfPresent(String.self, forKey: .zIPCODE)
	}

}
