/* 
Copyright (c) 2021 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct District : Codable {
	let dISTRICT_ID : Int?
	let dISTRICT_CODE : String?
	let dISTRICT_NAME : String?
	let gEO_ID : Int?
	let pROVINCE_ID : Int?

	enum CodingKeys: String, CodingKey {

		case dISTRICT_ID = "DISTRICT_ID"
		case dISTRICT_CODE = "DISTRICT_CODE"
		case dISTRICT_NAME = "DISTRICT_NAME"
		case gEO_ID = "GEO_ID"
		case pROVINCE_ID = "PROVINCE_ID"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		dISTRICT_ID = try values.decodeIfPresent(Int.self, forKey: .dISTRICT_ID)
		dISTRICT_CODE = try values.decodeIfPresent(String.self, forKey: .dISTRICT_CODE)
		dISTRICT_NAME = try values.decodeIfPresent(String.self, forKey: .dISTRICT_NAME)
		gEO_ID = try values.decodeIfPresent(Int.self, forKey: .gEO_ID)
		pROVINCE_ID = try values.decodeIfPresent(Int.self, forKey: .pROVINCE_ID)
	}

}
