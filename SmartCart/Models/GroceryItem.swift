//
//  GroceryItem.swift
//  SmartCart
//

import Foundation

struct GroceryItem: Codable, Identifiable, Equatable {
    var id: Int64
    var ingredientId: Int64
    var quantityText: String?
    var source: String
    var isChecked: Bool
    var category: String
    var sharedListId: Int64?
}
