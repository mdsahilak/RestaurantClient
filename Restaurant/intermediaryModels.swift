//
//  intermediaryModels.swift
//  Restaurant
//
//  Created by Muhammed Sahil on 06/09/18.
//  Copyright © 2018 MDAK. All rights reserved.
//

import Foundation

struct Categories: Codable {
    let categories: [String]
}

struct OrderSuccess: Codable {
    let orderID: UUID?
    let prepTime: Int
    
    enum CodingKeys: String, CodingKey {
        case orderID
        case prepTime // "preparation_time" // not required for the vapor swift server
    }
}
