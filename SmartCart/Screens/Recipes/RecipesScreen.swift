//
//  RecipesScreen.swift
//  SmartCart
//

import SwiftUI
import FirebaseAnalytics

struct RecipesScreen: View {
    @EnvironmentObject var store: AppStore
    @State private var searchText = ""
    @State private var difficultyFilter: String? = nil
    @State private var maxTimeFilter: Int? = nil
    @State private var selectedTag: String? = nil
    var onRecipeSelected: (Int64) -> Void

    private func handleRecipeSelected(_ recipeId: Int64) {
        // Track recipe view
        if let recipe = store.recipe(byId: recipeId) {
            AnalyticsHelper.trackFeatureUsed("recipe_browsing", details: [
                "recipe_id": recipeId,
                "recipe_name": recipe.name
            ])
        }
        onRecipeSelected(recipeId)
    }

    private static let difficulties = ["Easy", "Medium", "Hard"]
    private static let timeFilters = [15, 30, 45, 60]

    private var allTags: [String] {
        Array(Set(store.recipes.flatMap(\.tags))).sorted()
    }

    private var filteredRecipes: [Recipe] {
        var list = store.recipes
        if !searchText.isEmpty {
            list = list.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        if let d = difficultyFilter {
            list = list.filter { $0.difficulty == d }
        }
        if let t = maxTimeFilter {
            list = list.filter { $0.readyInMinutes <= t }
        }
        if let tag = selectedTag {
            list = list.filter { $0.tags.contains(tag) }
        }
        if !store.allergies.isEmpty {
            list = list.filter { recipe in
                !recipe.ingredients.contains { ing in
                    guard let ingredient = store.ingredient(byId: ing.ingredientId) else { return false }
                    let nameLower = ingredient.canonicalName.lowercased()
                    let aliasesLower = ingredient.aliases.map { $0.lowercased() }
                    return store.allergies.contains { allergy in
                        let a = allergy.lowercased()
                        return nameLower.contains(a) || aliasesLower.contains { $0.contains(a) }
                    }
                }
            }
        }
        return list
    }

    private var hasActiveFilters: Bool {
        !searchText.isEmpty || difficultyFilter != nil || maxTimeFilter != nil || selectedTag != nil
    }

    private var pantryIngredientIds: Set<Int64> {
        Set(store.pantryItems.map(\.ingredientId))
    }

    private func isRecipeReadyToCook(_ recipe: Recipe) -> Bool {
        let required = Set(recipe.ingredients.map(\.ingredientId))
        return required.isSubset(of: pantryIngredientIds)
    }

    private func clearFilters() {
        searchText = ""
        difficultyFilter = nil
        maxTimeFilter = nil
        selectedTag = nil
    }

    @ViewBuilder
    private var trendingSection: some View {
        Section("Trending This Week") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    trendingRecipeCard(3)
                    trendingRecipeCard(5)
                    trendingRecipeCard(7)
                    trendingRecipeCard(12)
                    trendingRecipeCard(15)
                }
                .padding(.vertical, 8)
            }
        }
        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
        .listRowBackground(Color.clear)
    }

    private func trendingRecipeCard(_ recipeId: Int64) -> some View {
        Group {
            if let recipe = store.recipe(byId: recipeId) {
                Button(action: {
                    handleRecipeSelected(recipeId)
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primary.opacity(0.2))
                            Image(systemName: "fork.knife")
                                .font(.system(size: 18))
                                .foregroundStyle(AppTheme.primary)
                        }
                        .frame(width: 40, height: 40)

                        Text(recipe.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.onSurface)
                            .lineLimit(2)
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("4.8")
                                .font(.caption2)
                        }
                        .foregroundStyle(AppTheme.secondary)
                    }
                    .frame(width: 110)
                    .padding(10)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    @ViewBuilder
    private var filtersSection: some View {
        Section {
            filterChips
        }
        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
        .listRowBackground(Color.clear)
    }

    private var recipesContentSection: some View {
        RecipesListContent(
            filteredRecipes: filteredRecipes,
            hasActiveFilters: hasActiveFilters,
            onClearFilters: clearFilters,
            isRecipeReadyToCook: isRecipeReadyToCook,
            store: store,
            onRecipeSelected: onRecipeSelected
        )
    }

    var body: some View {
        List {
            trendingSection
            filtersSection
            recipesContentSection
        }
        .searchable(text: $searchText, prompt: "Search recipes")
        .navigationTitle("Recipes")
        .background(AppTheme.background)
        .safeAreaInset(edge: .bottom, spacing: 0) { BannerAdView() }
        .refreshable {
            try? await Task.sleep(nanoseconds: 400_000_000)
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Self.difficulties, id: \.self) { d in
                    FilterChip(
                        label: d,
                        isSelected: difficultyFilter == d,
                        style: .difficulty
                    ) {
                        difficultyFilter = difficultyFilter == d ? nil : d
                    }
                }
                filterDivider
                ForEach(Self.timeFilters, id: \.self) { min in
                    FilterChip(
                        label: "≤\(min)m",
                        isSelected: maxTimeFilter == min,
                        style: .time
                    ) {
                        maxTimeFilter = maxTimeFilter == min ? nil : min
                    }
                }
                if !allTags.isEmpty {
                    filterDivider
                    ForEach(allTags.prefix(10), id: \.self) { tag in
                        FilterChip(
                            label: tag,
                            isSelected: selectedTag == tag,
                            style: .tag
                        ) {
                            selectedTag = selectedTag == tag ? nil : tag
                        }
                    }
                }
                if difficultyFilter != nil || maxTimeFilter != nil || selectedTag != nil {
                    filterDivider
                    FilterChip(label: "Clear all", isSelected: false, style: .tag) {
                        clearFilters()
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
        }
        .frame(height: 40)
    }

    private var filterDivider: some View {
        Rectangle()
            .fill(AppTheme.outline.opacity(0.5))
            .frame(width: 1, height: 20)
    }
}

private enum FilterChipStyle {
    case difficulty
    case time
    case tag
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    var style: FilterChipStyle = .tag
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : AppTheme.onSurfaceVariant)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? AppTheme.primary : AppTheme.surfaceVariant.opacity(0.8))
                )
        }
        .buttonStyle(.plain)
    }
}

