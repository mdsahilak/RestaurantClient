//
//  intermediaryModels.swift
//  Restaurant
//
//  Created by Muhammed Sahil on 06/09/18.
//  Copyright © 2018 MDAK. All rights reserved.
//

import Foundation

struct Categories: Codable{
    let categories: [String]
}

struct PreparationTime: Codable{
    let prepTime: Int
    
    enum CodingKeys: String, CodingKey{
        case prepTime = "preparation_time"
    }
}
