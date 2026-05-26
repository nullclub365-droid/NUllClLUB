# Phase 5: Growth Loops Implementation Guide

## Overview

Growth loops are **mechanisms that turn users into promoters**. Every action a user takes can trigger sharing/referral, which brings new users.

For SmartCart, we'll implement:
1. **Share Meal Plan** — User plans a week, taps "Share" → iMessage/email/social
2. **Share Recipe** — User finds good recipe, shares it → brings friends
3. **Referral System** — "Invite a friend → Get 1 week premium free"
4. **Analytics Tracking** — Measure which loops work

---

## Loop 1: Share Meal Plan

### When to Show the Share Button
- ✅ After user completes their first meal plan
- ✅ After each successful week plan
- ✅ On the Meal Plan screen (bottom button)

### What to Share
```
"Check out my week plan in SmartCart! 

Mon: Chicken Rice Bowl
Tue: Protein Oats
Wed: Mediterranean Quinoa Bowl
Thu: Turkey Chili
Fri: Comfort Fried Egg Rice

Download SmartCart and plan your meals in 5 minutes. No account needed.

https://apps.apple.com/us/app/smartcart-grocery-recipes/id6759084715"
```

### Code to Add (Swift/SwiftUI)

Add this to your MealPlannerScreen or wherever the meal plan is displayed:

```swift
import ShareSheet

// Add this button to your meal plan view
Button(action: shareMealPlan) {
    HStack {
        Image(systemName: "square.and.arrow.up")
        Text("Share This Week")
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.blue)
    .foregroundColor(.white)
    .cornerRadius(8)
}
.sheet(isPresented: $showShareSheet) {
    ShareSheet(items: [mealPlanShareText])
}

// Function to format meal plan as text
private func shareMealPlan() {
    let mealTexts = meals.enumerated().map { (index, meal) in
        let day = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][index]
        return "\(day): \(meal.name)"
    }
    
    let message = """
    Check out my week plan in SmartCart! 
    
    \(mealTexts.joined(separator: "\n"))
    
    Download SmartCart and plan your meals in 5 minutes. No account needed.
    
    https://apps.apple.com/us/app/smartcart-grocery-recipes/id6759084715
    """
    
    mealPlanShareText = message
    showShareSheet = true
}

// Add to view state
@State private var showShareSheet = false
@State private var mealPlanShareText = ""
```

### Analytics Event
```swift
// Track when user shares meal plan
Analytics.logEvent("meal_plan_shared", parameters: [
    "week_count": userMealPlansCount,
    "timestamp": Date().timeIntervalSince1970
])
```

---

## Loop 2: Share Recipe

### When to Show the Share Button
- ✅ On the Recipe Detail screen
- ✅ After user marks a recipe as favorite
- ✅ In the Recipe list (swipe action or menu)

### What to Share
```
"Just found this amazing recipe in SmartCart:

🍽️ Chicken Broccoli Rice Bowl
⏱️ 20 minutes
🥗 450 cal | 35g protein | 45g carbs

Try it yourself in SmartCart - meal planner with 415+ recipes. Download free.

https://apps.apple.com/us/app/smartcart-grocery-recipes/id6759084715"
```

### Code to Add

```swift
// Add to RecipeDetailScreen
Button(action: shareRecipe) {
    HStack {
        Image(systemName: "square.and.arrow.up")
        Text("Share Recipe")
    }
    .padding()
    .background(Color.green)
    .foregroundColor(.white)
    .cornerRadius(8)
}
.sheet(isPresented: $showRecipeShareSheet) {
    ShareSheet(items: [recipeShareText])
}

// Function to format recipe for sharing
private func shareRecipe() {
    let nutrition = "🥗 \(recipe.calories) cal | \(recipe.protein)g protein | \(recipe.carbs)g carbs"
    
    let message = """
    Just found this amazing recipe in SmartCart:
    
    🍽️ \(recipe.name)
    ⏱️ \(recipe.cookTime) minutes
    \(nutrition)
    
    Try it yourself in SmartCart - meal planner with 415+ recipes. Download free.
    
    https://apps.apple.com/us/app/smartcart-grocery-recipes/id6759084715
    """
    
    recipeShareText = message
    showRecipeShareSheet = true
}

// Add to view state
@State private var showRecipeShareSheet = false
@State private var recipeShareText = ""
```

### Analytics Event
```swift
Analytics.logEvent("recipe_shared", parameters: [
    "recipe_id": recipe.id,
    "recipe_name": recipe.name,
    "timestamp": Date().timeIntervalSince1970
])
```

---

## Loop 3: Referral System

### How It Works
1. User gets unique referral link (stored locally)
2. User taps "Invite Friends" 
3. Shares link via iMessage/email/social
4. Friend downloads app with that link
5. Both get 1 week premium free

### Implementation Steps

#### Step 1: Generate Unique Referral Code

