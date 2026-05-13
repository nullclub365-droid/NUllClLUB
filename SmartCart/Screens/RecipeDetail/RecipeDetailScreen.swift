//
//  RecipeDetailScreen.swift
//  SmartCart
//

import SwiftUI

struct RecipeDetailScreen: View {
    @EnvironmentObject var store: AppStore
    let recipeId: Int64
    var onStartCooking: (Int64) -> Void
    var onBack: () -> Void

    @State private var showAddToCollection = false
    private var recipe: Recipe? { store.recipe(byId: recipeId) }

    var body: some View {
        Group {
            if recipe == nil {
                ContentUnavailableView("Recipe not found", systemImage: "doc.text.magnifyingglass")
            } else if let recipe = recipe {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        AsyncImage(url: URL(string: "https://raw.githubusercontent.com/nullclub365-droid/smartcart-assets/main/\(recipe.id).jpg")) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 240)
                                    .clipped()
                            case .empty:
                                ZStack {
                                    AppTheme.surfaceVariant
                                    ProgressView()
                                        .tint(AppTheme.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                            case .failure:
                                ZStack {
                                    AppTheme.surfaceVariant
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                            @unknown default:
                                ZStack {
                                    AppTheme.surfaceVariant
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                            }
                        }
                        VStack(alignment: .leading, spacing: 24) {
                            header(recipe)
                        missingIngredientsSection(recipe)
                        ingredientsSection(recipe)
                        stepsSection(recipe)
                        notesSection(recipeId: recipe.id)
                        Button(action: { onStartCooking(recipe.id) }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Cooking")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .accessibilityActionLabel("Start Cooking", descriptive: "Start cooking mode for \(recipe.name)", hint: "Double tap to begin cooking")
                        .accessibilityTouchTarget()
                        .padding(.top, 8)
                        Button(action: { logRecipeAsEaten(recipe) }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Log as eaten")
                            }
                            .font(.headline)
                            .foregroundStyle(AppTheme.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.primary.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .accessibilityActionLabel("Log as eaten", descriptive: "Log \(recipe.name) to today's food log", hint: "Double tap to log calories and protein")
                        .accessibilityTouchTarget()
                        .padding(.top, 8)
                        Button(action: { shareRecipe(recipe) }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Recipe")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppTheme.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .accessibilityActionLabel("Share Recipe", descriptive: "Share \(recipe.name) with friends", hint: "Double tap to share this recipe")
                        .accessibilityTouchTarget()
                        .padding(.top, 8)
                        }
                        .padding(20)
                    }
                }
                .background(AppTheme.background)
                .navigationTitle(recipe.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 16) {
                            Button(action: { showAddToCollection = true }) {
                                Image(systemName: "folder.badge.plus")
                                    .foregroundStyle(AppTheme.primary)
                            }
                            .accessibilityActionLabel("Add to collection", descriptive: "Add this recipe to a collection", hint: "Double tap to choose a collection")
                            .accessibilityTouchTarget()
                            ShareLink(item: shareText(for: recipe), subject: Text(recipe.name)) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(AppTheme.primary)
                            }
                            .accessibilityLabel("Share recipe")
                            .accessibilityHint("Double tap to share")
                            .accessibilityTouchTarget()
                            Button(action: {
                                Haptics.light()
                                store.toggleFavorite(recipeId: recipe.id)
                                AchievementTracker.checkAndTrackAchievements(store: store)
                            }) {
                                Image(systemName: store.isFavorite(recipeId: recipe.id) ? "heart.fill" : "heart")
                                    .foregroundStyle(store.isFavorite(recipeId: recipe.id) ? .red : AppTheme.onSurfaceVariant)
                            }
                            .accessibilityActionLabel(store.isFavorite(recipeId: recipe.id) ? "Remove from favorites" : "Add to favorites", descriptive: store.isFavorite(recipeId: recipe.id) ? "Remove \(recipe.name) from favorites" : "Add \(recipe.name) to favorites", hint: "Double tap to toggle")
                            .accessibilityTouchTarget()
                        }
                    }
                }
                .sheet(isPresented: $showAddToCollection) {
                    AddToCollectionSheet(recipeId: recipe.id, onDismiss: { showAddToCollection = false })
                        .environmentObject(store)
                }
                .onAppear { InterstitialAdHelper.preload() }
            } else {
                ContentUnavailableView("Recipe not found", systemImage: "fork.knife")
            }
        }
    }

    private func logRecipeAsEaten(_ recipe: Recipe) {
        InterstitialAdHelper.showInterstitial(onDismiss: {
            Haptics.light()
            store.addNutritionEntryFromRecipe(recipeId: recipe.id, recipeName: recipe.name, calories: recipe.calories, protein: recipe.protein)
            AccessibilitySettings.announce("Logged to food log")
        })
    }

    private func shareRecipe(_ recipe: Recipe) {
        Haptics.light()
        let message = ShareHelper.shareRecipe(name: recipe.name, cookTime: recipe.readyInMinutes, calories: recipe.calories, protein: recipe.protein)
        ShareHelper.shareContent(message) { _ in }
    }

    private func shareText(for recipe: Recipe) -> String {
        let ingList = recipe.ingredients.prefix(8).compactMap { store.ingredient(byId: $0.ingredientId)?.canonicalName }.joined(separator: ", ")
        return [
            recipe.name,
            recipe.description,
            "\(recipe.calories) kcal · \(recipe.protein)g protein · \(recipe.readyInMinutes) min",
            "Ingredients: \(ingList)"
        ].joined(separator: "\n\n")
    }

    private func header(_ recipe: Recipe) -> some View {
        return VStack(alignment: .leading, spacing: 12) {
            ratingRow(recipeId: recipe.id)
            Text(recipe.description)
                .font(.body)
                .foregroundStyle(AppTheme.onSurfaceVariant)
            HStack(spacing: 16) {
                Label("\(recipe.calories) kcal", systemImage: "flame")
                Label("\(recipe.protein)g protein", systemImage: "fork.knife")
                Label("\(recipe.readyInMinutes) min", systemImage: "clock")
            }
            .font(.subheadline)
            .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func ratingRow(recipeId: Int64) -> some View {
        let current = store.recipeRating(recipeId: recipeId) ?? 0
        return HStack(spacing: 4) {
            Text("Rate")
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
            ForEach(1...5, id: \.self) { star in
                Button(action: {
                    Haptics.light()
                    store.setRecipeRating(recipeId: recipeId, rating: star)
                    AchievementTracker.checkAndTrackAchievements(store: store)
                }) {
                    Image(systemName: star <= current ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(star <= current ? Color.yellow : AppTheme.onSurfaceVariant.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func missingIngredientsSection(_ recipe: Recipe) -> some View {
        MissingIngredientsSection(
            missing: recipe.ingredients.filter { !Set(store.pantryItems.map(\.ingredientId)).contains($0.ingredientId) },
            store: store
        )
    }

    private func ingredientsSection(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { _, ing in
                HStack {
                    Text(store.ingredient(byId: ing.ingredientId)?.canonicalName ?? "Ingredient")
                        .foregroundStyle(AppTheme.onSurface)
                    Spacer()
                    if let qty = ing.qtyText { Text(qty).foregroundStyle(AppTheme.onSurfaceVariant) }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func stepsSection(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Steps")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(AppTheme.primary)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.onSurface)
                        Text(step.description)
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    Spacer()
                }
                .padding(12)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func notesSection(recipeId: Int64) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My notes")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            TextField("Add a note for this recipe…", text: Binding(
                get: { store.recipeNote(recipeId: recipeId) ?? "" },
                set: { store.setRecipeNote(recipeId: recipeId, note: $0) }
            ), axis: .vertical)
            .lineLimit(3...8)
            .textFieldStyle(.roundedBorder)
            .padding(12)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct MissingIngredientsSection: View {
    let missing: [RecipeIngredient]
    @ObservedObject var store: AppStore

    var body: some View {
        Group {
            if missing.isEmpty {
                EmptyView()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Missing from pantry")
                            .font(.headline)
                            .foregroundStyle(AppTheme.onSurface)
                        Spacer()
                        Button(action: addMissingToGroceryList) {
                            Label("Add to grocery list", systemImage: "cart.badge.plus")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(AppTheme.secondary)
                                .clipShape(Capsule())
                        }
                    }
                    ForEach(missing, id: \.ingredientId) { ing in
                        let ingredient = store.ingredient(byId: ing.ingredientId)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(ingredient?.canonicalName ?? "Ingredient")
                                    .foregroundStyle(AppTheme.onSurface)
                                Spacer()
                                if let qty = ing.qtyText { Text(qty).foregroundStyle(AppTheme.onSurfaceVariant) }
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(AppTheme.surfaceVariant.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }

    private func addMissingToGroceryList() {
        Haptics.light()
        store.addItemsToGroceryList(missing.map { ($0.ingredientId, $0.qtyText ?? "") })
    }
}

private struct AddToCollectionSheet: View {
    @EnvironmentObject var store: AppStore
    let recipeId: Int64
    var onDismiss: () -> Void

    @State private var showNewCollection = false
    @State private var newCollectionName = ""

    private var collectionIdsContainingRecipe: Set<Int64> {
        Set(store.collectionIds(containing: recipeId))
    }

    var body: some View {
        NavigationStack {
            List {
                Button(action: { showNewCollection = true }) {
                    Label("Create new collection", systemImage: "plus.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                }
                ForEach(store.recipeCollections) { col in
                    let alreadyAdded = collectionIdsContainingRecipe.contains(col.id)
                    Button(action: {
                        if !alreadyAdded {
                            store.addRecipeToCollection(recipeId: recipeId, collectionId: col.id)
                            Haptics.light()
                            onDismiss()
                        }
                    }) {
                        HStack {
                            Text(col.name)
                                .foregroundStyle(AppTheme.onSurface)
                            Spacer()
                            if alreadyAdded {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.primary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(alreadyAdded)
                }
            }
            .navigationTitle("Add to collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: onDismiss)
                        .foregroundStyle(AppTheme.primary)
                }
            }
            .sheet(isPresented: $showNewCollection) {
                NavigationStack {
                    Form {
                        TextField("Collection name", text: $newCollectionName)
                    }
                    .navigationTitle("New collection")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showNewCollection = false
                                newCollectionName = ""
                            }
                            .foregroundStyle(AppTheme.primary)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") {
                                let name = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !name.isEmpty {
                                    store.addCollection(name: name)
                                    if let newCol = store.recipeCollections.last {
                                        store.addRecipeToCollection(recipeId: recipeId, collectionId: newCol.id)
                                    }
                                    Haptics.light()
                                    showNewCollection = false
                                    newCollectionName = ""
                                    onDismiss()
                                }
                            }
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.primary)
                            .disabled(newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailScreen(recipeId: 1, onStartCooking: { _ in }, onBack: {})
            .environmentObject(AppStore())
    }
}
