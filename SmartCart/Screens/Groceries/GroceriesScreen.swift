//
//  GroceriesScreen.swift
//  SmartCart
//

import SwiftUI
import FirebaseAnalytics

private enum GroceryTab: String, CaseIterable {
    case list = "List"
    case pantry = "Pantry"
}

struct GroceriesScreen: View {
    @EnvironmentObject var store: AppStore
    var onAddItems: () -> Void
    var onSwipeToAdd: () -> Void = {}

    @State private var selectedTab: GroceryTab = .list
    @State private var editingPantryIngredientId: Int64? = nil
    @State private var editingQuantity: String = ""

    private var checkedCount: Int { store.groceryItems.filter(\.isChecked).count }
    private var sortedPantryItems: [PantryItem] {
        store.pantryItems.sorted { a, b in
            (store.ingredient(byId: a.ingredientId)?.canonicalName ?? "").localizedCaseInsensitiveCompare(store.ingredient(byId: b.ingredientId)?.canonicalName ?? "") == .orderedAscending
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("Tab", selection: $selectedTab) {
                ForEach(GroceryTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("List or Pantry")
            .accessibilityHint("Double tap to switch between grocery list and pantry")
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(AppTheme.surface.opacity(0.5))

            Group {
                if selectedTab == .list {
                    listTabContent
                } else {
                    pantryTabContent
                }
            }
        }
        .navigationTitle("Groceries")
        .background(AppTheme.background)
        .refreshable {
            try? await Task.sleep(nanoseconds: 400_000_000)
        }
        .onAppear {
            AnalyticsHelper.trackFeatureUsed("grocery_list")
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if selectedTab == .pantry {
                    Button(action: { Haptics.light(); onSwipeToAdd() }) {
                        Image(systemName: "hand.draw.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .accessibilityActionLabel("Swipe to add", descriptive: "Swipe through ingredients to add to pantry", hint: "Double tap to start swiping")
                    .accessibilityTouchTarget()
                } else {
                    Button(action: onAddItems) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .accessibilityActionLabel("Add items", descriptive: "Add ingredients to list", hint: "Double tap to search and add items")
                    .accessibilityTouchTarget()
                }
            }
        }
        .sheet(item: Binding(
            get: { editingPantryIngredientId.map { PantryEditId(id: $0) } },
            set: { editingPantryIngredientId = $0?.id }
        )) { editId in
            pantryEditSheet(ingredientId: editId.id)
        }
    }

    private var listTabContent: some View {
        Group {
            if store.groceryItems.isEmpty {
                ScrollView {
                    EmptyStateView(
                        icon: "cart",
                        title: "Your list is empty",
                        message: "Add ingredients from your pantry or search to build your grocery list.",
                        actionTitle: "Add items",
                        action: onAddItems
                    )
                    .padding(.top, 60)
                }
            } else {
                List {
                    if checkedCount > 0 {
                        Section {
                            Button(action: {
                                Haptics.light()
                                store.moveCheckedItemsToPantry()
                                AccessibilitySettings.announce("Moved to pantry")
                            }) {
                                Label("Move \(checkedCount) checked to pantry", systemImage: "arrow.down.to.line.circle")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(AppTheme.primary)
                            }
                            .accessibilityActionLabel("Move \(checkedCount) checked to pantry", descriptive: "Move \(checkedCount) checked items from list to pantry", hint: "Double tap to move")
                            .accessibilityTouchTarget()
                        }
                    }
                    Section("Grocery list") {
                        ForEach(store.groceryItems) { item in
                            GroceryRow(
                                item: item,
                                ingredientName: store.ingredient(byId: item.ingredientId)?.canonicalName ?? "Item",
                                isChecked: item.isChecked,
                                onToggle: { store.toggleGroceryChecked(id: item.id) }
                            )
                        }
                        .onDelete { indexSet in
                            for i in indexSet {
                                store.deleteGroceryItem(id: store.groceryItems[i].id)
                            }
                        }
                    }
                }
            }
        }
    }

    private var pantryTabContent: some View {
        Group {
            if store.pantryItems.isEmpty {
                ScrollView {
                    EmptyStateView(
                        icon: "cabinet.fill",
                        title: "Your pantry is empty",
                        message: "Add ingredients you have at home. You can set expiry dates when adding.",
                        actionTitle: "Add items",
                        action: onAddItems
                    )
                    .padding(.top, 60)
                }
            } else {
                List {
                    Section(header: Text("\(store.pantryItems.count) items in pantry")) {
                        ForEach(sortedPantryItems, id: \.ingredientId) { pantry in
                            PantryListRow(
                                pantry: pantry,
                                ingredientName: store.ingredient(byId: pantry.ingredientId)?.canonicalName ?? "Item",
                                onEdit: {
                                    editingQuantity = pantry.quantityText ?? ""
                                    editingPantryIngredientId = pantry.ingredientId
                                },
                                onDelete: { store.deletePantryItem(ingredientId: pantry.ingredientId) }
                            )
                        }
                        .onDelete { indexSet in
                            for i in indexSet {
                                store.deletePantryItem(ingredientId: sortedPantryItems[i].ingredientId)
                            }
                        }
                    }
                }
            }
        }
    }

    private func pantryEditSheet(ingredientId: Int64) -> some View {
        let binding = Binding(
            get: { editingQuantity },
            set: { editingQuantity = $0 }
        )
        return NavigationStack {
            Form {
                TextField("Quantity (optional)", text: binding)
                    .textInputAutocapitalization(.never)
            }
            .navigationTitle(store.ingredient(byId: ingredientId)?.canonicalName ?? "Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        editingPantryIngredientId = nil
                    }
                    .foregroundStyle(AppTheme.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updatePantryQuantity(ingredientId: ingredientId, quantityText: editingQuantity.isEmpty ? nil : editingQuantity)
                        editingPantryIngredientId = nil
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primary)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            if let p = store.pantryItems.first(where: { $0.ingredientId == ingredientId }) {
                editingQuantity = p.quantityText ?? ""
            }
        }
    }
}

private struct PantryEditId: Identifiable {
    let id: Int64
}

private struct PantryListRow: View {
    let pantry: PantryItem
    let ingredientName: String
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var expiryText: String? {
        guard let ts = pantry.expiryDate else { return nil }
        let d = Date(timeIntervalSince1970: Double(ts) / 1000)
        let f = DateFormatter()
        f.dateStyle = .short
        return f.string(from: d)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredientName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.onSurface)
                HStack(spacing: 8) {
                    if let qty = pantry.quantityText, !qty.isEmpty {
                        Text(qty)
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    if let exp = expiryText {
                        Text("Exp: \(exp)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondary)
                    }
                }
            }
            Spacer()
            Button(action: onEdit) {
                Image(systemName: "pencil.circle")
                    .font(.title3)
                    .foregroundStyle(AppTheme.primary)
            }
            .buttonStyle(.plain)
            Button(action: {
                Haptics.light()
                onDelete()
            }) {
                Image(systemName: "trash")
                    .font(.body)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

private struct GroceryRow: View {
    let item: GroceryItem
    let ingredientName: String
    let isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                Haptics.light()
                onToggle()
            }) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isChecked ? AppTheme.primary : AppTheme.outline)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredientName)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(isChecked)
                    .foregroundStyle(AppTheme.onSurface)
                if let qty = item.quantityText, !qty.isEmpty {
                    Text(qty)
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    GroceriesScreen(onAddItems: {}, onSwipeToAdd: {})
        .environmentObject(AppStore())
}
