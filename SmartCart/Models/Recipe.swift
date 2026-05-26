//
//  Recipe.swift
//  SmartCart
//

import Foundation

struct Recipe: Codable, Identifiable, Equatable {
    var id: Int64
    var name: String
    var description: String
    var calories: Int
    var protein: Int
    var tags: [String]
    var steps: [RecipeStep]
    var ingredients: [RecipeIngredient]
    var readyInMinutes: Int
    var difficulty: String
}
