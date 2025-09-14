//
//  Product.swift
//  Powerplay
//
//  Created by Shahma on 13/09/25.
//

import Foundation

struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let brand: String?
    let stock: Int?
    let image: String?
    let specs: Specs?
    let rating: Rating?
}

struct Specs: Codable {
    let color: String?
    let weight: String?
    let storage: String?
    let battery: String?
    let waterproof: Bool?
    let screen: String?
    let ram: String?
    let connection: String?
    let capacity: String?
    let output: String?
}

struct Rating: Codable {
    let rate: Double
    let count: Int
}

struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let nextPage: Int?
}

struct APIResponse: Codable {
    let data: [Product]
    let pagination: Pagination
}

extension Specs {
    func toDisplayString() -> String {
        var specsArray: [String] = []
        
        if let color = color { specsArray.append("Color: \(color)") }
        if let weight = weight { specsArray.append("Weight: \(weight)") }
        if let storage = storage { specsArray.append("Storage: \(storage)") }
        if let battery = battery { specsArray.append("Battery: \(battery)") }
        if let waterproof = waterproof { specsArray.append("Waterproof: \(waterproof ? "Yes" : "No")") }
        if let screen = screen { specsArray.append("Screen: \(screen)") }
        if let ram = ram { specsArray.append("RAM: \(ram)") }
        if let connection = connection { specsArray.append("Connection: \(connection)") }
        if let capacity = capacity { specsArray.append("Capacity: \(capacity)") }
        if let output = output { specsArray.append("Output: \(output)") }
        
        return specsArray.joined(separator: "\n")
    }
}

extension Rating {
    func starRating() -> String {
        return String(format: "★%.1f (%d reviews)", rate, count)
    }
}
