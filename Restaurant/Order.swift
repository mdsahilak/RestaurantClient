//
//  Order.swift
//  Restaurant
//
//  Created by Muhammed Sahil on 21/06/19.
//  Copyright © 2019 MDAK. All rights reserved.
//

import Foundation

struct Order: Codable {
    var id: Int?
    
    var orderingEntity: String
    var orderedIds: [Int]
}
