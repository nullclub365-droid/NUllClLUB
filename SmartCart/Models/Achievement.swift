//
//  Achievement.swift
//  SmartCart
//

import Foundation

enum AchievementCategory: String, CaseIterable {
    case gettingStarted = "Getting Started"
    case streaks = "Cooking Streaks"
    case explorer = "Cuisine Explorer"
    case diet = "Diet Champions"
    case skill = "Skill Levels"
    case time = "Time Based"
    case special = "Special"
}

struct Achievement: Identifiable {
    let id: String
    let displayName: String
    let description: String
    let icon: String
    let target: Int
    let category: AchievementCategory
    var progress: Int
    var unlockedAt: Int64?

    var isUnlocked: Bool { unlockedAt != nil }
    var progressPercent: Float {
        guard target > 0 else { return 0 }
        return min(1, Float(progress) / Float(target))
    }
}

enum AchievementSeed {
    static func all(progress: (String) -> Int) -> [Achievement] {
        [
            Achievement(id: "first_cook", displayName: "First Timer", description: "Cook your first recipe", icon: "👨‍🍳", target: 1, category: .gettingStarted, progress: progress("first_cook"), unlockedAt: progress("first_cook") >= 1 ? 1 : nil),
            Achievement(id: "pantry_starter", displayName: "Pantry Starter", description: "Add 10 items to your pantry", icon: "🥫", target: 10, category: .gettingStarted, progress: progress("pantry_starter"), unlockedAt: progress("pantry_starter") >= 10 ? 1 : nil),
            Achievement(id: "pantry_pro", displayName: "Pantry Pro", description: "Add 25 items to your pantry", icon: "📦", target: 25, category: .gettingStarted, progress: progress("pantry_pro"), unlockedAt: progress("pantry_pro") >= 25 ? 1 : nil),
            Achievement(id: "century_chef", displayName: "Century Chef", description: "Cook 100 recipes total", icon: "💯", target: 100, category: .streaks, progress: progress("century_chef"), unlockedAt: progress("century_chef") >= 100 ? 1 : nil),
            Achievement(id: "veggie_champion", displayName: "Veggie Champion", description: "Cook 30 vegetarian meals", icon: "🥗", target: 30, category: .diet, progress: progress("veggie_champion"), unlockedAt: progress("veggie_champion") >= 30 ? 1 : nil),
            Achievement(id: "recipe_collector", displayName: "Recipe Collector", description: "Add 20 recipes to favorites", icon: "❤️", target: 20, category: .special, progress: progress("recipe_collector"), unlockedAt: progress("recipe_collector") >= 20 ? 1 : nil),
            Achievement(id: "easy_peasy", displayName: "Easy Peasy", description: "Complete 10 easy recipes", icon: "🟢", target: 10, category: .skill, progress: progress("easy_peasy"), unlockedAt: progress("easy_peasy") >= 10 ? 1 : nil),
            Achievement(id: "medium_master", displayName: "Medium Master", description: "Complete 10 medium-difficulty recipes", icon: "🟡", target: 10, category: .skill, progress: progress("medium_master"), unlockedAt: progress("medium_master") >= 10 ? 1 : nil),
            Achievement(id: "quick_cook", displayName: "Quick Cook", description: "Cook 10 recipes under 30 minutes", icon: "⚡", target: 10, category: .time, progress: progress("quick_cook"), unlockedAt: progress("quick_cook") >= 10 ? 1 : nil),
            Achievement(id: "week_warrior", displayName: "Week Warrior", description: "Plan 7 meals in one week", icon: "📅", target: 7, category: .time, progress: progress("week_warrior"), unlockedAt: progress("week_warrior") >= 7 ? 1 : nil),
            Achievement(id: "five_star", displayName: "Five Star", description: "Rate 5 recipes five stars", icon: "⭐", target: 5, category: .special, progress: progress("five_star"), unlockedAt: progress("five_star") >= 5 ? 1 : nil),
            Achievement(id: "recipe_rater", displayName: "Recipe Rater", description: "Rate 10 recipes", icon: "📝", target: 10, category: .special, progress: progress("recipe_rater"), unlockedAt: progress("recipe_rater") >= 10 ? 1 : nil),
            Achievement(id: "collection_curator", displayName: "Collection Curator", description: "Create 3 recipe collections", icon: "📁", target: 3, category: .special, progress: progress("collection_curator"), unlockedAt: progress("collection_curator") >= 3 ? 1 : nil),
            Achievement(id: "nutrition_logger", displayName: "Nutrition Logger", description: "Log 5 food entries", icon: "📊", target: 5, category: .diet, progress: progress("nutrition_logger"), unlockedAt: progress("nutrition_logger") >= 5 ? 1 : nil),
            Achievement(id: "planner_pro", displayName: "Planner Pro", description: "Plan 5 meals in the planner", icon: "🗓️", target: 5, category: .time, progress: progress("planner_pro"), unlockedAt: progress("planner_pro") >= 5 ? 1 : nil)
        ]
    }
}
