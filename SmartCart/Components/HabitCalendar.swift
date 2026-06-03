//
//  HabitCalendar.swift
//  SmartCart
//

import SwiftUI

struct HabitCalendar: View {
    let recipeHistory: [RecipeHistoryItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cooking Habit")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("This month's activity")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
                Text("\(currentStreak) day streak 🔥")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.secondary)
            }

            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(weekdayLabels, id: \.self) { day in
                        Text(day)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                            .frame(maxWidth: .infinity)
                    }
                }

                let days = daysInCurrentMonth()
                let firstWeekday = firstWeekdayOfMonth()
                let grid = gridItems(days: days, startingWeekday: firstWeekday)

                ForEach(0..<grid.count, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { col in
                            let idx = row * 7 + col
                            if idx < grid.count {
                                dayCell(grid[idx])
                            } else {
                                Color.clear
                                    .frame(height: 32)
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(AppTheme.surfaceVariant.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var weekdayLabels: [String] {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }

    private var currentStreak: Int {
        var streak = 0
        let today = Date()
        let calendar = Calendar.current

        for i in 0...30 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let cookedThisDay = recipeHistory.contains { item in
                let cookedDate = Date(timeIntervalSince1970: Double(item.cookedAt) / 1000)
                return cookedDate >= dayStart && cookedDate < dayEnd
            }

            if cookedThisDay {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    private func daysInCurrentMonth() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())!
        return range.count
    }

    private func firstWeekdayOfMonth() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let date = calendar.date(from: components)!
        let weekday = calendar.component(.weekday, from: date)
        return weekday - 1
    }

    private func gridItems(days: Int, startingWeekday: Int) -> [Int?] {
        var items: [Int?] = Array(repeating: nil, count: startingWeekday)
        items.append(contentsOf: (1...days).map { $0 })
        return items
    }

    private func dayCell(_ day: Int?) -> some View {
        let hasActivity = day.map { checkActivity(day: $0) } ?? false
        let opacity = hasActivity ? 1.0 : 0.3

        return ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(AppTheme.primary.opacity(opacity))
            if let day = day {
                Text("\(day)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
        }
        .frame(height: 32)
    }

    private func checkActivity(day: Int) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)

        guard let targetDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: day)) else {
            return false
        }

        let dayStart = calendar.startOfDay(for: targetDate)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

        return recipeHistory.contains { item in
            let cookedDate = Date(timeIntervalSince1970: Double(item.cookedAt) / 1000)
            return cookedDate >= dayStart && cookedDate < dayEnd
        }
    }
}

#Preview {
    HabitCalendar(recipeHistory: [
        RecipeHistoryItem(recipeId: 1, cookedAt: Int64(Date().timeIntervalSince1970 * 1000)),
        RecipeHistoryItem(recipeId: 2, cookedAt: Int64(Date(timeIntervalSinceNow: -86400).timeIntervalSince1970 * 1000)),
        RecipeHistoryItem(recipeId: 3, cookedAt: Int64(Date(timeIntervalSinceNow: -86400 * 3).timeIntervalSince1970 * 1000))
    ])
    .padding()
    .background(AppTheme.background)
}
