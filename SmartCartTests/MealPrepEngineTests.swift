//
//  MealPrepEngineTests.swift
//  SmartCartTests
//
//  Unit tests for the meal-prep planning engine, quantity scaler, and session persistence.
//

import Testing
import Foundation
@testable import SmartCart

private func makeRecipe(
    id: Int64,
    name: String,
    steps: [RecipeStep],
    ingredients: [RecipeIngredient] = [],
    calories: Int = 500,
    protein: Int = 30
) -> Recipe {
    Recipe(
        id: id,
        name: name,
        description: "",
        calories: calories,
        protein: protein,
        tags: [],
        steps: steps,
        ingredients: ingredients,
        readyInMinutes: 20,
        difficulty: "Easy"
    )
}

private func group(_ recipe: Recipe, days: [String]) -> BatchCookGroup {
    BatchCookGroup(
        recipe: recipe,
        appearances: days.map { (day: $0, mealType: "Dinner") },
        isSelected: true
    )
}

// MARK: - QtyScaler

struct QtyScalerTests {
    @Test func scalesWholeNumbersAndUnits() {
        #expect(QtyScaler.scale("250 g", by: 2) == "500 g")
        #expect(QtyScaler.scale("2 breasts", by: 2) == "4 breasts")
    }

    @Test func scalesSlashFraction() {
        #expect(QtyScaler.scale("1/2 cup", by: 2) == "1 cup")
    }

    @Test func scalesUnicodeFraction() {
        #expect(QtyScaler.scale("½ cup", by: 2) == "1 cup")
    }

    @Test func scalesRanges() {
        #expect(QtyScaler.scale("2-3 cloves", by: 2) == "4–6 cloves")
    }

    @Test func leavesVagueAmountsUntouched() {
        #expect(QtyScaler.scale("salt to taste", by: 3) == "salt to taste")
        #expect(QtyScaler.scale("a pinch", by: 4) == "a pinch")
    }

    @Test func multiplierOfOneIsIdentity() {
        #expect(QtyScaler.scale("250 g", by: 1) == "250 g")
    }

    @Test func combinesMatchingUnits() {
        #expect(QtyScaler.combine(["500 g", "250 g"]) == "750 g")
        #expect(QtyScaler.combine(["2 breasts", "4 breasts"]) == "6 breasts")
        #expect(QtyScaler.combine(["1 cup", "½ cup"]) == "1.5 cup")
    }

    @Test func refusesToCombineMismatchedUnits() {
        #expect(QtyScaler.combine(["500 g", "2 breasts"]) == nil)
        #expect(QtyScaler.combine(["to taste", "1 tsp"]) == nil)
    }
}

// MARK: - SessionTimer math

struct SessionTimerTests {
    @Test func remainingCountsDownFromEndEpoch() {
        let t = SessionTimer(id: "a", label: "x", totalSeconds: 600, endEpoch: Date().timeIntervalSince1970 + 300)
        #expect(t.remainingSeconds >= 299 && t.remainingSeconds <= 300)
        #expect(t.isFinished == false)
        #expect(t.progress > 0.49 && t.progress < 0.51)
    }

    @Test func finishedWhenPastEnd() {
        let t = SessionTimer(id: "a", label: "x", totalSeconds: 600, endEpoch: Date().timeIntervalSince1970 - 5)
        #expect(t.remainingSeconds == 0)
        #expect(t.isFinished)
        #expect(t.progress == 1)
    }

    @Test func pausedFreezesRemainingAndIsNotFinished() {
        let t = SessionTimer(id: "a", label: "x", totalSeconds: 600, endEpoch: Date().timeIntervalSince1970 - 100, pausedRemaining: 120)
        #expect(t.remainingSeconds == 120)   // frozen, ignores the elapsed wall clock
        #expect(t.isPaused)
        #expect(t.isFinished == false)
    }

    @Test func customTimerIdentified() {
        let t = SessionTimer(id: "custom-123", label: "Rest", totalSeconds: 300, endEpoch: 0)
        #expect(t.isCustom)
    }

    @Test func timeStringFormats() {
        let t = SessionTimer(id: "a", label: "x", totalSeconds: 600, endEpoch: Date().timeIntervalSince1970 + 65)
        #expect(t.timeString == "1:05" || t.timeString == "1:04")
    }
}

// MARK: - Planner

struct MealPrepPlannerTests {
    @Test func classifiesStepsIntoPhases() {
        let r = makeRecipe(id: 1, name: "Test", steps: [
            RecipeStep(title: "Prep", description: "Chop veg.", durationSeconds: 120),
            RecipeStep(title: "Boil", description: "Boil water.", durationSeconds: 600),
            RecipeStep(title: "Sear", description: "Sear chicken.", durationSeconds: 300),
            RecipeStep(title: "Assemble", description: "Plate it.", durationSeconds: 60)
        ])
        let plan = MealPrepPlanner.build(from: [group(r, days: ["Monday"])])
        #expect((plan.tasks[.prep] ?? []).contains { $0.title == "Prep" })
        #expect((plan.tasks[.slowCook] ?? []).contains { $0.title == "Boil" })
        #expect((plan.tasks[.activeCook] ?? []).contains { $0.title == "Sear" })
        #expect((plan.tasks[.assemble] ?? []).contains { $0.title == "Assemble" })
    }

