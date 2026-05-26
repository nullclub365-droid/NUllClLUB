import Foundation

// Example: How to add Premium route to AppRoute.swift

enum AppRoute: Hashable {
    case home
    case recipeDetail(id: String)
    case mealPlanner
    case foodLog
    case settings
    case premium  // ← ADD THIS LINE

    // If using NavigationStack:
    // @State private var navigationPath: NavigationPath = NavigationPath()
    //
    // Then in your view:
    // .navigationDestination(for: AppRoute.self) { route in
    //     switch route {
    //     case .home:
    //         HomeScreen()
    //     case .recipeDetail(let id):
    //         RecipeDetailScreen(recipeID: id)
    //     case .mealPlanner:
    //         MealPlannerScreen()
    //     case .foodLog:
    //         FoodLogScreen()
    //     case .settings:
    //         SettingsScreen()
    //     case .premium:
    //         PremiumScreen()
    //     }
    // }
}

// Example: How to show premium screen from different places

// 1. From a button in Settings
struct SettingsScreenExample: View {
    @State private var showPremium = false

    var body: some View {
        List {
            Section("Account") {
                Button(action: { showPremium = true }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Upgrade to Premium")
                    }
                }
            }
        }
        .sheet(isPresented: $showPremium) {
            PremiumScreen()
        }
    }
}

// 2. Using premiumGate modifier for features
struct AdvancedFiltersViewExample: View {
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        VStack {
            Text("Advanced Recipe Filters")
            // Your filter UI here
        }
        .premiumGate(true)  // Lock behind premium
    }
}

// 3. Conditional based on subscription
struct HomeScreenExample: View {
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        List {
            if storeManager.isPremium {
                Section("Premium Features") {
                    NavigationLink(destination: AdvancedFiltersViewExample()) {
                        Label("Advanced Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}

// 4. Using @EnvironmentObject to check premium status anywhere
struct AnyViewExample: View {
    @EnvironmentObject var storeManager: StoreManager

    var body: some View {
        if storeManager.isPremium {
            Text("Premium content")
        } else {
            Text("Basic content")
        }
    }
}
