//
//  IngredientSubstitutions.swift
//  SmartCart
//

import Foundation

enum IngredientSubstitutions {
    /// Specific ingredient name -> suggested substitute names (from catalog).
    private static let specific: [String: [String]] = [
        "Milk": ["Almond Milk", "Oat Milk", "Soy Milk", "Coconut Milk"],
        "Butter": ["Olive Oil", "Coconut Oil", "Margarine", "Avocado"],
        "Cheese": ["Nutritional Yeast", "Vegan Cheese", "Cottage Cheese"],
        "Eggs": ["Flax Egg", "Chia Egg", "Applesauce", "Banana"],
        "Yogurt": ["Greek Yogurt", "Coconut Yogurt", "Sour Cream"],
        "Cream": ["Coconut Cream", "Cashew Cream", "Milk"],
        "Chicken Breast": ["Tofu", "Tempeh", "Turkey Breast", "Chicken Thigh"],
        "Ground Beef": ["Ground Turkey", "Ground Chicken", "Lentils", "Mushrooms"],
        "Beef": ["Portobello Mushrooms", "Eggplant", "Tempeh"],
        "Pork": ["Chicken", "Turkey", "Tofu"],
        "Fish": ["Tofu", "Tempeh", "Chickpeas"],
        "White Rice": ["Brown Rice", "Quinoa", "Cauliflower Rice", "Barley"],
        "Pasta": ["Whole Wheat Pasta", "Zucchini Noodles", "Spaghetti Squash"],
        "White Flour": ["Whole Wheat Flour", "Almond Flour", "Coconut Flour"],
        "Sugar": ["Honey", "Maple Syrup", "Stevia", "Coconut Sugar"],
        "Olive Oil": ["Avocado Oil", "Coconut Oil", "Butter"],
        "Onion": ["Shallots", "Leeks", "Onion Powder"],
        "Garlic": ["Garlic Powder", "Shallots"],
        "Tomato": ["Canned Tomatoes", "Sun-Dried Tomatoes", "Tomato Paste"],
        "Potato": ["Sweet Potato", "Cauliflower", "Turnips"],
        "Carrot": ["Parsnips", "Sweet Potato", "Butternut Squash"],
        "Salt": ["Sea Salt", "Himalayan Salt", "Soy Sauce"],
        "Black Pepper": ["White Pepper", "Cayenne Pepper", "Paprika"],
        "Cumin": ["Coriander", "Chili Powder", "Paprika"],
        "Paprika": ["Cayenne Pepper", "Chili Powder", "Red Pepper Flakes"]
    ]

    /// Category -> substitute categories (for fallback).
    private static let categoryFallback: [String: [String]] = [
        "Dairy": ["Plant-Based", "Dairy"],
        "Meat": ["Plant-Based", "Seafood", "Meat"],
        "Pantry": ["Pantry", "Spices"],
        "Produce": ["Produce", "Frozen"],
        "Spices": ["Spices", "Pantry"]
    ]

    /// Returns ingredients from `allIngredients` that are suggested substitutes for `ingredient` (by name or category).
    static func findSubstitutions(for ingredient: Ingredient, in allIngredients: [Ingredient]) -> [Ingredient] {
        var result: [Ingredient] = []
        let name = ingredient.canonicalName

        if let names = specific[name] {
            for subName in names {
                if let found = allIngredients.first(where: { $0.canonicalName.caseInsensitiveCompare(subName) == .orderedSame }),
                   found.id != ingredient.id, !result.contains(where: { $0.id == found.id }) {
                    result.append(found)
                }
            }
        }

        if result.count < 3, let allowedCategories = categoryFallback[ingredient.category] {
            for other in allIngredients where other.id != ingredient.id && allowedCategories.contains(other.category) {
                if result.contains(where: { $0.id == other.id }) { continue }
                result.append(other)
                if result.count >= 3 { break }
            }
        }

        return Array(result.prefix(3))
    }
}
