//
//  HomeScreen.swift
//  SmartCart
//

import SwiftUI
import FirebaseAnalytics

struct HomeScreen: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var referralManager: ReferralManager
    @State private var appeared = false

    var onRecipeSelected: (Int64) -> Void
    var onSettings: () -> Void
    var onPremium: () -> Void
    var onNutrition: () -> Void
    var onMealPrep: () -> Void
    var onStatistics: () -> Void
    var onTimers: () -> Void
    var onCookingHistory: () -> Void
    var onAchievements: () -> Void
    var onConverter: () -> Void
    var onInsight: (String) -> Void
    /// Called when user taps "No meals planned" to open the Planner tab.
    var onOpenPlanner: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                nutritionHeroCard
                progressCard
                trendingRecipesSection
                weeklyChallengSection
                if !store.favoriteRecipeIds.isEmpty {
                    savedRecipesSection
                }
                quickTimerCard
                quickAccessGrid
                referralCard
                if store.plannedMealsForToday.isEmpty {
                    if !UserDefaults.standard.bool(forKey: "smartcart_tutorial_shown") {
                        plannedMealsEmptyCard
                    }
                } else {
                    plannedMealsSection
                }
                if store.recentHistoryItems.isEmpty {
                    recentlyCookedEmptyCard
                } else {
                    recentlyCookedSection
                }
                if !store.recipeHistory.isEmpty {
                    habitCalendarSection
                }
                featureDiscoverySection
                insightsSection
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(AppTheme.background)
        .safeAreaInset(edge: .bottom, spacing: 0) { BannerAdView() }
        .refreshable {
            try? await Task.sleep(nanoseconds: 400_000_000)
        }
        .onAppear {
            if AccessibilitySettings.shouldReduceMotion { appeared = true }
            else { withAnimation(.easeOut(duration: 0.2)) { appeared = true } }
        }
    }

    private func shareReferralCode() {
        let message = "Join me on SmartCart! 🍽️\n\nGet 1 week free premium with my code: \(referralManager.userId.prefix(6).uppercased())\n\nDownload SmartCart: \(ShareHelper.appStoreLink)"
        let items: [Any] = [message]

        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.windows.first?.rootViewController?.present(vc, animated: true)

        AnalyticsHelper.trackShareInitiated(type: "referral", content: "invite_friends")
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.body)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Text("What's cooking?")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()
            HStack(spacing: 4) {
                // Premium hidden for next version
                // QuickActionButton(icon: "crown.fill", label: "Premium", action: onPremium)
                QuickActionButton(icon: "chart.bar", label: "Statistics", action: onStatistics)
                QuickActionButton(icon: "gearshape", label: "Settings", action: onSettings)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -20)
    }

    private var nutritionHeroCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.primary)
                }
                Text("Today's Nutrition")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onPrimaryContainer)
            }
            HStack {
                Spacer()
                nutritionStat(value: store.todayCalories, unit: "kcal", icon: "flame.fill", color: AppTheme.primary)
                Rectangle()
                    .fill(AppTheme.onPrimaryContainer.opacity(0.2))
                    .frame(width: 1, height: 60)
                nutritionStat(value: store.todayProtein, unit: "g protein", icon: "fork.knife", color: AppTheme.secondary)
                Spacer()
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [AppTheme.primaryContainer, AppTheme.secondaryContainer.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 40)
    }

    private func nutritionStat(value: Int, unit: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.onPrimaryContainer)
            Text(unit)
                .font(.subheadline)
                .foregroundStyle(AppTheme.onPrimaryContainer.opacity(0.7))
        }
    }

    private var progressCard: some View {
        let totalMeals = store.currentPlan?.days.reduce(0) { sum, day in
            sum + [day.breakfastId, day.lunchId, day.dinnerId, day.snackId].compactMap { $0 }.count
        } ?? 0
        let progress = min(Double(totalMeals) / 21.0, 1.0)
        let progressPercent = Int(progress * 100)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week's Progress")
                        .font(.headline)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("\(totalMeals) of 21 meals planned")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.15))
                        .frame(width: 56, height: 56)
                    VStack(spacing: 0) {
                        Text("\(progressPercent)%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.primary)
                        Text("done")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.primary.opacity(0.15))
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [AppTheme.primary, AppTheme.secondary]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
                .frame(height: 8)
            }
            .frame(height: 8)

            HStack(spacing: 8) {
                Image(systemName: totalMeals >= 7 ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(totalMeals >= 7 ? AppTheme.primary : AppTheme.onSurfaceVariant)
                Text(totalMeals >= 7 ? "Great start! Keep it going" : "Add more meals to complete your week")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Spacer()
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var quickAccessGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                QuickAccessCard(icon: "chart.pie", title: "Food Log", color: AppTheme.secondary, action: onNutrition)
                QuickAccessCard(icon: "list.bullet.clipboard", title: "Meal Prep", color: AppTheme.tertiary, action: onMealPrep)
            }
            HStack(spacing: 12) {
                QuickAccessCard(icon: "clock.arrow.circlepath", title: "History", color: AppTheme.tertiary, action: onCookingHistory)
                QuickAccessCard(icon: "medal", title: "Badges", color: AppTheme.secondary, action: onAchievements)
                QuickAccessCard(icon: "function", title: "Converter", color: AppTheme.primary, action: onConverter)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 60)
    }

    private var referralCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 22))
                        .foregroundStyle(AppTheme.primary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Invite Friends")
                        .font(.headline)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("Get 1 week free premium each")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
            }
            .padding(12)
            .background(AppTheme.surfaceVariant.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 8) {
                Button(action: shareReferralCode) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Code")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button(action: {
                    UIPasteboard.general.string = referralManager.userId
                    Haptics.light()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc")
                        Text(referralManager.userId.prefix(6).uppercased())
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(AppTheme.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var plannedMealsEmptyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Get Started", subtitle: "Your 3-minute guide")

            VStack(spacing: 12) {
                quickStartStep(
                    number: "1",
                    title: "Browse 415+ recipes",
                    description: "Find meals you love",
                    icon: "fork.knife",
                    action: { }
                )
                quickStartStep(
                    number: "2",
                    title: "Plan your week",
                    description: "Choose recipes for each meal",
                    icon: "calendar.badge.plus",
                    action: { onOpenPlanner?() }
                )
                quickStartStep(
                    number: "3",
                    title: "Track nutrition",
                    description: "Log meals and see your stats",
                    icon: "chart.pie.fill",
                    action: onNutrition
                )
            }

            Button(action: { onOpenPlanner?() }) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Start Exploring")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(AppTheme.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private func quickStartStep(number: String, title: String, description: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Text(number)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            .padding(12)
            .background(AppTheme.surfaceVariant.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var recentlyCookedEmptyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recently Cooked", subtitle: "Your cooking history")
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.tertiary.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundStyle(AppTheme.tertiary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No meals cooked yet")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.onSurface)
                        Text("Start cooking from your planned meals to build your history")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    Spacer()
                }

                Button(action: { onOpenPlanner?() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "book.fill")
                        Text("View Meal Plan")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(AppTheme.tertiary.opacity(0.1))
                    .foregroundStyle(AppTheme.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .opacity(appeared ? 1 : 0)
    }

    private var plannedMealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Planned Meals", subtitle: "\(dayNameForToday())'s meals")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(store.plannedMealsForToday.enumerated()), id: \.offset) { _, meal in
                        RecipeCardCompact(
                            recipeId: meal.id,
                            name: meal.name,
                            calories: meal.calories,
                            protein: meal.protein,
                            readyInMinutes: store.recipe(byId: meal.id)?.readyInMinutes ?? 25,
                            onClick: { onRecipeSelected(meal.id) }
                        )
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    private var recentlyCookedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Recently Cooked", subtitle: "Your cooking history")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(store.recentHistoryItems.enumerated()), id: \.offset) { _, item in
                        HistoryCard(recipeId: item.recipeId, recipeName: item.recipeName, cookedAt: item.cookedAt) {
                            onRecipeSelected(item.recipeId)
                        }
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    private var featureDiscoverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Explore More", subtitle: "Features you haven't tried yet")

            VStack(spacing: 10) {
                if store.pantryItems.isEmpty {
                    featureCard(
                        icon: "bag.fill",
                        iconColor: AppTheme.secondary,
                        title: "Pantry Manager",
                        description: "Track ingredients and get expiry alerts",
                        action: { }
                    )
                }

                if store.recipeRatings.isEmpty && store.recipeHistory.count > 0 {
                    featureCard(
                        icon: "star.fill",
                        iconColor: AppTheme.secondary,
                        title: "Rate Recipes",
                        description: "Share feedback and unlock ratings badge",
                        action: { }
                    )
                }

                if store.nutritionEntries.isEmpty && store.recipeHistory.count > 0 {
                    featureCard(
                        icon: "chart.pie.fill",
                        iconColor: AppTheme.tertiary,
                        title: "Nutrition Tracking",
                        description: "Log meals and monitor your health goals",
                        action: onNutrition
                    )
                }

                if store.favoriteRecipeIds.isEmpty {
                    featureCard(
                        icon: "heart.fill",
                        iconColor: AppTheme.secondary,
                        title: "Save Favorites",
                        description: "Build your personal recipe collection",
                        action: { }
                    )
                }
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    private func featureCard(icon: String, iconColor: Color, title: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(iconColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(iconColor.opacity(0.6))
            }
            .padding(12)
            .background(AppTheme.surfaceVariant.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var quickTimerCard: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.secondary.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "timer")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Quick Timer")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                Text("Set cooking countdown & get notified")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .padding(12)
        .background(AppTheme.surfaceVariant.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .opacity(appeared ? 1 : 0)
    }

    private var savedRecipesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader(title: "Saved Recipes", subtitle: "Your favorite meals")
                Spacer()
                Text("\(store.favoriteRecipeIds.count)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.1))
                    .clipShape(Capsule())
            }
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.secondary.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.secondary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quick access to your favorites")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.onSurface)
                        Text("Tap recipes you like while browsing to save them here")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    Spacer()
                }
                .padding(12)
                .background(AppTheme.surfaceVariant.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    private var trendingRecipesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Trending Now", subtitle: "Popular this week")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TrendingRecipeCard(title: "Buddha Bowl", emoji: "🥗", badge: "Trending") {
                        onRecipeSelected(3)
                    }
                    TrendingRecipeCard(title: "Grilled Salmon", emoji: "🐟", badge: "Chef's Pick") {
                        onRecipeSelected(5)
                    }
                    TrendingRecipeCard(title: "Pasta Primavera", emoji: "🍝", badge: "Trending") {
                        onRecipeSelected(7)
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    private var weeklyChallengSection: some View {
        let mealsPlanned = store.currentPlan?.days.reduce(0) { count, day in
            count + [day.breakfastId, day.lunchId, day.dinnerId, day.snackId].compactMap { $0 }.count
        } ?? 0

        let thisWeekCooks = store.recipeHistory.filter { item in
            let cookedDate = Date(timeIntervalSince1970: Double(item.cookedAt) / 1000)
            let daysSinceCooked = Calendar.current.dateComponents([.day], from: cookedDate, to: Date()).day ?? 8
            return daysSinceCooked < 7
        }.count

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Weekly Challenge", subtitle: "Earn streaks & badges")

            VStack(spacing: 10) {
                ChallengeCard(
                    title: "Plan 7 Meals",
                    description: "Plan every meal for this week",
                    progress: Double(min(mealsPlanned, 7)) / 7.0,
                    count: "\(mealsPlanned)/7",
                    icon: "📋",
                    color: AppTheme.primary
                )

                ChallengeCard(
                    title: "Cook 5 Times",
                    description: "Actually cook from your plan",
                    progress: Double(min(thisWeekCooks, 5)) / 5.0,
                    count: "\(thisWeekCooks)/5",
                    icon: "👨‍🍳",
                    color: AppTheme.secondary
                )
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    private var habitCalendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Your Habits", subtitle: "Track your cooking momentum")
            HabitCalendar(recipeHistory: store.recipeHistory)
        }
        .opacity(appeared ? 1 : 0)
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Insights", subtitle: "Tips based on your cooking")
            ForEach(InsightRepository.random()) { insight in
                InsightCard(insight: insight) { onInsight(insight.id) }
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }

    private func dayNameForToday() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: Date())
    }
}

private struct QuickActionButton: View {
    let icon: String
    var label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .frame(width: 44, height: 44)
                .background(AppTheme.surfaceVariant.opacity(0.5))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityActionLabel(label, descriptive: "Open \(label)", hint: "Double tap to open \(label)")
        .accessibilityTouchTarget()
    }
}

private struct QuickAccessCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(color)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.onSurface)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityActionLabel(title, descriptive: "Open \(title)", hint: "Double tap to open \(title)")
        .accessibilityTouchTarget()
    }
}

