//
//  AddItemsScreen.swift
//  SmartCart
//

import SwiftUI

struct AddItemsScreen: View {
    @EnvironmentObject var store: AppStore
    var onBack: () -> Void
    var onAddToPantry: ([(Int64, String, Int64?)]) -> Void
    var onAddToGroceryList: ([(Int64, String)]) -> Void

    @State private var searchText = ""
    @State private var selectedItems: [(ingredientId: Int64, quantity: String)] = []
    @State private var pantryExpiryDays: Int? = nil // nil = no expiry; 3, 7, 14 = days from now

    /// Ingredients grouped by category; search bar filters this list.
    private var ingredientsByCategory: [(category: String, ingredients: [Ingredient])] {
        var list = store.ingredients
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter { ing in
                ing.canonicalName.lowercased().contains(q) ||
                ing.aliases.contains { $0.lowercased().contains(q) } ||
                ing.category.lowercased().contains(q)
            }
        }
        let sorted = list.sorted { a, b in a.canonicalName.localizedCompare(b.canonicalName) == .orderedAscending }
        let grouped = Dictionary(grouping: sorted, by: \.category)
        let keys = grouped.keys.sorted { $0.localizedCompare($1) == .orderedAscending }
        return keys.map { (category: $0, ingredients: grouped[$0] ?? []) }
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(ingredientsByCategory, id: \.category) { group in
                    Section(header: sectionHeader(group.category)) {
                        ForEach(group.ingredients, id: \.id) { ing in
                            AddItemRow(
                                ingredient: ing,
                                quantity: bindingFor(ingredientId: ing.id),
                                isSelected: selectedItems.contains { $0.ingredientId == ing.id },
                                onAdd: { addOne(ing.id) }
                            )
                        }
                    }
                }
            }
            .listStyle(.plain)

            if !selectedItems.isEmpty {
                VStack(spacing: 12) {
                    HStack {
                        Text("Pantry expiry (optional)")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                        Picker("", selection: $pantryExpiryDays) {
                            Text("None").tag(Optional<Int>.none)
                            Text("3 days").tag(Optional(3))
                            Text("7 days").tag(Optional(7))
                            Text("14 days").tag(Optional(14))
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    HStack(spacing: 12) {
                        Button("Add to Pantry") {
                            let expiry: Int64? = pantryExpiryDays.map { days in
                                Int64(Date().timeIntervalSince1970 * 1000) + Int64(days) * 24 * 60 * 60 * 1000
                            }
                            onAddToPantry(selectedItems.map { ($0.ingredientId, $0.quantity, expiry) })
                            AccessibilitySettings.announce("Added to pantry")
                            onBack()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.primary)
                        .accessibilityActionLabel("Add to Pantry", descriptive: "Add selected items to your pantry", hint: "Double tap to add to pantry")
                        .accessibilityTouchTarget()
                        Button("Add to Grocery List") {
                            onAddToGroceryList(selectedItems.map { ($0.ingredientId, $0.quantity) })
                            AccessibilitySettings.announce("Added to grocery list")
                            onBack()
                        }
                        .buttonStyle(.bordered)
                        .accessibilityActionLabel("Add to Grocery List", descriptive: "Add selected items to your grocery list", hint: "Double tap to add to list")
                        .accessibilityTouchTarget()
                    }
                }
                .padding()
            }
        }
        .searchable(text: $searchText, prompt: "Search ingredients")
        .navigationTitle("Add Items")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(AppTheme.primary)
    }

    private func bindingFor(ingredientId: Int64) -> Binding<String> {
        Binding(
            get: { selectedItems.first { $0.ingredientId == ingredientId }?.quantity ?? "" },
            set: { new in
                if let i = selectedItems.firstIndex(where: { $0.ingredientId == ingredientId }) {
                    var copy = selectedItems
                    copy[i].quantity = new
                    selectedItems = copy
                } else {
                    selectedItems.append((ingredientId: ingredientId, quantity: new))
                }
            }
        )
    }

    private func addOne(_ id: Int64) {
        if selectedItems.contains(where: { $0.ingredientId == id }) { return }
        selectedItems.append((ingredientId: id, quantity: ""))
    }
}

private struct AddItemRow: View {
    let ingredient: Ingredient
    @Binding var quantity: String
    let isSelected: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.canonicalName)
                    .font(.body)
                    .fontWeight(.medium)
                Text(ingredient.category)
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            Spacer()
            TextField("Qty", text: $quantity)
                .keyboardType(.default)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .disabled(!isSelected)
            Button(action: onAdd) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
                    .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.primary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AddItemsScreen(onBack: {}, onAddToPantry: { _ in }, onAddToGroceryList: { _ in })
        .environmentObject(AppStore())
}
