//
//  MealPlanTemplate.swift
//  SmartCart
//

import Foundation

struct MealPlanTemplate: Codable, Identifiable, Equatable {
    var id: Int64
    var name: String
    var focus: String
    var description: String?
    var meals: [TemplateDay]
}
