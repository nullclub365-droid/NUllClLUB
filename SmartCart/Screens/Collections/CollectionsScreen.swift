//
//  CollectionsScreen.swift
//  SmartCart
//

import SwiftUI

struct CollectionsScreen: View {
    @EnvironmentObject var store: AppStore
    var onBack: () -> Void
    var onCollectionSelected: (Int64) -> Void
    var onRecipeSelected: (Int64) -> Void

    @State private var showNewCollection = false
    @State private var newCollectionName = ""

    var body: some View {
        Group {
            if store.recipeCollections.isEmpty {
                EmptyStateView(
                    icon: "folder",
                    title: "No collections yet",
                    message: "Create a collection to group your favorite recipes (e.g. \"Weeknight Dinners\", \"Holiday\").",
                    actionTitle: "Create collection",
                    action: { showNewCollection = true }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(store.recipeCollections) { col in
                        Button(action: { onCollectionSelected(col.id) }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundStyle(AppTheme.primary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(col.name)
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.onSurface)
                                    Text("\(col.recipeIds.count) recipes")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.onSurfaceVariant)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .accessibilityActionLabel(col.name, descriptive: "\(col.name), \(col.recipeIds.count) recipes", hint: "Double tap to open collection")
                        .accessibilityTouchTarget()
                    }
                    .onDelete(perform: deleteCollections)
                }
            }
        }
        .navigationTitle("Collections")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showNewCollection = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                }
                .accessibilityActionLabel("New collection", descriptive: "Create a new recipe collection", hint: "Double tap to create")
                .accessibilityTouchTarget()
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
                        Button("Save") {
                            let name = newCollectionName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !name.isEmpty {
                                store.addCollection(name: name)
                                Haptics.light()
                                showNewCollection = false
                                newCollectionName = ""
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

    private func deleteCollections(at offsets: IndexSet) {
        let ids = store.recipeCollections.map(\.id)
        for i in offsets {
            if i < ids.count {
                store.deleteCollection(id: ids[i])
            }
        }
    }
}

#Preview {
    NavigationStack {
        CollectionsScreen(onBack: {}, onCollectionSelected: { _ in }, onRecipeSelected: { _ in })
            .environmentObject(AppStore())
    }
}
