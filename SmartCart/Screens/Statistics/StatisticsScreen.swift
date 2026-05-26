//
//  StatisticsScreen.swift
//  SmartCart
//

import SwiftUI
import FirebaseAnalytics

struct StatisticsScreen: View {
    @EnvironmentObject var store: AppStore
    var onBack: () -> Void

    private var totalCooked: Int { store.recipeHistory.count }
    private var thisWeekCooked: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: cal.date(byAdding: .day, value: -7, to: Date())!)
        return store.recipeHistory.filter { $0.cookedAt >= Int64(start.timeIntervalSince1970 * 1000) }.count
    }
    private var favoritesCount: Int { store.favoriteRecipeIds.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Statistics")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                Text("Your cooking journey at a glance")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)

                if totalCooked == 0 && favoritesCount == 0 {
                    EmptyStateView(
                        icon: "chart.bar",
                        title: "No cooking data yet",
                        message: "Start cooking recipes to see your statistics here."
                    )
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        QuickStatCard(icon: "fork.knife", value: "\(totalCooked)", label: "Total Cooked", color: AppTheme.primary)
                        QuickStatCard(icon: "calendar", value: "\(thisWeekCooked)", label: "This Week", color: AppTheme.secondary)
                        QuickStatCard(icon: "heart.fill", value: "\(favoritesCount)", label: "Favorites", color: AppTheme.tertiary)
                        QuickStatCard(icon: "flame.fill", value: "\(store.todayCalories)", label: "Today (kcal)", color: AppTheme.primary)
                    }
                }
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsHelper.trackFeatureUsed("statistics")
        }
    }
}

private struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.onSurface)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        StatisticsScreen(onBack: {})
            .environmentObject(AppStore())
    }
}
