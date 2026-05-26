//
//  OnboardingScreen.swift
//  SmartCart
//

import SwiftUI

struct OnboardingScreen: View {
    @EnvironmentObject var store: AppStore
    var onComplete: () -> Void

    private let commonAllergies = ["Peanuts", "Tree nuts", "Milk", "Eggs", "Wheat", "Soy", "Fish", "Shellfish"]
    private let commonDiets = ["Vegetarian", "Vegan", "Keto", "Paleo", "Low-carb", "Gluten-free", "Dairy-free"]
    private let commonGoals = ["Weight loss", "Muscle gain", "Heart health", "Better sleep", "More energy"]

    @State private var selectedAllergies: Set<String> = []
    @State private var selectedDiets: Set<String> = []
    @State private var selectedGoals: Set<String> = []
    @State private var otherAllergies: String = ""
    @State private var otherDiets: String = ""
    @State private var otherGoals: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                allergiesSection
                dietSection
                goalsSection
                getStartedButton
            }
            .padding(24)
        }
        .background(AppTheme.background)
        .onAppear {
            selectedAllergies = Set(store.allergies)
            selectedDiets = Set(store.dietPreferences.map { $0.capitalized })
            selectedGoals = Set(store.healthGoals.map { $0.capitalized })
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome to SmartCart")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.onSurface)
            Text("Set your preferences so we can tailor recipes to you. You can change these anytime in Settings.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
    }

    private var allergiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Allergies (we'll exclude these from suggestions)")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            FlowLayout(spacing: 8) {
                ForEach(commonAllergies, id: \.self) { item in
                    Chip(
                        title: item,
                        isSelected: selectedAllergies.contains(item)
                    ) {
                        if selectedAllergies.contains(item) {
                            selectedAllergies.remove(item)
                        } else {
                            selectedAllergies.insert(item)
                        }
                    }
                }
            }
            TextField("Other allergies (comma-separated)", text: $otherAllergies)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
        }
    }

    private var dietSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Diet preferences (we'll prioritize matching recipes)")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            FlowLayout(spacing: 8) {
                ForEach(commonDiets, id: \.self) { item in
                    Chip(
                        title: item,
                        isSelected: selectedDiets.contains(item)
                    ) {
                        if selectedDiets.contains(item) {
                            selectedDiets.remove(item)
                        } else {
                            selectedDiets.insert(item)
                        }
                    }
                }
            }
            TextField("Other diets (comma-separated)", text: $otherDiets)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
        }
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health goals (optional)")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)
            FlowLayout(spacing: 8) {
                ForEach(commonGoals, id: \.self) { item in
                    Chip(
                        title: item,
                        isSelected: selectedGoals.contains(item)
                    ) {
                        if selectedGoals.contains(item) {
                            selectedGoals.remove(item)
                        } else {
                            selectedGoals.insert(item)
                        }
                    }
                }
            }
            TextField("Other goals (comma-separated)", text: $otherGoals)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
        }
    }

    private var getStartedButton: some View {
        VStack(spacing: 12) {
            Button(action: saveAndComplete) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .accessibilityActionLabel("Get Started", descriptive: "Save preferences and finish setup", hint: "Double tap to continue")
            .accessibilityTouchTarget()

            Button(action: skipOnboarding) {
                Text("Skip for now")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            .accessibilityActionLabel("Skip for now", descriptive: "Continue without setting preferences", hint: "You can set allergies and diet later in Settings")
        }
        .padding(.top, 8)
    }

    private func skipOnboarding() {
        Haptics.light()
        store.completeOnboarding()
        onComplete()
    }

    private func saveAndComplete() {
        var allergiesList = Array(selectedAllergies)
        allergiesList.append(contentsOf: otherAllergies.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
        store.setAllergies(allergiesList)

        var dietsList = Array(selectedDiets).map { $0.lowercased() }
        dietsList.append(contentsOf: otherDiets.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }.filter { !$0.isEmpty })
        store.setDietPreferences(dietsList)

        var goalsList = Array(selectedGoals)
        goalsList.append(contentsOf: otherGoals.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
        store.setHealthGoals(goalsList)

        Haptics.light()
        store.completeOnboarding()
        onComplete()
    }
}

private struct Chip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : AppTheme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary : AppTheme.primary.opacity(0.15))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    OnboardingScreen(onComplete: {})
        .environmentObject(AppStore())
}
