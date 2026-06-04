//
//  AppStore.swift
//  SmartCart
//

import Foundation
import Combine

struct PendingTimer: Equatable {
    let label: String
    let minutes: Int
}

@MainActor
final class AppStore: ObservableObject {
    @Published var ingredients: [Ingredient] = []
    @Published var recipes: [Recipe] = []
    @Published var pantryItems: [PantryItem] = []
    @Published var groceryItems: [GroceryItem] = []
    @Published var currentPlan: MealPlanInstance?
    @Published var recipeHistory: [RecipeHistoryItem] = []
    @Published var nutritionEntries: [DailyNutritionEntry] = []
    @Published var favoriteRecipeIds: Set<Int64> = []
    @Published var mealPrepRecipeIds: [Int64] = []
    @Published var recipeNotes: [Int64: String] = [:]
    @Published var recipeRatings: [Int64: Int] = [:] // recipeId -> 1...5
    /// When set, MultiTimerScreen will add this timer on appear and then clear it (e.g. from Cooking "Start step timer").
    @Published var pendingTimerToAdd: PendingTimer? = nil
    @Published var recentRecipeSearches: [String] = [] // last 10 recipe search queries
    @Published var allergies: [String] = []
    @Published var dietPreferences: [String] = []
    @Published var healthGoals: [String] = []
    @Published var onboardingCompleted: Bool = false
    @Published var recipeCollections: [RecipeCollection] = []
    /// Custom meals (name + calories + protein). Max 50. Persisted.
    @Published var customMeals: [CustomMeal] = []
    /// Non-nil when the last save failed (e.g. disk full). Clear after user is informed.
    @Published var lastPersistenceError: String? = nil
    /// Increment when app returns to foreground so views showing "today" re-evaluate (e.g. after midnight).
    @Published var dayRefreshTrigger: UUID = UUID()

    private var nextGroceryId: Int64 = 1
    private var nextCollectionId: Int64 = 1
    private var nextNutritionId: Int64 = 1
    private var nextCustomMealId: Int64 = 1
    private var saveWorkItem: DispatchWorkItem?

    init() {
        ingredients = SeedData.ingredients
        recipes = SeedData.recipes
        if let loaded = Persistence.load() {
            apply(loaded: loaded)
        } else {
            loadOrSeed()
        }
        // Always load bundled catalog when available so catalog fixes (e.g. recipe nutrition) are applied.
        loadBundledCatalogIfAvailable()
        saveDebounced()
    }

