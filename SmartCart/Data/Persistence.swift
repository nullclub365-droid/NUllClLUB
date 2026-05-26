//
//  Persistence.swift
//  SmartCart
//

import Foundation

struct PersistedData: Codable, @unchecked Sendable {
    var pantryItems: [PantryItem]
    var groceryItems: [GroceryItem]
    var currentPlan: MealPlanInstance?
    var recipeHistory: [RecipeHistoryItem]
    var nutritionEntries: [DailyNutritionEntry]
    var favoriteRecipeIds: [Int64]
    var mealPrepRecipeIds: [Int64]
    var nextGroceryId: Int64
    var nextNutritionId: Int64
    var recipeNotes: [RecipeNotePayload]
    var recipeRatings: [RecipeRatingPayload]?
    var recentRecipeSearches: [String]?
    var allergies: [String]?
    var dietPreferences: [String]?
    var healthGoals: [String]?
    var onboardingCompleted: Bool?
    var recipeCollections: [RecipeCollectionPayload]?
    var nextCollectionId: Int64?
    /// User-defined custom meals (name + calories + protein) for quick logging. Max 50.
    var customMeals: [CustomMeal]?
    var nextCustomMealId: Int64?
    /// Imported or persisted recipe catalog (ingredients + recipes). When non-empty, used instead of SeedData.
    var ingredients: [Ingredient]?
    var recipes: [Recipe]?

    struct RecipeNotePayload: Codable {
        var recipeId: Int64
        var note: String
        var updatedAt: Int64
    }

    struct RecipeRatingPayload: Codable {
        var recipeId: Int64
        var rating: Int
    }

    struct RecipeCollectionPayload: Codable {
        var id: Int64
        var name: String
        var recipeIds: [Int64]
    }
}

enum Persistence {
    nonisolated private static let fileName = "smartcart_data.json"
    nonisolated private static let backupFileName = "smartcart_data.backup.json"

    nonisolated static var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }

    nonisolated private static var backupFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(backupFileName)
    }

    /// Loads persisted data. Tries main file first; on decode failure, tries backup file.
    nonisolated static func load() -> PersistedData? {
        let decoder = JSONDecoder()
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? decoder.decode(PersistedData.self, from: data) {
            return decoded
        }
        if let backupData = try? Data(contentsOf: backupFileURL),
           let decoded = try? decoder.decode(PersistedData.self, from: backupData) {
            return decoded
        }
        return nil
    }

    /// Saves data: copies current file to backup (if it exists), then writes atomically. Returns true on success.
    nonisolated static func save(_ data: PersistedData) -> Bool {
        guard let encoded = try? JSONEncoder().encode(data) else { return false }
        let fileURL = self.fileURL
        let backupURL = self.backupFileURL
        if FileManager.default.fileExists(atPath: fileURL.path),
           (try? FileManager.default.copyItem(at: fileURL, to: backupURL)) != nil { }
        let tempURL = fileURL.deletingLastPathComponent().appendingPathComponent(".\(fileName).tmp")
        do {
            try encoded.write(to: tempURL)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            try FileManager.default.moveItem(at: tempURL, to: fileURL)
            return true
        } catch {
            try? FileManager.default.removeItem(at: tempURL)
            return false
        }
    }
}
