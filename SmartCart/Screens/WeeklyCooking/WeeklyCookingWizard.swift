//
//  WeeklyCookingWizard.swift
//  SmartCart
//

import SwiftUI
import Combine
import UserNotifications
import UIKit
import AudioToolbox

// MARK: - Domain Models

struct BatchCookGroup: Identifiable {
    let id = UUID()
    let recipe: Recipe
    let appearances: [(day: String, mealType: String)]
    var isSelected: Bool

    var portionCount: Int { appearances.count }

    var daysLabel: String {
        appearances.map(\.day).joined(separator: " · ")
    }

    var portionLabel: String? {
        switch portionCount {
        case 1: return nil
        case 2: return "Double portion"
        case 3: return "Triple portion"
        default: return "× \(portionCount) portions"
        }
    }
}

private enum WizardStep: Int {
    case templateSelect, batchOverview, cookingSession, postCookCheck
}

// MARK: - Root Wizard

struct WeeklyCookingWizard: View {
    @EnvironmentObject var store: AppStore
    var onDismiss: () -> Void
    var onOpenRecipe: ((Int64) -> Void)? = nil

    @State private var step: WizardStep = .templateSelect
    @State private var selectedTemplate: MealPlanTemplate? = nil
    @State private var batchGroups: [BatchCookGroup] = []
    @State private var showAdUnavailableAlert = false
    @State private var savedSession: SavedMealPrepSession? = nil
    @State private var resumeForSession: SavedMealPrepSession? = nil
    @State private var showDiscardConfirm = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

                switch step {
                case .templateSelect:
                    TemplateSelectStep(
                        templates: store.mealPlanTemplates,
                        activeTemplateId: store.currentPlan?.templateId,
                        resumeTemplateName: savedSession.flatMap { s in store.mealPlanTemplates.first { $0.id == s.templateId }?.name },
                        onResume: resumeSavedSession,
                        onDiscardResume: { showDiscardConfirm = true },
                        onSelect: handleTemplateSelect
                    )
                case .batchOverview:
                    BatchOverviewStep(
                        groups: $batchGroups,
                        onStart: advance,
                        onBack: retreat
                    )
                case .cookingSession:
                    CookingSessionStep(
                        groups: batchGroups.filter(\.isSelected),
                        templateId: selectedTemplate?.id ?? -1,
                        resume: resumeForSession,
                        onComplete: advance,
                        onBack: retreat,
                        onOpenRecipe: onOpenRecipe
                    )
                case .postCookCheck:
                    WeeklyPostCookStep(
                        recipes: batchGroups.filter(\.isSelected).map(\.recipe),
                        onDone: {
                            AchievementTracker.checkAndTrackAchievements(store: store)
                            onDismiss()
                        }
                    )
                }
            }
        }
        .onAppear { savedSession = MealPrepSessionStore.load() }
        .alert("Discard your cook session?", isPresented: $showDiscardConfirm) {
            Button("Discard", role: .destructive) { discardSavedSession() }
            Button("Keep it", role: .cancel) {}
        } message: {
            Text("Your in-progress meal prep — checked steps and timers — will be permanently cleared.")
        }
        .alert("Ad Unavailable", isPresented: $showAdUnavailableAlert) {
            Button("Continue Anyway") {
                if let t = selectedTemplate {
                    batchGroups = buildBatchGroups(from: t)
                    advance()
                }
            }
            Button("Cancel", role: .cancel) { selectedTemplate = nil }
        } message: {
            Text("The ad couldn't load. You can still start your cook session.")
        }
    }

    // MARK: Resume

    private func resumeSavedSession() {
        guard let s = savedSession,
              let template = store.mealPlanTemplates.first(where: { $0.id == s.templateId }) else {
            discardSavedSession(); return
        }
        selectedTemplate = template
        let selected = Set(s.selectedRecipeIds)
        batchGroups = buildBatchGroups(from: template).map { group in
            var g = group
            g.isSelected = selected.contains(group.recipe.id)
            return g
        }
        resumeForSession = s
        Haptics.light()
        AnalyticsHelper.trackFeatureUsed("mealprep_session_resumed")
        withAnimation(.easeInOut(duration: 0.28)) { step = .cookingSession }
    }

    private func discardSavedSession() {
        MealPrepSessionStore.clear()
        savedSession = nil
        MealPrepStatusModel.shared.refresh()
        AnalyticsHelper.trackFeatureUsed("mealprep_session_discarded")
    }

    /// Close button — records where the user bailed (unless they've finished cooking).
    private func dismissWizard() {
        if step != .postCookCheck {
            AnalyticsHelper.trackFeatureUsed("mealprep_abandoned", details: ["step": String(describing: step)])
        }
        onDismiss()
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack {
            Button(action: dismissWizard) {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.surfaceVariant.opacity(0.7))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Close meal prep")
            Spacer()
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(i <= step.rawValue ? AppTheme.primary : AppTheme.surfaceVariant)
                        .frame(width: i == step.rawValue ? 20 : 8, height: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: step.rawValue)
                }
            }
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
    }

    // MARK: Navigation

    private func advance() {
        withAnimation(.easeInOut(duration: 0.28)) {
            switch step {
            case .templateSelect: step = .batchOverview
            case .batchOverview: step = .cookingSession
            case .cookingSession: step = .postCookCheck
            case .postCookCheck: break
            }
        }
    }

    private func retreat() {
        withAnimation(.easeInOut(duration: 0.28)) {
            switch step {
            case .batchOverview: step = .templateSelect
            case .cookingSession: step = .batchOverview
            default: break
            }
        }
    }

    // MARK: Ad + template

    private func handleTemplateSelect(_ template: MealPlanTemplate) {
        selectedTemplate = template
        resumeForSession = nil // fresh session
        Haptics.light()
        AnalyticsHelper.trackFeatureUsed("mealprep_template_chosen", details: ["template": template.name])
        RewardedAdHelper.showRewardedAd(
            onReward: {
                batchGroups = buildBatchGroups(from: template)
                advance()
            },
            onNotEarned: { showAdUnavailableAlert = true }
        )
    }

    // MARK: Batch grouping

    private func buildBatchGroups(from template: MealPlanTemplate) -> [BatchCookGroup] {
        let dayOrder = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var map: [Int64: [(day: String, mealType: String)]] = [:]

        for day in template.meals {
            let slots: [(Int64?, String)] = [
                (day.breakfastId, "Breakfast"),
                (day.lunchId, "Lunch"),
                (day.dinnerId, "Dinner"),
                (day.snackId, "Snack")
            ]
            for (optId, label) in slots {
                guard let id = optId else { continue }
                map[id, default: []].append((day: day.dayOfWeek, mealType: label))
            }
        }

        return map.compactMap { (id, apps) -> BatchCookGroup? in
            guard let recipe = store.recipe(byId: id) else { return nil }
            let sorted = apps.sorted {
                (dayOrder.firstIndex(of: $0.day) ?? 0) < (dayOrder.firstIndex(of: $1.day) ?? 0)
            }
            return BatchCookGroup(recipe: recipe, appearances: sorted, isSelected: true)
        }
        .sorted { $0.recipe.readyInMinutes > $1.recipe.readyInMinutes }
    }
}

// MARK: - Step 1: Template Select

private struct TemplateSelectStep: View {
    let templates: [MealPlanTemplate]
    let activeTemplateId: Int64?
    let resumeTemplateName: String?
    let onResume: () -> Void
    let onDiscardResume: () -> Void
    let onSelect: (MealPlanTemplate) -> Void

