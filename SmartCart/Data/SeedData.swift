//
//  SeedData.swift
//  SmartCart
//

import Foundation

enum SeedData {
    static let ingredients: [Ingredient] = [
        Ingredient(id: 1, canonicalName: "Eggs", category: "Dairy", aliases: ["egg", "eggs"], caloriesPerServing: 78, proteinPerServing: 6, carbsPerServing: 0, fatsPerServing: 5, standardServing: "1 large egg"),
        Ingredient(id: 2, canonicalName: "Milk", category: "Dairy", aliases: ["milk"], caloriesPerServing: 150, proteinPerServing: 8, carbsPerServing: 12, fatsPerServing: 8, standardServing: "1 cup"),
        Ingredient(id: 11, canonicalName: "Chicken Breast", category: "Meat", aliases: ["chicken"], caloriesPerServing: 165, proteinPerServing: 31, carbsPerServing: 0, fatsPerServing: 4, standardServing: "100g"),
        Ingredient(id: 36, canonicalName: "Russet Potato", category: "Produce", aliases: ["potato"], caloriesPerServing: 133, proteinPerServing: 3, carbsPerServing: 29, fatsPerServing: 0, standardServing: "1 medium potato"),
        Ingredient(id: 41, canonicalName: "Onion Yellow", category: "Produce", aliases: ["onion"], caloriesPerServing: 44, proteinPerServing: 1, carbsPerServing: 10, fatsPerServing: 0, standardServing: "1 medium onion"),
        Ingredient(id: 42, canonicalName: "Garlic", category: "Produce", aliases: ["garlic"], caloriesPerServing: 4, proteinPerServing: 0, carbsPerServing: 1, fatsPerServing: 0, standardServing: "1 clove"),
        Ingredient(id: 37, canonicalName: "Broccoli", category: "Produce", aliases: ["broccoli"], caloriesPerServing: 31, proteinPerServing: 3, carbsPerServing: 6, fatsPerServing: 0, standardServing: "1 cup chopped"),
        Ingredient(id: 7, canonicalName: "Butter", category: "Dairy", aliases: ["butter"], caloriesPerServing: 102, proteinPerServing: 0, carbsPerServing: 0, fatsPerServing: 12, standardServing: "1 tbsp")
    ]

    static let recipes: [Recipe] = [
        Recipe(
            id: 1,
            name: "Simple Grilled Chicken",
            description: "Quick grilled chicken breast with herbs.",
            calories: 280,
            protein: 42,
            tags: ["easy", "high-protein", "grill"],
            steps: [
                RecipeStep(title: "Prep", description: "Season chicken with salt and pepper.", durationSeconds: 120),
                RecipeStep(title: "Grill", description: "Grill 6–7 min per side until 165°F.", durationSeconds: 420)
            ],
            ingredients: [
                RecipeIngredient(ingredientId: 11, qtyText: "2 breasts", optional: false)
            ],
            readyInMinutes: 25,
            difficulty: "Easy"
        ),
        Recipe(
            id: 2,
            name: "Roasted Broccoli",
            description: "Crispy roasted broccoli with garlic.",
            calories: 85,
            protein: 4,
            tags: ["easy", "vegetarian", "side"],
            steps: [
                RecipeStep(title: "Toss", description: "Toss broccoli with oil, garlic, salt.", durationSeconds: 60),
                RecipeStep(title: "Roast", description: "Roast at 425°F for 20 minutes.", durationSeconds: 1200)
            ],
            ingredients: [
                RecipeIngredient(ingredientId: 37, qtyText: "1 head", optional: false),
                RecipeIngredient(ingredientId: 42, qtyText: "2 cloves", optional: false),
                RecipeIngredient(ingredientId: 7, qtyText: "1 tbsp", optional: false)
            ],
            readyInMinutes: 25,
            difficulty: "Easy"
        ),
        Recipe(
            id: 3,
            name: "Scrambled Eggs",
            description: "Fluffy scrambled eggs.",
            calories: 220,
            protein: 14,
            tags: ["breakfast", "easy", "quick"],
            steps: [
                RecipeStep(title: "Whisk", description: "Whisk eggs with a pinch of salt.", durationSeconds: 30),
                RecipeStep(title: "Cook", description: "Cook in butter over medium-low, stirring.", durationSeconds: 180)
            ],
            ingredients: [
                RecipeIngredient(ingredientId: 1, qtyText: "3 eggs", optional: false),
                RecipeIngredient(ingredientId: 7, qtyText: "1 tbsp", optional: false)
            ],
            readyInMinutes: 5,
            difficulty: "Easy"
        )
    ]

