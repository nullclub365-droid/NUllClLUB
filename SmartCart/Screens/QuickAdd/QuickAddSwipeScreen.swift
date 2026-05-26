//
//  QuickAddSwipeScreen.swift
//  SmartCart
//

import SwiftUI

struct QuickAddSwipeScreen: View {
    @EnvironmentObject var store: AppStore
    var onDone: () -> Void = {}

    @State private var deck: [Ingredient] = []
    @State private var addedIds: Set<Int64> = []
    @State private var selectedCategory: String? = nil
    @State private var makeableCountDisplay: Int = 0

    private var pantryIds: Set<Int64> { Set(store.pantryItems.map(\.ingredientId)) }

    private var displayedDeck: [Ingredient] {
        guard let cat = selectedCategory else { return deck }
        return deck.filter { $0.category.lowercased() == cat.lowercased() }
    }

    private var categories: [String] {
        var seen = Set<String>()
        return deck.compactMap { ing in
            let cat = ing.category
            guard !seen.contains(cat) else { return nil }
            seen.insert(cat)
            return cat
        }
    }

    private var deckIsEmpty: Bool {
        deck.isEmpty
    }

    private var deckIsFullyInPantry: Bool {
        !deckIsEmpty && displayedDeck.isEmpty && selectedCategory == nil
    }

    private var makeableCount: Int {
        let available = pantryIds.union(addedIds)
        return store.recipes.filter { recipe in
            recipe.ingredients.filter { !$0.optional }.allSatisfy { available.contains($0.ingredientId) }
        }.count
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                categoryPills
                    .padding(.top, 4)

                if deck.isEmpty {
                    allDoneView
                } else if displayedDeck.isEmpty {
                    noCategoryResultsView
                } else {
                    Spacer()
                    SwipeCardStack(items: displayedDeck, onSwipeLeft: handleSkip, onSwipeRight: handleAdd) { ingredient in
                        IngredientSwipeCard(ingredient: ingredient)
                    }
                    .padding(.horizontal, 24)
                    Spacer(minLength: 160)
                }
            }

            bottomBar
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
        }
        .navigationTitle("Swipe to Add")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    Haptics.light()
                    onDone()
                }
                .foregroundStyle(AppTheme.primary)
            }
        }
        .onAppear {
            if deck.isEmpty { deck = buildDeck() }
            makeableCountDisplay = makeableCount
        }
        .onChange(of: makeableCount) { _, new in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                makeableCountDisplay = new
            }
        }
    }

    // MARK: - Category pills

    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                pill(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(categories, id: \.self) { cat in
                    pill(title: "\(categoryEmoji(cat)) \(cat)", isSelected: selectedCategory == cat) {
                        selectedCategory = cat
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }

    private func pill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.light(); action() }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : AppTheme.onSurface)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary : AppTheme.surfaceVariant)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 10) {
            // Recipe count card
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryContainer)
                        .frame(width: 44, height: 44)
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppTheme.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Recipes you could make")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Text("\(makeableCountDisplay)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: makeableCountDisplay)
                }

                Spacer()

                if !addedIds.isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Added")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                        Text("\(addedIds.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.secondary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 3)

            // Swipe hints
            HStack {
                hintBubble(icon: "xmark", label: "Skip", color: .red)
                Spacer()
                Text("\(displayedDeck.count) left")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Spacer()
                hintBubble(icon: "checkmark", label: "Add to pantry", color: .green)
            }
        }
    }

    private func hintBubble(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Empty states

    private var allDoneView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: deckIsFullyInPantry ? "checkmark.circle.fill" : "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(AppTheme.primary)
            if deckIsFullyInPantry {
                Text("Pantry is fully stocked!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                Text("All available ingredients are already in your pantry.\n\(addedIds.count) item\(addedIds.count == 1 ? "" : "s") added this session.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            } else {
                Text("All caught up!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                Text("You've reviewed all ingredients.\n\(addedIds.count) item\(addedIds.count == 1 ? "" : "s") added to your pantry.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding()
    }

    private var noCategoryResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(categoryEmoji(selectedCategory ?? ""))
                .font(.system(size: 64))
            Text("No \(selectedCategory ?? "more") ingredients left")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            Button("Show all categories") { selectedCategory = nil }
                .font(.subheadline)
                .foregroundStyle(AppTheme.primary)
            Spacer()
        }
    }

    // MARK: - Actions

    private func handleAdd(_ ingredient: Ingredient) {
        deck.removeAll { $0.id == ingredient.id }
        store.addItemsToPantry([(ingredient.id, "", nil)])
        addedIds.insert(ingredient.id)
    }

    private func handleSkip(_ ingredient: Ingredient) {
        deck.removeAll { $0.id == ingredient.id }
    }

    // MARK: - Deck building

    private func buildDeck() -> [Ingredient] {
        let inPantry = Set(store.pantryItems.map(\.ingredientId))
        let candidates = store.ingredients.filter { !inPantry.contains($0.id) }

        var recipeCounts: [Int64: Int] = [:]
        for recipe in store.recipes {
            for ri in recipe.ingredients {
                recipeCounts[ri.ingredientId, default: 0] += 1
            }
        }

        let useful = candidates.filter { recipeCounts[$0.id] != nil }
            .sorted { (recipeCounts[$0.id] ?? 0) > (recipeCounts[$1.id] ?? 0) }
        let others = candidates.filter { recipeCounts[$0.id] == nil }
            .sorted { $0.canonicalName < $1.canonicalName }

        return useful + others
    }
}

// MARK: - Ingredient card view

private struct IngredientSwipeCard: View {
    let ingredient: Ingredient

    private var colors: (Color, Color) { categoryColors(ingredient.category) }
    private var emoji: String { categoryEmoji(ingredient.category) }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28)
                .fill(LinearGradient(
                    colors: [colors.0, colors.1],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .black.opacity(0.18), radius: 16, y: 8)

            VStack(alignment: .leading, spacing: 0) {
                // Header row
                HStack(alignment: .top) {
                    Text(ingredient.category)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.22))
                        .clipShape(Capsule())
                    Spacer()
                    Text(emoji)
                        .font(.system(size: 60))
                        .shadow(color: .black.opacity(0.1), radius: 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer()

                // Ingredient info
                VStack(alignment: .leading, spacing: 8) {
                    Text(ingredient.canonicalName)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .fixedSize(horizontal: false, vertical: true)

                    if let serving = ingredient.standardServing {
                        Text(serving)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.78))
                    }

                    if ingredient.caloriesPerServing != nil || ingredient.proteinPerServing != nil {
                        macroChips
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
    }

    private var macroChips: some View {
        HStack(spacing: 8) {
            if let cal = ingredient.caloriesPerServing {
                chip(label: "\(cal) kcal", icon: "flame.fill")
            }
            if let pro = ingredient.proteinPerServing {
                chip(label: "\(pro)g protein", icon: "bolt.fill")
            }
            if let carb = ingredient.carbsPerServing {
                chip(label: "\(carb)g carbs", icon: "leaf.fill")
            }
        }
    }

    private func chip(label: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white.opacity(0.92))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.white.opacity(0.22))
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        QuickAddSwipeScreen()
            .environmentObject(AppStore())
    }
}
