//
//  ShareHelper.swift
//  SmartCart
//
//  Centralized sharing functionality for growth loops
//

import SwiftUI

class ShareHelper {

    static let appStoreLink = "https://apps.apple.com/us/app/smartcart-grocery-recipes/id6759084715"

    // MARK: - Meal Plan Sharing

    static func shareMealPlan(meals: [String], dayNames: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]) -> String {
        var mealTexts = [String]()

        for (index, meal) in meals.enumerated() {
            if index < dayNames.count {
                mealTexts.append("\(dayNames[index]): \(meal)")
            }
        }

        let message = """
        Check out my week plan in SmartCart! 🍽️

        \(mealTexts.joined(separator: "\n"))

        Download SmartCart and plan your meals in 5 minutes. No account needed.

        \(appStoreLink)
        """

        // Track the share
        AnalyticsHelper.trackShareInitiated(type: "meal_plan", content: "week_plan")

        return message
    }

    // MARK: - Recipe Sharing

    static func shareRecipe(name: String, cookTime: Int, calories: Int, protein: Int) -> String {
        let message = """
        Just found this amazing recipe in SmartCart: 🍽️

        \(name)
        ⏱️ \(cookTime) minutes
        🥗 \(calories) cal | \(protein)g protein

        Try it yourself in SmartCart - meal planner with 415+ recipes. Download free.

        \(appStoreLink)
        """

        // Track the share
        AnalyticsHelper.trackShareInitiated(type: "recipe", content: name)

        return message
    }

    // MARK: - Achievement Sharing

    static func shareAchievement(name: String, description: String) -> String {
        let message = """
        🏆 I just unlocked "\(name)" in SmartCart!

        \(description)

        Join me in SmartCart - free meal planner with 415+ recipes.

        \(appStoreLink)
        """

        // Track the share
        AnalyticsHelper.trackShareInitiated(type: "achievement", content: name)

        return message
    }

    // MARK: - Referral Sharing

    static func shareReferral(code: String) -> String {
        let referralLink = "https://smartcart.app/ref/\(code)"

        let message = """
        Hey! I'm using SmartCart to plan my meals and save time on groceries.

        You get 1 week free premium when you sign up with my link:
        \(referralLink)

        Free meal planner with 415+ recipes, grocery list, nutrition tracking. No account needed.

        Download: \(appStoreLink)
        """

        // Track the referral share
        AnalyticsHelper.trackReferralShared(code: code)

        return message
    }

    // MARK: - Generic Share Handler

    static func shareContent(_ content: String, completion: @escaping (Bool) -> Void) {
        let activityController = UIActivityViewController(activityItems: [content], applicationActivities: nil)

        // Exclude certain activity types
        activityController.excludedActivityTypes = [
            .addToReadingList,
            .print
        ]

        activityController.completionWithItemsHandler = { _, completed, _, _ in
            if completed {
                AnalyticsHelper.trackShareCompleted(type: "generic")
            }
            completion(completed)
        }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
}

