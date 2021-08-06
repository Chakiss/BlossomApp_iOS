//
//  DefaultKey.swift
//  BlossomApp
//
//  Created by CHAKRIT PANIAM on 26/7/2564 BE.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    var role: DefaultsKey<String?> { .init("role") }
    var orderList: DefaultsKey<String?> { .init("orderList") }
}
