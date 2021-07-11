//
//  ProductListViewModel.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 9/7/2564 BE.
//

import Foundation


struct ProductsResponse: Codable {
    let paginate : Paginate?
    let products : [Product]?
    let sets : [Sets]?
    let options : Options?

    enum CodingKeys: String, CodingKey {

        case paginate = "paginate"
        case products = "products"
        case sets = "sets"
        case options = "options"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        paginate = try values.decodeIfPresent(Paginate.self, forKey: .paginate)
        products = try values.decodeIfPresent([Product].self, forKey: .products)
        sets = try values.decodeIfPresent([Sets].self, forKey: .sets)
        options = try values.decodeIfPresent(Options.self, forKey: .options)
    }
    
}