    static let defaultPlannedWeek: [PlannedDay] = {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days.map { PlannedDay(dayOfWeek: $0, breakfastId: 3, lunchId: 1, dinnerId: 2, snackId: nil, caloriesTotal: 0, proteinTotal: 0) }
    }()

    /// Meal plan templates (recipe IDs match catalog; works after catalog load). Order: Sunday–Saturday.
    static let mealPlanTemplates: [MealPlanTemplate] = [
        MealPlanTemplate(
            id: 200,
            name: "💪 Muscle Growth",
            focus: "🏋️ High protein & calories",
            description: "High protein and calories to support muscle building and recovery. Nutrient-dense meals to fuel workouts.",
            meals: [
                TemplateDay(dayOfWeek: "Sunday", breakfastId: 130, lunchId: 125, dinnerId: 143, snackId: 115),
                TemplateDay(dayOfWeek: "Monday", breakfastId: 107, lunchId: 126, dinnerId: 143, snackId: 115),
                TemplateDay(dayOfWeek: "Tuesday", breakfastId: 111, lunchId: 155, dinnerId: 172, snackId: 115),
                TemplateDay(dayOfWeek: "Wednesday", breakfastId: 115, lunchId: 126, dinnerId: 143, snackId: 115),
                TemplateDay(dayOfWeek: "Thursday", breakfastId: 107, lunchId: 125, dinnerId: 175, snackId: 115),
                TemplateDay(dayOfWeek: "Friday", breakfastId: 115, lunchId: 172, dinnerId: 143, snackId: 115),
                TemplateDay(dayOfWeek: "Saturday", breakfastId: 111, lunchId: 126, dinnerId: 175, snackId: 115)
            ]
        ),
        MealPlanTemplate(
            id: 201,
            name: "🥩 High Protein",
            focus: "💪 Max protein",
            description: "Maximize protein for satiety and muscle maintenance. Ideal for staying full and strong.",
            meals: [
                TemplateDay(dayOfWeek: "Sunday", breakfastId: 130, lunchId: 125, dinnerId: 155, snackId: 115),
                TemplateDay(dayOfWeek: "Monday", breakfastId: 107, lunchId: 120, dinnerId: 100, snackId: 115),
                TemplateDay(dayOfWeek: "Tuesday", breakfastId: 115, lunchId: 146, dinnerId: 126, snackId: 115),
                TemplateDay(dayOfWeek: "Wednesday", breakfastId: 153, lunchId: 120, dinnerId: 119, snackId: 115),
                TemplateDay(dayOfWeek: "Thursday", breakfastId: 107, lunchId: 143, dinnerId: 175, snackId: 115),
                TemplateDay(dayOfWeek: "Friday", breakfastId: 115, lunchId: 126, dinnerId: 120, snackId: 115),
                TemplateDay(dayOfWeek: "Saturday", breakfastId: 111, lunchId: 143, dinnerId: 119, snackId: 115)
            ]
        ),
        MealPlanTemplate(
            id: 202,
            name: "🌱 Vegan",
            focus: "🥬 Plant-based",
            description: "Completely plant-based. Whole foods, legumes, and vegetables for complete nutrition.",
            meals: [
                TemplateDay(dayOfWeek: "Sunday", breakfastId: 130, lunchId: 135, dinnerId: 114, snackId: 217),
                TemplateDay(dayOfWeek: "Monday", breakfastId: 130, lunchId: 127, dinnerId: 105, snackId: 217),
                TemplateDay(dayOfWeek: "Tuesday", breakfastId: 107, lunchId: 124, dinnerId: 114, snackId: 217),
                TemplateDay(dayOfWeek: "Wednesday", breakfastId: 136, lunchId: 135, dinnerId: 149, snackId: 217),
                TemplateDay(dayOfWeek: "Thursday", breakfastId: 130, lunchId: 122, dinnerId: 114, snackId: 217),
                TemplateDay(dayOfWeek: "Friday", breakfastId: 136, lunchId: 127, dinnerId: 105, snackId: 217),
                TemplateDay(dayOfWeek: "Saturday", breakfastId: 115, lunchId: 149, dinnerId: 124, snackId: 217)
            ]
        ),
        MealPlanTemplate(
            id: 203,
            name: "🥑 Keto",
            focus: "🥓 Low carb, high fat",
            description: "Low-carb, high-fat to support ketosis. Healthy fats and minimal carbs.",
            meals: [
                TemplateDay(dayOfWeek: "Sunday", breakfastId: 112, lunchId: 158, dinnerId: 165, snackId: 213),
                TemplateDay(dayOfWeek: "Monday", breakfastId: 112, lunchId: 109, dinnerId: 106, snackId: 213),
                TemplateDay(dayOfWeek: "Tuesday", breakfastId: 128, lunchId: 161, dinnerId: 148, snackId: 213),
                TemplateDay(dayOfWeek: "Wednesday", breakfastId: 142, lunchId: 158, dinnerId: 148, snackId: 213),
                TemplateDay(dayOfWeek: "Thursday", breakfastId: 112, lunchId: 168, dinnerId: 165, snackId: 213),
                TemplateDay(dayOfWeek: "Friday", breakfastId: 128, lunchId: 109, dinnerId: 151, snackId: 213),
                TemplateDay(dayOfWeek: "Saturday", breakfastId: 142, lunchId: 161, dinnerId: 148, snackId: 213)
            ]
        ),
        MealPlanTemplate(
            id: 204,
            name: "🫒 Mediterranean",
            focus: "🍅 Heart-healthy",
            description: "Inspired by Mediterranean eating. Rich in vegetables, whole grains, and healthy fats.",
            meals: [
                TemplateDay(dayOfWeek: "Sunday", breakfastId: 130, lunchId: 122, dinnerId: 169, snackId: 217),
                TemplateDay(dayOfWeek: "Monday", breakfastId: 130, lunchId: 104, dinnerId: 113, snackId: 217),
                TemplateDay(dayOfWeek: "Tuesday", breakfastId: 107, lunchId: 122, dinnerId: 147, snackId: 217),
                TemplateDay(dayOfWeek: "Wednesday", breakfastId: 115, lunchId: 169, dinnerId: 175, snackId: 217),
                TemplateDay(dayOfWeek: "Thursday", breakfastId: 130, lunchId: 127, dinnerId: 113, snackId: 217),
                TemplateDay(dayOfWeek: "Friday", breakfastId: 107, lunchId: 138, dinnerId: 175, snackId: 217),
                TemplateDay(dayOfWeek: "Saturday", breakfastId: 115, lunchId: 147, dinnerId: 113, snackId: 217)
            ]
        ),
        MealPlanTemplate(
            id: 205,
            name: "🥗 General Healthy",
            focus: "⚖️ Balanced",
            description: "Balanced whole foods, lean proteins, and vegetables. Steady energy all day.",
            meals: [
                TemplateDay(dayOfWeek: "Sunday", breakfastId: 111, lunchId: 125, dinnerId: 100, snackId: 212),
                TemplateDay(dayOfWeek: "Monday", breakfastId: 111, lunchId: 125, dinnerId: 155, snackId: 212),
                TemplateDay(dayOfWeek: "Tuesday", breakfastId: 130, lunchId: 118, dinnerId: 119, snackId: 212),
                TemplateDay(dayOfWeek: "Wednesday", breakfastId: 115, lunchId: 125, dinnerId: 100, snackId: 212),
                TemplateDay(dayOfWeek: "Thursday", breakfastId: 111, lunchId: 131, dinnerId: 120, snackId: 212),
                TemplateDay(dayOfWeek: "Friday", breakfastId: 130, lunchId: 140, dinnerId: 155, snackId: 212),
                TemplateDay(dayOfWeek: "Saturday", breakfastId: 115, lunchId: 118, dinnerId: 119, snackId: 212)
            ]
        ),
        MealPlanTemplate(
            id: 206,
            name: "📉 Weight Loss",
            focus: "🔥 Calorie control",
            description: "Calorie-controlled, nutrient-dense meals for gradual weight loss. Stay satisfied.",
            meals: [
                TemplateDay(dayOfWeek: "Sunday", breakfastId: 111, lunchId: 146, dinnerId: 100, snackId: 217),
                TemplateDay(dayOfWeek: "Monday", breakfastId: 111, lunchId: 146, dinnerId: 100, snackId: 217),
                TemplateDay(dayOfWeek: "Tuesday", breakfastId: 130, lunchId: 114, dinnerId: 109, snackId: 217),
                TemplateDay(dayOfWeek: "Wednesday", breakfastId: 115, lunchId: 146, dinnerId: 100, snackId: 217),
                TemplateDay(dayOfWeek: "Thursday", breakfastId: 111, lunchId: 114, dinnerId: 109, snackId: 217),
                TemplateDay(dayOfWeek: "Friday", breakfastId: 130, lunchId: 146, dinnerId: 100, snackId: 217),
                TemplateDay(dayOfWeek: "Saturday", breakfastId: 115, lunchId: 114, dinnerId: 109, snackId: 217)
            ]
        ),
        MealPlanTemplate(
            id: 207,
            name: "⚡ Quick & Easy",
            focus: "⏱️ Fast meals",
            description: "Simple recipes and short cook times. Perfect for busy weeknights.",
            meals: [
                TemplateDay(dayOfWeek: "Sunday", breakfastId: 111, lunchId: 147, dinnerId: 106, snackId: 212),
                TemplateDay(dayOfWeek: "Monday", breakfastId: 111, lunchId: 147, dinnerId: 106, snackId: 212),
                TemplateDay(dayOfWeek: "Tuesday", breakfastId: 130, lunchId: 113, dinnerId: 420, snackId: 212),
                TemplateDay(dayOfWeek: "Wednesday", breakfastId: 111, lunchId: 147, dinnerId: 106, snackId: 212),
                TemplateDay(dayOfWeek: "Thursday", breakfastId: 130, lunchId: 113, dinnerId: 420, snackId: 212),
                TemplateDay(dayOfWeek: "Friday", breakfastId: 111, lunchId: 147, dinnerId: 106, snackId: 212),
                TemplateDay(dayOfWeek: "Saturday", breakfastId: 130, lunchId: 113, dinnerId: 420, snackId: 212)
            ]
        ),
        MealPlanTemplate(
            id: 208,
            name: "👨‍👩‍👧 Family Favorites",
            focus: "🍝 Crowd-pleasers",
            description: "Meals the whole family will love. Classic, comforting, and easy to share.",
            meals: [
                TemplateDay(dayOfWeek: "Sunday", breakfastId: 111, lunchId: 122, dinnerId: 124, snackId: 212),
                TemplateDay(dayOfWeek: "Monday", breakfastId: 111, lunchId: 122, dinnerId: 124, snackId: 212),
                TemplateDay(dayOfWeek: "Tuesday", breakfastId: 136, lunchId: 127, dinnerId: 105, snackId: 212),
                TemplateDay(dayOfWeek: "Wednesday", breakfastId: 130, lunchId: 122, dinnerId: 124, snackId: 212),
                TemplateDay(dayOfWeek: "Thursday", breakfastId: 111, lunchId: 127, dinnerId: 105, snackId: 212),
                TemplateDay(dayOfWeek: "Friday", breakfastId: 136, lunchId: 122, dinnerId: 124, snackId: 212),
                TemplateDay(dayOfWeek: "Saturday", breakfastId: 130, lunchId: 127, dinnerId: 105, snackId: 212)
            ]
        )
    ]
}
