//
//  CookingScreen.swift
//  SmartCart
//

import Combine
import SwiftUI

struct CookingScreen: View {
    @EnvironmentObject var store: AppStore
    let recipeId: Int64
    var onComplete: () -> Void
    var onBack: () -> Void
    var onOpenTimers: ((Int) -> Void)? = nil

    private var recipe: Recipe? { store.recipe(byId: recipeId) }
    @State private var currentStepIndex: Int = 0
    @State private var timerRemainingSeconds: Int? = nil
    @State private var isTimerRunning: Bool = false

    private var currentStep: RecipeStep? {
        guard let recipe = recipe, currentStepIndex >= 0, currentStepIndex < recipe.steps.count else { return nil }
        return recipe.steps[currentStepIndex]
    }

    var body: some View {
        Group {
            if recipe == nil {
                ContentUnavailableView("Recipe not found", systemImage: "doc.text.magnifyingglass")
            } else if let recipe = recipe, !recipe.steps.isEmpty {
                ZStack {
                    LinearGradient(
                        colors: [AppTheme.surface, AppTheme.surfaceVariant.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .center, spacing: 0) {
                            Text(recipe.name)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.onSurfaceVariant)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)

                            stepProgressDots(current: currentStepIndex, total: recipe.steps.count)
                                .padding(.top, 24)

                            stepCard(recipe: recipe)
                                .padding(.top, 32)
                                .padding(.horizontal, 20)

                            Spacer(minLength: 24)

                            navigationButtons(recipe: recipe)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 24)
                        }
                        .padding(.top, 8)
                    }
                }
                .navigationTitle(recipe.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .tabBar)
                .onChange(of: currentStepIndex) { _, newIndex in
                    resetTimerForStep(at: newIndex, recipe: recipe)
                }
                .onAppear {
                    resetTimerForStep(at: currentStepIndex, recipe: recipe)
                }
                .onDisappear {
                    isTimerRunning = false
                }
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    guard isTimerRunning, let r = timerRemainingSeconds, r > 0 else { return }
                    timerRemainingSeconds = r - 1
                    if r - 1 <= 0 {
                        isTimerRunning = false
                        Haptics.success()
                        AccessibilitySettings.announce("Timer finished")
                    }
                }
            } else {
                ContentUnavailableView("No steps", systemImage: "list.number", description: Text("This recipe has no cooking steps."))
            }
        }
    }

    private func resetTimerForStep(at index: Int, recipe: Recipe) {
        isTimerRunning = false
        let step = recipe.steps.getOrNull(index)
        timerRemainingSeconds = step?.durationSeconds
    }

    private func stepProgressDots(current: Int, total: Int) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(0..<total, id: \.self) { index in
                    let isCompleted = index < current
                    let isCurrent = index == current
                    ZStack {
                        Circle()
                            .fill(isCompleted || isCurrent ? AppTheme.primary : AppTheme.surfaceVariant)
                            .frame(width: isCurrent ? 14 : 10, height: isCurrent ? 14 : 10)
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            Text("Step \(current + 1) of \(total)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
    }

    private func stepCard(recipe: Recipe) -> some View {
        let step = currentStep ?? RecipeStep(title: "", description: "", durationSeconds: nil)
        let stepNumber = currentStepIndex + 1

        return VStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryContainer)
                    .frame(width: 56, height: 56)
                Text("\(stepNumber)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onPrimaryContainer)
            }

            if !step.title.isEmpty {
                Text(step.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.onSurface)
            }

            Text(step.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .lineSpacing(6)

            if let duration = step.durationSeconds, duration > 0 {
                stepTimerView(durationSeconds: duration)
                    .padding(.top, 8)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private func stepTimerView(durationSeconds: Int) -> some View {
        let total = durationSeconds
        let remaining = timerRemainingSeconds ?? total
        let progress = total > 0 ? CGFloat(max(0, remaining)) / CGFloat(total) : 1
        let displaySeconds = max(0, remaining)
        let isUrgent = remaining <= 10 && isTimerRunning

        return VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(AppTheme.surfaceVariant, lineWidth: 12)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        isUrgent ? Color(red: 0.91, green: 0.12, blue: 0.39) : AppTheme.primary,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    if displaySeconds >= 60 {
                        Text(String(format: "%d:%02d", displaySeconds / 60, displaySeconds % 60))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(isUrgent ? Color(red: 0.91, green: 0.12, blue: 0.39) : AppTheme.primary)
                        Text("min")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    } else {
                        Text("\(displaySeconds)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(isUrgent ? Color(red: 0.91, green: 0.12, blue: 0.39) : AppTheme.primary)
                        Text("sec")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                }
            }
            .onTapGesture {
                toggleTimer(totalSeconds: durationSeconds)
            }

            Button(action: { toggleTimer(totalSeconds: durationSeconds) }) {
                Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(isTimerRunning ? AppTheme.surfaceVariant : AppTheme.primaryContainer)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)

            Text(isTimerRunning ? "Tap to pause" : "Tap to start")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
    }

    private func toggleTimer(totalSeconds: Int) {
        Haptics.light()
        if isTimerRunning {
            isTimerRunning = false
        } else {
            let current = timerRemainingSeconds ?? totalSeconds
            if current <= 0 {
                timerRemainingSeconds = totalSeconds
            }
            isTimerRunning = true
        }
    }

    private var totalSeconds: Int {
        currentStep?.durationSeconds ?? 0
    }

    private func navigationButtons(recipe: Recipe) -> some View {
        let touchPadding: CGFloat = AccessibilitySettings.largerTouchTargets ? 12 : 0
        return HStack(spacing: 16) {
            Button(action: {
                Haptics.light()
                if AccessibilitySettings.shouldReduceMotion {
                    currentStepIndex -= 1
                } else {
                    withAnimation { currentStepIndex -= 1 }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                    Text("Previous")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .background(AppTheme.surfaceVariant)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(touchPadding)
            }
            .buttonStyle(.plain)
            .disabled(currentStepIndex <= 0)
            .opacity(currentStepIndex <= 0 ? 0.5 : 1)
            .accessibilityLabel(AccessibilitySettings.descriptiveLabels ? "Go to previous cooking step" : "Previous")
            .accessibilityHint("Double tap to go back one step")

            let isLastStep = currentStepIndex >= recipe.steps.count - 1

            if isLastStep {
                Button(action: {
                    Haptics.success()
                    store.addToRecipeHistory(recipeId: recipeId)
                    store.saveNow()
                    AccessibilitySettings.announce("Recipe completed")
                    InterstitialAdHelper.showInterstitial { onComplete() }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.bold))
                        Text("Done!")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .foregroundStyle(.white)
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(touchPadding)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AccessibilitySettings.descriptiveLabels ? "Mark recipe as cooked and finish" : "Done")
                .accessibilityHint("Double tap to complete this recipe")
            } else {
                Button(action: {
                    if AccessibilitySettings.shouldReduceMotion {
                        currentStepIndex += 1
                    } else {
                        withAnimation { currentStepIndex += 1 }
                    }
                }) {
                    HStack(spacing: 4) {
                        Text("Next")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .foregroundStyle(.white)
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(touchPadding)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AccessibilitySettings.descriptiveLabels ? "Go to next cooking step" : "Next")
                .accessibilityHint("Double tap to continue")
            }
        }
    }
}

private extension Array {
    func getOrNull(_ index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

#Preview {
    NavigationStack {
        CookingScreen(recipeId: 1, onComplete: {}, onBack: {})
            .environmentObject(AppStore())
    }
}
