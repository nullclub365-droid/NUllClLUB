//
//  MultiTimerScreen.swift
//  SmartCart
//

import SwiftUI
import Combine
import FirebaseAnalytics

private let timerStorageKey = "smartcart_active_timers"

struct MultiTimerScreen: View {
    @EnvironmentObject var store: AppStore
    var onBack: () -> Void

    @State private var timers: [CookingTimerItem] = []
    @State private var showAddTimer = false
    @State private var newTimerLabel = ""
    @State private var newTimerMinutes = "5"
    @State private var saveWorkItem: DispatchWorkItem?

    private let quickPresets = [1, 3, 5, 10, 15]

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            quickPresetsSection
            timersList
        }
        .background(AppTheme.background)
        .navigationTitle("Cooking Timers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddTimer = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.primary)
                }
                .accessibilityActionLabel("Add timer", descriptive: "Add a new cooking timer", hint: "Double tap to add a timer")
                .accessibilityTouchTarget()
            }
        }
        .sheet(isPresented: $showAddTimer) {
            addTimerSheet
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            tickTimers()
        }
        .onAppear {
            let loaded = loadPersistedTimers()
            if !loaded.isEmpty { timers = loaded }

            AnalyticsHelper.trackFeatureUsed("timers")
        }
        .onDisappear {
            savePersistedTimers()
        }
        .onChange(of: timers) { _, _ in
            scheduleSaveTimers()
        }
        .onChange(of: store.pendingTimerToAdd) { _, new in
            guard let p = new else { return }
            let mins = max(1, p.minutes)
            timers.append(CookingTimerItem(
                id: UUID(),
                label: p.label,
                totalSeconds: mins * 60,
                remainingSeconds: mins * 60,
                isRunning: true,
                isPaused: false
            ))
            store.clearPendingTimerToAdd()
        }
    }

    private func loadPersistedTimers() -> [CookingTimerItem] {
        guard let data = UserDefaults.standard.data(forKey: timerStorageKey),
              let persisted = try? JSONDecoder().decode([PersistedTimer].self, from: data) else { return [] }
        let nowMs = Int64(Date().timeIntervalSince1970 * 1000)
        return persisted.compactMap { $0.toItem(nowMs: nowMs) }
    }

    private func scheduleSaveTimers() {
        saveWorkItem?.cancel()
        let item = DispatchWorkItem { savePersistedTimers() }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: item)
    }

    private func savePersistedTimers() {
        saveWorkItem?.cancel()
        let persisted = timers.map { PersistedTimer.from($0) }
        guard let data = try? JSONEncoder().encode(persisted) else { return }
        UserDefaults.standard.set(data, forKey: timerStorageKey)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cooking Timers")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                    Text("\(timers.count) active timers")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                Spacer()
                if timers.contains(where: { $0.isRunning }) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(AppTheme.primary)
                        Text("Running")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.primary.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            if timers.contains(where: { $0.isRunning && $0.remainingSeconds > 0 }) {
                Button(action: {
                    RewardedAdHelper.showRewardedAd(
                        onReward: { skipAllTimers() },
                        onNotEarned: nil
                    )
                }) {
                    Label("Skip all timers (watch ad)", systemImage: "forward.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(AppTheme.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.secondary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
    }

    private var quickPresetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Timers")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.onSurface)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickPresets, id: \.self) { min in
                        Button(action: {
                            Haptics.light()
                            addQuickTimer(minutes: min)
                        }) {
                            Text("\(min) min")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(AppTheme.primary.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var timersList: some View {
        List {
            ForEach(timers) { timer in
                TimerRow(
                    timer: timer,
                    onPlayPause: { toggleTimer(id: timer.id) },
                    onReset: { resetTimer(id: timer.id) },
                    onDelete: { deleteTimer(id: timer.id) }
                )
            }
        }
        .listStyle(.plain)
    }

    private var addTimerSheet: some View {
        NavigationStack {
            Form {
                TextField("Label (e.g. Pasta)", text: $newTimerLabel)
                TextField("Minutes", text: $newTimerMinutes)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddTimer = false
                        newTimerLabel = ""
                        newTimerMinutes = "5"
                    }
                    .foregroundStyle(AppTheme.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Haptics.light()
                        let min = max(1, min(120, Int(newTimerMinutes) ?? 5))
                        timers.append(CookingTimerItem(
                            id: UUID(),
                            label: newTimerLabel.isEmpty ? "Timer" : newTimerLabel,
                            totalSeconds: min * 60,
                            remainingSeconds: min * 60,
                            isRunning: false,
                            isPaused: false
                        ))
                        showAddTimer = false
                        newTimerLabel = ""
                        newTimerMinutes = "5"
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }

    private func addQuickTimer(minutes: Int) {
        timers.append(CookingTimerItem(
            id: UUID(),
            label: "\(minutes) min",
            totalSeconds: minutes * 60,
            remainingSeconds: minutes * 60,
            isRunning: true,
            isPaused: false
        ))
    }

    private func tickTimers() {
        var changed = false
        for i in timers.indices {
            var t = timers[i]
            guard t.isRunning, !t.isPaused else { continue }
            if t.remainingSeconds > 0 {
                t.remainingSeconds -= 1
                timers[i] = t
                changed = true
            } else {
                t.isRunning = false
                timers[i] = t
                changed = true
                AccessibilitySettings.announce("Timer finished: \(t.label)")
            }
        }
        if changed { timers = timers }
    }

    private func toggleTimer(id: UUID) {
        guard let i = timers.firstIndex(where: { $0.id == id }) else { return }
        if timers[i].remainingSeconds <= 0 { return }
        var t = timers[i]
        t.isRunning.toggle()
        t.isPaused = !t.isRunning
        timers[i] = t
    }

    private func resetTimer(id: UUID) {
        guard let i = timers.firstIndex(where: { $0.id == id }) else { return }
        var t = timers[i]
        t.remainingSeconds = t.totalSeconds
        t.isRunning = false
        t.isPaused = false
        timers[i] = t
    }

    private func deleteTimer(id: UUID) {
        timers.removeAll { $0.id == id }
    }

    private func skipAllTimers() {
        for i in timers.indices where timers[i].isRunning {
            timers[i].remainingSeconds = 0
            timers[i].isRunning = false
        }
        Haptics.success()
    }
}

private struct TimerRow: View {
    let timer: CookingTimerItem
    let onPlayPause: () -> Void
    let onReset: () -> Void
    let onDelete: () -> Void

    private var progress: Double {
        guard timer.totalSeconds > 0 else { return 0 }
        return Double(timer.totalSeconds - timer.remainingSeconds) / Double(timer.totalSeconds)
    }

    private var timeString: String {
        let m = timer.remainingSeconds / 60
        let s = timer.remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(timer.label)
                        .font(.headline)
                        .foregroundStyle(AppTheme.onSurface)
                    Text(timeString)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(timer.remainingSeconds <= 0 ? AppTheme.primary : AppTheme.onSurface)
                }
                Spacer()
                HStack(spacing: 12) {
                    Button(action: {
                        Haptics.light()
                        onPlayPause()
                    }) {
                        Image(systemName: timer.isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.primary)
                    }
                    .disabled(timer.remainingSeconds <= 0)
                    .accessibilityActionLabel(timer.isRunning ? "Pause" : "Play", descriptive: "\(timer.isRunning ? "Pause" : "Start") \(timer.label) timer", hint: "Double tap to \(timer.isRunning ? "pause" : "start")")
                    .accessibilityTouchTarget()
                    Button(action: {
                        Haptics.light()
                        onReset()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    .accessibilityActionLabel("Reset", descriptive: "Reset \(timer.label) timer", hint: "Double tap to reset")
                    .accessibilityTouchTarget()
                    Button(action: {
                        Haptics.light()
                        onDelete()
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .accessibilityActionLabel("Delete timer", descriptive: "Delete \(timer.label) timer", hint: "Double tap to remove")
                    .accessibilityTouchTarget()
                }
            }
            ProgressView(value: progress)
                .tint(AppTheme.primary)
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        MultiTimerScreen(onBack: {})
    }
}
