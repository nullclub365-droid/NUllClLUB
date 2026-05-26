//
//  MealPrepScreen.swift
//  SmartCart
//

import SwiftUI

struct MealPrepScreen: View {
    @EnvironmentObject var store: AppStore
    var onRecipeSelected: (Int64) -> Void
    var onStartCooking: (Int64) -> Void
    var onBack: () -> Void

    @State private var showAddRecipe = false
    @State private var batchMultiplier: [Int64: Int] = [:]
    @State private var addRecipeSearch = ""

    /// Recipes in meal prep, sorted by cook time (longest first) for suggested prep order.
    private var mealPrepRecipes: [Recipe] {
        store.mealPrepRecipeIds
            .compactMap { store.recipe(byId: $0) }
            .sorted { $0.readyInMinutes > $1.readyInMinutes }
    }

    private var totalCalories: Int {
        mealPrepRecipes.reduce(0) { sum, r in
            sum + r.calories * (batchMultiplier[r.id] ?? 1)
        }
    }

    private var totalProtein: Int {
        mealPrepRecipes.reduce(0) { sum, r in
            sum + (r.protein * (batchMultiplier[r.id] ?? 1))
        }
    }

    private var totalCookTimeMinutes: Int {
        mealPrepRecipes.reduce(0) { $0 + $1.readyInMinutes }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if mealPrepRecipes.isEmpty {
                    emptyState
                } else {
                    batchSummaryCard
                    logBatchSection
                    suggestedOrderSection
                }
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Meal Prep")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddRecipe = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.primary)
                }
                .accessibilityLabel("Add recipe to meal prep")
            }
        }
        .sheet(isPresented: $showAddRecipe) {
            addRecipeSheet
        }
    }

    private var batchSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.primary.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: "list.bullet.clipboard")
                        .font(.title2)
                        .foregroundStyle(AppTheme.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("This batch")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Text("\(mealPrepRecipes.count) recipes · ~\(totalCookTimeMinutes) min")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
            }
            HStack(spacing: 0) {
                batchStat(value: totalCalories, label: "kcal", icon: "flame.fill")
                Rectangle()
                    .fill(AppTheme.outline.opacity(0.3))
                    .frame(width: 1, height: 36)
                batchStat(value: totalProtein, label: "protein", icon: "fork.knife")
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(AppTheme.surface.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.primaryContainer.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func batchStat(value: Int, label: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppTheme.primary)
            Text("\(value)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.onSurface)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }

    private var logBatchSection: some View {
        Button(action: logBatchToToday) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                Text("Log batch to today")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            .foregroundStyle(AppTheme.onSurface)
            .padding(16)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Log batch to today")
        .accessibilityHint("Adds all recipes in this batch to today’s food log")
    }

    private var suggestedOrderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primary)
                Text("Suggested prep order (longest first)")
                    .font(.headline)
                    .foregroundStyle(AppTheme.onSurface)
            }
            Text("Start with the longest cook time so everything finishes around the same time.")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)

            ForEach(Array(mealPrepRecipes.enumerated()), id: \.element.id) { index, recipe in
                MealPrepRecipeRow(
                    orderNumber: index + 1,
                    recipe: recipe,
                    multiplier: Binding(
                        get: { batchMultiplier[recipe.id] ?? 1 },
                        set: { newVal in
                            var copy = batchMultiplier
                            copy[recipe.id] = newVal
                            batchMultiplier = copy
                        }
                    ),
                    onTap: { onRecipeSelected(recipe.id) },
                    onStartCooking: { onStartCooking(recipe.id) },
                    onRemove: { store.removeFromMealPrep(recipeId: recipe.id) }
                )
            }
        }
    }

    private func logBatchToToday() {
        for recipe in mealPrepRecipes {
            let mult = batchMultiplier[recipe.id] ?? 1
            store.addNutritionEntryFromRecipe(
                recipeId: recipe.id,
                recipeName: recipe.name,
                calories: recipe.calories * mult,
                protein: recipe.protein * mult
            )
        }
        AccessibilitySettings.announce("Batch logged to today")
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "fork.knife.circle",
            title: "No recipes in meal prep",
            message: "Tap + to add recipes you want to prep or cook in batch. You’ll see total calories and time, suggested order, and can log the whole batch to today.",
            actionTitle: "Add recipe",
            action: { showAddRecipe = true }
        )
    }

    private var addRecipeSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField("Search recipes", text: $addRecipeSearch)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(AppTheme.surface.opacity(0.5))
                List(store.recipes.filter {
                    let inPrep = store.mealPrepRecipeIds.contains($0.id)
                    guard !inPrep else { return false }
                    if addRecipeSearch.isEmpty { return true }
                    let q = addRecipeSearch.lowercased()
                    return $0.name.lowercased().contains(q) ||
                        $0.tags.contains { $0.lowercased().contains(q) }
                }) { recipe in
                    Button(action: {
                        store.addToMealPrep(recipeId: recipe.id)
                        showAddRecipe = false
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(recipe.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(AppTheme.onSurface)
                                Text("\(recipe.calories) kcal · \(recipe.readyInMinutes) min")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                            }
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(AppTheme.primary)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Add recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showAddRecipe = false }
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}

private struct MealPrepRecipeRow: View {
    let orderNumber: Int
    let recipe: Recipe
    @Binding var multiplier: Int
    let onTap: () -> Void
    let onStartCooking: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("\(orderNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(AppTheme.primary)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("\(recipe.calories * multiplier) kcal · \(recipe.protein * multiplier)g protein · \(recipe.readyInMinutes) min")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
                HStack(spacing: 8) {
                    Stepper("×\(multiplier)", value: $multiplier, in: 1...20)
                        .labelsHidden()
                    Text("×\(multiplier)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .frame(minWidth: 28, alignment: .trailing)
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.body)
                            .foregroundStyle(.red)
                    }
                }
            }
            HStack(spacing: 10) {
                Button(action: onTap) {
                    Text("View recipe")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.primary)
                }
                Button(action: onStartCooking) {
                    Label("Start cooking", systemImage: "play.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        MealPrepScreen(onRecipeSelected: { _ in }, onStartCooking: { _ in }, onBack: {})
            .environmentObject(AppStore())
    }
}
