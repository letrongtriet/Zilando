//
//  ZilandoItem.swift
//  Zilando
//
//  Created by Le, Triet on 30.12.2020
//

import Foundation

// MARK: - ZilandoItem
struct ZilandoItem: Codable, Equatable {
    let items: [Item]
    let next: String?
    let prev: String?
    let total: Int

    enum CodingKeys: String, CodingKey {
        case items = "result"
        case next, prev, total
    }
}

// MARK: - Item
struct Item: Codable, Equatable {
    let itemID: String
    let image: String
    let title: String
    let price: Price
    let description: String
    let category: String

    enum CodingKeys: String, CodingKey {
        case itemID = "item_id"
        case image, title, price, category, description
    }
}

// MARK: - Price
struct Price: Codable, Equatable {
    let value: Double
    let currency: String

    var priceWithCurrency: String {
        "\(currency)\(value)"
    }
}
