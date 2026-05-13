//
//  AchievementTracker.swift
//  SmartCart
//

import Foundation

enum AchievementTracker {
    static func checkAndTrackAchievements(store: AppStore) {
        let progressLookup: (String) -> Int = { id in
            switch id {
            case "first_cook": return store.recipeHistory.count
            case "pantry_starter": return store.pantryItems.count
            case "pantry_pro": return store.pantryItems.count
            case "century_chef": return store.recipeHistory.count
            case "veggie_champion":
                return store.recipeHistory.filter { store.recipe(byId: $0.recipeId)?.tags.contains("vegetarian") == true }.count
            case "recipe_collector": return store.favoriteRecipeIds.count
            case "easy_peasy":
                return store.recipeHistory.filter { store.recipe(byId: $0.recipeId)?.difficulty == "Easy" }.count
            case "medium_master":
                return store.recipeHistory.filter { store.recipe(byId: $0.recipeId)?.difficulty == "Medium" }.count
            case "quick_cook":
                return store.recipeHistory.filter { (store.recipe(byId: $0.recipeId)?.readyInMinutes ?? 999) < 30 }.count
            case "week_warrior":
                let plannedSlots = store.currentPlan?.days.reduce(0) { sum, day in
                    sum + [day.breakfastId, day.lunchId, day.dinnerId, day.snackId].compactMap { $0 }.count
                } ?? 0
                return plannedSlots
            case "five_star":
                return store.recipeRatings.values.filter { $0 == 5 }.count
            case "recipe_rater": return store.recipeRatings.count
            case "collection_curator": return store.recipeCollections.count
            case "nutrition_logger": return store.nutritionEntries.count
            case "planner_pro":
                let plannedSlots = store.currentPlan?.days.reduce(0) { sum, day in
                    sum + [day.breakfastId, day.lunchId, day.dinnerId, day.snackId].compactMap { $0 }.count
                } ?? 0
                return plannedSlots
            default: return 0
            }
        }

        let achievements = AchievementSeed.all(progress: progressLookup)

        for achievement in achievements {
            if achievement.isUnlocked {
                AnalyticsHelper.trackAchievementUnlocked(
                    achievementId: achievement.id,
                    achievementName: achievement.displayName
                )
            }
        }
    }
}