    @Test func filtersNoCookDishes() {
        let oats = makeRecipe(id: 2, name: "Overnight Oats", steps: [
            RecipeStep(title: "Mix", description: "Combine oats and milk.", durationSeconds: 60)
        ])
        let plan = MealPrepPlanner.build(from: [group(oats, days: ["Monday"])])
        #expect(plan.noCookItems.contains("Overnight Oats"))
        #expect(plan.storage.isEmpty)              // no-cook dishes aren't part of the cook/storage flow
        #expect((plan.tasks[.prep] ?? []).isEmpty)
    }

    @Test func marinadeSortsFirstInPrep() {
        let r = makeRecipe(id: 3, name: "Beef", steps: [
            RecipeStep(title: "Season", description: "Salt the beef.", durationSeconds: 60),
            RecipeStep(title: "Marinate", description: "Marinate in soy.", durationSeconds: 1800)
        ])
        let plan = MealPrepPlanner.build(from: [group(r, days: ["Monday"])])
        #expect(plan.tasks[.prep]?.first?.title == "Marinate")
    }

    @Test func emitsTechniqueHintForSharedPasta() {
        let a = makeRecipe(id: 4, name: "Chicken Pasta", steps: [
            RecipeStep(title: "Boil", description: "Cook pasta.", durationSeconds: 600)
        ])
        let b = makeRecipe(id: 5, name: "Veggie Pasta", steps: [
            RecipeStep(title: "Boil", description: "Cook pasta.", durationSeconds: 600)
        ])
        let plan = MealPrepPlanner.build(from: [group(a, days: ["Monday"]), group(b, days: ["Tuesday"])])
        #expect(plan.mergeHints.contains { $0.contains("Chicken Pasta") && $0.contains("Veggie Pasta") })
    }

    @Test func carriesPerPortionMacros() {
        let r = makeRecipe(id: 6, name: "Steak", steps: [
            RecipeStep(title: "Sear", description: "Sear it.", durationSeconds: 300)
        ], calories: 650, protein: 45)
        let plan = MealPrepPlanner.build(from: [group(r, days: ["Monday", "Wednesday"])])
        let storage = plan.storage.first
        #expect(storage?.caloriesPerPortion == 650)
        #expect(storage?.proteinPerPortion == 45)
        #expect(storage?.portionCount == 2)        // two appearances -> two portions
    }

    @Test func recipeStepOrderStaysMonotonic() {
        // A recipe whose steps would otherwise jump backwards in phase order.
        let r = makeRecipe(id: 7, name: "Odd", steps: [
            RecipeStep(title: "Sear", description: "Sear first.", durationSeconds: 120),
            RecipeStep(title: "Season", description: "Then season.", durationSeconds: 30) // prep, but comes after active
        ])
        let plan = MealPrepPlanner.build(from: [group(r, days: ["Monday"])])
        // "Season" must not have been pulled into an earlier phase than "Sear".
        #expect((plan.tasks[.prep] ?? []).contains { $0.title == "Season" } == false)
    }
}

// MARK: - Persistence

// Serialized: these tests share one UserDefaults key, so they must not run in parallel.
@Suite(.serialized)
struct MealPrepPersistenceTests {
    @Test func savesAndLoadsSession() {
        let session = SavedMealPrepSession(
            templateId: 200,
            selectedRecipeIds: [1, 2, 3],
            phaseIndex: 2,
            completedTaskIds: ["1#0", "2#1"],
            timers: [SavedTimer(taskId: "1#0", label: "Pasta", totalSeconds: 600, endEpoch: Date().timeIntervalSince1970 + 600, stopped: false, pausedRemaining: nil)],
            savedAtEpoch: Date().timeIntervalSince1970
        )
        MealPrepSessionStore.save(session)
        defer { MealPrepSessionStore.clear() }

        let loaded = MealPrepSessionStore.load()
        #expect(loaded?.templateId == 200)
        #expect(loaded?.selectedRecipeIds == [1, 2, 3])
        #expect(loaded?.phaseIndex == 2)
        #expect(loaded?.completedTaskIds.sorted() == ["1#0", "2#1"])
        #expect(loaded?.timers.first?.taskId == "1#0")
    }

    @Test func clearRemovesSession() {
        let session = SavedMealPrepSession(
            templateId: 1, selectedRecipeIds: [1], phaseIndex: 0,
            completedTaskIds: [], timers: [], savedAtEpoch: Date().timeIntervalSince1970
        )
        MealPrepSessionStore.save(session)
        MealPrepSessionStore.clear()
        #expect(MealPrepSessionStore.load() == nil)
    }

    @Test func ignoresStaleSessionsPastWindow() {
        let stale = SavedMealPrepSession(
            templateId: 1, selectedRecipeIds: [1], phaseIndex: 0,
            completedTaskIds: [], timers: [],
            savedAtEpoch: Date().timeIntervalSince1970 - (MealPrepSessionStore.staleAfter + 3600) // past 7-day window
        )
        MealPrepSessionStore.save(stale)
        defer { MealPrepSessionStore.clear() }
        #expect(MealPrepSessionStore.load() == nil)
    }

    @Test func keepsRecentSessionWithinWindow() {
        // A cook spanning a couple of days must NOT be dropped (no silent data loss).
        let twoDaysOld = SavedMealPrepSession(
            templateId: 1, selectedRecipeIds: [1, 2], phaseIndex: 1,
            completedTaskIds: ["1#0"], timers: [],
            savedAtEpoch: Date().timeIntervalSince1970 - 2 * 86400
        )
        MealPrepSessionStore.save(twoDaysOld)
        defer { MealPrepSessionStore.clear() }
        #expect(MealPrepSessionStore.load()?.phaseIndex == 1)
    }
}
