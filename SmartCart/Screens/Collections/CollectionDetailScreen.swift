//
//  CollectionDetailScreen.swift
//  SmartCart
//

import SwiftUI

struct CollectionDetailScreen: View {
    @EnvironmentObject var store: AppStore
    let collectionId: Int64
    var onBack: () -> Void
    var onRecipeSelected: (Int64) -> Void

    @State private var showAddRecipes = false
    @State private var showRename = false
    @State private var renameText = ""

    private var collection: RecipeCollection? { store.collection(byId: collectionId) }
    private var recipesInCollection: [Recipe] { store.recipes(in: collectionId) }

    var body: some View {
        Group {
            if let col = collection {
                List {
                    if recipesInCollection.isEmpty {
                        Section {
                            EmptyStateView(
                                icon: "fork.knife",
                                title: "No recipes",
                                message: "Tap \"Add recipes\" to add recipes to this collection.",
                                actionTitle: "Add recipes",
                                action: { showAddRecipes = true }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    } else {
                        ForEach(recipesInCollection) { recipe in
                            Button(action: { onRecipeSelected(recipe.id) }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(recipe.name)
                                            .font(.headline)
                                            .foregroundStyle(AppTheme.onSurface)
                                        Text("\(recipe.calories) kcal · \(recipe.readyInMinutes) min")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.onSurfaceVariant)
                                    }
                                    Spacer()
                                    Button(action: {
                                        Haptics.light()
                                        store.removeRecipeFromCollection(recipeId: recipe.id, collectionId: collectionId)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(.red.opacity(0.8))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: removeRecipesAtOffsets)
                    }
                }
                .navigationTitle(col.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 16) {
                            Button(action: {
                                renameText = col.name
                                showRename = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundStyle(AppTheme.primary)
                            }
                            Button(action: { showAddRecipes = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(AppTheme.primary)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddRecipes) {
                    AddRecipesToCollectionSheet(
                        collectionId: collectionId,
                        onDismiss: { showAddRecipes = false },
                        onRecipeSelected: { id in
                            showAddRecipes = false
                            onRecipeSelected(id)
                        }
                    )
                    .environmentObject(store)
                }
                .sheet(isPresented: $showRename) {
                    NavigationStack {
                        Form {
                            TextField("Collection name", text: $renameText)
                        }
                        .navigationTitle("Rename")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { showRename = false }
                                    .foregroundStyle(AppTheme.primary)
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Save") {
                                    let name = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !name.isEmpty {
                                        store.updateCollection(id: collectionId, name: name)
                                        Haptics.light()
                                        showRename = false
                                    }
                                }
                                .fontWeight(.semibold)
                                .foregroundStyle(AppTheme.primary)
                                .disabled(renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView("Collection not found", systemImage: "folder")
            }
        }
    }

    private func removeRecipesAtOffsets(at offsets: IndexSet) {
        let list = recipesInCollection
        for i in offsets {
            if i < list.count {
                store.removeRecipeFromCollection(recipeId: list[i].id, collectionId: collectionId)
            }
        }
    }
}

private struct AddRecipesToCollectionSheet: View {
    @EnvironmentObject var store: AppStore
    let collectionId: Int64
    var onDismiss: () -> Void
    var onRecipeSelected: (Int64) -> Void

    private var alreadyInCollection: Set<Int64> {
        Set(store.collection(byId: collectionId)?.recipeIds ?? [])
    }

    private var recipesNotInCollection: [Recipe] {
        store.recipes.filter { !alreadyInCollection.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            List {
                if recipesNotInCollection.isEmpty {
                    Text("All recipes are already in this collection.")
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .padding()
                } else {
                    ForEach(recipesNotInCollection) { recipe in
                        Button(action: {
                            store.addRecipeToCollection(recipeId: recipe.id, collectionId: collectionId)
                            Haptics.light()
                            onDismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(recipe.name)
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.onSurface)
                                    Text("\(recipe.calories) kcal · \(recipe.readyInMinutes) min")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.onSurfaceVariant)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(AppTheme.primary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Add recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: onDismiss)
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CollectionDetailScreen(collectionId: 1, onBack: {}, onRecipeSelected: { _ in })
            .environmentObject(AppStore())
    }
}
