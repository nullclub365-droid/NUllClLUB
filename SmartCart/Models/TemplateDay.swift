//
//  TemplateDay.swift
//  SmartCart
//

import Foundation

struct TemplateDay: Codable, Equatable {
    var dayOfWeek: String
    var breakfastId: Int64?
    var lunchId: Int64?
    var dinnerId: Int64?
    var snackId: Int64?
}