```swift
import CryptoKit

class ReferralManager {
    static let shared = ReferralManager()
    
    private let userDefaultsKey = "smartcart_referral_code"
    
    // Get or generate referral code
    var referralCode: String {
        if let existing = UserDefaults.standard.string(forKey: userDefaultsKey) {
            return existing
        }
        
        let code = generateCode()
        UserDefaults.standard.set(code, forKey: userDefaultsKey)
        return code
    }
    
    // Generate 8-character alphanumeric code
    private func generateCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in characters.randomElement()! })
    }
    
    // Get full referral link
    var referralLink: String {
        return "https://smartcart.app/ref/\(referralCode)"
        // Or use App Store link with campaign tracking:
        // "https://apps.apple.com/us/app/smartcart-grocery-recipes/id6759084715?utm_source=referral&utm_medium=share&utm_campaign=\(referralCode)"
    }
}
```

#### Step 2: Add Referral Invite Button

```swift
// Add to HomeScreen or Settings
Button(action: showReferralSheet) {
    HStack {
        Image(systemName: "person.badge.plus")
        Text("Invite Friends & Get Free Premium")
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.purple)
    .foregroundColor(.white)
    .cornerRadius(8)
}
.sheet(isPresented: $showReferralSheet) {
    ShareSheet(items: [referralMessage])
}

private func showReferralSheet() {
    let referralLink = ReferralManager.shared.referralLink
    
    let message = """
    Hey! I'm using SmartCart to plan my meals and save time on groceries.
    
    You get 1 week free premium when you sign up with my link:
    \(referralLink)
    
    Free meal planner with 415+ recipes, grocery list, nutrition tracking. No account needed.
    
    Download: https://apps.apple.com/us/app/smartcart-grocery-recipes/id6759084715
    """
    
    referralMessage = message
    showReferralSheet = true
}

@State private var showReferralSheet = false
@State private var referralMessage = ""
```

#### Step 3: Track Referral

```swift
// When user taps share
Analytics.logEvent("referral_shared", parameters: [
    "referral_code": ReferralManager.shared.referralCode,
    "timestamp": Date().timeIntervalSince1970
])

// When app launches, check for referral code in deep link
// (You'd handle this in ContentView or SceneDelegate)
if let referralCode = getLaunchReferralCode() {
    Analytics.logEvent("referral_clicked", parameters: [
        "referral_code": referralCode
    ])
    
    // Give user 7 days free premium
    grantPremiumDays(7, reason: "referral")
}
```

---

## Loop 4: Achievement Share

### How It Works
User unlocks achievement → Automatic prompt to share → "Share this win!"

### When to Trigger
- ✅ After 7-day cooking streak
- ✅ After 50 recipes cooked
- ✅ After first meal plan completed

### Code

```swift
// When achievement unlocked
func unlockAchievement(_ achievement: Achievement) {
    // Save achievement
    userAchievements.append(achievement)
    
    // Track
    Analytics.logEvent("achievement_unlocked", parameters: [
        "achievement_id": achievement.id,
        "achievement_name": achievement.name
    ])
    
    // Show share prompt
    showAchievementSharePrompt = true
    achievementToShare = achievement
}

// Share achievement
Button("Share Your Achievement") {
    let message = """
    🏆 I just unlocked "\(achievement.name)" in SmartCart!
    
    \(achievement.description)
    
    Join me in SmartCart - free meal planner with 415+ recipes.
    
    https://apps.apple.com/us/app/smartcart-grocery-recipes/id6759084715
    """
    
    // Show share sheet
    ShareSheet(items: [message])
}

@State private var showAchievementSharePrompt = false
@State private var achievementToShare: Achievement?
```

---

## ShareSheet Component (If Needed)

If you need a custom ShareSheet:

```swift
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Exclude certain activity types
        controller.excludedActivityTypes = [
            .addToReadingList,
            .print,
            .saveToPinterest
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
```

---

## Analytics Dashboard (What to Track)

In Firebase Console, create these custom events:

| Event | When | What to Measure |
|-------|------|-----------------|
| `meal_plan_shared` | User shares meal plan | Sharing frequency |
| `recipe_shared` | User shares recipe | Popular recipes |
| `referral_shared` | User shares referral link | Referral traffic |
| `referral_clicked` | Friend opens referral link | Conversion |
| `achievement_unlocked` | User earns badge | Engagement |
| `achievement_shared` | User shares achievement | Viral potential |

---

## Implementation Checklist

- [ ] Add Share Meal Plan button + code
- [ ] Add Share Recipe button + code
- [ ] Add Referral Manager class
- [ ] Add Invite Friends button
- [ ] Add Achievement Share prompt
- [ ] Test all share flows (send to yourself)
- [ ] Verify all events log in Firebase
- [ ] Build & run on device (simulator may have share limitations)

---

## Expected Impact

**After implementing growth loops:**
- 10-20% of users share content weekly
- 5-10% of downloads come from referral links
- Viral coefficient: 0.1-0.2 (each user brings 0.1-0.2 friends)

**Monthly impact:** If you have 500 users, expect 50-100 new users from sharing/referrals.

---

## Next Phase: Track & Optimize

Monitor these metrics in Firebase:
- Share rate (% of users who share)
- Referral conversion (% of shares → installs)
- Which content is shared most?
- Which channels (iMessage vs email vs social)?

Then optimize: More share prompts on high-engagement features, less on low-engagement.

---

*Growth loops compound over time. A small 5% referral rate compounds to 2x growth in 6 months.*
