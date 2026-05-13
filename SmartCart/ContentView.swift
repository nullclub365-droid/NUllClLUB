//
//  ContentView.swift
//  SmartCart
//

import SwiftUI

private let hasRequestedATTKey = "smartcart_att_requested"
private let hasRequestedNotificationPermissionKey = "smartcart_notification_permission_requested"

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var store = AppStore()
    @State private var selectedTab = 0
    @State private var homePath: [AppRoute] = []
    @State private var groceriesPath: [AppRoute] = []
    @State private var recipesPath: [AppRoute] = []
    @State private var plannerPath: [AppRoute] = []
    @State private var hasInitializedAds = false
    #if DEBUG
    @State private var showSimulatorATTMessage = false
    #endif

    var body: some View {
        TabView(selection: $selectedTab) {
            homeTab
            groceriesTab
            recipesTab
            plannerTab
        }
        .tint(AppTheme.primary)
        .environmentObject(store)
        .onChange(of: scenePhase) { _, new in
            if new == .active {
                store.notifyDayMayHaveChanged()
                NotificationScheduler.schedule(store: store)
                requestATTAndInitializeAdsIfNeeded()
            }
        }
        .onChange(of: store.onboardingCompleted) { _, completed in
            if completed { requestATTAndInitializeAdsIfNeeded() }
        }
        .onAppear {
            requestATTAndInitializeAdsIfNeeded()
        }
        .fullScreenCover(isPresented: Binding(
            get: { !store.onboardingCompleted && UserDefaults.standard.bool(forKey: hasRequestedATTKey) },
            set: { _ in }
        )) {
            OnboardingScreen(onComplete: {})
                .environmentObject(store)
        }
        .alert("Could not save data", isPresented: Binding(
            get: { store.lastPersistenceError != nil },
            set: { if !$0 { store.lastPersistenceError = nil } }
        )) {
            Button("OK") { store.lastPersistenceError = nil }
        } message: {
            Text(store.lastPersistenceError ?? "Data could not be saved. Free up space and try again.")
        }
        #if DEBUG
        .alert("Tracking permission (Simulator)", isPresented: $showSimulatorATTMessage) {
            Button("OK") { showSimulatorATTMessage = false }
        } message: {
            Text("The ATT dialog is not shown in the Simulator. On a real device, the system “Allow tracking?” prompt appears at first launch (before onboarding).")
        }
        #endif
    }

    private func requestATTAndInitializeAdsIfNeeded() {
        guard !hasInitializedAds else { return }
        let alreadyRequested = UserDefaults.standard.bool(forKey: hasRequestedATTKey)
        // On first launch show ATT before onboarding; after that require onboarding completed.
        guard store.onboardingCompleted || !alreadyRequested else { return }
        let doInit = {
            AdMobService.initialize {
                InterstitialAdHelper.preload()
                hasInitializedAds = true
            }
        }
        let requestNotificationsAfter = {
            self.requestNotificationPermissionIfNeeded()
        }
        if alreadyRequested {
            doInit()
            requestNotificationsAfter()
        } else {
            // Show ATT first, then notification permission (so user sees ATT prompt before the notification dialog).
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                AppTrackingService.requestTrackingThenPerform(
                    onComplete: {
                        UserDefaults.standard.set(true, forKey: hasRequestedATTKey)
                        doInit()
                        requestNotificationsAfter()
                    },
                    onDialogShown: { shown in
                        #if DEBUG
                        if !shown {
                            DispatchQueue.main.async { showSimulatorATTMessage = true }
                        }
                        #endif
                    }
                )
            }
        }
    }

    private func requestNotificationPermissionIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: hasRequestedNotificationPermissionKey) else { return }
        UserDefaults.standard.set(true, forKey: hasRequestedNotificationPermissionKey)
        NotificationScheduler.requestPermission { _ in
            NotificationScheduler.schedule(store: store)
        }
    }

    private var homeTab: some View {
        NavigationStack(path: $homePath) {
            HomeScreen(
                onRecipeSelected: { id in homePath.append(.recipeDetail(id)) },
                onSettings: { homePath.append(.settings) },
                onPremium: { homePath.append(.premium) },
                onNutrition: { homePath.append(.nutrition) },
                onMealPrep: { homePath.append(.mealPrep) },
                onStatistics: { homePath.append(.statistics) },
                onTimers: { homePath.append(.timers) },
                onCookingHistory: { homePath.append(.cookingHistory) },
                onAchievements: { homePath.append(.achievements) },
                onConverter: { homePath.append(.unitConverter) },
                onInsight: { id in homePath.append(.insightDetail(id)) },
                onOpenPlanner: { selectedTab = 3 }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route, path: $homePath)
            }
        }
        .tabItem {
            Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
        }
        .tag(0)
    }

    private var groceriesTab: some View {
        NavigationStack(path: $groceriesPath) {
            GroceriesScreen(
                onAddItems: { groceriesPath.append(.addItems) },
                onSwipeToAdd: { groceriesPath.append(.quickAddSwipe) }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route, path: $groceriesPath)
            }
        }
        .tabItem {
            Label("Groceries", systemImage: selectedTab == 1 ? "cart.fill" : "cart")
        }
        .tag(1)
    }

    private var recipesTab: some View {
        NavigationStack(path: $recipesPath) {
            RecipesScreen(onRecipeSelected: { id in recipesPath.append(.recipeDetail(id)) })
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route, path: $recipesPath)
                }
        }
        .tabItem {
            Label("Recipes", systemImage: selectedTab == 2 ? "fork.knife.circle.fill" : "fork.knife.circle")
        }
        .tag(2)
    }

    private var plannerTab: some View {
        NavigationStack(path: $plannerPath) {
            MealPlannerScreen(onRecipeClick: { id in plannerPath.append(.recipeDetail(id)) })
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route, path: $plannerPath)
                }
        }
        .tabItem {
            Label("Planner", systemImage: selectedTab == 3 ? "calendar.circle.fill" : "calendar.circle")
        }
        .tag(3)
    }

    private func safePop(path: Binding<[AppRoute]>) {
        if !path.wrappedValue.isEmpty {
            path.wrappedValue.removeLast()
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute, path: Binding<[AppRoute]>) -> some View {
        switch route {
        case .recipeDetail(let id):
            RecipeDetailScreen(
                recipeId: id,
                onStartCooking: { path.wrappedValue.append(.cooking($0)) },
                onBack: { safePop(path: path) }
            )
        case .cooking(let id):
            CookingScreen(
                recipeId: id,
                onComplete: { path.wrappedValue.append(.postCookingCheck(id)) },
                onBack: { safePop(path: path) },
                onOpenTimers: { minutes in
                    store.setPendingTimerToAdd(label: "Cooking step", minutes: minutes)
                    path.wrappedValue.append(.timers)
                }
            )
        case .settings:
            SettingsScreen(
                onAbout: { path.wrappedValue.append(.about) },
                onBackup: { path.wrappedValue.append(.backup) },
                onNotifications: { path.wrappedValue.append(.notifications) },
                onCollections: { path.wrappedValue.append(.collections) },
                onAccessibility: { path.wrappedValue.append(.accessibility) },
                onBack: { safePop(path: path) }
            )
        case .accessibility:
            AccessibilityScreen()
        case .backup:
            BackupScreen(onBack: { safePop(path: path) })
        case .about:
            AboutScreen(
                onTerms: { path.wrappedValue.append(.termsOfService) },
                onPrivacy: { path.wrappedValue.append(.privacyPolicy) },
                onBack: { safePop(path: path) }
            )
        case .termsOfService:
            LegalScreen(title: "Terms of Service", onBack: { safePop(path: path) })
        case .privacyPolicy:
            LegalScreen(title: "Privacy Policy", onBack: { safePop(path: path) })
        case .nutrition:
            NutritionTrackingScreen(onBack: { safePop(path: path) })
        case .mealPrep:
            MealPrepScreen(
                onRecipeSelected: { id in path.wrappedValue.append(.recipeDetail(id)) },
                onStartCooking: { id in path.wrappedValue.append(.cooking(id)) },
                onBack: { safePop(path: path) }
            )
        case .statistics:
            StatisticsScreen(onBack: { safePop(path: path) })
        case .timers:
            MultiTimerScreen(onBack: { safePop(path: path) })
        case .cookingHistory:
            CookingHistoryScreen(onRecipeClick: { id in path.wrappedValue.append(.recipeDetail(id)) }, onBack: { safePop(path: path) })
        case .achievements:
            AchievementsScreen(onBack: { safePop(path: path) })
        case .unitConverter:
            UnitConverterScreen(onBack: { safePop(path: path) })
        case .insightDetail(let id):
            InsightDetailScreen(insightId: id, onBack: { safePop(path: path) }, onRecipeSelected: { rid in path.wrappedValue.append(.recipeDetail(rid)) })
        case .notifications:
            NotificationsScreen(onBack: { safePop(path: path) })
        case .collections:
            CollectionsScreen(
                onBack: { safePop(path: path) },
                onCollectionSelected: { id in path.wrappedValue.append(.collectionDetail(id)) },
                onRecipeSelected: { id in path.wrappedValue.append(.recipeDetail(id)) }
            )
        case .collectionDetail(let id):
            CollectionDetailScreen(
                collectionId: id,
                onBack: { safePop(path: path) },
                onRecipeSelected: { rid in path.wrappedValue.append(.recipeDetail(rid)) }
            )
        case .addItems:
            AddItemsScreen(
                onBack: { safePop(path: path) },
                onAddToPantry: { items in store.addItemsToPantry(items); safePop(path: path) },
                onAddToGroceryList: { items in store.addItemsToGroceryList(items); safePop(path: path) }
            )
        case .quickAddSwipe:
            QuickAddSwipeScreen(onDone: { safePop(path: path) })
                .environmentObject(store)
        case .postCookingCheck(let id):
            if let recipe = store.recipes.first(where: { $0.id == id }) {
                PostCookingCheckScreen(recipe: recipe, onDone: { safePop(path: path) })
                    .environmentObject(store)
            }
        case .premium:
            PremiumScreen(onBack: { safePop(path: path) })
        default:
            EmptyView()
        }
    }
}