private struct SectionHeader: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.onSurface)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
        }
    }
}

private struct RecipeCardCompact: View {
    let recipeId: Int64
    let name: String
    let calories: Int
    let protein: Int
    let readyInMinutes: Int
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.surfaceVariant)
                        .frame(width: 160, height: 80)

                    AsyncImage(url: URL(string: "https://raw.githubusercontent.com/nullclub365-droid/smartcart-assets/main/\(recipeId).jpg")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        default:
                            Image(systemName: "fork.knife")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.5))
                        }
                    }
                }
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text("\(calories) kcal · \(protein)g protein")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            .frame(width: 160)
            .padding(16)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityActionLabel(name, descriptive: "Planned meal \(name), \(calories) kcal, \(protein)g protein", hint: "Double tap to open recipe")
        .accessibilityTouchTarget()
    }
}

private struct HistoryCard: View {
    let recipeId: Int64
    let recipeName: String
    let cookedAt: Int64
    let onClick: () -> Void

    private var formattedDate: String {
        let d = Date(timeIntervalSince1970: Double(cookedAt) / 1000)
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: d)
    }

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.surfaceVariant)
                        .frame(width: 200, height: 80)

                    AsyncImage(url: URL(string: "https://raw.githubusercontent.com/nullclub365-droid/smartcart-assets/main/\(recipeId).jpg")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        default:
                            Image(systemName: "fork.knife")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.5))
                        }
                    }
                }
                Text(recipeName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                    .lineLimit(2)
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.8))
            }
            .frame(width: 200)
            .padding(16)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityActionLabel(recipeName, descriptive: "Recently cooked \(recipeName), \(formattedDate)", hint: "Double tap to open recipe")
        .accessibilityTouchTarget()
    }
}

private struct InsightCard: View {
    let insight: Insight
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppTheme.tertiary.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: insight.iconName)
                        .font(.system(size: 26))
                        .foregroundStyle(AppTheme.tertiary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(insight.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text(insight.shortDescription)
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 20))
                    .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.6))
            }
            .padding(20)
            .background(AppTheme.tertiaryContainer.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityActionLabel(insight.title, descriptive: "\(insight.title). \(insight.shortDescription)", hint: "Double tap to read more")
        .accessibilityTouchTarget()
    }
}

#Preview {
    HomeScreen(
        onRecipeSelected: { _ in },
        onSettings: {},
        onPremium: {},
        onNutrition: {},
        onMealPrep: {},
        onStatistics: {},
        onTimers: {},
        onCookingHistory: {},
        onAchievements: {},
        onConverter: {},
        onInsight: { _ in }
    )
    .environmentObject(AppStore())
}
