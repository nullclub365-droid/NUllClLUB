//
//  SmartCartTests.swift
//  SmartCartTests
//
//  Created by lazare tchaava on 02.02.26.
//

import Testing
@testable import SmartCart

struct SmartCartTests {

    @Test func plannedDayTotals_sumsCaloriesAndProteinFromRecipes() async throws {
        let recipe1 = Recipe(
            id: 1,
            name: "Breakfast",
            description: "",
            calories: 400,
            protein: 15,
            tags: [],
            steps: [],
            ingredients: [],
            readyInMinutes: 10,
            difficulty: "Easy"
        )
        let recipe2 = Recipe(
            id: 2,
            name: "Lunch",
            description: "",
            calories: 600,
            protein: 35,
            tags: [],
            steps: [],
            ingredients: [],
            readyInMinutes: 30,
            difficulty: "Medium"
        )
        let day = PlannedDay(
            dayOfWeek: "Monday",
            breakfastId: 1,
            lunchId: 2,
            dinnerId: nil,
            snackId: nil,
            caloriesTotal: 0,
            proteinTotal: 0
        )
        let lookup: (Int64) -> Recipe? = { id in
            if id == 1 { return recipe1 }
            if id == 2 { return recipe2 }
            return nil
        }
        let totals = day.totals(recipeLookup: lookup)
        #expect(totals.calories == 1000)
        #expect(totals.protein == 50)
    }

    @Test func plannedDayTotals_emptyDay_returnsZero() async throws {
        let day = PlannedDay(
            dayOfWeek: "Tuesday",
            breakfastId: nil,
            lunchId: nil,
            dinnerId: nil,
            snackId: nil,
            caloriesTotal: 0,
            proteinTotal: 0
        )
        let totals = day.totals(recipeLookup: { _ in nil })
        #expect(totals.calories == 0)
        #expect(totals.protein == 0)
    }

    @Test func admobService_adUnitIDsAreSet() async throws {
        #expect(!AdMobService.bannerAdUnitID.isEmpty)
        #expect(!AdMobService.rewardedAdUnitID.isEmpty)
        #expect(!AdMobService.interstitialAdUnitID.isEmpty)
    }

    /// Today's nutrition should include entries with date in [todayStart, tomorrowStart), not tomorrow.
    @Test func todayNutritionDateBoundary_excludesTomorrow() async throws {
        let todayStart: Int64 = 1_700_000_000_000
        let tomorrowStart = todayStart + 86400 * 1000
        #expect(isEntryDateInToday(entryDate: todayStart, todayStart: todayStart) == true)
        #expect(isEntryDateInToday(entryDate: todayStart + 1, todayStart: todayStart) == true)
        #expect(isEntryDateInToday(entryDate: tomorrowStart - 1, todayStart: todayStart) == true)
        #expect(isEntryDateInToday(entryDate: tomorrowStart, todayStart: todayStart) == false)
        #expect(isEntryDateInToday(entryDate: tomorrowStart + 1, todayStart: todayStart) == false)
    }

    @Test @MainActor func persistence_saveAndLoadRoundtrip() async throws {
        let data = PersistedData(
            pantryItems: [],
            groceryItems: [],
            currentPlan: nil,
            recipeHistory: [],
            nutritionEntries: [],
            favoriteRecipeIds: [],
            mealPrepRecipeIds: [],
            nextGroceryId: 1,
            nextNutritionId: 1,
            recipeNotes: [],
            recipeRatings: nil,
            recentRecipeSearches: nil,
            allergies: nil,
            dietPreferences: nil,
            healthGoals: nil,
            onboardingCompleted: nil,
            recipeCollections: nil,
            nextCollectionId: nil,
            customMeals: nil,
            nextCustomMealId: nil,
            ingredients: nil,
            recipes: nil
        )
        let saved = Persistence.save(data)
        #expect(saved == true)
        let loaded = Persistence.load()
        #expect(loaded != nil)
        let loadedCount = loaded?.nutritionEntries.count ?? -1
        #expect(loadedCount == 0)
        let pantryCount = loaded?.pantryItems.count ?? -1
        #expect(pantryCount == data.pantryItems.count)
    }

    /// Allergy filtering: recipe with peanut ingredient is excluded when "peanuts" is in allergies.
    @Test func allergyFiltering_excludesRecipeWhenIngredientMatchesAllergy() async throws {
        let peanutIngredient = Ingredient(
            id: 1,
            canonicalName: "Peanut Butter",
            category: "Condiments",
            aliases: [],
            caloriesPerServing: nil,
            proteinPerServing: nil,
            carbsPerServing: nil,
            fatsPerServing: nil,
            standardServing: nil
        )
        let recipe = Recipe(
            id: 1,
            name: "Test",
            description: "",
            calories: 100,
            protein: 5,
            tags: [],
            steps: [],
            ingredients: [RecipeIngredient(ingredientId: 1, qtyText: "1 tbsp", optional: false)],
            readyInMinutes: 5,
            difficulty: "Easy"
        )
        let ingredientMap: [Int64: Ingredient] = [1: peanutIngredient]

        #expect(AppStore.recipeExcludesAllergens(recipe: recipe, ingredientMap: ingredientMap, allergies: []) == true)
        #expect(AppStore.recipeExcludesAllergens(recipe: recipe, ingredientMap: ingredientMap, allergies: ["peanuts"]) == false)
        #expect(AppStore.recipeExcludesAllergens(recipe: recipe, ingredientMap: ingredientMap, allergies: ["tree nuts"]) == true)
    }
}

private func isEntryDateInToday(entryDate: Int64, todayStart: Int64) -> Bool {
    let tomorrowStart = todayStart + 86400 * 1000
    return entryDate >= todayStart && entryDate < tomorrowStart
}