struct NotificationsScreen: View {
    @EnvironmentObject var store: AppStore
    var onBack: () -> Void

    @AppStorage(NotificationScheduler.keyBreakfastTime) private var breakfastTime = "08:00"
    @AppStorage(NotificationScheduler.keyLunchTime) private var lunchTime = "12:00"
    @AppStorage(NotificationScheduler.keyDinnerTime) private var dinnerTime = "18:00"
    @AppStorage(NotificationScheduler.keyMealRemindersEnabled) private var mealRemindersEnabled = false
    @AppStorage(NotificationScheduler.keyRemindWhenNoMealPlanned) private var remindWhenNoMealPlanned = true
    @AppStorage(NotificationScheduler.keyExpiryReminderEnabled) private var expiryReminderEnabled = false
    @AppStorage(NotificationScheduler.keyExpiryDaysBefore) private var expiryDaysBefore = 2

    @State private var breakfastDate = Self.date(from: "08:00")
    @State private var lunchDate = Self.date(from: "12:00")
    @State private var dinnerDate = Self.date(from: "18:00")
    @State private var permissionRequested = false
    @State private var showExpiryBetaAlert = false

    var body: some View {
        List {
            Section {
                DatePicker("Breakfast", selection: $breakfastDate, displayedComponents: .hourAndMinute)
                    .onChange(of: breakfastDate) { _, new in breakfastTime = Self.string(from: new); schedule() }
                DatePicker("Lunch", selection: $lunchDate, displayedComponents: .hourAndMinute)
                    .onChange(of: lunchDate) { _, new in lunchTime = Self.string(from: new); schedule() }
                DatePicker("Dinner", selection: $dinnerDate, displayedComponents: .hourAndMinute)
                    .onChange(of: dinnerDate) { _, new in dinnerTime = Self.string(from: new); schedule() }
            } header: {
                Text("Meal times")
            } footer: {
                Text("We’ll notify you when it’s time to start cooking based on your planner and recipe cook times.")
            }

            Section {
                Toggle("Start cooking reminders", isOn: $mealRemindersEnabled)
                    .onChange(of: mealRemindersEnabled) { _, enabled in
                        if enabled && !permissionRequested {
                            permissionRequested = true
                            NotificationScheduler.requestPermission { _ in schedule() }
                        } else {
                            schedule()
                        }
                    }
                if mealRemindersEnabled {
                    Toggle("Remind when no meal planned", isOn: $remindWhenNoMealPlanned)
                        .onChange(of: remindWhenNoMealPlanned) { _, _ in schedule() }
                }
            } header: {
                Text("Meal reminders")
            } footer: {
                Text("Get a notification before each meal so you can start cooking in time (e.g. lunch at 12:00, recipe 3 min → notify at 11:57).")
            }

            Section {
                Toggle("Expiring items", isOn: $expiryReminderEnabled)
                    .onChange(of: expiryReminderEnabled) { _, new in
                        if new {
                            showExpiryBetaAlert = true
                            if !permissionRequested {
                                permissionRequested = true
                                NotificationScheduler.requestPermission { _ in schedule() }
                            } else {
                                schedule()
                            }
                        } else {
                            schedule()
                        }
                    }
                if expiryReminderEnabled {
                    Picker("Notify before expiry", selection: $expiryDaysBefore) {
                        Text("1 day before").tag(1)
                        Text("2 days before").tag(2)
                        Text("3 days before").tag(3)
                    }
                    .onChange(of: expiryDaysBefore) { _, _ in schedule() }
                }
            } header: {
                Text("Pantry")
            } footer: {
                Text("Remind you when pantry items are close to their expiry date.")
            }

            Section {
                HStack(spacing: 12) {
                    Image(systemName: "bell.badge")
                        .font(.body)
                        .foregroundStyle(AppTheme.primary)
                    Text("All reminders are local. We ask for notification permission when the app opens so reminders can work.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            breakfastDate = Self.date(from: breakfastTime)
            lunchDate = Self.date(from: lunchTime)
            dinnerDate = Self.date(from: dinnerTime)
        }
        .alert("Beta feature", isPresented: $showExpiryBetaAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This feature is in beta. Always check labels for expiring food.")
        }
    }

    private func schedule() {
        NotificationScheduler.schedule(store: store)
    }

    private static func date(from time: String) -> Date {
        let parts = time.split(separator: ":")
        let h = Int(parts.first ?? "8") ?? 8
        let m = Int(parts.dropFirst().first ?? "0") ?? 0
        return Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date()) ?? Date()
    }

    private static func string(from date: Date) -> String {
        let c = Calendar.current
        let h = c.component(.hour, from: date)
        let m = c.component(.minute, from: date)
        return String(format: "%02d:%02d", h, m)
    }
}

struct SettingsScreen: View {
    @AppStorage("smartcart_theme_mode") private var themeRaw: String = ThemeMode.system.rawValue
    var onAbout: () -> Void
    var onBackup: () -> Void
    var onNotifications: () -> Void
    var onCollections: () -> Void
    var onAccessibility: () -> Void
    var onBack: () -> Void
    var body: some View {
        List {
            Section("Appearance") {
                Picker("Theme", selection: $themeRaw) {
                    ForEach(ThemeMode.allCases, id: \.rawValue) {
                        Text($0.rawValue).tag($0.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
            Section("Notifications") {
                Button(action: onNotifications) {
                    Label("Reminders", systemImage: "bell.badge")
                }
            }
            Section("Accessibility") {
                Button(action: onAccessibility) {
                    Label("Accessibility", systemImage: "accessibility")
                }
            }
            Section("Data") {
                Button(action: onCollections) {
                    Label("Collections", systemImage: "folder")
                }
                Button(action: onAbout) {
                    Label("About", systemImage: "info.circle")
                }
                Button(action: onBackup) {
                    Label("Backup & Restore", systemImage: "square.and.arrow.down")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutScreen: View {
    var onTerms: () -> Void
    var onPrivacy: () -> Void
    var onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                aboutHeader
                aboutDescription
                tipsSection
                faqSection
                legalLinks
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var aboutHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryContainer.opacity(0.6))
                    .frame(width: 64, height: 64)
                Image(systemName: "cart.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.primary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("SmartCart")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                Text("Meal planning & grocery list")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            Spacer()
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var aboutDescription: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            Text("SmartCart helps you plan meals, manage recipes, track nutrition, and organize your grocery list. All data stays on your device—no account required. Use the Planner to assign recipes to days, log food in the Food Log, and keep your pantry and grocery list in sync.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Tips", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.primary)
            VStack(alignment: .leading, spacing: 8) {
                tipRow("Plan your week in the Planner tab, then tap a slot to change or add a recipe.")
                tipRow("Add missing ingredients from a recipe to your grocery list with one tap.")
                tipRow("Check off groceries as you shop; move checked items to Pantry from the List tab.")
                tipRow("Use Backup & Restore in Settings to export or import your data.")
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(AppTheme.primary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("FAQ", systemImage: "questionmark.circle.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.primary)
            faqItem(q: "How do I add items to my grocery list?", a: "Open the Groceries tab, tap +, then search for ingredients. Add them to your list or to Pantry with an optional expiry.")
            faqItem(q: "Where is my data stored?", a: "All data is stored only on your device. Nothing is sent to external servers.")
            faqItem(q: "Can I backup my data?", a: "Yes. Go to Settings → Backup & Restore to export a JSON file or import a previous backup.")
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func faqItem(q: String, a: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(q)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.onSurface)
            Text(a)
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var legalLinks: some View {
        VStack(spacing: 12) {
            Button(action: onTerms) {
                HStack {
                    Label("Terms of Service", systemImage: "doc.text")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurface)
                .padding(16)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            Button(action: onPrivacy) {
                HStack {
                    Label("Privacy Policy", systemImage: "hand.raised")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurface)
                .padding(16)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }
}

struct LegalScreen: View {
    let title: String
    var onBack: () -> Void

    private var sections: [LegalSection] {
        title.lowercased().contains("privacy") ? LegalContent.privacyPolicy : LegalContent.termsOfService
    }

    private var isPrivacyPolicy: Bool { title.lowercased().contains("privacy") }

    private var lastUpdated: String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: Date())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if isPrivacyPolicy, let url = LegalContent.privacyPolicyURL {
                    Link(destination: url) {
                        HStack(spacing: 8) {
                            Image(systemName: "safari")
                            Text("View full Privacy Policy online")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.primary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.primary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title)
                            .font(.headline)
                            .foregroundStyle(AppTheme.primary)
                        ForEach(section.paragraphs, id: \.self) { p in
                            Text(p)
                                .font(.body)
                                .foregroundStyle(AppTheme.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                Text("Last updated: \(lastUpdated)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
