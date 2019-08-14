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
    
    /// URL for running on an iOS device on my WiFi network
    let baseURL = URL(string: "http://home-macbook-pro.local:8080/")!
    
    /// URL for running on the simulator
    //let baseURL = URL(string:"http://localhost:8080/")!
    
    // uncomment the url you want to use and comment out the other one. While using the local network url, please use your computers network name in place of home-macbook-pro . It can be found under system preferences -> Sharing -> below the Computer Name textField.
    
    //
    func fetchCategories(completion: @escaping ([String]?) -> Void) {
        //let categoryURL = URL(string: "http://home-macbook-pro.local:8080/categories")!
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
        // <Ignore>
        //let initialMenuURL = baseURL.appendingPathComponent("menu")
        //var components = URLComponents(url: initialMenuURL, resolvingAgainstBaseURL: true)!
        //components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        // </Ignore> (only if url requires query items)
        
        //let menuURL = URL(string: "http://home-macbook-pro.local:8080/menu/\(categoryName)")!
        let AllMenuURL = baseURL.appendingPathComponent("menu")
        let menuURL = AllMenuURL.appendingPathComponent(categoryName)
        
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
    func submitOrder(order: Order, completion: @escaping (OrderSuccess?) -> Void) {
        //let orderURL = URL(string: "http://home-macbook-pro.local:8080/order")!
        let orderURL = baseURL.appendingPathComponent("order")
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //let data: [String: [Int]] = ["menuIds": menuIds]
        let data: [String: Order] = ["order": order]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(data)
        
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let orderSuccess = try? jsonDecoder.decode(OrderSuccess.self, from: data) {
                //
                //print(String(data: data, encoding: .utf8))
                //print(preparationTime)
                //
                completion(orderSuccess)
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
