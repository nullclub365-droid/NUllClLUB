//
//  NotificationScheduler.swift
//  SmartCart
//

import Foundation
import UserNotifications

enum NotificationScheduler {
    private static let prefix = "smartcart_"

    // MARK: - UserDefaults keys
    static let keyBreakfastTime = "\(prefix)breakfast_time"      // "08:00"
    static let keyLunchTime = "\(prefix)lunch_time"              // "12:00"
    static let keyDinnerTime = "\(prefix)dinner_time"            // "18:00"
    static let keyMealRemindersEnabled = "\(prefix)meal_reminders_enabled"
    static let keyRemindWhenNoMealPlanned = "\(prefix)remind_no_meal"
    static let keyExpiryReminderEnabled = "\(prefix)expiry_reminder_enabled"
    static let keyExpiryDaysBefore = "\(prefix)expiry_days_before"

    // MARK: - Permission
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    static func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    // MARK: - Clear
    static func clearAllPending() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.identifier.hasPrefix(prefix) }.map(\.identifier)
            guard !ids.isEmpty else { return }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    // MARK: - Schedule
    static func schedule(store: AppStore) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests.filter { $0.identifier.hasPrefix(prefix) }.map(\.identifier)
            if !ids.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
            }
            DispatchQueue.main.async {
                performSchedule(store: store)
            }
        }
    }

    private static func performSchedule(store: AppStore) {
        let defaults = UserDefaults.standard
        let mealEnabled = defaults.bool(forKey: keyMealRemindersEnabled)
        let remindNoMeal = defaults.bool(forKey: keyRemindWhenNoMealPlanned)
        let breakfastStr = defaults.string(forKey: keyBreakfastTime) ?? "08:00"
        let lunchStr = defaults.string(forKey: keyLunchTime) ?? "12:00"
        let dinnerStr = defaults.string(forKey: keyDinnerTime) ?? "18:00"
        let expiryEnabled = defaults.bool(forKey: keyExpiryReminderEnabled)
        let expiryDays = defaults.integer(forKey: keyExpiryDaysBefore)
        let expiryDaysBefore = expiryDays > 0 ? expiryDays : 2

        if mealEnabled {
            scheduleMealReminders(
                plan: store.currentPlan,
                recipes: store.recipes,
                breakfastTime: breakfastStr,
                lunchTime: lunchStr,
                dinnerTime: dinnerStr,
                remindWhenNoMeal: remindNoMeal
            )
        }
        if expiryEnabled {
            scheduleExpiryReminders(
                pantryItems: store.pantryItems,
                ingredients: store.ingredients,
                daysBefore: expiryDaysBefore
            )
        }
    }

    // MARK: - Meal reminders
    private static func scheduleMealReminders(
        plan: MealPlanInstance?,
        recipes: [Recipe],
        breakfastTime: String,
        lunchTime: String,
        dinnerTime: String,
        remindWhenNoMeal: Bool
    ) {
        let calendar = Calendar.current
        let recipeMap = Dictionary(uniqueKeysWithValues: recipes.map { ($0.id, $0) })
        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

        func parseTime(_ s: String) -> (hour: Int, minute: Int)? {
            let parts = s.split(separator: ":")
            guard parts.count >= 2,
                  let h = Int(parts[0]), let m = Int(parts[1]),
                  h >= 0, h <= 23, m >= 0, m <= 59 else { return nil }
            return (h, m)
        }

        guard let b = parseTime(breakfastTime), let l = parseTime(lunchTime), let d = parseTime(dinnerTime) else { return }

        var toSchedule: [(date: Date, identifier: String, title: String, body: String)] = []

        for dayOffset in 0..<7 {
            guard let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: Date())) else { continue }
            let weekday = calendar.component(.weekday, from: dayDate) // 1 = Sunday
            let dayName = dayNames[weekday - 1]
            let dayPlan = plan?.days.first { $0.dayOfWeek == dayName }

            // Breakfast
            if var fire = calendar.date(bySettingHour: b.hour, minute: b.minute, second: 0, of: dayDate) {
                let recipeId = dayPlan?.breakfastId
                let recipe = recipeId.flatMap { recipeMap[$0] }
                if let r = recipe {
                    fire = calendar.date(byAdding: .minute, value: -r.readyInMinutes, to: fire) ?? fire
                    toSchedule.append((
                        fire,
                        "\(prefix)meal_breakfast_\(dayOffset)_\(dayName)",
                        "Start cooking",
                        "\(r.name) for breakfast – ready in \(r.readyInMinutes) min"
                    ))
                } else if remindWhenNoMeal {
                    toSchedule.append((
                        fire,
                        "\(prefix)meal_breakfast_\(dayOffset)_\(dayName)",
                        "Breakfast at \(breakfastTime)",
                        "No meal planned"
                    ))
                }
            }

            // Lunch
            if var fire = calendar.date(bySettingHour: l.hour, minute: l.minute, second: 0, of: dayDate) {
                let recipeId = dayPlan?.lunchId
                let recipe = recipeId.flatMap { recipeMap[$0] }
                if let r = recipe {
                    fire = calendar.date(byAdding: .minute, value: -r.readyInMinutes, to: fire) ?? fire
                    toSchedule.append((
                        fire,
                        "\(prefix)meal_lunch_\(dayOffset)_\(dayName)",
                        "Start cooking",
                        "\(r.name) for lunch – ready in \(r.readyInMinutes) min"
                    ))
                } else if remindWhenNoMeal {
                    toSchedule.append((
                        fire,
                        "\(prefix)meal_lunch_\(dayOffset)_\(dayName)",
                        "Lunch at \(lunchTime)",
                        "No meal planned"
                    ))
                }
            }

            // Dinner
            if var fire = calendar.date(bySettingHour: d.hour, minute: d.minute, second: 0, of: dayDate) {
                let recipeId = dayPlan?.dinnerId
                let recipe = recipeId.flatMap { recipeMap[$0] }
                if let r = recipe {
                    fire = calendar.date(byAdding: .minute, value: -r.readyInMinutes, to: fire) ?? fire
                    toSchedule.append((
                        fire,
                        "\(prefix)meal_dinner_\(dayOffset)_\(dayName)",
                        "Start cooking",
                        "\(r.name) for dinner – ready in \(r.readyInMinutes) min"
                    ))
                } else if remindWhenNoMeal {
                    toSchedule.append((
                        fire,
                        "\(prefix)meal_dinner_\(dayOffset)_\(dayName)",
                        "Dinner at \(dinnerTime)",
                        "No meal planned"
                    ))
                }
            }
        }

        let now = Date()
        for item in toSchedule where item.date > now {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.body
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: item.date), repeats: false)
            let request = UNNotificationRequest(identifier: item.identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    // MARK: - Expiry reminders
    private static func scheduleExpiryReminders(
        pantryItems: [PantryItem],
        ingredients: [Ingredient],
        daysBefore: Int
    ) {
        let ingredientMap = Dictionary(uniqueKeysWithValues: ingredients.map { ($0.id, $0) })
        let calendar = Calendar.current
        let now = Date()

        for item in pantryItems {
            guard let expiryMs = item.expiryDate else { continue }
            let expiryDate = Date(timeIntervalSince1970: TimeInterval(expiryMs) / 1000)
            let daysUntilExpiry = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: expiryDate)).day ?? 0
            guard daysUntilExpiry >= 0, daysUntilExpiry <= daysBefore else { continue }

            let name = ingredientMap[item.ingredientId]?.canonicalName ?? "Item"
            let dayToNotify = calendar.date(byAdding: .day, value: -daysUntilExpiry, to: calendar.startOfDay(for: expiryDate)) ?? expiryDate
            let notifyDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dayToNotify) ?? dayToNotify
            let body: String
            if daysUntilExpiry == 0 { body = "\(name) expires today" }
            else if daysUntilExpiry == 1 { body = "\(name) expires tomorrow" }
            else { body = "\(name) expires in \(daysUntilExpiry) days" }

            guard notifyDate > now else { continue }
            let content = UNMutableNotificationContent()
            content.title = "Expiring soon"
            content.body = body
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notifyDate), repeats: false)
            let id = "\(prefix)expiry_\(item.ingredientId)_\(expiryMs)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
