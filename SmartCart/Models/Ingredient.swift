//
//  Ingredient.swift
//  SmartCart
//

import Foundation

struct Ingredient: Codable, Identifiable, Equatable {
    var id: Int64
    var canonicalName: String
    var category: String
    var aliases: [String]
    var caloriesPerServing: Int?
    var proteinPerServing: Int?
    var carbsPerServing: Int?
    var fatsPerServing: Int?
    var standardServing: String?
}
