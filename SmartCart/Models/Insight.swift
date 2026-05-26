//
//  Insight.swift
//  SmartCart
//

import Foundation
import SwiftUI

struct Insight: Identifiable {
    var id: String
    var title: String
    var shortDescription: String
    var iconName: String
    var category: String
}

struct InsightContent {
    let id: String
    let title: String
    let subtitle: String
    let mainContent: String
    let keyPoints: [String]
    let tips: [String]?
    let benefits: [String]?
    var relatedRecipeIds: [Int64] = []
}

enum InsightRepository {
    static let all: [Insight] = [
        Insight(id: "hydration", title: "Stay Hydrated", shortDescription: "Drink water before and during cooking to stay focused.", iconName: "drop.fill", category: "Health"),
        Insight(id: "prep", title: "Prep Ahead", shortDescription: "Chop vegetables the night before to save time.", iconName: "leaf.fill", category: "Meal Prep"),
        Insight(id: "leftovers", title: "Love Leftovers", shortDescription: "Cook double portions and refrigerate for tomorrow.", iconName: "refrigerator.fill", category: "Meal Prep"),
        Insight(id: "meal_timing", title: "Meal Timing Matters", shortDescription: "Eating at consistent times helps regulate metabolism.", iconName: "clock.fill", category: "Nutrition"),
        Insight(id: "protein_intake", title: "Prioritize Protein", shortDescription: "Include protein in every meal for sustained energy.", iconName: "flame.fill", category: "Nutrition"),
        Insight(id: "breakfast", title: "Never Skip Breakfast", shortDescription: "Start your day with a nutritious breakfast.", iconName: "sunrise.fill", category: "Nutrition"),
        Insight(id: "portion_control", title: "Portion Control", shortDescription: "Use smaller plates to naturally eat less.", iconName: "circle.lefthalf.filled", category: "Habits"),
        Insight(id: "fiber", title: "Eat More Fiber", shortDescription: "Fiber keeps you full and supports digestion.", iconName: "leaf.circle.fill", category: "Nutrition"),
        Insight(id: "mindful_eating", title: "Eat Mindfully", shortDescription: "Slow down and savor each bite.", iconName: "brain.head.profile", category: "Habits"),
        Insight(id: "cooking_at_home", title: "Cook at Home", shortDescription: "Home-cooked meals are healthier and cheaper.", iconName: "frying.pan.fill", category: "Meal Prep"),
        Insight(id: "grocery_list", title: "Plan Your Grocery List", shortDescription: "Shop with a list to avoid waste and overspending.", iconName: "cart.fill", category: "Meal Prep"),
        Insight(id: "sleep_nutrition", title: "Sleep & Nutrition", shortDescription: "Poor sleep affects hunger hormones and choices.", iconName: "moon.zzz.fill", category: "Health"),
        Insight(id: "healthy_fats", title: "Include Healthy Fats", shortDescription: "Avocado, nuts, and olive oil support health.", iconName: "drop.fill", category: "Nutrition"),
        Insight(id: "reduce_sugar", title: "Reduce Added Sugar", shortDescription: "Cut back on sugary drinks and snacks.", iconName: "cube.fill", category: "Nutrition"),
        Insight(id: "batch_cooking", title: "Batch Cooking", shortDescription: "Cook in bulk and freeze portions for busy days.", iconName: "refrigerator.fill", category: "Meal Prep"),
        Insight(id: "seasonal_eat", title: "Eat Seasonal", shortDescription: "Seasonal produce is fresher, tastier, and often cheaper.", iconName: "carrot.fill", category: "Nutrition"),
        Insight(id: "herbs_spices", title: "Herbs & Spices", shortDescription: "Flavor food without extra salt or sugar.", iconName: "leaf.fill", category: "Habits"),
        Insight(id: "read_labels", title: "Read Nutrition Labels", shortDescription: "Check serving size and ingredients when you shop.", iconName: "doc.text.fill", category: "Habits"),
        Insight(id: "slow_cooker", title: "Use a Slow Cooker", shortDescription: "Set it and forget it for easy, hands-off meals.", iconName: "slowmo", category: "Meal Prep"),
        Insight(id: "one_pot_meals", title: "One-Pot Meals", shortDescription: "Fewer dishes and full flavor in a single pan.", iconName: "frying.pan.fill", category: "Meal Prep"),
        Insight(id: "salad_first", title: "Start with a Salad", shortDescription: "Fill up on veggies before the main course.", iconName: "leaf.circle.fill", category: "Nutrition"),
        Insight(id: "chew_slowly", title: "Chew Slowly", shortDescription: "Give your brain time to register fullness.", iconName: "brain.head.profile", category: "Habits"),
        Insight(id: "limit_processed", title: "Limit Processed Foods", shortDescription: "Choose whole foods when you can.", iconName: "cube.fill", category: "Nutrition"),
        Insight(id: "oily_fish", title: "Eat Oily Fish Weekly", shortDescription: "Salmon, mackerel, and sardines support heart and brain.", iconName: "fish.fill", category: "Nutrition"),
        Insight(id: "vegetables_first", title: "Veggies First", shortDescription: "Fill half your plate with vegetables.", iconName: "carrot.fill", category: "Nutrition"),
        Insight(id: "reduce_salt", title: "Reduce Sodium", shortDescription: "Use herbs, citrus, and spices instead of extra salt.", iconName: "drop.fill", category: "Nutrition"),
        Insight(id: "fermented_foods", title: "Try Fermented Foods", shortDescription: "Yogurt, kimchi, and sauerkraut support gut health.", iconName: "leaf.fill", category: "Nutrition"),
        Insight(id: "nuts_seeds", title: "Add Nuts & Seeds", shortDescription: "A handful adds crunch, protein, and healthy fats.", iconName: "circle.fill", category: "Nutrition"),
        Insight(id: "meal_plan_weekly", title: "Plan Meals Weekly", shortDescription: "One planning session saves stress all week.", iconName: "calendar", category: "Meal Prep"),
        Insight(id: "kitchen_tools", title: "Good Kitchen Tools", shortDescription: "A sharp knife and a few basics make cooking easier.", iconName: "scissors", category: "Meal Prep"),
        Insight(id: "cooking_with_kids", title: "Cook with Family", shortDescription: "Get kids involved; they eat more of what they make.", iconName: "person.2.fill", category: "Habits"),
        Insight(id: "stress_eating", title: "Notice Stress Eating", shortDescription: "Pause and ask if you're hungry or stressed.", iconName: "brain.head.profile", category: "Habits"),
        Insight(id: "variety", title: "Eat a Variety", shortDescription: "Different foods provide different nutrients.", iconName: "square.grid.2x2.fill", category: "Nutrition"),
        Insight(id: "small_plates", title: "Use Smaller Plates", shortDescription: "Portions look bigger; you may eat less.", iconName: "circle.lefthalf.filled", category: "Habits"),
        Insight(id: "protein_breakfast", title: "Protein at Breakfast", shortDescription: "Eggs, yogurt, or nut butter keep you full longer.", iconName: "sunrise.fill", category: "Nutrition"),
        Insight(id: "walk_after_meal", title: "Walk After Meals", shortDescription: "A short walk helps digestion and blood sugar.", iconName: "figure.walk", category: "Health"),
        Insight(id: "limit_alcohol", title: "Limit Alcohol", shortDescription: "Alcohol adds calories and can affect sleep and choices.", iconName: "wineglass.fill", category: "Health"),
        Insight(id: "whole_grains", title: "Choose Whole Grains", shortDescription: "Oats, brown rice, and whole wheat add fiber.", iconName: "leaf.circle.fill", category: "Nutrition"),
        Insight(id: "legumes", title: "Add Legumes", shortDescription: "Beans and lentils are cheap, filling, and nutritious.", iconName: "circle.fill", category: "Nutrition"),
        Insight(id: "colorful_plate", title: "Eat the Rainbow", shortDescription: "Different colors often mean different nutrients.", iconName: "paintpalette.fill", category: "Nutrition"),
        Insight(id: "avoid_screens", title: "No Screens While Eating", shortDescription: "Eat at the table without TV or phones.", iconName: "tv.slash", category: "Habits"),
        Insight(id: "grocery_after_meal", title: "Shop After a Meal", shortDescription: "You'll buy less junk when you're not hungry.", iconName: "cart.fill", category: "Meal Prep"),
        Insight(id: "freezer_staples", title: "Keep Freezer Staples", shortDescription: "Frozen veggies, protein, and grains for quick meals.", iconName: "snowflake", category: "Meal Prep"),
        Insight(id: "pantry_staples", title: "Stock Pantry Staples", shortDescription: "Canned beans, pasta, and rice mean you can always cook.", iconName: "cabinet.fill", category: "Meal Prep"),
        Insight(id: "cooking_confidence", title: "Build Cooking Confidence", shortDescription: "Start with simple recipes and repeat them.", iconName: "star.fill", category: "Meal Prep"),
        Insight(id: "leftovers_creative", title: "Get Creative with Leftovers", shortDescription: "Turn last night's roast into tacos or a salad.", iconName: "lightbulb.fill", category: "Meal Prep"),
        Insight(id: "hydration_cues", title: "Listen to Thirst Cues", shortDescription: "Drink when you're thirsty; don't wait until you're parched.", iconName: "drop.fill", category: "Health"),
        Insight(id: "meal_prep_sunday", title: "Sunday Meal Prep", shortDescription: "Prep ingredients or full meals for the week ahead.", iconName: "calendar.badge.clock", category: "Meal Prep"),
        Insight(id: "mindful_grocery", title: "Mindful Grocery Shopping", shortDescription: "Stick to the list and avoid impulse buys.", iconName: "cart.fill", category: "Habits"),
        Insight(id: "balanced_plate", title: "Balance Your Plate", shortDescription: "Protein, carbs, and veggies in each meal.", iconName: "circle.lefthalf.filled", category: "Nutrition"),
        Insight(id: "reduce_fried", title: "Cut Back on Fried Foods", shortDescription: "Bake, grill, or steam instead when you can.", iconName: "flame.fill", category: "Nutrition"),
        Insight(id: "snack_smart", title: "Snack Smart", shortDescription: "Keep fruit, nuts, or yogurt on hand for hunger between meals.", iconName: "leaf.fill", category: "Nutrition"),
        Insight(id: "rest_and_digest", title: "Rest After Eating", shortDescription: "Avoid intense activity right after a big meal.", iconName: "moon.zzz.fill", category: "Health"),
        Insight(id: "label_serving", title: "Check Serving Size", shortDescription: "Nutrition labels are per serving; portions add up.", iconName: "doc.text.fill", category: "Habits"),
    ]

