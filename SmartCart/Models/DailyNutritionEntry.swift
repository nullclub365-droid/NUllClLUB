//
//  DailyNutritionEntry.swift
//  SmartCart
//

import Foundation

struct DailyNutritionEntry: Codable, Identifiable {
    var id: Int64
    var date: Int64
    var entryType: String
    var ingredientId: Int64?
    var quantityText: String?
    var calories: Int
    var protein: Int?
    var carbs: Int?
    var fats: Int?
    var createdAt: Int64
}
