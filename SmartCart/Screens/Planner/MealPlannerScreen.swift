//
//  MealPlannerScreen.swift
//  SmartCart
//

import SwiftUI
import FirebaseAnalytics

struct MealPlannerScreen: View {
    @EnvironmentObject var store: AppStore
    var onRecipeClick: (Int64) -> Void

    @State private var editingSlot: (dayOfWeek: String, mealType: String)? = nil
    @State private var showingGenerateAlert = false
    @State private var generateMessage = ""
    @State private var showingAdUnavailableAlert = false
    @State private var templateForPreview: TemplatePreviewItem?

    private var dayNames: [String] {
        ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !store.mealPlanTemplates.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Templates")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.onSurface)
                            .padding(.horizontal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(store.mealPlanTemplates) { template in
                                    TemplateCard(
                                        template: template,
                                        isSelected: store.currentPlan?.templateId == template.id,
                                        onTap: {
                                            Haptics.light()
                                            templateForPreview = TemplatePreviewItem(template: template)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                Text("This week")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                    .padding(.horizontal)

                ForEach(dayNames, id: \.self) { dayName in
                    DayCard(
                        dayName: dayName,
                        plan: store.currentPlan,
                        recipe: { store.recipe(byId: $0) },
                        onRecipeClick: onRecipeClick,
                        onSlotTap: { editingSlot = ($0, $1) },
                        onClearSlot: { day, meal in
                            Haptics.light()
                            store.setPlanSlot(dayOfWeek: day, mealType: meal, recipeId: nil)
                        }
                    )
                }

                Button {
                    Haptics.light()
                    RewardedAdHelper.showRewardedAd(
                        onReward: {
                            let result = store.generateGroceryListFromPlan()
                            generateMessage = result.message
                            AccessibilitySettings.announce("Grocery list generated")
                            showingGenerateAlert = true
                        },
                        onNotEarned: {
                            showingAdUnavailableAlert = true
                        }
                    )
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.fill")
                            .font(.body.weight(.semibold))
                        Text("Generate Grocery List")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 8)
                .accessibilityLabel(AccessibilitySettings.descriptiveLabels ? "Generate grocery list from this week's meal plan" : "Generate Grocery List")
                .accessibilityHint("Double tap to watch an ad and generate the list")

                Button {
                    Haptics.light()
                    shareMealPlan()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.semibold))
                        Text("Share Meal Plan")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.secondary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 8)
                .accessibilityLabel(AccessibilitySettings.descriptiveLabels ? "Share this week's meal plan with friends" : "Share Meal Plan")
                .accessibilityHint("Double tap to share your meal plan")
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Meal Planner")
        .background(AppTheme.background)
        .alert("Generate Grocery List", isPresented: $showingGenerateAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(generateMessage)
        }
        .alert("Ad Unavailable", isPresented: $showingAdUnavailableAlert) {
            Button("Continue without ad") {
                let result = store.generateGroceryListFromPlan()
                generateMessage = result.message
                showingGenerateAlert = true
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("The ad couldn't load. You can continue without watching an ad and still generate your grocery list.")
        }
        .sheet(item: $templateForPreview) { item in
            TemplatePreviewSheet(
                template: item.template,
                recipe: { store.recipe(byId: $0) },
                onConfirm: {
                    Haptics.light()
                    store.applyTemplate(item.template)
                    templateForPreview = nil
                },
                onDismiss: { templateForPreview = nil }
            )
        }
        .sheet(item: Binding(
            get: { editingSlot.map { SlotId(dayOfWeek: $0.dayOfWeek, mealType: $0.mealType) } },
            set: { new in editingSlot = new.map { ($0.dayOfWeek, $0.mealType) } }
        )) { slotId in
            RecipePickerSheet(
                dayOfWeek: slotId.dayOfWeek,
                mealType: slotId.mealType,
                currentRecipeId: store.currentPlan?.days.first { $0.dayOfWeek == slotId.dayOfWeek }?.recipeId(for: slotId.mealType),
                recipes: store.recipes,
                onSelect: { recipeId in
                    Haptics.light()
                    store.setPlanSlot(dayOfWeek: slotId.dayOfWeek, mealType: slotId.mealType, recipeId: recipeId)
                    editingSlot = nil
                },
                onClear: {
                    Haptics.light()
                    store.setPlanSlot(dayOfWeek: slotId.dayOfWeek, mealType: slotId.mealType, recipeId: nil)
                    editingSlot = nil
                },
                onDismiss: { editingSlot = nil }
            )
        }
    }

    private func shareMealPlan() {
        var meals: [String] = []
        if let plan = store.currentPlan {
            for day in plan.days {
                for id in [day.breakfastId, day.lunchId, day.dinnerId, day.snackId].compactMap({ $0 }) {
                    if let recipe = store.recipe(byId: id) {
                        meals.append(recipe.name)
                    }
                }
            }
        }
        let message = ShareHelper.shareMealPlan(meals: meals, dayNames: dayNames)
        ShareHelper.shareContent(message) { _ in }
    }
}

private struct SlotId: Identifiable {
    let dayOfWeek: String
    let mealType: String
    var id: String { "\(dayOfWeek)_\(mealType)" }
}

private extension PlannedDay {
    func recipeId(for mealType: String) -> Int64? {
        switch mealType {
        case "breakfast": return breakfastId
        case "lunch": return lunchId
        case "dinner": return dinnerId
        case "snack": return snackId
        default: return nil
        }
    }
}

private struct DayCard: View {
    let dayName: String
    let plan: MealPlanInstance?
    let recipe: (Int64) -> Recipe?
    let onRecipeClick: (Int64) -> Void
    let onSlotTap: (String, String) -> Void
    let onClearSlot: (String, String) -> Void

    private var dayPlan: PlannedDay? {
        plan?.days.first { $0.dayOfWeek == dayName }
    }

    private var dayTotals: (calories: Int, protein: Int) {
        dayPlan?.totals(recipeLookup: recipe) ?? (0, 0)
    }

    private func mealSlot(_ id: Int64?, label: String, mealType: String) -> some View {
        Button(action: { onSlotTap(dayName, mealType) }) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .frame(width: 70, alignment: .leading)
                if let rid = id, let r = recipe(rid) {
                    Text(r.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.primary)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                } else {
                    Text("Tap to add")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Spacer()
                    Image(systemName: "plus.circle")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.primary.opacity(0.7))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(AppTheme.surfaceVariant.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .contextMenu {
            if id != nil {
                Button(role: .destructive, action: { onClearSlot(dayName, mealType) }) {
                    Label("Clear slot", systemImage: "trash")
                }
            }
            if let rid = id {
                Button(action: { onRecipeClick(rid) }) {
                    Label("View recipe", systemImage: "doc.text")
                }
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
                Text("🔥\(dayTotals.calories) 💪\(dayTotals.protein)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            VStack(spacing: 8) {
                mealSlot(dayPlan?.breakfastId, label: "Breakfast", mealType: "breakfast")
                mealSlot(dayPlan?.lunchId, label: "Lunch", mealType: "lunch")
                mealSlot(dayPlan?.dinnerId, label: "Dinner", mealType: "dinner")
                mealSlot(dayPlan?.snackId, label: "Snack", mealType: "snack")
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}

private struct TemplatePreviewItem: Identifiable {
    let template: MealPlanTemplate
    var id: Int64 { template.id }
}

private struct TemplateCard: View {
    let template: MealPlanTemplate
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(template.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? AppTheme.onPrimaryContainer : AppTheme.onSurface)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.primary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? AppTheme.primaryContainer : AppTheme.surface)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct TemplatePreviewSheet: View {
    let template: MealPlanTemplate
    let recipe: (Int64) -> Recipe?
    let onConfirm: () -> Void
    let onDismiss: () -> Void

    private var dayOrder: [String] {
        ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(template.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.onSurface)
                        Text(template.focus)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.primary)
                        if let desc = template.description {
                            Text(desc)
                                .font(.body)
                                .foregroundStyle(AppTheme.onSurfaceVariant)
                        }
                    }
                    .padding(.horizontal)

                    Text("This week")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.onSurface)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        ForEach(dayOrder, id: \.self) { dayName in
                            if let day = template.meals.first(where: { $0.dayOfWeek == dayName }) {
                                DayPreviewRow(
                                    dayName: dayName,
                                    day: day,
                                    recipe: recipe
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 24)

                    VStack(spacing: 12) {
                        Button(action: onConfirm) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Confirm & Apply")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)

                        Button("Cancel", action: onDismiss)
                            .font(.body)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
                .padding(.top, 8)
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onDismiss)
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}

private struct DayPreviewRow: View {
    let dayName: String
    let day: TemplateDay
    let recipe: (Int64) -> Recipe?

    private func mealName(_ id: Int64?) -> String {
        guard let id = id, let r = recipe(id) else { return "—" }
        return r.name
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dayName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.onSurface)
            VStack(alignment: .leading, spacing: 4) {
                Label(mealName(day.breakfastId), systemImage: "sunrise.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Label(mealName(day.lunchId), systemImage: "sun.max.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Label(mealName(day.dinnerId), systemImage: "moon.stars.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Label(mealName(day.snackId), systemImage: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct RecipePickerSheet: View {
    let dayOfWeek: String
    let mealType: String
    let currentRecipeId: Int64?
    let recipes: [Recipe]
    let onSelect: (Int64) -> Void
    let onClear: () -> Void
    let onDismiss: () -> Void

    private var mealLabel: String {
        mealType.prefix(1).uppercased() + mealType.dropFirst()
    }

    var body: some View {
        NavigationStack {
            List {
                if currentRecipeId != nil {
                    Section {
                        Button(role: .destructive, action: onClear) {
                            Label("Clear slot", systemImage: "xmark.circle")
                        }
                    }
                }
                Section(header: Text("Choose recipe")) {
                    ForEach(recipes) { r in
                        Button(action: { onSelect(r.id) }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(r.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(AppTheme.onSurface)
                                    Text("\(r.calories) kcal · \(r.readyInMinutes) min")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.onSurfaceVariant)
                                }
                                Spacer()
                                if r.id == currentRecipeId {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppTheme.primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("\(mealLabel) – \(dayOfWeek)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}

#Preview {
    MealPlannerScreen(onRecipeClick: { _ in })
        .environmentObject(AppStore())
}
