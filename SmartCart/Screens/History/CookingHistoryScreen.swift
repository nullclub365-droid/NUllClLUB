//
//  CookingHistoryScreen.swift
//  SmartCart
//

import SwiftUI

struct CookingHistoryScreen: View {
    @EnvironmentObject var store: AppStore
    var onRecipeClick: (Int64) -> Void
    var onBack: () -> Void

    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date? = nil

    private let calendar = Calendar.current
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    private var monthStart: Date { calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))! }
    private var monthEnd: Date { calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)! }
    private var monthStartMs: Int64 { Int64(monthStart.timeIntervalSince1970 * 1000) }
    private var monthEndMs: Int64 { Int64(monthEnd.timeIntervalSince1970 * 1000) + 86400 * 1000 - 1 }

    private var historyInMonth: [RecipeHistoryItem] {
        store.recipeHistory.filter { $0.cookedAt >= monthStartMs && $0.cookedAt <= monthEndMs }
    }

    private var cookingDates: [Int64: Int] {
        Dictionary(grouping: historyInMonth, by: { startOfDayMs(for: $0.cookedAt) })
            .mapValues { $0.count }
    }

    private var selectedDateStartMs: Int64? {
        guard let d = selectedDate else { return nil }
        return Int64(calendar.startOfDay(for: d).timeIntervalSince1970 * 1000)
    }

    private var recipesOnSelectedDate: [(recipeId: Int64, name: String, cookedAt: Int64, count: Int)] {
        guard let dayStart = selectedDateStartMs else { return [] }
        let dayEnd = dayStart + 86400 * 1000
        let dayHistory = store.recipeHistory.filter { $0.cookedAt >= dayStart && $0.cookedAt < dayEnd }
        return Dictionary(grouping: dayHistory, by: { $0.recipeId })
            .map { (recipeId, entries) in
                let r = store.recipe(byId: recipeId)
                return (recipeId, r?.name ?? "Recipe", entries[0].cookedAt, entries.count)
            }
            .sorted { $0.cookedAt > $1.cookedAt }
    }

    private var totalCookedThisMonth: Int { historyInMonth.count }
    private var uniqueRecipesThisMonth: Int { Set(historyInMonth.map(\.recipeId)).count }

    private var topRecipesThisMonth: [(recipeId: Int64, name: String, count: Int)] {
        let grouped = Dictionary(grouping: historyInMonth, by: { $0.recipeId })
        let withCount: [(recipeId: Int64, name: String, count: Int)] = grouped.map { recipeId, entries in
            let name = store.recipe(byId: recipeId)?.name ?? "Recipe"
            return (recipeId: recipeId, name: name, count: entries.count)
        }
        let sorted = withCount.sorted { $0.count > $1.count }
        return Array(sorted.prefix(5))
    }

    private var foodLogEntriesForSelectedDate: [DailyNutritionEntry] {
        guard let dayStart = selectedDateStartMs else { return [] }
        return store.nutritionEntries.filter { $0.date == dayStart }.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Cooking History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                    .padding(.horizontal)

                calendarCard
                if let _ = selectedDate {
                    selectedDateSection
                } else {
                    monthlySummarySection
                }
            }
            .padding(.vertical, 16)
        }
        .background(AppTheme.background)
        .navigationTitle("Cooking History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var calendarCard: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(AppTheme.primary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                Spacer()
                Text(monthYearString(from: currentMonth))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(AppTheme.primary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)

            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(Array(daysInMonthGrid().enumerated()), id: \.offset) { _, day in
                    if let date = day {
                        let dayStart = Int64(calendar.startOfDay(for: date).timeIntervalSince1970 * 1000)
                        let count = cookingDates[dayStart] ?? 0
                        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
                        Button(action: {
                            selectedDate = isSelected ? nil : date
                        }) {
                            VStack(spacing: 2) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.subheadline)
                                    .fontWeight(isSelected ? .bold : .regular)
                                    .foregroundStyle(isSelected ? .white : AppTheme.onSurface)
                                if count > 0 {
                                    Text("\(count)")
                                        .font(.caption2)
                                        .foregroundStyle(isSelected ? .white.opacity(0.9) : AppTheme.primary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(isSelected ? AppTheme.primary : (count > 0 ? AppTheme.primary.opacity(0.15) : Color.clear))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(AppTheme.surfaceVariant.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private var selectedDateSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let d = selectedDate {
                Text(formattedDate(d))
                    .font(.headline)
                    .foregroundStyle(AppTheme.onSurface)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Recipes cooked")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                if recipesOnSelectedDate.isEmpty {
                    Text("No recipes cooked this day")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(Array(recipesOnSelectedDate.enumerated()), id: \.offset) { _, item in
                        Button(action: { onRecipeClick(item.recipeId) }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(AppTheme.onSurface)
                                    if item.count > 1 {
                                        Text("Cooked \(item.count) times")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.onSurfaceVariant)
                                    }
                                }
                                Spacer()
                                Text(formatTime(item.cookedAt))
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                            }
                            .padding(12)
                            .background(AppTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Food log")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                if foodLogEntriesForSelectedDate.isEmpty {
                    Text("No food log entries this day")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(foodLogEntriesForSelectedDate) { entry in
                        FoodLogHistoryEntryRow(entry: entry, store: store)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var monthlySummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(monthYearString(from: currentMonth)) summary")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)

            HStack(spacing: 16) {
                summaryPill(value: "\(totalCookedThisMonth)", label: "Cooked")
                summaryPill(value: "\(uniqueRecipesThisMonth)", label: "Unique")
            }

            if !topRecipesThisMonth.isEmpty {
                Text("Top recipes")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                ForEach(Array(topRecipesThisMonth.enumerated()), id: \.offset) { idx, item in
                    HStack {
                        Text("\(idx + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(AppTheme.primary)
                            .clipShape(Circle())
                        Text(item.name)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.onSurface)
                        Spacer()
                        Text("\(item.count)×")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    .padding(12)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Text("No cooking this month yet")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }

    private func summaryPill(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.onSurface)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func daysInMonthGrid() -> [Date?] {
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)!.count
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for d in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: d, of: monthStart) {
                days.append(date)
            }
        }
        let remainder = 42 - days.count
        if remainder > 0 { days.append(contentsOf: Array(repeating: nil, count: remainder)) }
        return days
    }

    private func previousMonth() {
        selectedDate = nil
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }

    private func nextMonth() {
        selectedDate = nil
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }

    private func startOfDayMs(for cookedAt: Int64) -> Int64 {
        let d = Date(timeIntervalSince1970: Double(cookedAt) / 1000)
        return Int64(calendar.startOfDay(for: d).timeIntervalSince1970 * 1000)
    }

    private func monthYearString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: date)
    }

    private func formatTime(_ cookedAt: Int64) -> String {
        let d = Date(timeIntervalSince1970: Double(cookedAt) / 1000)
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: d)
    }
}

private struct FoodLogHistoryEntryRow: View {
    let entry: DailyNutritionEntry
    @ObservedObject var store: AppStore

    private var label: String {
        if entry.entryType == "manual" {
            return "Manual: \(entry.calories) kcal"
        }
        if entry.entryType == "recipe" || entry.entryType == "custom", let name = entry.quantityText, !name.isEmpty {
            return "\(name): \(entry.calories) kcal"
        }
        if let id = entry.ingredientId, let ing = store.ingredient(byId: id) {
            let portion = entry.quantityText ?? ing.standardServing
            if let p = portion, !p.isEmpty {
                return "\(ing.canonicalName) (\(p)) · \(entry.calories) kcal"
            }
            return "\(ing.canonicalName) · \(entry.calories) kcal"
        }
        return "\(entry.calories) kcal"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.onSurface)
                if let p = entry.protein, p > 0 {
                    Text("\(p)g protein")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        CookingHistoryScreen(onRecipeClick: { _ in }, onBack: {})
            .environmentObject(AppStore())
    }
}
