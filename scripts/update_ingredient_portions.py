#!/usr/bin/env python3
"""
Update smartcart_catalog.json so every ingredient has a sensible standard serving.
- Single-item produce (banana, carrot, apple, etc.): 1 medium [item] with average weight.
- Berries/small fruits: 1 cup with typical weight.
- Leaves 1 cup, 1 tbsp, 1 oz, 100g, etc. unchanged where already set; converts 100g to piece/cup where mapped.
"""
import json
import os

# canonicalName -> (standardServing, weight_grams for scaling from per-100g)
# We only scale when current standardServing is "100g" or "100g cooked"; otherwise we just set serving if in map.
PIECE_SERVING_MAP = {
    # Single-item fruits
    "Banana": ("1 medium banana", 118),
    "Apple": ("1 medium apple", 182),
    "Orange": ("1 medium orange", 131),
    "Pear": ("1 medium pear", 178),
    "Peach": ("1 medium peach", 150),
    "Nectarine": ("1 medium nectarine", 142),
    "Plum": ("1 medium plum", 66),
    "Apricot": ("1 medium apricot", 35),
    "Kiwi": ("1 medium kiwi", 75),
    "Mango": ("1 medium mango", 336),
    "Avocado": ("1 medium avocado", 136),
    "Lemon": ("1 medium lemon", 58),
    "Lime": ("1 medium lime", 67),
    "Pomegranate": ("1 medium pomegranate", 282),
    "Passion Fruit": ("1 medium passion fruit", 18),
    "Dragon Fruit": ("1 medium dragon fruit", 198),
    "Papaya": ("1 medium papaya", 304),
    "Coconut Fresh": ("1 medium coconut", 397),
    "Figs": ("1 medium fig", 50),
    "Dates": ("2 medjool dates", 40),
    # Single-item vegetables
    "Carrot": ("1 medium carrot", 61),
    "Tomato": ("1 medium tomato", 123),
    "Cucumber": ("1 medium cucumber", 201),
    "Zucchini": ("1 medium zucchini", 196),
    "Bell Pepper Red": ("1 medium pepper", 119),
    "Bell Pepper Green": ("1 medium pepper", 119),
    "Bell Pepper Yellow": ("1 medium pepper", 119),
    "Bell Pepper Orange": ("1 medium pepper", 119),
    "Russet Potato": ("1 medium potato", 173),
    "Sweet Potato": ("1 medium sweet potato", 130),
    "Onion Yellow": ("1 medium onion", 110),
    "Jalapeno": ("1 medium jalapeño", 14),
    "Poblano Pepper": ("1 medium pepper", 85),
    "Serrano Pepper": ("1 medium pepper", 10),
    "Habanero": ("1 pepper", 17),
    "Yellow Squash": ("1 medium squash", 196),
    "Acorn Squash": ("1 medium squash", 431),
    "Spaghetti Squash": ("1 medium squash", 609),
    "Delicata Squash": ("1 medium squash", 250),
    "Pumpkin": ("1 cup cubed", 116),
    "Okra": ("8 pods", 85),
    "Artichoke": ("1 medium artichoke", 128),
    "Beets": ("1 medium beet", 82),
    "Celery": ("1 medium stalk", 40),
    "Radish": ("4 radishes", 25),
    "Turnip": ("1 medium turnip", 122),
    "Rutabaga": ("1 cup cubed", 140),
    "Fennel": ("1 medium bulb", 234),
    "Eggplant": ("1 cup cubed", 82),
    "Garlic": ("1 clove", 3),
    "Leeks": ("1 medium leek", 89),
    "Shallots": ("1 medium shallot", 25),
    "Scallions": ("1 scallion", 10),
    # Berries and small fruits (1 cup)
    "Blueberries": ("1 cup", 148),
    "Strawberries": ("1 cup halves", 152),
    "Raspberries": ("1 cup", 123),
    "Blackberries": ("1 cup", 144),
    "Grapes": ("1 cup", 92),
    "Cherries": ("1 cup", 138),
    "Cranberries": ("1 cup", 100),
    "Pineapple": ("1 cup chunks", 165),
    "Cherry Tomato": ("1 cup", 149),
    "Cherry Tomatoes Yellow": ("1 cup", 149),
    "Grape Tomatoes": ("1 cup", 149),
    "Mushrooms": ("1 cup sliced", 70),
    "Broccoli": ("1 cup chopped", 91),
    "Cauliflower": ("1 cup chopped", 107),
    "Brussels Sprouts": ("1 cup", 88),
    "Green Beans": ("1 cup", 125),
    "Asparagus": ("6 spears", 90),
    "Cabbage": ("1 cup shredded", 89),
    "Lettuce Romaine": ("1 cup shredded", 47),
    "Arugula": ("1 cup", 20),
    "Mixed Greens": ("1 cup", 30),
    "Iceberg Lettuce": ("1 cup shredded", 72),
    "Butter Lettuce": ("1 cup", 15),
    "Red Leaf Lettuce": ("1 cup", 20),
    "Green Leaf Lettuce": ("1 cup", 20),
    "Spinach": ("1 cup", 30),
    "Kale": ("1 cup chopped", 67),
    "Bok Choy": ("1 cup shredded", 70),
    "Collard Greens": ("1 cup chopped", 36),
    "Swiss Chard": ("1 cup", 36),
    "Watercress": ("1 cup", 34),
    "Endive": ("1 cup chopped", 50),
    "Radicchio": ("1 cup shredded", 40),
    "Frisee": ("1 cup", 25),
    # Herbs - small amounts
    "Basil Fresh": ("1/4 cup leaves", 5),
    "Cilantro": ("1/4 cup", 4),
    "Parsley": ("1/4 cup", 15),
    "Green Onion": ("1 green onion", 15),
    "Dill": ("1 tbsp fresh", 1),
    "Mint": ("1/4 cup leaves", 6),
    "Oregano Fresh": ("1 tbsp", 1),
    "Thyme Fresh": ("1 tbsp", 1),
    "Rosemary Fresh": ("1 tbsp", 1),
    "Sage": ("1 tbsp", 1),
    "Tarragon": ("1 tbsp", 1),
    "Chives": ("1 tbsp", 1),
    # More produce / veg
    "Ginger": ("1 tbsp grated", 6),
    "Celery Root": ("1 cup diced", 156),
    "Heirloom Tomatoes": ("1 medium tomato", 123),
    "Plum Tomatoes": ("2 plum tomatoes", 100),
    "Pattypan Squash": ("1 medium squash", 130),
    "Napa Cabbage": ("1 cup shredded", 76),
    "Red Cabbage": ("1 cup shredded", 89),
    "Savoy Cabbage": ("1 cup shredded", 70),
    "Mustard Greens": ("1 cup chopped", 56),
    "Belgian Endive": ("1 head", 50),
    "Corn Kernels": ("1 cup", 164),
    "Peas Frozen": ("1 cup", 134),
    "Mixed Veg Frozen": ("1 cup", 130),
    "Edamame": ("1 cup", 155),
    "Berry Mix Frozen": ("1 cup", 150),
    "Pomegranate Seeds": ("1/2 cup", 87),
    "Figs Dried": ("2 figs", 38),
    "Cranberries Dried": ("1/4 cup", 40),
    "Coconut Shredded": ("1/4 cup", 20),
    "Artichoke Hearts Canned": ("1/2 cup", 80),
    "Hearts of Palm": ("1/2 cup", 78),
}

