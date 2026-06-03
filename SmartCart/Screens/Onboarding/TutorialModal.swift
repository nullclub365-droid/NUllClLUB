//
//  TutorialModal.swift
//  SmartCart
//

import SwiftUI

struct TutorialModal: View {
    @State private var currentStep = 1
    var onDismiss: () -> Void
    var dietPreferences: [String] = []

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Step \(currentStep) of 3")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.primary)
                        Text("Welcome to SmartCart")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.onSurface)
                    }
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                }
                .padding(20)

                // Step indicator
                HStack(spacing: 6) {
                    ForEach(1...3, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? AppTheme.primary : AppTheme.primary.opacity(0.2))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Step content - Interactive
                if currentStep == 1 {
                    step1Content
                } else if currentStep == 2 {
                    step2Content
                } else {
                    step3Content
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: nextStep) {
                        Text(currentStep == 3 ? "Get Started" : "Next Step")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(AppTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: onDismiss) {
                        Text(currentStep == 3 ? "" : "Skip tutorial")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                    }
                }
                .padding(20)
            }
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(24)
        }
    }

    private var step1Content: some View {
        VStack(spacing: 16) {
            Text("Browse 415+ Recipes")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.onSurface)

            Text(dietPreferences.isEmpty ? "Tap any recipe to see nutrition, cook time, and ingredients" : "Recipes matched to your \(dietPreferences.first?.lowercased() ?? "diet") preference")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                if dietPreferences.contains("vegan") || dietPreferences.contains("vegetarian") {
                    recipeCard(title: "Buddha Bowl", time: "20 min", cal: "380 cal", image: "🥗")
                    recipeCard(title: "Lentil Curry", time: "25 min", cal: "420 cal", image: "🌶️")
                    recipeCard(title: "Chickpea Pasta", time: "15 min", cal: "360 cal", image: "🍝")
                } else if dietPreferences.contains("keto") || dietPreferences.contains("low-carb") {
                    recipeCard(title: "Grilled Steak & Veggies", time: "30 min", cal: "520 cal", image: "🥩")
                    recipeCard(title: "Salmon with Butter", time: "25 min", cal: "580 cal", image: "🐟")
                    recipeCard(title: "Eggs & Bacon", time: "10 min", cal: "450 cal", image: "🍳")
                } else if dietPreferences.contains("paleo") {
                    recipeCard(title: "Grilled Chicken Bowl", time: "25 min", cal: "450 cal", image: "🍗")
                    recipeCard(title: "Salmon with Sweet Potato", time: "30 min", cal: "520 cal", image: "🐟")
                    recipeCard(title: "Turkey & Vegetables", time: "20 min", cal: "380 cal", image: "🦃")
                } else {
                    recipeCard(title: "Grilled Chicken Bowl", time: "25 min", cal: "450 cal", image: "🍗")
                    recipeCard(title: "Veggie Stir Fry", time: "20 min", cal: "320 cal", image: "🥦")
                    recipeCard(title: "Salmon with Rice", time: "30 min", cal: "580 cal", image: "🐟")
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(20)
    }

    private var step2Content: some View {
        VStack(spacing: 16) {
            Text("Plan Your Week")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.onSurface)

            Text("Pick recipes for each meal and auto-generate your grocery list")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                plannerDay(day: "Monday", meal: "🍗 Grilled Chicken Bowl")
                plannerDay(day: "Tuesday", meal: "🥦 Veggie Stir Fry")
                plannerDay(day: "Wednesday", meal: "🐟 Salmon with Rice")

                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                    Text("Add more meals")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.primary)
                    Spacer()
                }
                .padding(12)
                .background(AppTheme.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 16)
        }
        .padding(20)
    }

    private var step3Content: some View {
        VStack(spacing: 16) {
            Text("Track Your Nutrition")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.onSurface)

            Text("Log meals and watch your nutrition stats in real-time")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                nutritionStat(label: "Calories", value: "1,450", icon: "🔥", color: AppTheme.primary)
                nutritionStat(label: "Protein", value: "85g", icon: "💪", color: AppTheme.secondary)
                nutritionStat(label: "Carbs", value: "180g", icon: "🌾", color: AppTheme.tertiary)
            }
            .padding(.horizontal, 16)

            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.primary)
                Text("See detailed insights on the Nutrition tab")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Spacer()
            }
            .padding(12)
            .background(AppTheme.primary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
        }
        .padding(20)
    }

    private func recipeCard(title: String, time: String, cal: String, image: String) -> some View {
        HStack(spacing: 12) {
            Text(image)
                .font(.system(size: 32))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                HStack(spacing: 12) {
                    Label(time, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Label(cal, systemImage: "flame")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .padding(12)
        .background(AppTheme.surfaceVariant.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func plannerDay(day: String, meal: String) -> some View {
        HStack(spacing: 12) {
            Text(day)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.onSurface)
                .frame(width: 70, alignment: .leading)
            Text(meal)
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
            Spacer()
            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundStyle(AppTheme.primary)
        }
        .padding(10)
        .background(AppTheme.surfaceVariant.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func nutritionStat(label: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 24))
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
            }
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func nextStep() {
        if currentStep < 3 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        } else {
            onDismiss()
        }
    }
}

#Preview {
    TutorialModal(onDismiss: {})
        .background(AppTheme.background)
}