    static let contentById: [String: InsightContent] = [
        "hydration": InsightContent(
            id: "hydration",
            title: "Stay Hydrated",
            subtitle: "Small habit, big impact",
            mainContent: "Drink a glass of water before you start cooking and keep a glass nearby while you cook. Staying hydrated helps you stay focused, reduces fatigue, and can prevent overeating. Aim for at least 8 glasses a day.",
            keyPoints: [
                "Aim for 8–10 glasses of water per day",
                "Drink water before, during, and after meals",
                "Carry a water bottle with you",
                "Eat water-rich foods like fruits and vegetables",
            ],
            tips: [
                "Start your day with a glass of water",
                "Set reminders to drink water regularly",
                "Flavor water with lemon, cucumber, or mint",
                "Drink water 30 minutes before meals",
            ],
            benefits: [
                "Improved energy and mental clarity",
                "Better skin health",
                "Enhanced physical performance",
                "Better digestion and nutrient absorption",
            ]
        ),
        "prep": InsightContent(
            id: "prep",
            title: "Prep Ahead",
            subtitle: "Save time on busy days",
            mainContent: "Chop onions, garlic, and vegetables the night before and store them in airtight containers in the fridge. Pre-measure dry ingredients for recipes you plan to make. This way, when you're short on time, you can get dinner on the table in minutes.",
            keyPoints: [
                "Chop vegetables and store in airtight containers",
                "Pre-measure dry ingredients the night before",
                "Keep a few ready-to-cook components in the fridge",
                "Batch-cook grains and proteins for the week",
            ],
            tips: [
                "Dedicate 30 minutes on Sunday to prep for the week",
                "Use clear containers so you can see what's ready",
                "Prep aromatics (onion, garlic) in one go",
                "Label containers with dates to avoid waste",
            ],
            benefits: [
                "Faster weeknight dinners",
                "Less stress and decision fatigue",
                "More consistent healthy eating",
                "Less food waste",
            ]
        ),
        "leftovers": InsightContent(
            id: "leftovers",
            title: "Love Leftovers",
            subtitle: "Cook once, eat twice",
            mainContent: "When you make a recipe, double the batch and refrigerate or freeze half. Reheat for lunch or dinner the next day. Many dishes like soups, curries, and casseroles taste even better the next day. You'll save time and reduce food waste.",
            keyPoints: [
                "Double the batch when you cook",
                "Store in portion-sized containers",
                "Freeze what you won't eat in 3–4 days",
                "Reheat safely to avoid bacteria",
            ],
            tips: [
                "Cook extra rice or grains to use in bowls",
                "Soups and stews freeze well for months",
                "Label freezer bags with name and date",
                "Thaw in the fridge overnight when possible",
            ],
            benefits: [
                "Save time and money",
                "Reduce food waste",
                "Convenient healthy meals on busy days",
                "Less daily cooking effort",
            ]
        ),
        "meal_timing": InsightContent(
            id: "meal_timing",
            title: "Meal Timing Matters",
            subtitle: "When you eat is just as important as what you eat",
            mainContent: "Your body's metabolism follows a circadian rhythm. Eating at consistent times helps regulate your metabolism, improve digestion, and maintain stable energy levels. Research shows that meal timing can affect weight management, sleep quality, and overall health.",
            keyPoints: [
                "Eat breakfast within 2 hours of waking",
                "Space meals 3–4 hours apart",
                "Avoid large meals 2–3 hours before bed",
                "Consistent meal times help regulate hunger hormones",
            ],
            tips: [
                "Plan your meals ahead of time",
                "Set meal reminders if needed",
                "Don't skip meals—it can slow metabolism",
                "Allow 12–14 hours between dinner and breakfast",
            ],
            benefits: [
                "Better blood sugar control",
                "Improved digestion",
                "More stable energy",
                "Enhanced weight management",
            ]
        ),
        "protein_intake": InsightContent(
            id: "protein_intake",
            title: "Prioritize Protein",
            subtitle: "Include protein in every meal",
            mainContent: "Protein helps you feel full longer, supports muscle repair, and keeps your metabolism active. Aim to include a source of protein—eggs, fish, legumes, poultry, or tofu—in every meal. A palm-sized portion is a good visual guide.",
            keyPoints: [
                "Include protein in every meal",
                "Aim for 20–30 g per meal for most adults",
                "Vary sources: animal and plant-based",
                "Pair protein with fiber for lasting fullness",
            ],
            tips: [
                "Add beans or lentils to salads and soups",
                "Keep hard-boiled eggs in the fridge",
                "Choose Greek yogurt for breakfast",
                "Add nuts or seeds to snacks",
            ],
            benefits: [
                "Sustained energy and fullness",
                "Better muscle maintenance",
                "Supports metabolism",
                "Helps with weight management",
            ],
            relatedRecipeIds: [100, 103, 107, 108]
        ),
        "breakfast": InsightContent(
            id: "breakfast",
            title: "Never Skip Breakfast",
            subtitle: "Start your day with a nutritious meal",
            mainContent: "Breakfast literally means breaking the fast. A nutritious breakfast provides essential energy and nutrients to start your day. People who eat breakfast tend to have better concentration, more stable energy, and make healthier choices throughout the day.",
            keyPoints: [
                "Eat within 2 hours of waking",
                "Include protein and fiber",
                "Even a small breakfast is better than none",
                "Prep breakfast the night before if you're rushed",
            ],
            tips: [
                "Overnight oats or smoothies for busy mornings",
                "Keep fruit and yogurt on hand",
                "Eggs and whole-grain toast take under 10 minutes",
                "Make a batch of muffins or energy balls on weekends",
            ],
            benefits: [
                "Better focus and concentration",
                "Stable energy until lunch",
                "Healthier food choices later",
                "Supports a healthy weight",
            ],
            relatedRecipeIds: [107, 111, 130, 178]
        ),
        "portion_control": InsightContent(
            id: "portion_control",
            title: "Portion Control",
            subtitle: "Use your plate as a guide",
            mainContent: "You can eat healthy foods and still overeat if portions are too large. Using smaller plates, filling half your plate with vegetables, and pausing before seconds can help you eat the right amount without feeling deprived.",
            keyPoints: [
                "Use smaller plates to naturally eat less",
                "Fill half your plate with vegetables",
                "Wait 10 minutes before taking seconds",
                "Serve food in the kitchen, not at the table",
            ],
            tips: [
                "Use a salad plate instead of a dinner plate",
                "Measure portions until you can eyeball them",
                "Eat slowly and put your fork down between bites",
                "Avoid eating straight from the package",
            ],
            benefits: [
                "Easier weight management",
                "Less overeating",
                "Better digestion",
                "More mindful eating",
            ]
        ),
        "fiber": InsightContent(
            id: "fiber",
            title: "Eat More Fiber",
            subtitle: "Fiber keeps you full and supports digestion",
            mainContent: "Fiber is found in fruits, vegetables, whole grains, and legumes. It helps you feel full, supports healthy digestion, and can help manage blood sugar and cholesterol. Most people need 25–30 grams per day.",
            keyPoints: [
                "Aim for 25–30 g of fiber per day",
                "Eat whole fruits instead of juice",
                "Choose whole grains over refined",
                "Add beans and lentils to meals",
            ],
            tips: [
                "Start the day with oatmeal or whole-grain cereal",
                "Add vegetables to every meal",
                "Snack on fruit, nuts, or hummus with veggies",
                "Switch to brown rice, quinoa, or whole-wheat pasta",
            ],
            benefits: [
                "Long-lasting fullness",
                "Better gut health",
                "More stable blood sugar",
                "Lower cholesterol",
            ],
            relatedRecipeIds: [101, 114, 122, 130]
        ),
        "mindful_eating": InsightContent(
            id: "mindful_eating",
            title: "Eat Mindfully",
            subtitle: "Slow down and savor each bite",
            mainContent: "Mindful eating means paying attention to what you eat and how you feel—without judgment. It helps you recognize true hunger and fullness, enjoy food more, and often eat less without dieting.",
            keyPoints: [
                "Eat without screens or distractions",
                "Chew slowly and notice flavors and textures",
                "Pause halfway through to check fullness",
                "Notice why you're eating—hunger vs. habit",
            ],
            tips: [
                "Put your fork down between bites",
                "Take a few deep breaths before starting",
                "Use a smaller plate so you don't overload",
                "Eat at a table, not on the couch",
            ],
            benefits: [
                "Better recognition of hunger and fullness",
                "More enjoyment of food",
                "Less overeating",
                "Improved digestion",
            ]
        ),
        "cooking_at_home": InsightContent(
            id: "cooking_at_home",
            title: "Cook at Home",
            subtitle: "Healthier and cheaper than eating out",
            mainContent: "When you cook at home, you control the ingredients, portions, and methods. Home-cooked meals are typically lower in salt, sugar, and unhealthy fats—and cost less than restaurants or takeout. Start with simple recipes and build from there.",
            keyPoints: [
                "You control ingredients and portions",
                "Usually lower in salt, sugar, and fat",
                "Saves money compared to eating out",
                "Build skills and confidence over time",
            ],
            tips: [
                "Start with one or two simple recipes per week",
                "Keep a well-stocked pantry and freezer",
                "Cook extra and freeze for busy days",
                "Involve family so it becomes a habit",
            ],
            benefits: [
                "Better nutrition",
                "Lower cost",
                "More variety and creativity",
                "Quality time with family",
            ]
        ),
        "grocery_list": InsightContent(
            id: "grocery_list",
            title: "Plan Your Grocery List",
            subtitle: "Shop with a list to avoid waste",
            mainContent: "Planning your grocery list around meals you'll actually cook reduces impulse buys, food waste, and last-minute takeout. Check your pantry first, then list what you need for the week. Stick to the list when you shop.",
            keyPoints: [
                "Plan meals before you shop",
                "Check pantry and fridge first",
                "List ingredients by store section",
                "Stick to the list to avoid overspending",
            ],
            tips: [
                "Keep a running list on your phone",
                "Shop after a meal so you're not hungry",
                "Buy versatile ingredients you can use in multiple meals",
                "Compare unit prices, not just package price",
            ],
            benefits: [
                "Less food waste",
                "Lower grocery bills",
                "Healthier choices",
                "Less stress about what to cook",
            ]
        ),
        "sleep_nutrition": InsightContent(
            id: "sleep_nutrition",
            title: "Sleep & Nutrition",
            subtitle: "Poor sleep affects hunger and choices",
            mainContent: "When you're sleep-deprived, your body produces more ghrelin (hunger hormone) and less leptin (fullness hormone). You're also more likely to crave high-calorie, sugary foods. Prioritizing sleep supports healthier eating and weight.",
            keyPoints: [
                "Poor sleep increases hunger hormones",
                "Lack of sleep leads to more cravings",
                "Aim for 7–9 hours per night",
                "Consistent sleep times help metabolism",
            ],
            tips: [
                "Avoid heavy meals and caffeine close to bedtime",
                "Keep a regular sleep schedule",
                "Limit screens before bed",
                "Create a dark, cool, quiet sleep environment",
            ],
            benefits: [
                "Better appetite regulation",
                "More energy for healthy choices",
                "Improved mood and focus",
                "Supports weight and health goals",
            ]
        ),
        "healthy_fats": InsightContent(
            id: "healthy_fats",
            title: "Include Healthy Fats",
            subtitle: "Avocado, nuts, olive oil, and fish",
            mainContent: "Healthy fats—from olive oil, avocado, nuts, seeds, and fatty fish—support heart health, help you absorb vitamins, and keep you satisfied. They're not something to avoid; just keep portions in check since they're calorie-dense.",
            keyPoints: [
                "Choose unsaturated fats (olive oil, nuts, fish)",
                "Limit trans fats and excess saturated fat",
                "A small handful of nuts is a good portion",
                "Fat helps you absorb vitamins A, D, E, K",
            ],
            tips: [
                "Use olive oil for cooking and dressings",
                "Add avocado to toast, salads, or smoothies",
                "Eat fatty fish like salmon 1–2 times per week",
                "Snack on nuts and seeds in moderation",
            ],
            benefits: [
                "Heart health",
                "Better absorption of fat-soluble vitamins",
                "Longer-lasting fullness",
                "Improved mood and brain function",
            ],
            relatedRecipeIds: [106, 134, 165, 181]
        ),
        "reduce_sugar": InsightContent(
            id: "reduce_sugar",
            title: "Reduce Added Sugar",
            subtitle: "Cut back on sugary drinks and snacks",
            mainContent: "Added sugars—in sodas, sweets, and many packaged foods—add calories without nutrients and can spike blood sugar. Reducing them doesn't mean giving up sweetness; fruit and small amounts of natural sweeteners can still satisfy.",
            keyPoints: [
                "Limit sugary drinks; choose water or unsweetened options",
                "Read labels—sugar hides in sauces and packaged foods",
                "Choose fruit for a sweet fix",
                "Reduce gradually so your taste adjusts",
            ],
            tips: [
                "Swap soda for sparkling water with lemon or mint",
                "Use fruit (banana, dates) to sweeten oatmeal or smoothies",
                "Choose plain yogurt and add your own fruit",
                "Save dessert for special occasions",
            ],
            benefits: [
                "More stable energy",
                "Better dental health",
                "Easier weight management",
                "Reduced risk of chronic disease",
            ]
        ),
        "batch_cooking": InsightContent(
            id: "batch_cooking",
            title: "Batch Cooking",
            subtitle: "Cook in bulk and freeze for busy days",
            mainContent: "Set aside a few hours on the weekend to cook large batches of grains, proteins, and vegetables. Portion them into containers and refrigerate or freeze. During the week, you can assemble meals in minutes instead of cooking from scratch.",
            keyPoints: [
                "Cook grains, proteins, and veggies in bulk",
                "Portion into single-serving containers",
                "Freeze what you won't use in 3–4 days",
                "Label with name and date",
            ],
            tips: [
                "Roast a big tray of vegetables",
                "Cook a large pot of rice, quinoa, or beans",
                "Grill or bake several chicken breasts or tofu",
                "Make a big pot of soup or chili to freeze",
            ],
            benefits: [
                "Saves time on busy weeknights",
                "Reduces daily decision fatigue",
                "Less temptation to order takeout",
                "Consistent healthy eating",
            ],
            relatedRecipeIds: [103, 114, 119, 146]
        ),
        "seasonal_eat": InsightContent(id: "seasonal_eat", title: "Eat Seasonal", subtitle: "Fresher, tastier, often cheaper", mainContent: "Seasonal produce is picked at peak ripeness, so it tastes better and often costs less. Check farmers' markets and grocery flyers for what's in season in your area.", keyPoints: ["Seasonal produce is fresher and more nutritious", "Often cheaper when in abundance", "Supports local growers when possible", "Vary your diet with the seasons"], tips: ["Check what's in season in your region", "Buy extra and freeze or preserve", "Try one new seasonal vegetable per week", "Farmers' markets are great for seasonal finds"], benefits: ["Better flavor and nutrition", "Lower grocery bills", "More variety through the year", "Supports local food systems"]),
        "herbs_spices": InsightContent(id: "herbs_spices", title: "Herbs & Spices", subtitle: "Flavor without extra salt or sugar", mainContent: "Herbs and spices add flavor, color, and even health benefits without extra calories, salt, or sugar. Build a small collection and use them liberally.", keyPoints: ["Fresh or dried herbs add flavor without salt", "Spices like turmeric and cinnamon have health benefits", "Start with basil, oregano, cumin, and paprika", "Store in a cool, dark place to keep flavor"], tips: ["Add herbs at the end of cooking for freshness", "Toast spices briefly to deepen flavor", "Keep garlic, ginger, and onions as flavor bases", "Experiment with one new spice per week"], benefits: ["Less need for salt and sugar", "More interesting meals", "Potential anti-inflammatory effects", "Satisfying without extra calories"]),
        "read_labels": InsightContent(id: "read_labels", title: "Read Nutrition Labels", subtitle: "Know what you're eating", mainContent: "Nutrition labels show serving size, calories, and key nutrients. Checking them helps you compare products and avoid hidden sugar, salt, and unhealthy fats.", keyPoints: ["Serving size is at the top—portions add up", "Check sodium, added sugar, and saturated fat", "Ingredients are listed by weight (first = most)", "Front-of-package claims can be misleading"], tips: ["Compare similar products per 100g or per serving", "Look for short ingredient lists on packaged foods", "Sugar has many names (syrup, honey, juice concentrate)", "Use labels to choose higher fiber and protein"], benefits: ["Better food choices", "Awareness of hidden sugar and salt", "Easier to meet nutrition goals", "More control over your diet"]),
        "slow_cooker": InsightContent(id: "slow_cooker", title: "Use a Slow Cooker", subtitle: "Set it and forget it", mainContent: "A slow cooker lets you add ingredients in the morning and come home to a hot meal. Great for soups, stews, pulled meat, and beans with minimal hands-on time.", keyPoints: ["Ideal for tough cuts of meat and beans", "Low and slow preserves moisture and flavor", "You can leave it unattended safely", "Batch size is easy to scale up"], tips: ["Brown meat first for deeper flavor", "Layer harder vegetables at the bottom", "Don't overfill—two-thirds full is a good max", "Use the low setting when you have more time"], benefits: ["Saves active cooking time", "Tender, flavorful results", "One pot, minimal cleanup", "Meal prep with no babysitting"], relatedRecipeIds: [103, 114, 146, 162]),
        "one_pot_meals": InsightContent(id: "one_pot_meals", title: "One-Pot Meals", subtitle: "Fewer dishes, full flavor", mainContent: "Skillet dinners, sheet-pan meals, and one-pot pasta mean less cleanup and often faster cooking. Everything cooks together, so flavors meld and you use fewer dishes.", keyPoints: ["One pan or pot = less cleanup", "Ingredients cook together for layered flavor", "Great for weeknights when time is short", "Easier to portion and store leftovers"], tips: ["Start with aromatics, then add protein and veggies", "Use a large skillet or Dutch oven", "Add delicate greens or herbs at the end", "Sheet pans work for roasted veg + protein"], benefits: ["Faster cleanup", "Simple weeknight dinners", "Fewer dishes to wash", "Still hearty and satisfying"], relatedRecipeIds: [103, 105, 114, 146]),
        "salad_first": InsightContent(id: "salad_first", title: "Start with a Salad", subtitle: "Fill up on veggies first", mainContent: "Eating a small salad or vegetable-based starter before the main course helps you fill up on fiber and nutrients, so you may eat less of higher-calorie foods and feel satisfied with smaller portions.", keyPoints: ["Veggies first increases fiber and volume", "Can reduce total calories per meal", "Adds variety and color to your plate", "Light dressing or lemon keeps it healthy"], tips: ["Keep greens washed and ready in the fridge", "Add protein (chickpeas, nuts) to make it a side", "Use vinegar and oil instead of creamy dressings", "Try a small soup or crudités if you prefer"], benefits: ["More vegetables without thinking about it", "Natural portion control", "Better digestion", "Steady energy from fiber"], relatedRecipeIds: [113, 122, 127, 142]),
        "chew_slowly": InsightContent(id: "chew_slowly", title: "Chew Slowly", subtitle: "Give your brain time to register fullness", mainContent: "It takes about 20 minutes for your brain to get the signal that you're full. Eating slowly and chewing well helps you notice when you've had enough and can reduce overeating.", keyPoints: ["Fullness signals take time to reach the brain", "Chewing well aids digestion", "Slower eating often means less consumed", "You enjoy food more when you slow down"], tips: ["Put your fork down between bites", "Take smaller bites", "Avoid eating in front of screens", "Set a minimum time for meals"], benefits: ["Better digestion", "Natural portion control", "More enjoyment of food", "Less discomfort after eating"]),
        "limit_processed": InsightContent(id: "limit_processed", title: "Limit Processed Foods", subtitle: "Choose whole foods when you can", mainContent: "Highly processed foods—packaged snacks, sugary cereals, and many ready meals—often contain extra salt, sugar, and additives. Choosing whole or minimally processed options most of the time supports better health and weight.", keyPoints: ["Whole foods have fewer additives", "Processed foods often have hidden sugar and salt", "Not all packaged food is bad—check labels", "Cook from scratch when you can"], tips: ["Swap packaged snacks for fruit or nuts", "Choose plain oats over flavored instant", "Make simple sauces instead of jarred", "Batch-cook so whole-food meals are easy"], benefits: ["Fewer empty calories", "Better control over ingredients", "More nutrients per bite", "Supports long-term health"]),
        "oily_fish": InsightContent(id: "oily_fish", title: "Eat Oily Fish Weekly", subtitle: "Salmon, mackerel, sardines for heart and brain", mainContent: "Oily fish like salmon, mackerel, herring, and sardines are rich in omega-3 fatty acids, which support heart health, brain function, and inflammation. Aim for at least one portion per week.", keyPoints: ["Omega-3s support heart and brain", "Canned sardines and salmon are affordable", "Grill, bake, or steam to keep it healthy", "Pregnant women should follow local fish guidelines"], tips: ["Add canned salmon to salads or pasta", "Try tinned sardines on toast or crackers", "Grill or bake fresh salmon with herbs", "Mix mackerel into rice or grain bowls"], benefits: ["Heart health", "Brain function", "Anti-inflammatory", "Quality protein and nutrients"], relatedRecipeIds: [106, 113, 133, 147]),
        "vegetables_first": InsightContent(id: "vegetables_first", title: "Veggies First", subtitle: "Fill half your plate with vegetables", mainContent: "Making vegetables the star of your plate—half by volume—automatically boosts fiber, vitamins, and minerals while leaving less room for heavier, calorie-dense foods. It's one of the simplest ways to eat better.", keyPoints: ["Half the plate is a visual, easy goal", "More veggies = more fiber and nutrients", "Adds color and variety", "Works at home or when plating takeout"], tips: ["Prep veggies so they're easy to grab", "Roast a big tray and reheat during the week", "Add greens to eggs, pasta, and stir-fries", "Keep frozen vegetables for quick sides"], benefits: ["More nutrients and fiber", "Natural portion control", "Better digestion", "Supports weight and health goals"], relatedRecipeIds: [108, 122, 127, 156]),
        "reduce_salt": InsightContent(id: "reduce_salt", title: "Reduce Sodium", subtitle: "Use herbs, citrus, and spices instead of extra salt", mainContent: "Too much sodium can raise blood pressure and increase health risks. You can cut back without losing flavor by using herbs, citrus, vinegar, and spices instead of reaching for the salt shaker.", keyPoints: ["Herbs and spices replace salt without missing flavor", "Processed foods are often high in sodium", "Taste adjusts when you reduce gradually", "Read labels for sodium per serving"], tips: ["Use lemon, lime, or vinegar to brighten dishes", "Add garlic, ginger, and fresh herbs", "Rinse canned beans to reduce sodium", "Choose low-sodium broths and sauces"], benefits: ["Better blood pressure", "Lower risk of heart issues", "Less bloating", "Kinder to kidneys"]),
        "fermented_foods": InsightContent(id: "fermented_foods", title: "Try Fermented Foods", subtitle: "Yogurt, kimchi, sauerkraut for gut health", mainContent: "Fermented foods like yogurt, kefir, kimchi, sauerkraut, and kombucha contain beneficial bacteria that can support gut health and digestion. Add a small serving regularly rather than large amounts occasionally.", keyPoints: ["Probiotics support gut and digestion", "Start with small amounts if you're new", "Plain yogurt has less sugar than flavored", "Check labels for live cultures"], tips: ["Add plain yogurt to breakfast or smoothies", "Try kimchi or sauerkraut as a side", "Use kefir in smoothies or overnight oats", "Introduce one fermented food at a time"], benefits: ["Better digestion", "Gut health", "Possible immune support", "Variety in your diet"], relatedRecipeIds: [107, 183, 130, 136]),
        "nuts_seeds": InsightContent(id: "nuts_seeds", title: "Add Nuts & Seeds", subtitle: "A handful adds crunch, protein, and healthy fats", mainContent: "Nuts and seeds add protein, healthy fats, and crunch to meals and snacks. A small handful is a good portion—they're nutrient-dense, so a little goes a long way.", keyPoints: ["Nuts and seeds are calorie-dense; portions matter", "They provide protein, fiber, and healthy fats", "Great on oatmeal, salads, and yogurt", "Store in a cool place to keep oils fresh"], tips: ["Keep small bags of nuts for snacks", "Sprinkle seeds on salads and stir-fries", "Use nut butter on toast or in smoothies", "Choose unsalted when possible"], benefits: ["Satisfying snacks", "Heart-healthy fats", "Protein and fiber", "Easy to add to any meal"], relatedRecipeIds: [136, 181, 194, 210]),
        "meal_plan_weekly": InsightContent(id: "meal_plan_weekly", title: "Plan Meals Weekly", subtitle: "One planning session saves stress all week", mainContent: "Spend 15–30 minutes once a week deciding what you'll eat for the next few days. You'll shop smarter, waste less, and avoid the daily \"what's for dinner?\" stress.", keyPoints: ["One session reduces daily decisions", "Makes grocery lists and shopping easier", "Use a calendar or app to track plans", "Leave room for leftovers and flexibility"], tips: ["Pick 2–3 dinners and repeat or vary", "Check the fridge before planning", "Plan around what's on sale or in season", "Prep one or two components in advance"], benefits: ["Less stress", "Less food waste", "More balanced meals", "Easier to stick to goals"]),
        "kitchen_tools": InsightContent(id: "kitchen_tools", title: "Good Kitchen Tools", subtitle: "A sharp knife and a few basics make cooking easier", mainContent: "You don't need a full restaurant kitchen, but a sharp chef's knife, a good cutting board, a few pots and pans, and basic utensils make cooking faster, safer, and more enjoyable. Invest in the basics first.", keyPoints: ["A sharp knife is safer and faster than a dull one", "A good cutting board protects blades and counters", "One large skillet and one pot cover many recipes", "Quality beats quantity"], tips: ["Learn to sharpen or hone your knife", "Use the right size pan for the job", "Keep tongs, spatula, and a wooden spoon handy", "Store tools where you use them"], benefits: ["Faster prep", "Safer cooking", "More confidence", "Less frustration"]),
        "cooking_with_kids": InsightContent(id: "cooking_with_kids", title: "Cook with Family", subtitle: "Get kids involved; they eat more of what they make", mainContent: "When kids help in the kitchen—washing veggies, stirring, or choosing a recipe—they're more likely to try new foods and build lifelong skills. Start with simple tasks and age-appropriate jobs.", keyPoints: ["Kids who cook are more likely to try new foods", "Start with washing, mixing, and safe tasks", "Let them pick a recipe once a week", "Keep it fun; mess is part of learning"], tips: ["Give them a dedicated job each meal", "Use a step stool so they can reach safely", "Talk about where food comes from", "Celebrate their contributions"], benefits: ["Better eaters", "Life skills", "Family time", "Less picky eating"]),
        "stress_eating": InsightContent(id: "stress_eating", title: "Notice Stress Eating", subtitle: "Pause and ask if you're hungry or stressed", mainContent: "Sometimes we eat because we're bored, anxious, or stressed—not because we're hungry. Noticing the difference helps you choose whether to eat, find another activity, or address the feeling directly.", keyPoints: ["Emotional eating is common and normal", "Pausing helps you notice true hunger", "Find non-food ways to cope with stress", "Being kind to yourself matters more than perfection"], tips: ["Pause and rate hunger from 1–10 before eating", "Drink water and wait 10 minutes", "Take a short walk or call a friend", "Keep tempting snacks out of easy reach when stressed"], benefits: ["Better relationship with food", "Fewer unnecessary calories", "More awareness", "Healthier coping"]),
        "variety": InsightContent(id: "variety", title: "Eat a Variety", subtitle: "Different foods provide different nutrients", mainContent: "No single food has everything you need. Eating a variety of vegetables, fruits, grains, proteins, and fats helps you get a broad range of nutrients and keeps meals interesting.", keyPoints: ["Variety covers more vitamins and minerals", "Different colors often mean different nutrients", "Rotate proteins and grains", "Try one new food per week"], tips: ["Shop different aisles and try new produce", "Vary your grains—oats, rice, quinoa, barley", "Switch up proteins—beans, fish, poultry, eggs", "Add new herbs or spices to familiar dishes"], benefits: ["Better nutrition", "Less boredom", "Discovery of new favorites", "Balanced diet"]),
        "small_plates": InsightContent(id: "small_plates", title: "Use Smaller Plates", subtitle: "Portions look bigger; you may eat less", mainContent: "Serving food on smaller plates makes portions look larger, which can help you feel satisfied with less. It's a simple visual trick that works without strict dieting.", keyPoints: ["Same portion looks bigger on a small plate", "You can always take more if still hungry", "Works for main meals and snacks", "No need to measure—just plate mindfully"], tips: ["Use salad plates for main meals", "Put snacks in a bowl instead of eating from the bag", "Serve family style so you choose your amount", "Leave serving dishes off the table"], benefits: ["Natural portion control", "No strict counting", "Mindful eating", "Can support weight goals"]),
        "protein_breakfast": InsightContent(id: "protein_breakfast", title: "Protein at Breakfast", subtitle: "Eggs, yogurt, or nut butter keep you full longer", mainContent: "Starting the day with protein—eggs, Greek yogurt, nut butter, or beans—helps stabilize blood sugar and keeps you full longer than a sugary or carb-only breakfast.", keyPoints: ["Protein at breakfast reduces mid-morning hunger", "Eggs, yogurt, and nut butter are easy options", "Pair with fiber (fruit, oats) for balance", "Prep ahead for busy mornings"], tips: ["Hard-boil eggs for the week", "Make overnight oats with Greek yogurt", "Add nut butter to toast or smoothies", "Try beans and eggs for a savory start"], benefits: ["Longer-lasting energy", "Fewer cravings", "Better focus", "Supports muscle and metabolism"], relatedRecipeIds: [101, 107, 111, 178]),
        "walk_after_meal": InsightContent(id: "walk_after_meal", title: "Walk After Meals", subtitle: "A short walk helps digestion and blood sugar", mainContent: "A 10–15 minute walk after a meal can help digestion and blunt blood sugar spikes. You don't need to run—a gentle stroll after lunch or dinner is enough to see benefits.", keyPoints: ["Movement after eating aids digestion", "Can improve blood sugar response", "No need for intensity—walking is enough", "Builds a habit that fits into the day"], tips: ["Walk after your biggest meal of the day", "Use a phone or timer for 10–15 minutes", "Walk with a colleague or family member", "Step outside when possible for fresh air"], benefits: ["Better digestion", "Stable energy", "Mood boost", "Easy daily habit"]),
        "limit_alcohol": InsightContent(id: "limit_alcohol", title: "Limit Alcohol", subtitle: "Alcohol adds calories and can affect sleep and choices", mainContent: "Alcohol adds calories with little nutrition and can affect sleep, appetite, and willpower. Limiting how much and how often you drink supports better sleep, weight, and overall health.", keyPoints: ["Alcohol is calorie-dense and can increase appetite", "It can disrupt sleep and next-day choices", "Guidelines suggest moderation or less", "Alternate with water or low-calorie drinks"], tips: ["Set a limit before you start", "Choose smaller servings or lower-alcohol options", "Have a glass of water between drinks", "Avoid drinking on an empty stomach"], benefits: ["Better sleep", "Fewer empty calories", "Clearer choices", "Long-term health"]),
        "whole_grains": InsightContent(id: "whole_grains", title: "Choose Whole Grains", subtitle: "Oats, brown rice, whole wheat add fiber", mainContent: "Whole grains—oats, brown rice, quinoa, whole wheat—keep the bran and germ, so they have more fiber and nutrients than refined grains. Swap white rice or white bread for whole-grain options when you can.", keyPoints: ["Whole grains have more fiber and nutrients", "Look for \"whole\" as the first ingredient", "Oats, brown rice, quinoa are easy swaps", "Fiber helps fullness and digestion"], tips: ["Use oats for breakfast or in baking", "Choose brown rice or quinoa for dinner", "Pick whole-grain bread and pasta", "Try barley or bulgur in soups and salads"], benefits: ["More fiber", "Steadier energy", "Better digestion", "Nutrient boost"], relatedRecipeIds: [101, 104, 122, 130]),
        "legumes": InsightContent(id: "legumes", title: "Add Legumes", subtitle: "Beans and lentils are cheap, filling, and nutritious", mainContent: "Beans, lentils, and chickpeas are affordable, high in protein and fiber, and versatile. Add them to soups, salads, tacos, and grain bowls for filling, nutritious meals.", keyPoints: ["Legumes are cheap, shelf-stable, and nutritious", "High in protein and fiber", "Canned or dried both work", "Rinse canned to reduce sodium"], tips: ["Keep canned beans for quick meals", "Cook dried lentils for soups and curries", "Add chickpeas to salads and roasted veg", "Use black beans in tacos and burritos"], benefits: ["Budget-friendly", "Filling and satisfying", "Plant-based protein", "Supports heart and gut health"], relatedRecipeIds: [105, 114, 127, 135]),
        "colorful_plate": InsightContent(id: "colorful_plate", title: "Eat the Rainbow", subtitle: "Different colors often mean different nutrients", mainContent: "Different-colored fruits and vegetables provide different vitamins, minerals, and phytonutrients. Aim for a mix of red, orange, yellow, green, blue, and purple on your plate over the day or week.", keyPoints: ["Color variety often means nutrient variety", "Red: lycopene; green: folate; orange: vitamin A", "No need for every color every meal", "Frozen and canned count too"], tips: ["Add one extra color to each meal", "Keep frozen mixed vegetables on hand", "Try a new fruit or vegetable each week", "Use herbs and spices for more variety"], benefits: ["Broader nutrition", "More interesting meals", "Antioxidants and vitamins", "Simple visual goal"], relatedRecipeIds: [104, 108, 122, 156]),
        "avoid_screens": InsightContent(id: "avoid_screens", title: "No Screens While Eating", subtitle: "Eat at the table without TV or phones", mainContent: "Eating while watching TV or scrolling can make you eat more without noticing, because you're distracted from fullness cues. Eating at a table without screens helps you tune in to taste and satisfaction.", keyPoints: ["Distracted eating often leads to overeating", "Screens delay or hide fullness signals", "Table meals improve digestion and connection", "Start with one screen-free meal a day"], tips: ["Put phones away during meals", "Eat at a table when possible", "Use a placemat to define \"meal space\"", "Talk or listen instead of watching"], benefits: ["Better portion awareness", "More enjoyment of food", "Improved digestion", "Quality time with others"]),
        "grocery_after_meal": InsightContent(id: "grocery_after_meal", title: "Shop After a Meal", subtitle: "You'll buy less junk when you're not hungry", mainContent: "Shopping on an empty stomach can lead to more impulse buys and less healthy choices. Eat a snack or meal before you go so you stick to your list and avoid loading the cart with treats.", keyPoints: ["Hunger increases impulse buying", "A full stomach helps you stick to the list", "Plan shopping after lunch or a snack", "Same applies to ordering food online"], tips: ["Never shop hungry—have a snack first", "Stick to the list; avoid browsing aisles", "Shop the perimeter for fresh foods first", "Leave treats for occasional, planned buys"], benefits: ["Fewer impulse buys", "Healthier cart", "Lower bill", "Less food waste"]),
        "freezer_staples": InsightContent(id: "freezer_staples", title: "Keep Freezer Staples", subtitle: "Frozen veggies, protein, and grains for quick meals", mainContent: "A stocked freezer means you can always put a meal together. Keep frozen vegetables, proteins like chicken or fish, and even cooked grains so you're never stuck without options.", keyPoints: ["Frozen produce is nutritious and convenient", "Frozen protein defrosts for quick dinners", "Cooked grains freeze well for reheating", "Label and date everything"], tips: ["Keep frozen broccoli, peas, and spinach", "Freeze portions of cooked rice or quinoa", "Stock frozen chicken breasts or fish fillets", "Use freezer bags to save space"], benefits: ["Always something to cook", "Less food waste", "Quick weeknight meals", "No last-minute takeout"]),
        "pantry_staples": InsightContent(id: "pantry_staples", title: "Stock Pantry Staples", subtitle: "Canned beans, pasta, and rice mean you can always cook", mainContent: "A few pantry staples—canned beans, tomatoes, pasta, rice, and oils—mean you can make a meal even when the fridge is bare. Rotate and restock so nothing sits for years.", keyPoints: ["Pantry items have long shelf lives", "Canned beans and tomatoes are versatile", "Pasta, rice, and grains are filling bases", "Oils, vinegar, and spices round out flavor"], tips: ["Keep canned chickpeas, black beans, and tomatoes", "Stock pasta, rice, and maybe quinoa", "Have olive oil, vinegar, and basic spices", "Check dates and use older items first"], benefits: ["No empty-kitchen stress", "Budget-friendly meals", "Flexible cooking", "Always ready to cook"]),
        "cooking_confidence": InsightContent(id: "cooking_confidence", title: "Build Cooking Confidence", subtitle: "Start with simple recipes and repeat them", mainContent: "You don't need to be a chef to eat well. Pick a few simple recipes—eggs, a stir-fry, a soup—and make them until they feel easy. Confidence grows with repetition.", keyPoints: ["Simple recipes build skills and confidence", "Repeat favorites until they're easy", "Mistakes are part of learning", "You need only a handful of go-to meals"], tips: ["Master eggs first—scrambled, fried, omelet", "Learn one soup and one stir-fry", "Cook the same recipe 2–3 times in a month", "Use a timer and follow recipes at first"], benefits: ["Less reliance on takeout", "More control over health", "Saves money", "Satisfying skill"]),
        "leftovers_creative": InsightContent(id: "leftovers_creative", title: "Get Creative with Leftovers", subtitle: "Turn last night's roast into tacos or a salad", mainContent: "Leftovers don't have to be the same meal again. Shred last night's chicken into tacos, toss roasted vegetables into a grain bowl, or add beans and broth to make soup. A little creativity reduces waste and keeps meals interesting.", keyPoints: ["Same ingredients, new dish", "Proteins and grains are especially versatile", "Add sauce, greens, or grains to change it up", "Label and date containers"], tips: ["Plan \"leftover night\" once a week", "Keep tortillas and greens for quick wraps and salads", "Turn roasted veg into soup with broth", "Use rice or pasta in stir-fries or bowls"], benefits: ["Less waste", "Less cooking", "More variety", "Budget-friendly"]),
        "hydration_cues": InsightContent(id: "hydration_cues", title: "Listen to Thirst Cues", subtitle: "Drink when you're thirsty; don't wait until you're parched", mainContent: "Thirst is your body's way of saying it needs fluid. Drink when you feel thirsty, and keep water handy so you don't have to wait. By the time you're very thirsty, you're already somewhat dehydrated.", keyPoints: ["Thirst is a normal signal—respond to it", "Keep water visible and easy to reach", "Urine color can be a cue (pale = well hydrated)", "Increase fluids in heat or when active"], tips: ["Keep a water bottle at your desk or in your bag", "Drink a glass when you wake up", "Set a gentle reminder if you forget", "Flavor with fruit or herbs if you prefer"], benefits: ["Better energy", "Clearer thinking", "Supports digestion", "Healthy habit"]),
        "meal_prep_sunday": InsightContent(id: "meal_prep_sunday", title: "Sunday Meal Prep", subtitle: "Prep ingredients or full meals for the week ahead", mainContent: "Use part of Sunday to prep for the week—wash and chop vegetables, cook a batch of grains or protein, or assemble full meals in containers. Weekday cooking becomes faster and less stressful.", keyPoints: ["One block of time saves daily time", "Prep ingredients or full meals—your choice", "Containers and labels keep things organized", "Refrigerate or freeze based on use-by timing"], tips: ["Start with 1–2 hours; don't overdo it", "Prep components (grains, proteins, veggies) to mix and match", "Make a big pot of soup or chili to portion", "Keep a list of what you prepped and when"], benefits: ["Easier weeknights", "Less decision fatigue", "Consistent healthy eating", "Less food waste"]),
        "mindful_grocery": InsightContent(id: "mindful_grocery", title: "Mindful Grocery Shopping", subtitle: "Stick to the list and avoid impulse buys", mainContent: "Shopping with a list and a calm mindset helps you buy what you need and avoid impulse purchases. Plan meals ahead, list ingredients, and try to shop when you're not rushed or hungry.", keyPoints: ["A list keeps you on track and saves money", "Avoid shopping when stressed or hungry", "Stick to the perimeter for more whole foods", "Compare unit prices when choosing packaged items"], tips: ["Write the list after meal planning", "Don't browse aisles you don't need", "Use pickup or delivery to avoid impulse buys", "Review the list before you enter the store"], benefits: ["Less overspending", "Healthier choices", "Less food waste", "Less stress"]),
        "balanced_plate": InsightContent(id: "balanced_plate", title: "Balance Your Plate", subtitle: "Protein, carbs, and veggies in each meal", mainContent: "A balanced plate has protein, carbohydrates, and vegetables (and some healthy fat). You don't need to measure everything—aim for rough balance so you stay full and get a mix of nutrients.", keyPoints: ["Protein + carbs + veggies + fat = balanced", "Half veggies, quarter protein, quarter grains is a guide", "Adjust for appetite and activity", "Balance over the day matters more than per meal"], tips: ["Use the half-plate veggie rule", "Add a palm-sized portion of protein", "Include a fist-sized portion of grains or starch", "Add fat via oil, nuts, or avocado"], benefits: ["Sustained energy", "Fullness and satisfaction", "Broad nutrition", "Flexible structure"]),
        "reduce_fried": InsightContent(id: "reduce_fried", title: "Cut Back on Fried Foods", subtitle: "Bake, grill, or steam instead when you can", mainContent: "Fried foods are often high in calories and unhealthy fats. Swapping for baked, grilled, or steamed versions when you can reduces calories and supports heart health without giving up flavor.", keyPoints: ["Baking and grilling use less oil", "Air fryers can give crunch with less fat", "Steaming preserves nutrients and needs no oil", "Occasional fried food is fine—frequency matters"], tips: ["Use an air fryer for crispy results with less oil", "Roast vegetables instead of frying", "Grill or bake chicken and fish", "Choose oven-baked over deep-fried when eating out"], benefits: ["Fewer calories", "Better heart health", "Lighter meals", "Still satisfying"], relatedRecipeIds: [106, 119, 127, 114]),
        "snack_smart": InsightContent(id: "snack_smart", title: "Snack Smart", subtitle: "Keep fruit, nuts, or yogurt on hand for hunger between meals", mainContent: "Smart snacking can keep energy stable and prevent overeating at the next meal. Choose snacks that combine protein or fiber with a bit of satisfaction—fruit and nuts, yogurt, or veggies and hummus.", keyPoints: ["Snacks can help or hurt depending on choice", "Protein and fiber keep you full longer", "Portion snacks so you don't mindlessly overeat", "Keep healthy options visible and easy"], tips: ["Prep snack portions in bags or containers", "Keep fruit on the counter", "Pair carbs with protein (apple + nut butter)", "Avoid eating from the package"], benefits: ["Stable energy", "Fewer cravings", "Better choices at meals", "No crash"]),
        "rest_and_digest": InsightContent(id: "rest_and_digest", title: "Rest After Eating", subtitle: "Avoid intense activity right after a big meal", mainContent: "Digestion works best when you're not in fight-or-flight mode. A short rest or gentle walk after a meal is better than intense exercise or rushing back to work. Give your body a few minutes to start digesting.", keyPoints: ["Blood flow shifts to digestion after eating", "Intense exercise right after can cause discomfort", "A 10-minute rest or slow walk helps", "Listen to your body"], tips: ["Sit for 5–10 minutes after a large meal", "Take a short, gentle walk instead of a run", "Avoid heavy lifting right after eating", "Schedule harder workouts before meals or 1–2 hours after"], benefits: ["Better digestion", "Less discomfort", "More energy later", "Respect for your body"]),
        "label_serving": InsightContent(id: "label_serving", title: "Check Serving Size", subtitle: "Nutrition labels are per serving; portions add up", mainContent: "Nutrition facts on packages are per serving, not per package. A bag of chips might list 150 calories per serving but contain 3 servings—so the whole bag is 450 calories. Always check serving size first.", keyPoints: ["Serving size is at the top of the label", "Compare similar products per 100g or per serving", "Portions add up quickly with snacks and drinks", "Use measuring cups or a scale at home to learn portions"], tips: ["Read serving size before calories", "Check how many servings are in the package", "Measure snacks once to learn what a portion looks like", "Use smaller bowls and plates to avoid over-pouring"], benefits: ["Accurate picture of what you eat", "Better control", "Informed choices", "Easier to meet goals"]),
    ]

    static func random(count: Int = 3) -> [Insight] {
        Array(all.shuffled().prefix(count))
    }

    static func content(forId id: String) -> InsightContent? {
        contentById[id]
    }

    static func categories() -> [String] {
        Array(Set(all.map(\.category))).sorted()
    }
}
