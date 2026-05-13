//
//  AppRoute.swift
//  SmartCart
//

import Foundation

enum AppRoute: Hashable {
    case home
    case groceries
    case recipes
    case planner
    case recipeDetail(Int64)
    case cooking(Int64)
    case settings
    case about
    case nutrition
    case mealPrep
    case statistics
    case backup
    case addItems
    case timers
    case cookingHistory
    case achievements
    case unitConverter
    case insightDetail(String)
    case termsOfService
    case privacyPolicy
    case notifications
    case collections
    case collectionDetail(Int64)
    case accessibility
    case quickAddSwipe
    case postCookingCheck(Int64)
    case premium
}