private struct RecipesListContent: View {
    let filteredRecipes: [Recipe]
    let hasActiveFilters: Bool
    let onClearFilters: () -> Void
    let isRecipeReadyToCook: (Recipe) -> Bool
    @ObservedObject var store: AppStore
    let onRecipeSelected: (Int64) -> Void

    private var readyToCook: [Recipe] {
        filteredRecipes.filter { isRecipeReadyToCook($0) }
    }
    private var missingIngredients: [Recipe] {
        filteredRecipes.filter { !isRecipeReadyToCook($0) }
    }

    var body: some View {
        Group {
            if hasActiveFilters {
                Section {
                    Button("Clear filters") { onClearFilters() }
                        .foregroundStyle(AppTheme.primary)
                }
            }
            if !readyToCook.isEmpty {
                Section(header: Text("Ready to Cook")) {
                    ForEach(readyToCook, id: \.id) { recipe in
                        RecipeListRow(
                            recipe: recipe,
                            isFavorite: store.isFavorite(recipeId: recipe.id),
                            isReadyToCook: true,
                            onTap: { onRecipeSelected(recipe.id) },
                            onFavorite: { store.toggleFavorite(recipeId: recipe.id) }
                        )
                    }
                }
            }
            if !missingIngredients.isEmpty {
                Section(header: Text("Missing Ingredients")) {
                    ForEach(missingIngredients, id: \.id) { recipe in
                        RecipeListRow(
                            recipe: recipe,
                            isFavorite: store.isFavorite(recipeId: recipe.id),
                            isReadyToCook: false,
                            onTap: { onRecipeSelected(recipe.id) },
                            onFavorite: { store.toggleFavorite(recipeId: recipe.id) }
                        )
                    }
                }
            }
            if filteredRecipes.isEmpty {
                Section {
                    EmptyStateView(
                        icon: "fork.knife",
                        title: "No recipes found",
                        message: hasActiveFilters ? "Try adjusting your filters" : "Add ingredients to your pantry to see what you can cook"
                    )
                }
            }
        }
    }
}

private struct RecipeListRow: View {
    let recipe: Recipe
    let isFavorite: Bool
    let isReadyToCook: Bool
    let onTap: () -> Void
    let onFavorite: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: "https://raw.githubusercontent.com/nullclub365-droid/smartcart-assets/main/\(recipe.id).jpg")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .empty:
                        ProgressView()
                            .tint(AppTheme.primary)
                    case .failure:
                        Image(systemName: "photo.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.6))
                    @unknown default:
                        Image(systemName: "fork.knife")
                            .font(.title2)
                            .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.5))
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .background(AppTheme.surfaceVariant, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(recipe.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.onSurface)
                        if isReadyToCook {
                            Text("Ready to cook")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.primary)
                                .clipShape(Capsule())
                        }
                    }
                    Text("\(recipe.calories) kcal · \(recipe.protein)g protein · \(recipe.readyInMinutes) min")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    if !recipe.tags.isEmpty {
                        Text(recipe.tags.prefix(3).joined(separator: ", "))
                            .font(.caption2)
                            .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.8))
                    }
                }
                Spacer()
                Button(action: {
                    Haptics.light()
                    onFavorite()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : AppTheme.onSurfaceVariant)
                }
                .buttonStyle(.plain)
                .accessibilityActionLabel(isFavorite ? "Remove from favorites" : "Add to favorites", hint: "Double tap to toggle")
                .accessibilityTouchTarget()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .accessibilityActionLabel(recipe.name, descriptive: "\(recipe.name), \(recipe.calories) kcal\(isReadyToCook ? ", ready to cook" : "")", hint: "Double tap to open recipe")
        .accessibilityTouchTarget()
    }
}

#Preview {
    RecipesScreen(onRecipeSelected: { _ in })
        .environmentObject(AppStore())
}