    private var activeTemplate: MealPlanTemplate? {
        guard let id = activeTemplateId else { return nil }
        return templates.first { $0.id == id }
    }

    private var otherTemplates: [MealPlanTemplate] {
        templates.filter { $0.id != activeTemplateId }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("What are we cooking?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("Pick a plan and we'll batch cook your whole week in one session.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                .padding(.horizontal, 24)

                if let name = resumeTemplateName {
                    resumeBanner(name: name)
                        .padding(.horizontal, 24)
                }

                if let active = activeTemplate {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Active in Planner", systemImage: "calendar.badge.checkmark")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.primary)
                            .padding(.horizontal, 24)

                        TemplateSelectCard(template: active, isHighlighted: true) {
                            onSelect(active)
                        }
                        .padding(.horizontal, 24)
                    }
                }

                if !otherTemplates.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        if activeTemplate != nil {
                            Text("Other Plans")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(AppTheme.onSurface)
                                .padding(.horizontal, 24)
                        }
                        ForEach(otherTemplates) { template in
                            TemplateSelectCard(template: template, isHighlighted: false) {
                                onSelect(template)
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }

                Spacer(minLength: 32)
            }
            .padding(.top, 4)
        }
    }

    private func resumeBanner(name: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundStyle(AppTheme.primary)
                Text("Cook session in progress")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
            }
            Text("You have an unfinished \(name) session. Pick up where you left off?")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
            HStack(spacing: 10) {
                Button(action: onResume) {
                    Text("Resume")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(AppTheme.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                Button(action: onDiscardResume) {
                    Text("Start over")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(height: 40)
                        .padding(.horizontal, 18)
                        .background(AppTheme.surfaceVariant)
                        .foregroundStyle(AppTheme.onSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(AppTheme.primaryContainer.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct TemplateSelectCard: View {
    let template: MealPlanTemplate
    let isHighlighted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text(template.focus)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.primary)
                    if let desc = template.description {
                        Text(desc)
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                            .lineLimit(2)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            .padding(16)
            .background(isHighlighted ? AppTheme.primaryContainer.opacity(0.4) : AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isHighlighted ? AppTheme.primary.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 2: Batch Overview

private struct BatchOverviewStep: View {
    @Binding var groups: [BatchCookGroup]
    let onStart: () -> Void
    let onBack: () -> Void

    private var selectedCount: Int { groups.filter(\.isSelected).count }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your cook plan")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.onSurface)
                        Text("We grouped repeating recipes into bigger batches so you cook them once. Deselect anything you want to skip.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 10) {
                        ForEach($groups) { $group in
                            BatchGroupRow(group: $group)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 100)
                }
                .padding(.top, 4)
            }

            bottomBar {
                Button(action: onStart) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                        Text("Start Cooking · \(selectedCount) dish\(selectedCount == 1 ? "" : "es")")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(selectedCount > 0 ? AppTheme.primary : AppTheme.surfaceVariant)
                    .foregroundStyle(selectedCount > 0 ? .white : AppTheme.onSurfaceVariant)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(selectedCount == 0)

                Button(action: onBack) {
                    Text("Back")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }
        }
    }
}

private struct BatchGroupRow: View {
    @Binding var group: BatchCookGroup

    var body: some View {
        HStack(spacing: 14) {
            Button {
                Haptics.light()
                group.isSelected.toggle()
            } label: {
                Image(systemName: group.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(group.isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant.opacity(0.35))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(group.recipe.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(group.isSelected ? AppTheme.onSurface : AppTheme.onSurfaceVariant)
                    .strikethrough(!group.isSelected)

                HStack(spacing: 6) {
                    if let label = group.portionLabel {
                        Text(label)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppTheme.primaryContainer.opacity(0.5))
                            .clipShape(Capsule())
                    }
                    Text("⏱ \(group.recipe.readyInMinutes) min")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }

                Text(group.daysLabel)
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }

            Spacer()
        }
        .padding(14)
        .background(group.isSelected ? AppTheme.surface : AppTheme.surface.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(group.isSelected ? 1 : 0.55)
        .animation(.easeInOut(duration: 0.18), value: group.isSelected)
    }
}

private struct CookingSessionStep: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.scenePhase) private var scenePhase
    let groups: [BatchCookGroup]
    let templateId: Int64
    let resume: SavedMealPrepSession?
    let onComplete: () -> Void
    let onBack: () -> Void

    var onOpenRecipe: ((Int64) -> Void)? = nil

    @State private var plan = MealPrepPlanner.Plan(tasks: [:], storage: [], timeline: [], equipment: [], ovenWarning: nil, noCookItems: [])
    @State private var phases: [CookPhaseKind] = [.gamePlan]
    @State private var phaseIndex = 0
    @State private var completedTaskIds: Set<String> = []
    @State private var timers: [SessionTimer] = []
    @State private var tick = 0
    @State private var showSkipAlert = false
    @State private var sessionStartEpoch: Double? = nil
    @State private var firedTimerIds: Set<String> = []
    @State private var ringingTimer: SessionTimer? = nil
    @State private var notifAuthorized = true
    @State private var quickLookRecipeId: Int64? = nil
    @State private var householdSize = 1
    @State private var excludedRecipeIds: Set<Int64> = []
    @State private var showCompletion = false
    @State private var setAsPlan = true
    @State private var showAddTimer = false

    /// Dishes actually being cooked this session (after the user removes any they can't make).
    private var activeGroups: [BatchCookGroup] { groups.filter { !excludedRecipeIds.contains($0.recipe.id) } }

    private var currentPhase: CookPhaseKind { phases[min(phaseIndex, phases.count - 1)] }
    private var isLastPhase: Bool { phaseIndex >= phases.count - 1 }
    private var isCookingPhase: Bool { currentPhase != .gamePlan && currentPhase != .store }

    /// One pass over timers, reused by the live clock and the "now" anchor.
    private var soonestActiveTimer: SessionTimer? {
        timers.filter { !$0.isFinished && !$0.isPaused }.min { $0.remainingSeconds < $1.remainingSeconds }
    }

    /// Overall step progress across every cooking phase.
    private var overallProgress: (done: Int, total: Int) {
        let all = [CookPhaseKind.prep, .slowCook, .activeCook, .assemble].flatMap { plan.tasks[$0] ?? [] }
        return (all.filter { completedTaskIds.contains($0.id) }.count, all.count)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                phaseHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                if isCookingPhase {
                    liveClockBar
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                }

                if isCookingPhase || !timers.isEmpty {
                    timerStrip
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        switch currentPhase {
                        case .gamePlan: gamePlanBody
                        case .store: storeBody
                        default: taskListBody
                        }
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }

                bottomBar {
                    Button(action: attemptNextPhase) {
                        HStack(spacing: 8) {
                            Image(systemName: isLastPhase ? "checkmark.circle.fill" : "arrow.right")
                            Text(nextButtonLabel)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(AppTheme.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)

                    Button(action: prevPhase) {
                        Text(phaseIndex == 0 ? "Back to plan" : "Previous phase")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                }
            }

            if let ringing = ringingTimer {
                timerRingOverlay(ringing)
            }

            if showCompletion {
                completionOverlay
            }
        }
        .onAppear {
            buildPlan()
            UIApplication.shared.isIdleTimerDisabled = true // keep screen awake while cooking
            refreshNotificationStatus()
            AnalyticsHelper.trackFeatureUsed("mealprep_session_started", details: ["dishes": activeGroups.count])
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: householdSize) { _, _ in
            withAnimation { rebuildPlan() }
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Returning to the app: re-anchor timers, catch any that finished while away, refresh perms.
            if newPhase == .active {
                refreshNotificationStatus()
                detectFinishedTimers()
                tick &+= 1
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            // Only re-render every second when there's something live to update.
            guard isCookingPhase || timers.contains(where: { !$0.isPaused && !$0.isFinished }) else { return }
            tick &+= 1
            detectFinishedTimers()
        }
        .sheet(isPresented: $showAddTimer) {
            AddTimerSheet { label, minutes in
                addCustomTimer(label: label, minutes: minutes)
                showAddTimer = false
            }
        }
        .sheet(item: Binding(
            get: { quickLookRecipeId.map { RecipeRef(id: $0) } },
            set: { quickLookRecipeId = $0?.id }
        )) { ref in
            if let recipe = store.recipe(byId: ref.id) {
                RecipeQuickLookSheet(
                    recipe: recipe,
                    store: store,
                    onOpenInApp: onOpenRecipe.map { cb in { cb(ref.id) } }
                )
            }
        }
        .alert("Some steps aren't checked", isPresented: $showSkipAlert) {
            Button("Keep cooking", role: .cancel) {}
            Button("Move on anyway") { goNext() }
        } message: {
            Text("You've still got unchecked steps in this phase. Move on anyway?")
        }
    }

    // MARK: Live session clock

    private var liveClockBar: some View {
        let elapsedSecs = sessionStartEpoch.map { Int(Date().timeIntervalSince1970 - $0) } ?? 0
        let plannedMin = max(MealPrepPlanner.estimateMinutes(plan.tasks).total, 1)
        let elapsedMin = elapsedSecs / 60
        let behind = elapsedMin > plannedMin + max(5, plannedMin / 5) // >20% (min 5 min) over
        let prog = overallProgress
        return HStack(spacing: 10) {
            Image(systemName: "stopwatch.fill")
                .font(.caption)
                .foregroundStyle(behind ? AppTheme.secondary : AppTheme.primary)
            Text("\(clock(elapsedSecs)) / ~\(plannedMin)m")
                .font(.system(.caption, design: .monospaced).weight(.semibold))
                .foregroundStyle(AppTheme.onSurface)
                .accessibilityLabel("Elapsed \(clock(elapsedSecs)) of about \(plannedMin) minutes planned")
            if behind {
                Text("behind")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppTheme.secondary)
            }
            Spacer()
            if prog.total > 0 {
                Text("\(prog.done)/\(prog.total) steps")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            if let next = soonestActiveTimer {
                Text("· next \(next.timeString)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(AppTheme.primary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background((behind ? AppTheme.secondary : AppTheme.primary).opacity(0.12))
        .clipShape(Capsule())
    }

    private func clock(_ secs: Int) -> String {
        String(format: "%d:%02d", secs / 60, secs % 60)
    }

    // MARK: Timer ring overlay (foreground alert)

    private func timerRingOverlay(_ timer: SessionTimer) -> some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 18) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.secondary)
                    .symbolEffect(.bounce, options: AccessibilitySettings.shouldReduceMotion ? .nonRepeating : .repeating)
                Text("Timer done")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                Text(timer.label)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                Button {
                    ringingTimer = nil
                } label: {
                    Text("Got it")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(28)
            .frame(maxWidth: 320)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(40)
        }
        .transition(.opacity)
        .accessibilityAddTraits(.isModal)
        .accessibilityElement(children: .contain)
    }

    // MARK: Completion celebration

    private var completionOverlay: some View {
        let dishCount = plan.storage.count
        let meals = plan.storage.reduce(0) { $0 + $1.portionCount }
        let elapsed = sessionStartEpoch.map { Int(Date().timeIntervalSince1970 - $0) } ?? 0
        let existingDifferent = (store.currentPlan?.templateId).map { $0 != templateId } ?? false
        return ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.primary)
                        .symbolEffect(.bounce)
                    Text("Week prepped! 🎉")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("You cooked \(dishCount) dish\(dishCount == 1 ? "" : "es") into \(meals) ready meals in \(clock(elapsed)).")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .multilineTextAlignment(.center)

                    // Freezer recap
                    VStack(spacing: 8) {
                        ForEach(plan.storage) { s in
                            HStack(spacing: 8) {
                                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.tertiary)
                                Text(s.recipeName)
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.onSurface)
                                Spacer()
                                Text("×\(s.portionCount)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                            }
                        }
                    }
                    .padding(12)
                    .background(AppTheme.surfaceVariant.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Toggle(isOn: $setAsPlan) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Set as this week's plan")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.onSurface)
                            if existingDifferent {
                                Text("Replaces your current planner")
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.secondary)
                            }
                        }
                    }
                    .tint(AppTheme.primary)

                    Button {
                        confirmCompletion()
                    } label: {
                        Text("Finish & check ingredients")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
            }
            .frame(maxWidth: 360, maxHeight: 560)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(24)
        }
        .transition(.opacity)
        .accessibilityAddTraits(.isModal)
        .accessibilityElement(children: .contain)
    }

    private var nextButtonLabel: String {
        switch currentPhase {
        case .gamePlan: return hasCookWork ? "Let's start" : "Done"
        case .store: return "Done — check ingredients"
        default: return "Next: \(nextPhaseShortTitle)"
        }
    }

    private var nextPhaseShortTitle: String {
        guard phaseIndex + 1 < phases.count else { return "" }
        switch phases[phaseIndex + 1] {
        case .prep: return "Prep"
        case .slowCook: return "Slow cook"
        case .activeCook: return "Cook"
        case .assemble: return "Assemble"
        case .store: return "Freeze"
        case .gamePlan: return ""
        }
    }

    // MARK: Header

    private var phaseHeader: some View {
        let accent = currentPhase.accent
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                ForEach(Array(phases.enumerated()), id: \.offset) { i, _ in
                    Capsule()
                        .fill(i < phaseIndex ? AppTheme.primary :
                              i == phaseIndex ? accent : AppTheme.surfaceVariant)
                        .frame(height: 5)
                }
            }

            HStack(spacing: 12) {
                Image(systemName: currentPhase.icon)
                    .font(.title2)
                    .foregroundStyle(accent)
                    .frame(width: 44, height: 44)
                    .background(accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentPhase.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text(currentPhase.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                if let progress = phaseProgress {
                    Text(progress)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(accent.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private var phaseProgress: String? {
        guard currentPhase != .gamePlan, currentPhase != .store else { return nil }
        let tasks = plan.tasks[currentPhase] ?? []
        guard !tasks.isEmpty else { return nil }
        let done = tasks.filter { completedTaskIds.contains($0.id) }.count
        return "\(done)/\(tasks.count)"
    }

    // MARK: Timer strip

    private var timerStrip: some View {
        _ = tick
        return VStack(spacing: 8) {
            ForEach(timers) { t in
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: t.isFinished ? "bell.fill" : (t.isPaused ? "pause.circle.fill" : "timer"))
                            .font(.caption)
                            .foregroundStyle(t.isFinished ? Color.orange : AppTheme.primary)
                        Text(t.label)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.onSurface)
                            .lineLimit(1)
                        Spacer()
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(AppTheme.surfaceVariant).frame(height: 5)
                                Capsule()
                                    .fill(t.isFinished ? Color.orange : AppTheme.primary)
                                    .frame(width: geo.size.width * t.progress, height: 5)
                            }
                        }
                        .frame(width: 52, height: 5)
                        Text(t.isFinished ? "Ready!" : t.timeString)
                            .font(.system(.caption, design: .monospaced).weight(.bold))
                            .foregroundStyle(t.isFinished ? Color.orange : AppTheme.onSurface)
                            .frame(width: 44, alignment: .trailing)
                    }

                    HStack(spacing: 6) {
                        if !t.isFinished {
                            timerControl(t.isPaused ? "play.fill" : "pause.fill", "Resume or pause timer") { togglePause(t) }
                            timerControl("minus", "Subtract a minute") { adjustTimer(t, by: -60) }
                            timerControl("plus", "Add a minute") { adjustTimer(t, by: 60) }
                        }
                        Spacer()
                        Button {
                            MealPrepTimerNotifier.cancel(taskId: t.id)
                            timers.removeAll { $0.id == t.id }
                            firedTimerIds.remove(t.id)
                            persist()
                        } label: {
                            Text(t.isFinished ? "Dismiss" : "Cancel")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.onSurfaceVariant)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button { showAddTimer = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add a timer")
                        .fontWeight(.medium)
                }
                .font(.caption)
                .foregroundStyle(AppTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(AppTheme.primaryContainer.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
    }

    private func timerControl(_ icon: String, _ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.light(); action() }) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppTheme.primary)
                .frame(width: 26, height: 26)
                .background(AppTheme.primaryContainer.opacity(0.4))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: Game plan (time sheet)

    // Total food produced this session (per-serving macros × meals × people).
    private var weeklyCalories: Int {
        plan.storage.reduce(0) { $0 + $1.caloriesPerPortion * $1.portionCount } * householdSize
    }
    private var weeklyProtein: Int {
        plan.storage.reduce(0) { $0 + $1.proteinPerPortion * $1.portionCount } * householdSize
    }

    @ViewBuilder
    private var gamePlanBody: some View {
        if !hasCookWork {
            noCookWeekState
        } else {
            cookableGamePlanBody
        }
    }

    /// Shown when every dish in the plan is make-fresh (oats, shakes) — there's nothing to batch cook.
    private var noCookWeekState: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.primary)
            Text("No cooking needed this week")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.onSurface)
            Text(plan.noCookItems.isEmpty
                 ? "There's nothing to batch cook for this plan."
                 : "These are all made fresh: \(plan.noCookItems.joined(separator: ", ")). Just whip them up on the day — tap Done to review ingredients.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var cookableGamePlanBody: some View {
        let est = MealPrepPlanner.estimateMinutes(plan.tasks)
        let dishCount = plan.storage.count
        let portionCount = plan.storage.reduce(0) { $0 + $1.portionCount }
        let weeklyKcal = weeklyCalories
        return VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                gamePlanStat(value: "\(dishCount)", label: "dishes")
                gamePlanStat(value: "\(portionCount)", label: "meals")
                gamePlanStat(value: "~\(max(est.total, 1))m", label: "total time")
            }

            // Household scaling
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(AppTheme.primary)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Cooking for")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.onSurface)
                    Text(householdSize == 1 ? "Just me — standard portions" : "\(householdSize) people — quantities scaled ×\(householdSize)")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
                Stepper("", value: $householdSize, in: 1...8)
                    .labelsHidden()
                    .accessibilityLabel("Cooking for \(householdSize) people")
                Text("\(householdSize)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 22)
            }
            .padding(14)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            // Weekly nutrition yield
            if weeklyKcal > 0 {
                HStack(spacing: 10) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(AppTheme.primary)
                    Text("This batch yields ~\(weeklyKcal.formatted()) kcal · \(weeklyProtein)g protein across \(portionCount) meals.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Spacer()
                }
                .padding(12)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if !notifAuthorized {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "bell.slash.fill")
                        .foregroundStyle(AppTheme.secondary)
                    Text("Notifications are off, so timers can't alert you when the app is in the background. Enable them in Settings to get pinged when something's ready.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Spacer()
                }
                .padding(12)
                .background(AppTheme.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if !plan.noCookItems.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(AppTheme.primary)
                    Text("Make fresh, no cooking needed: \(plan.noCookItems.joined(separator: ", ")). We left these out of the cook flow.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Spacer()
                }
                .padding(12)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            preCookCheckSection

            equipmentSection

            // Suggested timeline (the real time sheet)
            VStack(alignment: .leading, spacing: 10) {
                Text("Suggested timeline")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                VStack(spacing: 0) {
                    ForEach(Array(plan.timeline.enumerated()), id: \.element.id) { idx, entry in
                        HStack(alignment: .top, spacing: 12) {
                            Text(entry.clock)
                                .font(.system(.caption, design: .monospaced).weight(.bold))
                                .foregroundStyle(entry.isHandsOff ? AppTheme.secondary : AppTheme.primary)
                                .frame(minWidth: 42, alignment: .leading)
                                .fixedSize(horizontal: true, vertical: false)
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(entry.isHandsOff ? AppTheme.secondary : AppTheme.primary)
                                    .frame(width: 8, height: 8)
                                if idx < plan.timeline.count - 1 {
                                    Rectangle()
                                        .fill(AppTheme.surfaceVariant)
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            Text(entry.text)
                                .font(.caption)
                                .foregroundStyle(AppTheme.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 12)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(14)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func gamePlanStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // Pre-cook "do you have everything?" check
    private var preCookCheckSection: some View {
        let missing = missingIngredients
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: missing.isEmpty ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(missing.isEmpty ? AppTheme.primary : AppTheme.secondary)
                Text(missing.isEmpty ? "You have everything" : "You may be missing \(missing.count) item\(missing.count == 1 ? "" : "s")")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
            }
            if missing.isEmpty {
                Text("Everything these recipes need is in your pantry. (We check what you have, not exact amounts.)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            } else {
                Text(missing.map { $0.onList ? "\($0.name) (on list)" : $0.name }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Text("We check what's in your pantry, not exact quantities — double-check you have enough.")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.8))

                let notOnList = missing.filter { !$0.onList }
                if !notOnList.isEmpty {
                    Button {
                        Haptics.light()
                        store.addItemsToGroceryList(notOnList.map { ($0.id, "") })
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "cart.badge.plus")
                            Text("Add \(notOnList.count) to grocery list")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(AppTheme.secondary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }

                let affected = dishesMissingIngredients
                if !affected.isEmpty && affected.count < activeGroups.count {
                    Button {
                        Haptics.light()
                        excludedRecipeIds.formUnion(affected)
                        withAnimation { rebuildPlan() }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "minus.circle")
                            Text("Skip the \(affected.count) dish\(affected.count == 1 ? "" : "es") I can't make")
                                .fontWeight(.medium)
                        }
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(AppTheme.surfaceVariant)
                        .foregroundStyle(AppTheme.onSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }

            if !excludedRecipeIds.isEmpty {
                Button {
                    Haptics.light()
                    excludedRecipeIds.removeAll()
                    withAnimation { rebuildPlan() }
                } label: {
                    Text("Add removed dishes back")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.primary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background((missingIngredients.isEmpty ? AppTheme.primary : AppTheme.secondary).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder((missingIngredients.isEmpty ? AppTheme.primary : AppTheme.secondary).opacity(0.25), lineWidth: 1)
        )
    }

    private var equipmentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "fork.knife")
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Text("Get these out")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
            }
            FlowChips(items: plan.equipment)
            if let warning = plan.ovenWarning {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.secondary)
                    Text(warning)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Task list (prep / slow / active / assemble)

    private var taskListBody: some View {
        let tasks = plan.tasks[currentPhase] ?? []
        return VStack(spacing: 10) {
            if let now = nowAnchor {
                nowBanner(now)
            }
            if currentPhase == .slowCook {
                ForEach(plan.mergeHints, id: \.self) { hint in
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.merge")
                            .foregroundStyle(AppTheme.secondary)
                        Text(hint)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.onSurface)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(12)
                    .background(AppTheme.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            if currentPhase == .prep {
                miseEnPlaceCard
            }
            ForEach(tasks) { task in
                taskRow(task)
            }
        }
    }

    /// The single most useful "do this now" hint: the soonest-ringing timer, else the first unchecked task.
    private var nowAnchor: String? {
        if let next = soonestActiveTimer {
            return "\(next.label.components(separatedBy: " · ").first ?? "A timer") rings in \(next.timeString) — keep moving on other steps."
        }
        if let firstOpen = (plan.tasks[currentPhase] ?? []).first(where: { !completedTaskIds.contains($0.id) }) {
            return "Now: \(firstOpen.recipeName) — \(firstOpen.title.lowercased())."
        }
        return nil
    }

    private func nowBanner(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.right.circle.fill")
                .foregroundStyle(currentPhase.accent)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.onSurface)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(12)
        .background(currentPhase.accent.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func taskRow(_ task: PhaseTask) -> some View {
        let done = completedTaskIds.contains(task.id)
        let hasTimer = timers.contains { $0.id == task.id }
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    Haptics.light()
                    if done { completedTaskIds.remove(task.id) } else { completedTaskIds.insert(task.id) }
                    persist()
                } label: {
                    Image(systemName: done ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(done ? AppTheme.primary : AppTheme.onSurfaceVariant.opacity(0.4))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(done ? "Mark step not done" : "Mark step done")
                .accessibilityHint("\(task.recipeName), \(task.title)")

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(task.recipeName.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.primary)
                            .tracking(0.5)
                        if task.portionCount > 1 {
                            Text("×\(task.portionCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(AppTheme.primary)
                                .clipShape(Capsule())
                        }
                        if task.recipeId > 0 {
                            Image(systemName: "info.circle")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.onSurfaceVariant.opacity(0.6))
                        }
                    }
                    Text(task.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(done ? AppTheme.onSurfaceVariant : AppTheme.onSurface)
                        .strikethrough(done, color: AppTheme.onSurfaceVariant)
                    Text(task.instruction)
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .fixedSize(horizontal: false, vertical: true)
                    if (task.portionCount > 1 || householdSize > 1), let scaled = scaledQtyHint(for: task) {
                        Text(scaled)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.primary)
                            .padding(.top, 1)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if task.recipeId > 0 { Haptics.light(); quickLookRecipeId = task.recipeId }
                }
                Spacer()
            }

            if let dur = task.durationSeconds, dur >= 60, !hasTimer {
                Button {
                    Haptics.light()
                    startTimer(for: task, seconds: dur)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                        Text("Start \(dur / 60) min timer")
                            .fontWeight(.medium)
                        Spacer()
                        Text(currentPhase == .slowCook ? "Runs hands-off →" : "")
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    .font(.caption)
                    .padding(10)
                    .background(AppTheme.primaryContainer.opacity(0.35))
                    .foregroundStyle(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Start \(dur / 60) minute timer for \(task.recipeName)")
            }
        }
        .padding(14)
        .background(done ? AppTheme.surface.opacity(0.5) : AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(done ? 0.7 : 1)
        .animation(.easeInOut(duration: 0.18), value: done)
    }

    /// Shows the real bigger amount of the recipe's headline ingredient for batch portions.
    private func scaledQtyHint(for task: PhaseTask) -> String? {
        guard let recipe = store.recipe(byId: task.recipeId),
              let first = recipe.ingredients.first(where: { !$0.optional && ($0.qtyText?.isEmpty == false) }),
              let qty = first.qtyText,
              let ing = store.ingredient(byId: first.ingredientId) else { return nil }
        let mult = task.portionCount * householdSize
        return "Make ×\(mult): e.g. \(QtyScaler.scale(qty, by: mult)) \(ing.canonicalName.lowercased())"
    }

    // MARK: Mise en place

    private var miseEnPlaceCard: some View {
        let items = prepIngredients
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "basket.fill")
                    .foregroundStyle(AppTheme.tertiary)
                Text("Pull everything out first")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
                Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            Text("Quantities below are already scaled for the whole week.")
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle.dashed")
                            .font(.caption)
                            .foregroundStyle(AppTheme.tertiary.opacity(0.7))
                            .padding(.top, 2)
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(spacing: 6) {
                                Text(item.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(AppTheme.onSurface)
                                if let total = item.combinedTotal {
                                    Text(total)
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(AppTheme.tertiary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 1)
                                        .background(AppTheme.tertiary.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                            // Show the per-dish breakdown only when there's more than one dish.
                            if item.contributions.count > 1 {
                                Text(item.qtyLabel)
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                                    .fixedSize(horizontal: false, vertical: true)
                            } else if item.combinedTotal == nil {
                                Text(item.qtyLabel)
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        Spacer()
                    }
                    .padding(.vertical, 7)
                    if idx < items.count - 1 { Divider().opacity(0.4) }
                }
            }
        }
        .padding(16)
        .background(AppTheme.tertiary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.tertiary.opacity(0.25), lineWidth: 1)
        )
    }

    private var prepIngredients: [PrepIngredient] {
        var order: [Int64] = []
        var contrib: [Int64: [(dish: String, qty: String)]] = [:]
        for group in activeGroups {
            for ing in group.recipe.ingredients where !ing.optional {
                if contrib[ing.ingredientId] == nil { order.append(ing.ingredientId) }
                let scaled = QtyScaler.scale(ing.qtyText ?? "", by: group.portionCount * householdSize)
                contrib[ing.ingredientId, default: []].append((dish: group.recipe.name, qty: scaled))
            }
        }
        return order.map { id in
            let ingredient = store.ingredient(byId: id)
            return PrepIngredient(
                id: id,
                name: ingredient?.canonicalName ?? "Ingredient",
                category: ingredient?.category ?? "Other",
                contributions: contrib[id] ?? []
            )
        }
        .sorted { $0.category < $1.category }
    }

    /// Recipe ids whose required ingredients aren't all in the pantry.
    private var dishesMissingIngredients: Set<Int64> {
        let pantry = Set(store.pantryItems.map(\.ingredientId))
        var result = Set<Int64>()
        for group in activeGroups {
            if group.recipe.ingredients.contains(where: { !$0.optional && !pantry.contains($0.ingredientId) }) {
                result.insert(group.recipe.id)
            }
        }
        return result
    }

    private var missingIngredients: [(id: Int64, name: String, onList: Bool)] {
        let pantry = Set(store.pantryItems.map(\.ingredientId))
        let onGroceryList = Set(store.groceryItems.map(\.ingredientId))
        var seen = Set<Int64>()
        var result: [(id: Int64, name: String, onList: Bool)] = []
        for group in activeGroups {
            for ing in group.recipe.ingredients where !ing.optional && !pantry.contains(ing.ingredientId) && !seen.contains(ing.ingredientId) {
                seen.insert(ing.ingredientId)
                result.append((
                    id: ing.ingredientId,
                    name: store.ingredient(byId: ing.ingredientId)?.canonicalName ?? "Ingredient",
                    onList: onGroceryList.contains(ing.ingredientId)
                ))
            }
        }
        return result
    }

    // MARK: Store / freeze phase

    private var storeBody: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(AppTheme.tertiary)
                Text("Let everything cool before sealing — warm food in a sealed container spoils faster. Label each container with its name and today's date.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Spacer()
            }
            .padding(12)
            .background(AppTheme.tertiary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            ForEach(plan.storage) { plan in
                storageCard(plan)
            }

            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(AppTheme.primary)
                Text("That's the whole week cooked. Open each recipe and tap \"Log as eaten\" on the day you have it.")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
            }
            .padding(12)
            .background(AppTheme.primaryContainer.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func storageCard(_ plan: StoragePlan) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(plan.recipeName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
                Text("\(plan.portionCount) container\(plan.portionCount == 1 ? "" : "s")")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.tertiary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.tertiary.opacity(0.15))
                    .clipShape(Capsule())
            }

            storageLine("square.split.2x2", householdSize > 1
                ? "Split into \(plan.portionCount) container\(plan.portionCount == 1 ? "" : "s") (each feeds \(householdSize)), label \"\(plan.recipeName)\"."
                : "Split into \(plan.portionCount) portion\(plan.portionCount == 1 ? "" : "s"), label each \"\(plan.recipeName)\".")
            if plan.caloriesPerPortion > 0 {
                storageLine("flame.circle", "Per serving: ~\(plan.caloriesPerPortion) kcal · \(plan.proteinPerPortion)g protein.")
            }
            if !plan.fridgeDays.isEmpty {
                storageLine("refrigerator", "Fridge: eat on \(scheduleLabel(plan.fridgeDays)).")
            }
            if !plan.freezerDays.isEmpty {
                storageLine("snowflake", "Freeze: thaw overnight, eat on \(scheduleLabel(plan.freezerDays)).")
            }
            storageLine("microwave", reheatTip(for: plan.recipeName))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private func storageLine(_ icon: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppTheme.tertiary)
                .frame(width: 16)
            Text(text)
                .font(.caption)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private func scheduleLabel(_ days: [String]) -> String {
        days.map { dayName in
            guard let date = upcomingDate(for: dayName) else { return dayName }
            let fmt = DateFormatter()
            fmt.dateFormat = "EEE d"
            return fmt.string(from: date)
        }.joined(separator: ", ")
    }

    private func upcomingDate(for dayName: String) -> Date? {
        let names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        guard let weekday = names.firstIndex(of: dayName).map({ $0 + 1 }) else { return nil }
        return Calendar.current.nextDate(after: Date().addingTimeInterval(-1), matching: DateComponents(weekday: weekday), matchingPolicy: .nextTimePreservingSmallerComponents)
    }

    private func reheatTip(for name: String) -> String {
        let n = name.lowercased()
        if n.contains("soup") || n.contains("stew") || n.contains("chili") || n.contains("curry") || n.contains("broth") {
            return "Reheat: stovetop over medium until steaming, ~5 min."
        }
        if n.contains("salad") || n.contains("wrap") || n.contains("overnight") || n.contains("smoothie") {
            return "Eat cold — no reheating needed."
        }
        if n.contains("bake") || n.contains("roast") || n.contains("casserole") || n.contains("crust") {
            return "Reheat: oven at 350°F / 175°C for ~10 min to keep it crisp."
        }
        return "Reheat: microwave 2–3 min, stirring halfway, until hot."
    }

    // MARK: Logic

    private func buildPlan() {
        guard plan.storage.isEmpty else { return } // first build only
        rebuildPlan()

        // Restore a saved/in-progress session.
        if let r = resume {
            phaseIndex = min(r.phaseIndex, phases.count - 1)
            completedTaskIds = Set(r.completedTaskIds)
            firedTimerIds = Set(r.firedTimerIds)
            timers = r.timers.map {
                SessionTimer(id: $0.taskId, label: $0.label, totalSeconds: $0.totalSeconds, endEpoch: $0.endEpoch, stopped: $0.stopped, pausedRemaining: $0.pausedRemaining)
            }
            // A timer that already finished while we were away shouldn't re-ring.
            for t in timers where t.isFinished { firedTimerIds.insert(t.id) }
        }
    }

    /// Recomputes the plan from the currently-active dishes (after exclusions). Safe to call repeatedly.
    private func rebuildPlan() {
        plan = MealPrepPlanner.build(from: activeGroups, household: householdSize)
        var ordered: [CookPhaseKind] = [.gamePlan]
        for p in [CookPhaseKind.prep, .slowCook, .activeCook, .assemble] where !(plan.tasks[p] ?? []).isEmpty {
            ordered.append(p)
        }
        if hasCookWork { ordered.append(.store) } // nothing to portion/freeze if there's no cooking
        phases = ordered
        phaseIndex = min(phaseIndex, phases.count - 1)
    }

    /// Whether this session has any real cooking (vs. an all-make-fresh week).
    private var hasCookWork: Bool { !plan.storage.isEmpty }

    private func startTimer(for task: PhaseTask, seconds: Int) {
        let timer = SessionTimer(
            id: task.id,
            label: "\(task.recipeName) · \(task.title)",
            totalSeconds: seconds,
            endEpoch: Date().timeIntervalSince1970 + Double(seconds)
        )
        timers.append(timer)
        MealPrepTimerNotifier.schedule(taskId: task.id, label: timer.label, fireAfter: seconds)
        persist()
    }

    private func addCustomTimer(label: String, minutes: Int) {
        let secs = max(60, minutes * 60)
        let id = "custom-\(UUID().uuidString)"
        let name = label.trimmingCharacters(in: .whitespaces).isEmpty ? "Timer" : label
        timers.append(SessionTimer(id: id, label: name, totalSeconds: secs, endEpoch: Date().timeIntervalSince1970 + Double(secs)))
        MealPrepTimerNotifier.schedule(taskId: id, label: name, fireAfter: secs)
        persist()
    }

    private func togglePause(_ t: SessionTimer) {
        guard let idx = timers.firstIndex(where: { $0.id == t.id }) else { return }
        if timers[idx].isPaused {
            // Resume: re-anchor end time and reschedule the notification.
            let remaining = timers[idx].pausedRemaining ?? 0
            timers[idx].pausedRemaining = nil
            timers[idx].endEpoch = Date().timeIntervalSince1970 + Double(remaining)
            MealPrepTimerNotifier.schedule(taskId: t.id, label: timers[idx].label, fireAfter: remaining)
        } else {
            // Pause: freeze remaining, cancel the pending notification.
            timers[idx].pausedRemaining = timers[idx].remainingSeconds
            MealPrepTimerNotifier.cancel(taskId: t.id)
        }
        persist()
    }

    private func adjustTimer(_ t: SessionTimer, by deltaSeconds: Int) {
        guard let idx = timers.firstIndex(where: { $0.id == t.id }) else { return }
        if timers[idx].isPaused {
            timers[idx].pausedRemaining = max(0, (timers[idx].pausedRemaining ?? 0) + deltaSeconds)
        } else {
            let newRemaining = max(0, timers[idx].remainingSeconds + deltaSeconds)
            timers[idx].endEpoch = Date().timeIntervalSince1970 + Double(newRemaining)
            MealPrepTimerNotifier.cancel(taskId: t.id)
            MealPrepTimerNotifier.schedule(taskId: t.id, label: timers[idx].label, fireAfter: newRemaining)
        }
        timers[idx].totalSeconds = max(timers[idx].totalSeconds + deltaSeconds, timers[idx].remainingSeconds)
        firedTimerIds.remove(t.id) // it can ring again
        persist()
    }

    private func attemptNextPhase() {
        // All-make-fresh week: nothing to cook — skip the celebration and go to the ingredient check.
        if currentPhase == .gamePlan && !hasCookWork { onComplete(); return }
        if isLastPhase { finish(); return }
        // Gate: warn if the current checklist phase has unchecked items.
        let tasks = plan.tasks[currentPhase] ?? []
        let allDone = tasks.allSatisfy { completedTaskIds.contains($0.id) }
        if !tasks.isEmpty && !allDone {
            showSkipAlert = true
        } else {
            goNext()
        }
    }

    private func goNext() {
        // Start the live session clock the moment we leave the game plan.
        if currentPhase == .gamePlan && sessionStartEpoch == nil {
            sessionStartEpoch = Date().timeIntervalSince1970
        }
        Haptics.light()
        withAnimation(.easeInOut(duration: 0.25)) { phaseIndex += 1 }
        AnalyticsHelper.trackFeatureUsed("mealprep_phase_reached", details: ["phase": String(describing: currentPhase)])
        persist()
    }

    private func prevPhase() {
        if phaseIndex == 0 { onBack(); return }
        Haptics.light()
        withAnimation(.easeInOut(duration: 0.25)) { phaseIndex -= 1 }
        persist()
    }

    private func finish() {
        // Default the "set as my plan" toggle on, unless a *different* plan already exists (don't clobber silently).
        if let existing = store.currentPlan?.templateId, existing != templateId {
            setAsPlan = false
        } else {
            setAsPlan = true
        }
        Haptics.success()
        withAnimation(.easeInOut(duration: 0.25)) { showCompletion = true }
    }

    /// Called from the completion overlay's "Finish" button — records everything, then exits.
    private func confirmCompletion() {
        timers.forEach { MealPrepTimerNotifier.cancel(taskId: $0.id) }
        MealPrepSessionStore.clear()
        if setAsPlan, let template = store.mealPlanTemplates.first(where: { $0.id == templateId }) {
            store.applyTemplate(template)
        }
        // Save a lightweight "what's stored" summary other screens can read later.
        let stash = plan.storage.map { "\($0.recipeName) ×\($0.portionCount)" }
        UserDefaults.standard.set(stash, forKey: "smartcart_mealprep_last_stash")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "smartcart_mealprep_last_completed")
        MealPrepStatusModel.shared.refresh()
        AnalyticsHelper.trackFeatureUsed("mealprep_session_completed", details: [
            "dishes": plan.storage.count,
            "meals": plan.storage.reduce(0) { $0 + $1.portionCount },
            "household": householdSize,
            "set_as_plan": setAsPlan
        ])
        onComplete()
    }

    private func persist() {
        let session = SavedMealPrepSession(
            templateId: templateId,
            selectedRecipeIds: groups.map(\.recipe.id),
            phaseIndex: phaseIndex,
            completedTaskIds: Array(completedTaskIds),
            timers: timers.map { SavedTimer(taskId: $0.id, label: $0.label, totalSeconds: $0.totalSeconds, endEpoch: $0.endEpoch, stopped: $0.stopped, pausedRemaining: $0.pausedRemaining) },
            savedAtEpoch: Date().timeIntervalSince1970,
            firedTimerIds: Array(firedTimerIds)
        )
        MealPrepSessionStore.save(session)
        MealPrepStatusModel.shared.refresh()
    }

    // MARK: Timer finish detection + notifications

    private func detectFinishedTimers() {
        for t in timers where t.isFinished && !t.stopped && !firedTimerIds.contains(t.id) {
            firedTimerIds.insert(t.id)
            AudioServicesPlaySystemSound(1005) // alert tone
            Haptics.success()
            withAnimation(.easeInOut(duration: 0.2)) { ringingTimer = t }
        }
    }

    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let nowAuthorized = settings.authorizationStatus == .authorized
                // If the user just granted permission mid-session, schedule notifications for
                // any timers that are already running so they'll alert when backgrounded.
                if nowAuthorized && !notifAuthorized {
                    for t in timers where !t.isPaused && !t.isFinished {
                        MealPrepTimerNotifier.schedule(taskId: t.id, label: t.label, fireAfter: t.remainingSeconds)
                    }
                }
                notifAuthorized = nowAuthorized
            }
        }
    }
}

/// Wrapper so an Int64 recipe id can drive a `.sheet(item:)`.
private struct RecipeRef: Identifiable { let id: Int64 }

// MARK: - Add custom timer sheet

private struct AddTimerSheet: View {
    let onAdd: (String, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var label = ""
    @State private var minutes = 5
    private let presets = [1, 3, 5, 10, 15, 20, 30]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's it for?")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.onSurface)
                    TextField("e.g. Rest the meat", text: $label)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Minutes")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.onSurface)
                        Spacer()
                        Text("\(minutes) min")
                            .font(.headline)
                            .foregroundStyle(AppTheme.primary)
                    }
                    Stepper("", value: $minutes, in: 1...180).labelsHidden()
                    HStack(spacing: 8) {
                        ForEach(presets, id: \.self) { p in
                            Button { minutes = p } label: {
                                Text("\(p)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .frame(width: 34, height: 30)
                                    .background(minutes == p ? AppTheme.primary : AppTheme.surfaceVariant)
                                    .foregroundStyle(minutes == p ? .white : AppTheme.onSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Button {
                    onAdd(label, minutes)
                } label: {
                    Text("Start timer")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(20)
            .background(AppTheme.background)
            .navigationTitle("Add a timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Simple wrapping chip row

private struct FlowChips: View {
    let items: [String]

    var body: some View {
        // Lightweight two-per-row wrap that avoids iOS-version-specific Layout APIs.
        let rows = stride(from: 0, to: items.count, by: 2).map { Array(items[$0..<min($0 + 2, items.count)]) }
        return VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { item in
                        Text(item)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.onSurface)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(AppTheme.surfaceVariant.opacity(0.7))
                            .clipShape(Capsule())
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

// MARK: - Recipe quick-look (tap a task to see the full recipe)

private struct RecipeQuickLookSheet: View {
    let recipe: Recipe
    let store: AppStore
    var onOpenInApp: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Macros
                    HStack(spacing: 10) {
                        macro("\(recipe.calories)", "kcal")
                        macro("\(recipe.protein)g", "protein")
                        macro("\(recipe.readyInMinutes)m", "time")
                        macro(recipe.difficulty, "level")
                    }

                    // Actions
                    HStack(spacing: 10) {
                        Button {
                            Haptics.light()
                            store.toggleFavorite(recipeId: recipe.id)
                            isFavorite = store.isFavorite(recipeId: recipe.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                Text(isFavorite ? "Favorited" : "Favorite")
                                    .fontWeight(.medium)
                            }
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(AppTheme.surfaceVariant)
                            .foregroundStyle(isFavorite ? AppTheme.primary : AppTheme.onSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)

                        if let open = onOpenInApp {
                            Button {
                                Haptics.light()
                                dismiss()
                                open()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up.forward.app")
                                    Text("Open recipe")
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(AppTheme.primary)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if !recipe.description.isEmpty {
                        Text(recipe.description)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.onSurface)
                        ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { _, ing in
                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 5))
                                    .foregroundStyle(AppTheme.onSurfaceVariant)
                                Text(store.ingredient(byId: ing.ingredientId)?.canonicalName ?? "Ingredient")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.onSurface)
                                if let q = ing.qtyText, !q.isEmpty {
                                    Text("· \(q)")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.onSurfaceVariant)
                                }
                                Spacer()
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Steps")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.onSurface)
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { idx, step in
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(idx + 1)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 22, height: 22)
                                    .background(AppTheme.primary)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(step.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(AppTheme.onSurface)
                                    Text(step.description)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.onSurfaceVariant)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(AppTheme.background)
            .navigationTitle(recipe.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { isFavorite = store.isFavorite(recipeId: recipe.id) }
    }

    private func macro(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Step 4: Post-Cook Check

private struct WeeklyPostCookStep: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var notificationManager: NotificationManager
    let recipes: [Recipe]
    let onDone: () -> Void

    @State private var deck: [CookingIngredientEntry] = []
    @State private var usedUpEntries: [(ingredientId: Int64, qtyText: String?)] = []
    @State private var removedCount = 0
    @State private var keptCount = 0
    @State private var isCheckComplete = false
    @State private var showSundaySheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()

            if isCheckComplete {
                completionView
            } else if deck.isEmpty {
                completionView
            } else {
                swipeView
            }
        }
        .onAppear { buildDeck() }
        .sheet(isPresented: $showSundaySheet) {
            SundayReminderSheet(
                onEnable: {
                    scheduleSundayReminder()
                    showSundaySheet = false
                    onDone()
                },
                onSkip: {
                    showSundaySheet = false
                    onDone()
                }
            )
        }
    }

    private var swipeView: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                progressHeader

                VStack(spacing: 4) {
                    Text("Still have these?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("Swipe right to keep · left if you used it up")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)

                Spacer()

                SwipeCardStack(
                    items: deck,
                    onSwipeLeft: handleUsedUp,
                    onSwipeRight: handleStillHave,
                    rightLabel: "HAVE IT",
                    leftLabel: "USED UP"
                ) { entry in
                    WeeklyIngredientCard(
                        entry: entry,
                        ingredient: store.ingredient(byId: entry.ingredientId)
                    )
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 120)
            }

            swipeHints
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
    }

    private var progressHeader: some View {
        let reviewed = keptCount + removedCount
        let total = reviewed + deck.count
        return VStack(spacing: 8) {
            HStack {
                Text("\(reviewed) of \(total) reviewed")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                Spacer()
                if removedCount > 0 {
                    Text("\(removedCount) removed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.secondary)
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.surfaceVariant)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.primary)
                        .frame(
                            width: total > 0 ? geo.size.width * CGFloat(reviewed) / CGFloat(total) : 0,
                            height: 6
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: reviewed)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(AppTheme.primary)

            VStack(spacing: 8) {
                Text("Week prepped!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                Text("You're all set. Open any recipe and tap \"Log as eaten\" when you have each meal.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            if !usedUpEntries.isEmpty {
                Button {
                    let items = usedUpEntries.map { ($0.ingredientId, $0.qtyText ?? "") }
                    store.addItemsToGroceryList(items)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.badge.plus")
                        Text("Add \(usedUpEntries.count) missing to Grocery List")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.secondary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
            }

            Button {
                notificationManager.scheduleEngagementNotifications(store: store)
                AppReviewPrompt.requestReviewIfEligible(store: store)
                showSundaySheet = true
            } label: {
                Text("Done")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    private var swipeHints: some View {
        HStack {
            HStack(spacing: 4) {
                Image(systemName: "xmark").font(.caption.weight(.bold))
                Text("Used it up").font(.caption).fontWeight(.medium)
            }
            .foregroundStyle(.red)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Color.red.opacity(0.12))
            .clipShape(Capsule())

            Spacer()
            Text("\(deck.count) left").font(.caption).foregroundStyle(AppTheme.onSurfaceVariant)
            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "checkmark").font(.caption.weight(.bold))
                Text("Still have it").font(.caption).fontWeight(.medium)
            }
            .foregroundStyle(.green)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Color.green.opacity(0.12))
            .clipShape(Capsule())
        }
    }

    private func handleUsedUp(_ entry: CookingIngredientEntry) {
        deck.removeAll { $0.id == entry.id }
        store.deletePantryItem(ingredientId: entry.ingredientId)
        usedUpEntries.append((ingredientId: entry.ingredientId, qtyText: entry.qtyText))
        removedCount += 1
        checkComplete()
    }

    private func handleStillHave(_ entry: CookingIngredientEntry) {
        deck.removeAll { $0.id == entry.id }
        keptCount += 1
        checkComplete()
    }

    private func checkComplete() {
        if deck.isEmpty {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isCheckComplete = true
            }
        }
    }

    private func buildDeck() {
        let pantryIds = Set(store.pantryItems.map(\.ingredientId))
        var seen = Set<Int64>()
        deck = recipes.flatMap { recipe in
            recipe.ingredients
                .filter { !$0.optional && pantryIds.contains($0.ingredientId) && !seen.contains($0.ingredientId) }
                .compactMap { ing -> CookingIngredientEntry? in
                    seen.insert(ing.ingredientId)
                    return CookingIngredientEntry(ingredientId: ing.ingredientId, qtyText: ing.qtyText)
                }
        }
    }

    private func scheduleSundayReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Time to batch cook! 👨‍🍳"
        content.body = "Prep your meals for the week now and save time every day."
        content.sound = .default

        var dc = DateComponents()
        dc.weekday = 1  // Sunday
        dc.hour = 15
        dc.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let request = UNNotificationRequest(
            identifier: "smartcart_sunday_batch_cook",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Ingredient Swipe Card

private struct WeeklyIngredientCard: View {
    let entry: CookingIngredientEntry
    let ingredient: Ingredient?

    private var name: String { ingredient?.canonicalName ?? "Ingredient" }
    private var category: String { ingredient?.category ?? "" }
    private var colors: (Color, Color) { categoryColors(category) }
    private var emoji: String { categoryEmoji(category) }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(LinearGradient(
                    colors: [colors.0, colors.1],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: .black.opacity(0.18), radius: 16, y: 8)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    if !category.isEmpty {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.22))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Text(emoji)
                        .font(.system(size: 60))
                        .shadow(color: .black.opacity(0.1), radius: 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text(name)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .fixedSize(horizontal: false, vertical: true)

                    if let qty = entry.qtyText, !qty.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "scalemass.fill").font(.caption)
                            Text("Used: \(qty)").font(.subheadline).fontWeight(.medium)
                        }
                        .foregroundStyle(.white.opacity(0.88))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.22))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
    }
}

// MARK: - Sunday Reminder Sheet

private struct SundayReminderSheet: View {
    let onEnable: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.primary)

            VStack(spacing: 8) {
                Text("Prep every Sunday?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.onSurface)
                Text("Get a reminder every Sunday at 3 PM to batch cook your week.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Button(action: onEnable) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                        Text("Remind me every Sunday")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)

                Button("Maybe later", action: onSkip)
                    .font(.body)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Shared helper

private func bottomBar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(spacing: 10) {
        content()
    }
    .padding(.horizontal, 24)
    .padding(.top, 12)
    .padding(.bottom, 32)
    .background(AppTheme.background)
}
