//
//  MealPlanInstance.swift
//  SmartCart
//

import Foundation

struct MealPlanInstance: Codable, Identifiable, Equatable {
    var id: Int64
    var weekStart: Int64
    var templateId: Int64?
    var days: [PlannedDay]
}
