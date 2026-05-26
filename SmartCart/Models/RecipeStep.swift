//
//  RecipeStep.swift
//  SmartCart
//

import Foundation

struct RecipeStep: Codable, Equatable {
    var title: String
    var description: String
    var durationSeconds: Int?
}
