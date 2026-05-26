//
//  PlannedDay.swift
//  SmartCart
//

import Foundation

struct PlannedDay: Codable, Equatable {
    var dayOfWeek: String
    var breakfastId: Int64?
    var lunchId: Int64?
    var dinnerId: Int64?
    var snackId: Int64?
    var caloriesTotal: Int
    var proteinTotal: Int

    /// Returns total calories and protein for the day from the given recipe lookup (for display and tests).
    nonisolated func totals(recipeLookup: (Int64) -> Recipe?) -> (calories: Int, protein: Int) {
        let ids: [Int64?] = [breakfastId, lunchId, dinnerId, snackId]
        var calories = 0
        var protein = 0
        for id in ids.compactMap({ $0 }) {
            if let r = recipeLookup(id) {
                calories += r.calories
                protein += r.protein
            }
        }
        return (calories, protein)
    }
}