    /// Load full recipe catalog from bundled JSON (same 415 recipes as Android).
    private func loadBundledCatalogIfAvailable() {
        guard let url = Bundle.main.url(forResource: "smartcart_catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(RecipeCatalogFile.self, from: data) else { return }
        ingredients = catalog.ingredients
        recipes = catalog.recipes
    }

    private func apply(loaded: PersistedData) {
        pantryItems = loaded.pantryItems
        groceryItems = loaded.groceryItems
        currentPlan = loaded.currentPlan
        recipeHistory = loaded.recipeHistory
        nutritionEntries = loaded.nutritionEntries
        favoriteRecipeIds = Set(loaded.favoriteRecipeIds)
        mealPrepRecipeIds = loaded.mealPrepRecipeIds
        nextGroceryId = loaded.nextGroceryId
        nextNutritionId = loaded.nextNutritionId
        recipeNotes = Dictionary(uniqueKeysWithValues: loaded.recipeNotes.map { ($0.recipeId, $0.note) })
        recipeRatings = Dictionary(uniqueKeysWithValues: (loaded.recipeRatings ?? []).map { ($0.recipeId, $0.rating) })
        recentRecipeSearches = loaded.recentRecipeSearches ?? []
        allergies = loaded.allergies ?? []
        dietPreferences = loaded.dietPreferences ?? []
        healthGoals = loaded.healthGoals ?? []
        onboardingCompleted = loaded.onboardingCompleted ?? true
        recipeCollections = (loaded.recipeCollections ?? []).map { RecipeCollection(id: $0.id, name: $0.name, recipeIds: $0.recipeIds) }
        nextCollectionId = loaded.nextCollectionId ?? 1
        customMeals = loaded.customMeals ?? []
        nextCustomMealId = loaded.nextCustomMealId ?? 1
        if let ing = loaded.ingredients, !ing.isEmpty { ingredients = ing }
        if let rec = loaded.recipes, !rec.isEmpty { recipes = rec }
        if currentPlan == nil {
            currentPlan = MealPlanInstance(
                id: 1,
                weekStart: Int64(Date().timeIntervalSince1970 * 1000),
                templateId: 1,
                days: SeedData.defaultPlannedWeek
            )
        }
    }

    private func loadOrSeed() {
        if currentPlan == nil {
            currentPlan = MealPlanInstance(
                id: 1,
                weekStart: Int64(Date().timeIntervalSince1970 * 1000),
                templateId: 1,
                days: SeedData.defaultPlannedWeek
            )
        }
        if pantryItems.isEmpty {
            pantryItems = [
                PantryItem(ingredientId: 1, quantityText: "6", expiryDate: nil),
                PantryItem(ingredientId: 7, quantityText: "1 stick", expiryDate: nil)
            ]
        }
    }

    private func saveDebounced() {
        saveWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.persist()
            }
        }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
    }

    private func persist() {
        let data = PersistedData(
            pantryItems: pantryItems,
            groceryItems: groceryItems,
            currentPlan: currentPlan,
            recipeHistory: recipeHistory,
            nutritionEntries: nutritionEntries,
            favoriteRecipeIds: Array(favoriteRecipeIds),
            mealPrepRecipeIds: mealPrepRecipeIds,
            nextGroceryId: nextGroceryId,
            nextNutritionId: nextNutritionId,
            recipeNotes: recipeNotes.map { PersistedData.RecipeNotePayload(recipeId: $0.key, note: $0.value, updatedAt: Int64(Date().timeIntervalSince1970 * 1000)) },
            recipeRatings: recipeRatings.isEmpty ? nil : recipeRatings.map { PersistedData.RecipeRatingPayload(recipeId: $0.key, rating: $0.value) },
            recentRecipeSearches: recentRecipeSearches.isEmpty ? nil : recentRecipeSearches,
            allergies: allergies.isEmpty ? nil : allergies,
            dietPreferences: dietPreferences.isEmpty ? nil : dietPreferences,
            healthGoals: healthGoals.isEmpty ? nil : healthGoals,
            onboardingCompleted: onboardingCompleted,
            recipeCollections: recipeCollections.map { PersistedData.RecipeCollectionPayload(id: $0.id, name: $0.name, recipeIds: $0.recipeIds) },
            nextCollectionId: nextCollectionId,
            customMeals: customMeals.isEmpty ? nil : customMeals,
            nextCustomMealId: nextCustomMealId,
            ingredients: ingredients.isEmpty ? nil : ingredients,
            recipes: recipes.isEmpty ? nil : recipes
        )
        if Persistence.save(data) {
            lastPersistenceError = nil
        } else {
            lastPersistenceError = "Data could not be saved. Free up space and try again."
        }
    }

    func saveNow() {
        saveWorkItem?.cancel()
        persist()
    }

    /// Call when app returns to foreground so "today" totals and similar views re-evaluate (e.g. after midnight).
    func notifyDayMayHaveChanged() {
        dayRefreshTrigger = UUID()
    }

    func recipeNote(recipeId: Int64) -> String? {
        recipeNotes[recipeId]
    }

    func setRecipeNote(recipeId: Int64, note: String) {
        if note.isEmpty {
            recipeNotes.removeValue(forKey: recipeId)
        } else {
            recipeNotes[recipeId] = note
        }
        saveDebounced()
    }

    func recipeRating(recipeId: Int64) -> Int? {
        recipeRatings[recipeId]
    }

    func setRecipeRating(recipeId: Int64, rating: Int) {
        let clamped = max(1, min(5, rating))
        recipeRatings[recipeId] = clamped
        saveDebounced()
    }

    func recipe(byId id: Int64) -> Recipe? {
        recipes.first { $0.id == id }
    }

    func ingredient(byId id: Int64) -> Ingredient? {
        ingredients.first { $0.id == id }
    }

    var todayCalories: Int {
        let todayStart = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 * 1000
        let tomorrowStart = todayStart + 86400 * 1000
        let fromHistory = recipeHistory
            .filter { $0.cookedAt >= Int64(todayStart) && $0.cookedAt < Int64(tomorrowStart) }
            .compactMap { recipe(byId: $0.recipeId)?.calories }
        let fromEntries = nutritionEntries
            .filter { $0.date >= Int64(todayStart) && $0.date < Int64(tomorrowStart) }
        return fromHistory.reduce(0, +) + fromEntries.reduce(0) { $0 + $1.calories }
    }

    var todayProtein: Int {
        let todayStart = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 * 1000
        let tomorrowStart = todayStart + 86400 * 1000
        let fromHistory = recipeHistory
            .filter { $0.cookedAt >= Int64(todayStart) && $0.cookedAt < Int64(tomorrowStart) }
            .compactMap { recipe(byId: $0.recipeId)?.protein }
        let fromEntries = nutritionEntries
            .filter { $0.date >= Int64(todayStart) && $0.date < Int64(tomorrowStart) }
            .compactMap { $0.protein }
        return fromHistory.reduce(0, +) + fromEntries.reduce(0, +)
    }

    var plannedMealsForToday: [(id: Int64, name: String, calories: Int, protein: Int)] {
        let dayName = dayNameForToday()
        guard let plan = currentPlan,
              let day = plan.days.first(where: { $0.dayOfWeek == dayName }) else { return [] }
        var result: [(Int64, String, Int, Int)] = []
        for (rid, _) in [(day.breakfastId, "Breakfast"), (day.lunchId, "Lunch"), (day.dinnerId, "Dinner"), (day.snackId, "Snack")] {
            guard let rid = rid, let r = recipe(byId: rid) else { continue }
            result.append((r.id, r.name, r.calories, r.protein))
        }
        return result
    }

    var todayEntries: [DailyNutritionEntry] {
        let todayStart = Int64(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 * 1000)
        return nutritionEntries.filter { $0.date == todayStart }
    }

    func addManualNutritionEntry(calories: Int, protein: Int? = nil, carbs: Int? = nil, fats: Int? = nil) {
        let todayStart = Int64(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 * 1000)
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        nutritionEntries.append(DailyNutritionEntry(id: nextNutritionId, date: todayStart, entryType: "manual", ingredientId: nil, quantityText: nil, calories: calories, protein: protein, carbs: carbs, fats: fats, createdAt: now))
        nextNutritionId += 1
        saveDebounced()
    }

    /// Logs one or more servings of an ingredient. Use servings > 1 for multi-serving (e.g. 2 eggs).
    func addNutritionEntryFromIngredient(ingredientId: Int64, quantityText: String?, servings: Double = 1) {
        guard let ing = ingredient(byId: ingredientId), servings > 0 else { return }
        let calPer = ing.caloriesPerServing ?? 0
        let protPer = ing.proteinPerServing ?? 0
        let carbsPer = ing.carbsPerServing
        let fatsPer = ing.fatsPerServing
        let cal = max(0, Int((Double(calPer) * servings).rounded()))
        let prot = max(0, Int((Double(protPer) * servings).rounded()))
        let carbs = carbsPer.map { max(0, Int((Double($0) * servings).rounded())) }
        let fats = fatsPer.map { max(0, Int((Double($0) * servings).rounded())) }
        let todayStart = Int64(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 * 1000)
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        nutritionEntries.append(DailyNutritionEntry(id: nextNutritionId, date: todayStart, entryType: "ingredient", ingredientId: ingredientId, quantityText: quantityText, calories: cal, protein: prot, carbs: carbs, fats: fats, createdAt: now))
        nextNutritionId += 1
        saveDebounced()
    }

    /// Logs a recipe's nutrition to today (e.g. meal prepped and eaten without cooking mode).
    func addNutritionEntryFromRecipe(recipeId: Int64, recipeName: String, calories: Int, protein: Int) {
        let todayStart = Int64(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 * 1000)
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        nutritionEntries.append(DailyNutritionEntry(id: nextNutritionId, date: todayStart, entryType: "recipe", ingredientId: nil, quantityText: recipeName, calories: calories, protein: protein, carbs: nil, fats: nil, createdAt: now))
        nextNutritionId += 1
        saveDebounced()
    }

    /// Logs a custom meal with optional servings (e.g. 1.5x). Entry shows meal name.
    func addNutritionEntryFromCustomMeal(mealId: Int64, servings: Double = 1) {
        guard let meal = customMeal(byId: mealId), servings > 0 else { return }
        let cal = max(0, Int((Double(meal.calories) * servings).rounded()))
        let prot = max(0, Int((Double(meal.protein) * servings).rounded()))
        let todayStart = Int64(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 * 1000)
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        nutritionEntries.append(DailyNutritionEntry(id: nextNutritionId, date: todayStart, entryType: "custom", ingredientId: nil, quantityText: meal.name, calories: cal, protein: prot, carbs: nil, fats: nil, createdAt: now))
        nextNutritionId += 1
        saveDebounced()
    }

    func customMeal(byId id: Int64) -> CustomMeal? {
        customMeals.first { $0.id == id }
    }

    static let maxCustomMeals = 50

    func addCustomMeal(name: String, calories: Int, protein: Int) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, calories > 0, customMeals.count < Self.maxCustomMeals else { return false }
        let meal = CustomMeal(id: nextCustomMealId, name: trimmed, calories: calories, protein: max(0, protein))
        nextCustomMealId += 1
        customMeals.append(meal)
        saveDebounced()
        return true
    }

    func updateCustomMeal(id: Int64, name: String, calories: Int, protein: Int) {
        guard let i = customMeals.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, calories > 0 else { return }
        customMeals[i].name = trimmed
        customMeals[i].calories = calories
        customMeals[i].protein = max(0, protein)
        saveDebounced()
    }

    func deleteCustomMeal(id: Int64) {
        customMeals.removeAll { $0.id == id }
        saveDebounced()
    }

    func deleteNutritionEntry(id: Int64) {
        nutritionEntries.removeAll { $0.id == id }
        saveDebounced()
    }

    func updateNutritionEntry(id: Int64, calories: Int, protein: Int?, carbs: Int?, fats: Int?) {
        guard let i = nutritionEntries.firstIndex(where: { $0.id == id }) else { return }
        nutritionEntries[i].calories = calories
        nutritionEntries[i].protein = protein
        nutritionEntries[i].carbs = carbs
        nutritionEntries[i].fats = fats
        saveDebounced()
    }

    var recentHistoryItems: [(recipeId: Int64, recipeName: String, cookedAt: Int64)] {
        recipeHistory
            .sorted { $0.cookedAt > $1.cookedAt }
            .prefix(10)
            .compactMap { item in
                recipe(byId: item.recipeId).map { (item.recipeId, $0.name, item.cookedAt) }
            }
    }

    func addToRecipeHistory(recipeId: Int64) {
        recipeHistory.append(RecipeHistoryItem(recipeId: recipeId, cookedAt: Int64(Date().timeIntervalSince1970 * 1000)))
        saveDebounced()
    }

    func toggleFavorite(recipeId: Int64) {
        if favoriteRecipeIds.contains(recipeId) {
            favoriteRecipeIds.remove(recipeId)
        } else {
            favoriteRecipeIds.insert(recipeId)
        }
        saveDebounced()
    }

    func isFavorite(recipeId: Int64) -> Bool {
        favoriteRecipeIds.contains(recipeId)
    }

    private func dayNameForToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }

    // Groceries
    func addGroceryItem(ingredientId: Int64, quantityText: String?, category: String, source: String = "manual") {
        let item = GroceryItem(id: nextGroceryId, ingredientId: ingredientId, quantityText: quantityText, source: source, isChecked: false, category: category, sharedListId: nil)
        nextGroceryId += 1
        groceryItems.append(item)
        saveDebounced()
    }

    /// Generate grocery list from current meal plan. Returns (success, message).
    func generateGroceryListFromPlan() -> (success: Bool, message: String) {
        guard let plan = currentPlan else {
            return (false, "No meal plan found. Create a meal plan by adding recipes to your week.")
        }
        let pantryIds = Set(pantryItems.map(\.ingredientId))
        let existingGroceryIds = Set(groceryItems.map(\.ingredientId))

        print("[DEBUG] Starting grocery generation")
        print("[DEBUG] Pantry items: \(pantryItems.count), IDs: \(pantryIds)")
        print("[DEBUG] Existing grocery items: \(groceryItems.count), IDs: \(existingGroceryIds)")
        let ingredientMap = Dictionary(uniqueKeysWithValues: ingredients.map { ($0.id, $0) })
        let diets = dietPreferences
        let allergies = allergies

        var needed: [(ingredientId: Int64, qtyText: String?, category: String)] = []
        var addedIngredientIds: Set<Int64> = []
        var recipeCount = 0

        for day in plan.days {
            let recipeIds = [day.breakfastId, day.lunchId, day.dinnerId, day.snackId].compactMap { $0 }
            for recipeId in recipeIds {
                guard let recipe = recipe(byId: recipeId) else { continue }
                recipeCount += 1
                print("[DEBUG] Recipe \(recipeId): \(recipe.name), ingredients: \(recipe.ingredients.count)")
                if !matchesDiet(recipe: recipe, diets: diets) {
                    print("[DEBUG]   - Skipped due to diet filter")
                    continue
                }
                if !excludesAllergens(recipe: recipe, ingredientMap: ingredientMap, allergies: allergies) {
                    print("[DEBUG]   - Skipped due to allergen filter")
                    continue
                }
                for ing in recipe.ingredients where !ing.optional {
                    if pantryIds.contains(ing.ingredientId) { continue }
                    if existingGroceryIds.contains(ing.ingredientId) { continue }
                    if addedIngredientIds.contains(ing.ingredientId) { continue }
                    addedIngredientIds.insert(ing.ingredientId)
                    let category = ingredientMap[ing.ingredientId]?.category ?? "Misc"
                    needed.append((ing.ingredientId, ing.qtyText, category))
                }
            }
        }

        print("[DEBUG] Recipes found: \(recipeCount), needed ingredients: \(needed.count)")
        print("[DEBUG] Needed: \(needed.map(\.ingredientId))")

        if needed.isEmpty {
            if recipeCount == 0 {
                return (false, "No recipes in meal plan. Add recipes first!")
            }
            print("[DEBUG] All ingredients already accounted for - pantry: \(pantryIds.count), grocery: \(existingGroceryIds.count)")
            return (false, "All ingredients are already in your pantry or grocery list!")
        }

        print("[DEBUG] Before adding items: groceryItems.count = \(groceryItems.count)")
        for item in needed {
            let newItem = GroceryItem(id: nextGroceryId, ingredientId: item.ingredientId, quantityText: item.qtyText, source: "planner", isChecked: false, category: item.category, sharedListId: nil)
            nextGroceryId += 1
            groceryItems.append(newItem)
            print("[DEBUG] Added item: \(item.ingredientId), total now: \(groceryItems.count)")
        }
        print("[DEBUG] Before saveNow: groceryItems.count = \(groceryItems.count)")
        saveNow()
        print("[DEBUG] After saveNow: groceryItems.count = \(groceryItems.count)")
        let count = needed.count
        let finalCount = groceryItems.count
        print("[DEBUG] Returning success: Added \(count), Final count: \(finalCount)")
        return (true, "✅ Added \(count) items! Total in list: \(finalCount)")
    }

    private func matchesDiet(recipe: Recipe, diets: [String]) -> Bool {
        if diets.isEmpty { return true }
        let recipeTags = recipe.tags.map { $0.lowercased() }
        return diets.contains { recipeTags.contains($0.lowercased()) }
    }

    private func excludesAllergens(recipe: Recipe, ingredientMap: [Int64: Ingredient], allergies: [String]) -> Bool {
        Self.recipeExcludesAllergens(recipe: recipe, ingredientMap: ingredientMap, allergies: allergies)
    }

    /// Used by generateGroceryListFromPlan and by tests. Returns true when the recipe has no ingredients matching any allergy.
    nonisolated static func recipeExcludesAllergens(recipe: Recipe, ingredientMap: [Int64: Ingredient], allergies: [String]) -> Bool {
        if allergies.isEmpty { return true }
        let allergyPatterns = allergies.flatMap { a -> [String] in
            let lower = a.lowercased()
            var patterns = [lower]
            if lower.count > 1, lower.hasSuffix("s") {
                patterns.append(String(lower.dropLast()))
            }
            return patterns
        }
        for ing in recipe.ingredients {
            guard let ingredient = ingredientMap[ing.ingredientId] else { continue }
            let name = ingredient.canonicalName.lowercased()
            for pattern in allergyPatterns where !pattern.isEmpty {
                if name.contains(pattern) { return false }
            }
        }
        return true
    }

    func toggleGroceryChecked(id: Int64) {
        if let i = groceryItems.firstIndex(where: { $0.id == id }) {
            groceryItems[i].isChecked.toggle()
        }
        saveDebounced()
    }

    func deleteGroceryItem(id: Int64) {
        groceryItems.removeAll { $0.id == id }
        saveDebounced()
    }

    func addItemsToPantry(_ items: [(Int64, String, Int64?)]) {
        for (ingredientId, qty, expiryDate) in items {
            if pantryItems.contains(where: { $0.ingredientId == ingredientId }) {
                if let i = pantryItems.firstIndex(where: { $0.ingredientId == ingredientId }) {
                    pantryItems[i].quantityText = qty.isEmpty ? pantryItems[i].quantityText : qty
                    pantryItems[i].expiryDate = expiryDate
                }
            } else {
                pantryItems.append(PantryItem(ingredientId: ingredientId, quantityText: qty.isEmpty ? nil : qty, expiryDate: expiryDate))
            }
        }
        saveDebounced()
    }

    func deletePantryItem(ingredientId: Int64) {
        pantryItems.removeAll { $0.ingredientId == ingredientId }
        saveDebounced()
    }

    func updatePantryQuantity(ingredientId: Int64, quantityText: String?) {
        guard let i = pantryItems.firstIndex(where: { $0.ingredientId == ingredientId }) else { return }
        pantryItems[i].quantityText = quantityText?.isEmpty == true ? nil : quantityText
        saveDebounced()
    }

    /// Move all checked grocery items to pantry, then remove them from the list.
    func moveCheckedItemsToPantry() {
        let checked = groceryItems.filter(\.isChecked)
        for item in checked {
            addItemsToPantry([(item.ingredientId, item.quantityText ?? "", nil)])
        }
        groceryItems.removeAll(where: \.isChecked)
        saveDebounced()
    }

    func addItemsToGroceryList(_ items: [(Int64, String)]) {
        for (ingredientId, qty) in items {
            let category = ingredient(byId: ingredientId)?.category ?? "Other"
            addGroceryItem(ingredientId: ingredientId, quantityText: qty.isEmpty ? nil : qty, category: category)
        }
        saveDebounced()
    }

    func addToMealPrep(recipeId: Int64) {
        if !mealPrepRecipeIds.contains(recipeId) { mealPrepRecipeIds.append(recipeId) }
        saveDebounced()
    }

    func removeFromMealPrep(recipeId: Int64) {
        mealPrepRecipeIds.removeAll { $0 == recipeId }
        saveDebounced()
    }

    func completeOnboarding() {
        onboardingCompleted = true
        saveNow()
    }

    func setAllergies(_ list: [String]) {
        allergies = list.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        saveDebounced()
    }

    func setDietPreferences(_ list: [String]) {
        dietPreferences = list.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }.filter { !$0.isEmpty }
        saveDebounced()
    }

    func setHealthGoals(_ list: [String]) {
        healthGoals = list.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        saveDebounced()
    }

    func addCollection(name: String) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let id = nextCollectionId
        nextCollectionId += 1
        recipeCollections.append(RecipeCollection(id: id, name: name, recipeIds: []))
        saveDebounced()
    }

    func deleteCollection(id: Int64) {
        recipeCollections.removeAll { $0.id == id }
        saveDebounced()
    }

    func updateCollection(id: Int64, name: String) {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, let i = recipeCollections.firstIndex(where: { $0.id == id }) else { return }
        recipeCollections[i].name = name
        saveDebounced()
    }

    func addRecipeToCollection(recipeId: Int64, collectionId: Int64) {
        guard let i = recipeCollections.firstIndex(where: { $0.id == collectionId }) else { return }
        if !recipeCollections[i].recipeIds.contains(recipeId) {
            recipeCollections[i].recipeIds.append(recipeId)
            saveDebounced()
        }
    }

    func removeRecipeFromCollection(recipeId: Int64, collectionId: Int64) {
        guard let i = recipeCollections.firstIndex(where: { $0.id == collectionId }) else { return }
        recipeCollections[i].recipeIds.removeAll { $0 == recipeId }
        saveDebounced()
    }

    func collection(byId id: Int64) -> RecipeCollection? {
        recipeCollections.first { $0.id == id }
    }

    func recipes(in collectionId: Int64) -> [Recipe] {
        guard let col = collection(byId: collectionId) else { return [] }
        return col.recipeIds.compactMap { recipe(byId: $0) }
    }

    func collectionIds(containing recipeId: Int64) -> [Int64] {
        recipeCollections.filter { $0.recipeIds.contains(recipeId) }.map(\.id)
    }

    func addRecentRecipeSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return }
        recentRecipeSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        recentRecipeSearches.insert(trimmed, at: 0)
        if recentRecipeSearches.count > 10 { recentRecipeSearches = Array(recentRecipeSearches.prefix(10)) }
        saveDebounced()
    }

    /// Available meal plan templates (from SeedData).
    var mealPlanTemplates: [MealPlanTemplate] { SeedData.mealPlanTemplates }

    /// Apply a template to the current plan. Replaces the week with the template's meals.
    func applyTemplate(_ template: MealPlanTemplate) {
        let plannedDays: [PlannedDay] = template.meals.map { td in
            let ids = [td.breakfastId, td.lunchId, td.dinnerId, td.snackId].compactMap { $0 }
            let calories = ids.compactMap { recipe(byId: $0)?.calories }.reduce(0, +)
            let protein = ids.compactMap { recipe(byId: $0)?.protein }.reduce(0, +)
            return PlannedDay(
                dayOfWeek: td.dayOfWeek,
                breakfastId: td.breakfastId,
                lunchId: td.lunchId,
                dinnerId: td.dinnerId,
                snackId: td.snackId,
                caloriesTotal: calories,
                proteinTotal: protein
            )
        }
        currentPlan = MealPlanInstance(
            id: currentPlan?.id ?? 1,
            weekStart: Int64(Date().timeIntervalSince1970 * 1000),
            templateId: template.id,
            days: plannedDays
        )
        saveDebounced()
    }

    /// Set or clear a meal slot. mealType: "breakfast", "lunch", "dinner", "snack". recipeId: nil to clear.
    func setPlanSlot(dayOfWeek: String, mealType: String, recipeId: Int64?) {
        guard var plan = currentPlan,
              let dayIndex = plan.days.firstIndex(where: { $0.dayOfWeek == dayOfWeek }) else { return }
        var day = plan.days[dayIndex]
        switch mealType {
        case "breakfast": day.breakfastId = recipeId
        case "lunch": day.lunchId = recipeId
        case "dinner": day.dinnerId = recipeId
        case "snack": day.snackId = recipeId
        default: return
        }
        let ids = [day.breakfastId, day.lunchId, day.dinnerId, day.snackId].compactMap { $0 }
        day.caloriesTotal = ids.compactMap { recipe(byId: $0)?.calories }.reduce(0, +)
        day.proteinTotal = ids.compactMap { recipe(byId: $0)?.protein }.reduce(0, +)
        plan.days[dayIndex] = day
        currentPlan = plan
        saveDebounced()
    }

    func setPendingTimerToAdd(label: String, minutes: Int) {
        pendingTimerToAdd = PendingTimer(label: label, minutes: minutes)
    }

    func clearPendingTimerToAdd() {
        pendingTimerToAdd = nil
    }

    /// Restore from backup (replaces user data)
    func restore(from backup: BackupData) {
        pantryItems = backup.pantry
        groceryItems = backup.grocery
        favoriteRecipeIds = Set(backup.favoriteRecipeIds)
        mealPrepRecipeIds = backup.mealPrepRecipeIds
        nutritionEntries = backup.nutritionEntries
        recipeHistory = backup.recipeHistory
        recipeNotes = Dictionary(uniqueKeysWithValues: (backup.recipeNotes ?? []).map { ($0.recipeId, $0.note) })
        recipeRatings = Dictionary(uniqueKeysWithValues: (backup.recipeRatings ?? []).map { ($0.recipeId, $0.rating) })
        recentRecipeSearches = backup.recentRecipeSearches ?? []
        allergies = backup.allergies ?? []
        dietPreferences = backup.dietPreferences ?? []
        healthGoals = backup.healthGoals ?? []
        recipeCollections = (backup.recipeCollections ?? []).map { RecipeCollection(id: $0.id, name: $0.name, recipeIds: $0.recipeIds) }
        nextCollectionId = (recipeCollections.map(\.id).max() ?? 0) + 1
        customMeals = backup.customMeals ?? []
        nextCustomMealId = (customMeals.map(\.id).max() ?? 0) + 1
        nextGroceryId = (groceryItems.map(\.id).max() ?? Int64(0)) + 1
        nextNutritionId = (nutritionEntries.map(\.id).max() ?? Int64(0)) + 1
        saveNow()
    }

    /// Merge backup into existing data (append lists, union sets, merge notes/ratings).
    func merge(from backup: BackupData) {
        let maxGroceryId = groceryItems.map(\.id).max() ?? 0
        let maxNutritionId = nutritionEntries.map(\.id).max() ?? 0
        var nextGrocery = maxGroceryId + 1
        var nextNutrition = maxNutritionId + 1
        for item in backup.grocery {
            groceryItems.append(GroceryItem(id: nextGrocery, ingredientId: item.ingredientId, quantityText: item.quantityText, source: item.source, isChecked: item.isChecked, category: item.category, sharedListId: item.sharedListId))
            nextGrocery += 1
        }
        for item in backup.pantry {
            if !pantryItems.contains(where: { $0.ingredientId == item.ingredientId }) {
                pantryItems.append(item)
            }
        }
        favoriteRecipeIds.formUnion(backup.favoriteRecipeIds)
        for id in backup.mealPrepRecipeIds where !mealPrepRecipeIds.contains(id) {
            mealPrepRecipeIds.append(id)
        }
        for entry in backup.nutritionEntries {
            nutritionEntries.append(DailyNutritionEntry(id: nextNutrition, date: entry.date, entryType: entry.entryType, ingredientId: entry.ingredientId, quantityText: entry.quantityText, calories: entry.calories, protein: entry.protein, carbs: entry.carbs, fats: entry.fats, createdAt: entry.createdAt))
            nextNutrition += 1
        }
        recipeHistory.append(contentsOf: backup.recipeHistory)
        recipeHistory.sort { $0.cookedAt > $1.cookedAt }
        for note in backup.recipeNotes ?? [] {
            if recipeNotes[note.recipeId] == nil { recipeNotes[note.recipeId] = note.note }
        }
        for rating in backup.recipeRatings ?? [] {
            if recipeRatings[rating.recipeId] == nil { recipeRatings[rating.recipeId] = rating.rating }
        }
        var seenSearch = Set<String>()
        var mergedSearches: [String] = []
        for s in recentRecipeSearches + (backup.recentRecipeSearches ?? []) {
            if !seenSearch.contains(s) { seenSearch.insert(s); mergedSearches.append(s) }
        }
        recentRecipeSearches = Array(mergedSearches.prefix(10))
        for col in backup.recipeCollections ?? [] {
            recipeCollections.append(RecipeCollection(id: nextCollectionId, name: col.name, recipeIds: col.recipeIds))
            nextCollectionId += 1
        }
        for meal in backup.customMeals ?? [] where customMeals.count < Self.maxCustomMeals {
            customMeals.append(CustomMeal(id: nextCustomMealId, name: meal.name, calories: meal.calories, protein: meal.protein))
            nextCustomMealId += 1
        }
        nextGroceryId = nextGrocery
        nextNutritionId = nextNutrition
        saveNow()
    }

    /// Import recipe catalog (ingredients + recipes) from Android export. Replaces current catalog and persists.
    func importCatalog(ingredients: [Ingredient], recipes: [Recipe]) {
        self.ingredients = ingredients
        self.recipes = recipes
        saveNow()
    }
}
