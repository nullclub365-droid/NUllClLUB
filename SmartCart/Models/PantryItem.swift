//
//  PantryItem.swift
//  SmartCart
//

import Foundation

struct PantryItem: Codable, Equatable {
    var ingredientId: Int64
    var quantityText: String?
    var expiryDate: Int64?
}
