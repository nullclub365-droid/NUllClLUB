//
//  PostCookingCheckScreen.swift
//  SmartCart
//

import SwiftUI
import FirebaseAnalytics

struct PostCookingCheckScreen: View {
    @EnvironmentObject var store: AppStore
    let recipe: Recipe
    var onDone: () -> Void

    @State private var deck: [CookingIngredientEntry] = []
    @State private var removedCount = 0
    @State private var isComplete = false

    private var totalCount: Int { deck.count + removedCount + reviewedButKeptCount }
    @State private var reviewedButKeptCount = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()

            if isComplete {
                completionView
            } else if deck.isEmpty && !isComplete {
                completionView
            } else {
                VStack(spacing: 0) {
                    progressHeader

                    VStack(spacing: 4) {
                        Text("Still have these?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.onSurface)
                        Text("Swipe right to keep · left if you used it up")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)

                    Spacer()

                    SwipeCardStack(
                        items: deck,
                        onSwipeLeft: handleUsedUp,
                        onSwipeRight: handleStillHave,
                        rightLabel: "HAVE IT",
                        leftLabel: "USED UP"
                    ) { entry in
                        PostCookingCard(
                            entry: entry,
                            ingredient: store.ingredient(byId: entry.ingredientId)
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 120)
                }

                bottomHints
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Skip") { onDone() }
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
        }
        .onAppear { if deck.isEmpty { buildDeck() } }
    }

    // MARK: - Progress header

    private var progressHeader: some View {
        let reviewed = reviewedButKeptCount + removedCount
        let total = reviewed + deck.count
        return VStack(spacing: 8) {
            HStack {
                Text("\(reviewed) of \(total) reviewed")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Spacer()
                if removedCount > 0 {
                    Text("\(removedCount) removed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.secondary)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.surfaceVariant)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.primary)
                        .frame(
                            width: total > 0 ? geo.size.width * CGFloat(reviewed) / CGFloat(total) : 0,
                            height: 6
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: reviewed)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: removedCount > 0 ? "minus.circle.fill" : "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(removedCount > 0 ? AppTheme.secondary : AppTheme.primary)

            VStack(spacing: 8) {
                Text("Pantry updated")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                if removedCount > 0 {
                    Text("\(removedCount) ingredient\(removedCount == 1 ? "" : "s") removed from your pantry")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Great news — everything's still stocked!")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }

            Button(action: {
                AchievementTracker.checkAndTrackAchievements(store: store)
                AppReviewPrompt.requestReviewIfEligible(store: store)
                onDone()
            }) {
                Text("Done")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    // MARK: - Bottom hints

    private var bottomHints: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                Text("Used it up")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.12))
            .clipShape(Capsule())

            Spacer()
            Text("\(deck.count) remaining")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                Text("Still have it")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.green)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.12))
            .clipShape(Capsule())
        }
    }

    // MARK: - Actions

    private func handleUsedUp(_ entry: CookingIngredientEntry) {
        deck.removeAll { $0.id == entry.id }
        store.deletePantryItem(ingredientId: entry.ingredientId)
        removedCount += 1
        checkComplete()
    }

    private func handleStillHave(_ entry: CookingIngredientEntry) {
        deck.removeAll { $0.id == entry.id }
        reviewedButKeptCount += 1
        checkComplete()
    }

    private func checkComplete() {
        if deck.isEmpty {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isComplete = true
            }
        }
    }

    private func buildDeck() {
        let pantryIds = Set(store.pantryItems.map(\.ingredientId))
        deck = recipe.ingredients
            .filter { !$0.optional && pantryIds.contains($0.ingredientId) }
            .map { CookingIngredientEntry(ingredientId: $0.ingredientId, qtyText: $0.qtyText) }
    }
}

// MARK: - Entry model

struct CookingIngredientEntry: Identifiable {
    let id = UUID()
    let ingredientId: Int64
    let qtyText: String?
}

// MARK: - Card view

private struct PostCookingCard: View {
    let entry: CookingIngredientEntry
    let ingredient: Ingredient?

    private var name: String { ingredient?.canonicalName ?? "Ingredient" }
    private var category: String { ingredient?.category ?? "" }
    private var colors: (Color, Color) { categoryColors(category) }
    private var emoji: String { categoryEmoji(category) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(LinearGradient(
                    colors: [colors.0, colors.1],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .black.opacity(0.18), radius: 16, y: 8)

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    if !category.isEmpty {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.22))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Text(emoji)
                        .font(.system(size: 60))
                        .shadow(color: .black.opacity(0.1), radius: 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer()

                // Name + qty
                VStack(alignment: .leading, spacing: 10) {
                    Text(name)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .fixedSize(horizontal: false, vertical: true)

                    if let qty = entry.qtyText, !qty.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "scalemass.fill")
                                .font(.caption)
                            Text("Used: \(qty)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.white.opacity(0.88))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.22))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
    }
}

#Preview {
    NavigationStack {
        PostCookingCheckScreen(
            recipe: Recipe(
                id: 1,
                name: "Test Recipe",
                description: "",
                calories: 400,
                protein: 30,
                tags: [],
                steps: [],
                ingredients: [],
                readyInMinutes: 20,
                difficulty: "Easy"
            ),
            onDone: {}
        )
        .environmentObject(AppStore())
    }
}
