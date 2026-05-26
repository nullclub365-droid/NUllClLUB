//
//  NutritionTrackingScreen.swift
//  SmartCart
//

import SwiftUI
import FirebaseAnalytics

struct NutritionTrackingScreen: View {
    @EnvironmentObject var store: AppStore
    var onBack: () -> Void

    @State private var manualCalories = ""
    @State private var manualProtein = ""
    @State private var manualSaveAsCustomName = ""
    @State private var showAddManual = false
    @State private var showAddIngredient = false
    @State private var showCustomMeals = false
    @State private var showAddCustomMealForm = false
    @State private var customMealServings: [Int64: Double] = [:]
    @State private var ingredientSearch = ""
    @State private var entryToEdit: DailyNutritionEntry? = nil
    @State private var ingredientServings: Double = 1
    @State private var manualPer100gMode = false
    @State private var manualWeightGrams = ""
    @State private var customMealToEdit: CustomMeal? = nil
    @State private var customMealToDelete: CustomMeal? = nil
    @State private var showLoggedToast = false

    private var todayStart: Int64 {
        Int64(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 * 1000)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerCard
                addButtons
                entriesList
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [AppTheme.primaryContainer.opacity(0.15), AppTheme.surface],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("Food Log")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsHelper.trackFeatureUsed("nutrition_tracking")
        }
        .sheet(isPresented: $showAddManual) {
            addManualSheet
        }
        .sheet(isPresented: $showAddIngredient) {
            addIngredientSheet
        }
        .sheet(isPresented: $showCustomMeals) {
            customMealsSheet
        }
        .sheet(isPresented: $showAddCustomMealForm) {
            addCustomMealFormSheet
        }
        .sheet(item: $customMealToEdit) { meal in
            editCustomMealSheet(meal: meal)
        }
        .confirmationDialog("Delete custom meal?", isPresented: Binding(get: { customMealToDelete != nil }, set: { if !$0 { customMealToDelete = nil } }), titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let m = customMealToDelete { store.deleteCustomMeal(id: m.id) }
                customMealToDelete = nil
            }
            Button("Cancel", role: .cancel) { customMealToDelete = nil }
        } message: {
            if let m = customMealToDelete { Text("Remove \"\(m.name)\" from your custom meals?") }
        }
        .sheet(item: $entryToEdit) { entry in
            EditNutritionEntrySheet(
                entry: entry,
                onSave: { cal, prot, carbs, fats in
                    store.updateNutritionEntry(id: entry.id, calories: cal, protein: prot, carbs: carbs, fats: fats)
                    AccessibilitySettings.announce("Entry updated")
                    entryToEdit = nil
                    showLoggedToast = true
                },
                onCancel: { entryToEdit = nil }
            )
        }
        .overlay(alignment: .bottom) {
            if showLoggedToast {
                Text("Food logged")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppTheme.primary)
                    .clipShape(Capsule())
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeOut(duration: 0.2)) { showLoggedToast = false }
                        }
                    }
            }
        }
        .animation(.easeOut(duration: 0.25), value: showLoggedToast)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(AppTheme.primary)
                }
                Text("Today's Intake")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
            }
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("\(store.todayCalories)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("kcal")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Rectangle()
                    .fill(AppTheme.outline.opacity(0.5))
                    .frame(width: 1, height: 40)
                VStack(spacing: 4) {
                    Text("\(store.todayProtein)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("g protein")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }
        }
        .id(store.dayRefreshTrigger)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            LinearGradient(
                colors: [AppTheme.primaryContainer.opacity(0.3), AppTheme.secondaryContainer.opacity(0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var addButtons: some View {
        HStack(spacing: 12) {
            addLogButton(
                title: "Manual entry",
                icon: "plus.circle.fill",
                color: AppTheme.primary,
                action: { showAddManual = true },
                accessibilityLabel: "Manual entry",
                accessibilityDescriptive: "Add calories and protein manually",
                accessibilityHint: "Double tap to add a manual food log entry"
            )
            addLogButton(
                title: "From ingredient",
                icon: "magnifyingglass",
                color: AppTheme.secondary,
                action: { showAddIngredient = true },
                accessibilityLabel: "From ingredient",
                accessibilityDescriptive: "Search and add an ingredient to today's log",
                accessibilityHint: "Double tap to search ingredients"
            )
            addLogButton(
                title: "Custom meals",
                icon: "heart.fill",
                color: AppTheme.tertiary,
                action: { showCustomMeals = true },
                accessibilityLabel: "Custom meals",
                accessibilityDescriptive: "Log from your saved custom meals",
                accessibilityHint: "Double tap to pick a saved meal"
            )
        }
    }

    private func addLogButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void,
        accessibilityLabel: String,
        accessibilityDescriptive: String,
        accessibilityHint: String
    ) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(color.opacity(0.15))
                .foregroundStyle(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityActionLabel(accessibilityLabel, descriptive: accessibilityDescriptive, hint: accessibilityHint)
        .accessibilityTouchTarget()
    }

    private var entriesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's entries")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            if store.todayEntries.isEmpty {
                EmptyStateView(
                    icon: "chart.pie",
                    title: "No entries yet",
                    message: "Log from custom meals, manual entry, or ingredients.",
                    actionTitle: "Custom meals",
                    action: { showCustomMeals = true }
                )
                .padding(.vertical, 8)
            } else {
                ForEach(store.todayEntries.sorted(by: { $0.createdAt > $1.createdAt })) { entry in
                    NutritionEntryRow(entry: entry, store: store, onEdit: { entryToEdit = $0 })
                }
            }
        }
    }

    private var calculated100gCalories: Int? {
        guard manualPer100gMode,
              let cal100 = Double(manualCalories), cal100 > 0,
              let weight = Double(manualWeightGrams), weight > 0 else { return nil }
        return Int((cal100 * weight / 100).rounded())
    }

    private var calculated100gProtein: Int? {
        guard manualPer100gMode,
              let prot100 = Double(manualProtein), prot100 > 0,
              let weight = Double(manualWeightGrams), weight > 0 else { return nil }
        return Int((prot100 * weight / 100).rounded())
    }

    private var isManualEntryValid: Bool {
        if manualPer100gMode {
            guard let cal100 = Double(manualCalories), cal100 > 0,
                  let weight = Double(manualWeightGrams), weight > 0 else { return false }
            return true
        }
        return (Int(manualCalories) ?? 0) > 0
    }

    private var addManualSheet: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Entry mode", selection: $manualPer100gMode) {
                        Text("Direct").tag(false)
                        Text("Per 100g").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                } footer: {
                    Text(manualPer100gMode
                         ? "Enter nutrition per 100g and the actual product weight — calories are calculated automatically."
                         : "Enter the total calories for the whole serving.")
                }

                if manualPer100gMode {
                    Section("Calories per 100g") {
                        TextField("e.g. 540", text: $manualCalories)
                            .keyboardType(.decimalPad)
                    }
                    Section("Protein per 100g (optional)") {
                        TextField("e.g. 6", text: $manualProtein)
                            .keyboardType(.decimalPad)
                    }
                    Section("Product weight (g)") {
                        TextField("e.g. 85", text: $manualWeightGrams)
                            .keyboardType(.decimalPad)
                    }
                    if let totalCal = calculated100gCalories {
                        Section("Result") {
                            HStack(spacing: 16) {
                                Label("\(totalCal) kcal", systemImage: "flame.fill")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppTheme.primary)
                                if let totalProt = calculated100gProtein {
                                    Label("\(totalProt)g protein", systemImage: "fork.knife")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(AppTheme.secondary)
                                }
                            }
                        }
                    }
                } else {
                    Section("Calories (required)") {
                        TextField("Calories", text: $manualCalories)
                            .keyboardType(.numberPad)
                    }
                    Section("Optional") {
                        TextField("Protein (g)", text: $manualProtein)
                            .keyboardType(.numberPad)
                    }
                }

                Section {
                    TextField("Save as custom meal (name)", text: $manualSaveAsCustomName)
                        .textInputAutocapitalization(.words)
                } footer: {
                    Text("Enter a name to save this as a custom meal for quick logging later.")
                }
            }
            .navigationTitle("Add manual entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddManual = false
                        manualCalories = ""
                        manualProtein = ""
                        manualSaveAsCustomName = ""
                        manualPer100gMode = false
                        manualWeightGrams = ""
                    }
                    .foregroundStyle(AppTheme.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let cal: Int
                        let prot: Int
                        if manualPer100gMode {
                            guard let c = calculated100gCalories else { return }
                            cal = c
                            prot = calculated100gProtein ?? 0
                        } else {
                            guard let c = Int(manualCalories), c > 0 else { return }
                            cal = c
                            prot = Int(manualProtein) ?? 0
                        }
                        store.addManualNutritionEntry(calories: cal, protein: prot > 0 ? prot : nil)
                        let nameToSave = manualSaveAsCustomName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !nameToSave.isEmpty, store.customMeals.count < AppStore.maxCustomMeals {
                            _ = store.addCustomMeal(name: nameToSave, calories: cal, protein: prot)
                        }
                        AccessibilitySettings.announce("Entry added")
                        showAddManual = false
                        manualCalories = ""
                        manualProtein = ""
                        manualSaveAsCustomName = ""
                        manualPer100gMode = false
                        manualWeightGrams = ""
                        showLoggedToast = true
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primary)
                    .disabled(!isManualEntryValid)
                }
            }
        }
    }

    private var sortedIngredients: [Ingredient] {
        var seen = Set<Int64>()
        var recentIds: [Int64] = []
        for entry in store.nutritionEntries.sorted(by: { $0.createdAt > $1.createdAt }) {
            if let id = entry.ingredientId, !seen.contains(id) {
                seen.insert(id)
                recentIds.append(id)
            }
        }
        let filtered = store.ingredients.filter {
            ingredientSearch.isEmpty ||
            $0.canonicalName.localizedCaseInsensitiveContains(ingredientSearch) ||
            $0.aliases.contains { $0.localizedCaseInsensitiveContains(ingredientSearch) }
        }
        return filtered.sorted { a, b in
            let aIdx = recentIds.firstIndex(of: a.id) ?? Int.max
            let bIdx = recentIds.firstIndex(of: b.id) ?? Int.max
            if aIdx != bIdx { return aIdx < bIdx }
            return a.canonicalName.localizedCaseInsensitiveCompare(b.canonicalName) == .orderedAscending
        }
    }

    private var addIngredientSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("Servings:")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Stepper(value: $ingredientServings, in: 0.25...20, step: 0.25) {
                        Text(ingredientServings == 1 ? "1 serving" : String(format: "%.2g servings", ingredientServings))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.onSurface)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                TextField("Search ingredients", text: $ingredientSearch)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                List {
                    ForEach(sortedIngredients.prefix(30), id: \.id) { ing in
                        Button(action: {
                            store.addNutritionEntryFromIngredient(ingredientId: ing.id, quantityText: ing.standardServing, servings: ingredientServings)
                            AccessibilitySettings.announce("Entry added")
                            showAddIngredient = false
                            ingredientSearch = ""
                            ingredientServings = 1
                            showLoggedToast = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ing.canonicalName)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(AppTheme.onSurface)
                                    Text("\(ing.caloriesPerServing ?? 0) kcal · \(ing.proteinPerServing ?? 0)g protein per \(ing.standardServing ?? "serving")")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.onSurfaceVariant)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(AppTheme.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Log from ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { ingredientServings = 1 }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddIngredient = false
                        ingredientSearch = ""
                        ingredientServings = 1
                    }
                    .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }

    private var customMealsSheet: some View {
        NavigationStack {
            List {
                if store.customMeals.count < AppStore.maxCustomMeals {
                    Button(action: { showAddCustomMealForm = true }) {
                        Label("Add custom meal", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .accessibilityLabel("Add custom meal")
                }
                ForEach(store.customMeals) { meal in
                    CustomMealCard(
                        meal: meal,
                        servings: Binding(
                            get: { customMealServings[meal.id] ?? 1 },
                            set: { customMealServings[meal.id] = $0 }
                        ),
                        onLog: {
                            let s = customMealServings[meal.id] ?? 1
                            store.addNutritionEntryFromCustomMeal(mealId: meal.id, servings: s)
                            AccessibilitySettings.announce("Logged \(meal.name)")
                            showCustomMeals = false
                            showLoggedToast = true
                        },
                        onEdit: { customMealToEdit = meal },
                        onDelete: { customMealToDelete = meal }
                    )
                    .contextMenu {
                        Button("Edit") { customMealToEdit = meal }
                        Button("Delete", role: .destructive) { customMealToDelete = meal }
                    }
                }
            }
            .navigationTitle("Custom meals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showCustomMeals = false }
                        .foregroundStyle(AppTheme.primary)
                }
            }
            .onAppear {
                customMealServings = Dictionary(uniqueKeysWithValues: store.customMeals.map { ($0.id, 1.0) })
            }
        }
    }

    private var addCustomMealFormSheet: some View {
        AddOrEditCustomMealSheet(
            title: "Add custom meal",
            initialName: "",
            initialCalories: "",
            initialProtein: "",
            maxMeals: AppStore.maxCustomMeals,
            currentCount: store.customMeals.count,
            onSave: { name, cal, prot in
                if store.addCustomMeal(name: name, calories: cal, protein: prot) {
                    AccessibilitySettings.announce("Custom meal saved")
                    showAddCustomMealForm = false
                }
            },
            onCancel: { showAddCustomMealForm = false }
        )
    }

    private func editCustomMealSheet(meal: CustomMeal) -> some View {
        AddOrEditCustomMealSheet(
            title: "Edit custom meal",
            initialName: meal.name,
            initialCalories: "\(meal.calories)",
            initialProtein: "\(meal.protein)",
            maxMeals: AppStore.maxCustomMeals,
            currentCount: store.customMeals.count,
            onSave: { name, cal, prot in
                store.updateCustomMeal(id: meal.id, name: name, calories: cal, protein: prot)
                AccessibilitySettings.announce("Custom meal updated")
                customMealToEdit = nil
            },
            onCancel: { customMealToEdit = nil }
        )
    }
}

private struct NutritionEntryRow: View {
    let entry: DailyNutritionEntry
    @ObservedObject var store: AppStore
    var onEdit: (DailyNutritionEntry) -> Void

    private var label: String {
        if entry.entryType == "manual" {
            return "Manual: \(entry.calories) kcal"
        }
        if entry.entryType == "recipe" || entry.entryType == "custom", let name = entry.quantityText, !name.isEmpty {
            return "\(name): \(entry.calories) kcal"
        }
        if let id = entry.ingredientId, let ing = store.ingredient(byId: id) {
            let portion = entry.quantityText ?? ing.standardServing
            if let p = portion, !p.isEmpty {
                return "\(ing.canonicalName) (\(p)) · \(entry.calories) kcal"
            }
            return "\(ing.canonicalName) · \(entry.calories) kcal"
        }
        return "\(entry.calories) kcal"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.onSurface)
                if let p = entry.protein, p > 0 {
                    Text("\(p)g protein")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }
            Spacer()
            Button(action: { onEdit(entry) }) {
                Image(systemName: "pencil")
                    .foregroundStyle(AppTheme.primary)
            }
            .accessibilityLabel("Edit entry")
            Button(action: { store.deleteNutritionEntry(id: entry.id) }) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .accessibilityLabel("Delete entry")
        }
        .padding(12)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct EditNutritionEntrySheet: View {
    let entry: DailyNutritionEntry
    let onSave: (Int, Int?, Int?, Int?) -> Void
    let onCancel: () -> Void

    @State private var caloriesText: String = ""
    @State private var proteinText: String = ""
    @State private var carbsText: String = ""
    @State private var fatsText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Calories (required)") {
                    TextField("Calories", text: $caloriesText)
                        .keyboardType(.numberPad)
                }
                Section("Optional") {
                    TextField("Protein (g)", text: $proteinText)
                        .keyboardType(.numberPad)
                    TextField("Carbs (g)", text: $carbsText)
                        .keyboardType(.numberPad)
                    TextField("Fats (g)", text: $fatsText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit entry")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                caloriesText = "\(entry.calories)"
                proteinText = entry.protein.map { "\($0)" } ?? ""
                carbsText = entry.carbs.map { "\($0)" } ?? ""
                fatsText = entry.fats.map { "\($0)" } ?? ""
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                        .foregroundStyle(AppTheme.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let cal = Int(caloriesText), cal > 0 else { return }
                        let prot = Int(proteinText)
                        let carbs = Int(carbsText)
                        let fats = Int(fatsText)
                        onSave(
                            cal,
                            (prot != nil && prot! > 0) ? prot : nil,
                            (carbs != nil && carbs! > 0) ? carbs : nil,
                            (fats != nil && fats! > 0) ? fats : nil
                        )
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primary)
                    .disabled((Int(caloriesText) ?? 0) <= 0)
                }
            }
        }
    }
}