def scale_from_100g(ing, ref_g):
    """Scale nutrition from per-100g to per ref_g. Rounds to int."""
    factor = ref_g / 100.0
    def r(x):
        return max(0, int(round((x or 0) * factor)))
    return {
        "caloriesPerServing": r(ing.get("caloriesPerServing")),
        "proteinPerServing": r(ing.get("proteinPerServing")),
        "carbsPerServing": r(ing.get("carbsPerServing")),
        "fatsPerServing": r(ing.get("fatsPerServing")),
    }

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    catalog_path = os.path.join(script_dir, "..", "SmartCart", "smartcart_catalog.json")
    with open(catalog_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    updated = 0
    for ing in data["ingredients"]:
        name = ing.get("canonicalName", "")
        if name not in PIECE_SERVING_MAP:
            continue
        serving_str, ref_g = PIECE_SERVING_MAP[name]
        current = (ing.get("standardServing") or "").strip()
        # Scale when current is per-100g (or 100g cooked)
        if current in ("100g", "100g cooked"):
            scaled = scale_from_100g(ing, ref_g)
            ing["caloriesPerServing"] = scaled["caloriesPerServing"]
            ing["proteinPerServing"] = scaled["proteinPerServing"]
            ing["carbsPerServing"] = scaled["carbsPerServing"]
            ing["fatsPerServing"] = scaled["fatsPerServing"]
        ing["standardServing"] = serving_str
        updated += 1

    with open(catalog_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"Updated {updated} ingredients with piece/cup servings.")

if __name__ == "__main__":
    main()
