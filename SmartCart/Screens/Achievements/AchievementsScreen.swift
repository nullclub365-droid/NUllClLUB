//
//  AchievementsScreen.swift
//  SmartCart
//

import SwiftUI
import FirebaseAnalytics

struct AchievementsScreen: View {
    @EnvironmentObject var store: AppStore
    var onBack: () -> Void

    private var plannedSlotsCount: Int {
        store.currentPlan?.days.reduce(0) { sum, day in
            sum + [day.breakfastId, day.lunchId, day.dinnerId, day.snackId].compactMap { $0 }.count
        } ?? 0
    }

    private var achievements: [Achievement] {
        let progress: (String) -> Int = { id in
            switch id {
            case "first_cook": return store.recipeHistory.count
            case "pantry_starter": return store.pantryItems.count
            case "pantry_pro": return store.pantryItems.count
            case "century_chef": return store.recipeHistory.count
            case "veggie_champion": return store.recipeHistory.filter { store.recipe(byId: $0.recipeId)?.tags.contains("vegetarian") == true }.count
            case "recipe_collector": return store.favoriteRecipeIds.count
            case "easy_peasy": return store.recipeHistory.filter { store.recipe(byId: $0.recipeId)?.difficulty == "Easy" }.count
            case "medium_master": return store.recipeHistory.filter { store.recipe(byId: $0.recipeId)?.difficulty == "Medium" }.count
            case "quick_cook": return store.recipeHistory.filter { (store.recipe(byId: $0.recipeId)?.readyInMinutes ?? 999) < 30 }.count
            case "week_warrior": return plannedSlotsCount
            case "five_star": return store.recipeRatings.values.filter { $0 == 5 }.count
            case "recipe_rater": return store.recipeRatings.count
            case "collection_curator": return store.recipeCollections.count
            case "nutrition_logger": return store.nutritionEntries.count
            case "planner_pro": return plannedSlotsCount
            default: return 0
            }
        }
        return AchievementSeed.all(progress: progress)
    }

    private var unlockedCount: Int { achievements.filter(\.isUnlocked).count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerCard
                if unlockedCount == 0 {
                    EmptyStateView(
                        icon: "medal",
                        title: "No badges yet",
                        message: "Cook recipes, add items to your pantry, and favorite recipes to unlock achievements."
                    )
                    .padding(.top, 8)
                } else {
                    ForEach(AchievementCategory.allCases, id: \.rawValue) { category in
                        let items = achievements.filter { $0.category == category }
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.onSurface)
                                ForEach(items) { achievement in
                                    AchievementCard(achievement: achievement)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsHelper.trackFeatureUsed("achievements")
        }
    }

    private var headerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.2))
                    .frame(width: 56, height: 56)
                Text("🏆")
                    .font(.system(size: 28))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(unlockedCount) / \(achievements.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                Text("Achievements unlocked")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            Spacer()
        }
        .padding(20)
        .background(AppTheme.primaryContainer.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

private struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? AppTheme.primary.opacity(0.2) : AppTheme.surfaceVariant)
                    .frame(width: 48, height: 48)
                Text(achievement.icon)
                    .font(.title2)
                    .opacity(achievement.isUnlocked ? 1 : 0.5)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.displayName)
                    .font(.headline)
                    .foregroundStyle(AppTheme.onSurface)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                ProgressView(value: Double(achievement.progressPercent))
                    .tint(AppTheme.primary)
                    .padding(.top, 4)
                Text("\(achievement.progress) / \(achievement.target)")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            Spacer()
            if achievement.isUnlocked {
                Button(action: {
                    Haptics.light()
                    let message = ShareHelper.shareAchievement(name: achievement.displayName, description: achievement.description)
                    ShareHelper.shareContent(message) { _ in }
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.primary)
                }
                .accessibilityActionLabel("Share achievement", descriptive: "Share \(achievement.displayName)", hint: "Double tap to share")
                .accessibilityTouchTarget()
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        AchievementsScreen(onBack: {})
            .environmentObject(AppStore())
    }
}