private struct CustomMealCard: View {
    let meal: CustomMeal
    @Binding var servings: Double
    let onLog: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.onSurface)
                Text("\(meal.calories) kcal · \(meal.protein)g protein")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            Spacer()
            HStack(spacing: 8) {
                Text(servings == 1 ? "1×" : String(format: "%.2g×", servings))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .frame(minWidth: 32, alignment: .trailing)
                Stepper("", value: $servings, in: 0.25...10, step: 0.25)
                    .labelsHidden()
                Button(action: onLog) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.primary)
                }
                .accessibilityLabel("Log \(meal.name)")
            }
        }
        .padding(12)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct AddOrEditCustomMealSheet: View {
    let title: String
    let initialName: String
    let initialCalories: String
    let initialProtein: String
    let maxMeals: Int
    let currentCount: Int
    let onSave: (String, Int, Int) -> Void
    let onCancel: () -> Void

    @State private var name: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Meal name", text: $name)
                        .textInputAutocapitalization(.words)
                }
                Section("Nutrition") {
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.numberPad)
                }
                if currentCount >= maxMeals {
                    Section {
                        Text("You have reached the maximum of \(maxMeals) custom meals. Delete one to add another.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = initialName
                calories = initialCalories
                protein = initialProtein
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                        .foregroundStyle(AppTheme.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let cal = Int(calories), cal > 0,
                              let prot = Int(protein), prot >= 0,
                              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines), cal, prot)
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primary)
                    .disabled((Int(calories) ?? 0) <= 0 || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NutritionTrackingScreen(onBack: {})
            .environmentObject(AppStore())
    }
}
