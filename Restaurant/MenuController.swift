//
//  MenuController.swift
//  Restaurant
//
//  Created by Muhammed Sahil on 06/09/18.
//  Copyright © 2018 MDAK. All rights reserved.
//

import Foundation
import UIKit

class MenuController {
    static let shared = MenuController()
    
    let baseURL = URL(string: "http://home-macbook-pro.local:8090/")!
    
    //
    func fetchCategories(completion: @escaping ([String]?) -> Void) {
        let categoryURL = baseURL.appendingPathComponent("categories")
        let task = URLSession.shared.dataTask(with: categoryURL) { (data, urlResponse, error) in
            if let data = data, let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let categories = jsonDictionary?["categories"] as? [String] {
                completion(categories)
            } else {
                print("Categories fetch failed --MenuController.swift-")
                completion(nil)
            }
            
        }
        task.resume()
    }
    
    //
    func fetchMenuItems(categoryName: String, completion: @escaping ([MenuItem]?) -> Void) {
        let initialMenuURL = baseURL.appendingPathComponent("menu")
        var components = URLComponents(url: initialMenuURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        
        let menuURL = components.url!
        let task = URLSession.shared.dataTask(with: menuURL) { (data, urlResponse, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let menuItems = try? jsonDecoder.decode(MenuItems.self, from: data) {
                completion(menuItems.items)
            } else {
                print("Menu Items fetch failed --MenuController.swift-")
                completion(nil)
            }
        }
        task.resume()
    }
    
    //
    func submitOrder(menuIds: [Int], completion: @escaping (Int?) -> Void) {
        let orderURL = baseURL.appendingPathComponent("order")
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: [Int]] = ["menuIds": menuIds]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let preparationTime = try? jsonDecoder.decode(PreparationTime.self, from: data) {
                completion(preparationTime.prepTime)
            } else {
                print("Submit Order Failed --MenuController.swift-")
                completion(nil)
            }
        }
        task.resume()
    }
    
    //
    func fetchImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
            if let data = data, let image = UIImage(data: data) {
                
                completion(image)
            }else {
                print("Could not fetch image --MenuController.swift-")
                completion(nil)
            }
            
        }
        task.resume()
    }
    
    
}
