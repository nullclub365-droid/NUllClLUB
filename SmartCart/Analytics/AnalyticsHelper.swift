//
//  AnalyticsHelper.swift
//  SmartCart
//
//  Centralized analytics tracking for Firebase
//

import FirebaseAnalytics

class AnalyticsHelper {

    // MARK: - Core Actions

    static func trackMealPlanCreated(mealCount: Int) {
        Analytics.logEvent("meal_plan_created", parameters: [
            "meal_count": mealCount,
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    static func trackFirstMealPlanCreated() {
        Analytics.logEvent("first_meal_plan_created", parameters: [
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    // MARK: - Premium

    static func trackPremiumViewed(source: String = "settings") {
        Analytics.logEvent("premium_viewed", parameters: [
            "source": source
        ])
    }

    static func trackPremiumPurchased(price: Double, period: String = "monthly") {
        Analytics.logEvent("premium_purchased", parameters: [
            "price": NSNumber(value: price),
            "currency": "USD",
            "period": period,
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    // MARK: - Sharing & Growth

    static func trackShareInitiated(type: String, content: String = "") {
        Analytics.logEvent("share_initiated", parameters: [
            "share_type": type, // "meal_plan", "recipe", "achievement"
            "content_type": content,
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    static func trackShareCompleted(type: String, medium: String = "") {
        Analytics.logEvent("share_completed", parameters: [
            "share_type": type,
            "medium": medium, // "iMessage", "email", "social"
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    static func trackReferralShared(code: String) {
        Analytics.logEvent("referral_shared", parameters: [
            "referral_code": code,
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    // MARK: - Feature Usage

    static func trackFeatureUsed(_ featureName: String, details: [String: Any] = [:]) {
        var params: [String: NSObject] = ["feature_name": featureName as NSString]
        for (key, value) in details {
            if let nsValue = value as? NSObject {
                params[key] = nsValue
            } else if let intValue = value as? Int {
                params[key] = NSNumber(value: intValue)
            } else if let doubleValue = value as? Double {
                params[key] = NSNumber(value: doubleValue)
            } else if let stringValue = value as? String {
                params[key] = stringValue as NSString
            }
        }
        Analytics.logEvent("feature_used", parameters: params)
    }

    static func trackRecipeCookStarted(recipeId: String, recipeName: String) {
        Analytics.logEvent("recipe_cook_started", parameters: [
            "recipe_id": recipeId,
            "recipe_name": recipeName,
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    static func trackRecipeCooked(recipeId: String, recipeName: String, cookTime: Int) {
        Analytics.logEvent("recipe_cooked", parameters: [
            "recipe_id": recipeId,
            "recipe_name": recipeName,
            "cook_time": cookTime,
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    static func trackNutritionLogged(calories: Int, protein: Int) {
        Analytics.logEvent("nutrition_logged", parameters: [
            "calories": calories,
            "protein": protein,
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    // MARK: - Achievements

    static func trackAchievementUnlocked(achievementId: String, achievementName: String) {
        Analytics.logEvent("achievement_unlocked", parameters: [
            "achievement_id": achievementId,
            "achievement_name": achievementName,
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    // MARK: - Onboarding

    static func trackOnboardingStarted() {
        Analytics.logEvent("onboarding_started", parameters: [
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    static func trackOnboardingCompleted() {
        Analytics.logEvent("onboarding_completed", parameters: [
            "timestamp": NSNumber(value: Date().timeIntervalSince1970)
        ])
    }

    // MARK: - Screen Views (Auto-tracked by Firebase, but can supplement)

    static func trackScreenViewed(_ screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenName
        ])
    }
}
