//
//  RecipeCollection.swift
//  SmartCart
//

import Foundation

struct RecipeCollection: Codable, Identifiable, Equatable {
    var id: Int64
    var name: String
    var recipeIds: [Int64]
}
