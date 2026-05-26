//
//  CustomMeal.swift
//  SmartCart
//

import Foundation

struct CustomMeal: Codable, Identifiable, Equatable {
    var id: Int64
    var name: String
    var calories: Int
    var protein: Int
}
