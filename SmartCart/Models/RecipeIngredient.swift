//
//  RecipeIngredient.swift
//  SmartCart
//

import Foundation

struct RecipeIngredient: Codable, Equatable {
    var ingredientId: Int64
    var qtyText: String?
    var optional: Bool
}
