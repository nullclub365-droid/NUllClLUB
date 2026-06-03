//
//  CookingTimer.swift
//  SmartCart
//

import SwiftUI

struct CookingTimerCard: View {
    @State private var timeRemaining: Int = 0
    @State private var isRunning = false
    @State private var timer: Timer? = nil

    let recipeName: String
    let initialMinutes: Int
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cooking")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                    Text(recipeName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.onSurface)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.secondary)
            }

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.secondary.opacity(0.1))

                    VStack(spacing: 4) {
                        Text(timeString)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundStyle(timeRemaining < 60 ? AppTheme.secondary : AppTheme.primary)
                        Text("remaining")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                }
                .frame(height: 200)

                HStack(spacing: 12) {
                    Button(action: toggleTimer) {
                        HStack(spacing: 8) {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            Text(isRunning ? "Pause" : "Start")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(AppTheme.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button(action: resetTimer) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(AppTheme.surfaceVariant)
                        .foregroundStyle(AppTheme.onSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            timeRemaining = initialMinutes * 60
        }
        .onChange(of: timeRemaining) { _, newValue in
            if newValue <= 0 {
                isRunning = false
                timer?.invalidate()
                timer = nil
                sendNotification()
                onComplete()
            }
        }
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
            isRunning = false
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }
        }
    }

    private func resetTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        timeRemaining = initialMinutes * 60
    }

    private func sendNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Cooking Done! 🍳"
                content.body = "\(recipeName) is ready to serve!"
                content.sound = .default
                content.badge = NSNumber(value: 1)

                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request) { _ in }

                DispatchQueue.main.async {
                    AnalyticsHelper.trackFeatureUsed("cooking_timer_completed", details: [
                        "recipe": recipeName,
                        "duration_minutes": initialMinutes
                    ])
                }
            }
        }
    }
}

#Preview {
    CookingTimerCard(recipeName: "Grilled Salmon", initialMinutes: 25, onComplete: {})
        .padding()
        .background(AppTheme.background)
}
