//
//  TutorialModal.swift
//  SmartCart
//

import SwiftUI

struct TutorialModal: View {
    @State private var currentStep = 1
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Welcome to SmartCart")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
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

                // Step content
                VStack(alignment: .center, spacing: 24) {
                    if currentStep == 1 {
                        tutorialStep(
                            icon: "fork.knife",
                            title: "Browse 415+ Recipes",
                            description: "Discover delicious, healthy recipes with photos, nutrition info, and cook times.",
                            number: "1"
                        )
                    } else if currentStep == 2 {
                        tutorialStep(
                            icon: "calendar.badge.plus",
                            title: "Plan Your Week",
                            description: "Pick recipes for each meal. Generate a smart grocery list automatically.",
                            number: "2"
                        )
                    } else {
                        tutorialStep(
                            icon: "chart.pie.fill",
                            title: "Track Your Nutrition",
                            description: "Log meals, monitor calories, protein, and hit your health goals.",
                            number: "3"
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(30)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: nextStep) {
                        Text(currentStep == 3 ? "Get Started" : "Next")
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

    private func tutorialStep(icon: String, title: String, description: String, number: String) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.primary)
            }

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.onSurface)
                .multilineTextAlignment(.center)

            Text(description)
                .font(.body)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
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
