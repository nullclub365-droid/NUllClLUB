//
//  CookingTimer.swift
//  SmartCart
//

import Foundation

struct CookingTimerItem: Identifiable, Equatable {
    let id: UUID
    var label: String
    var totalSeconds: Int
    var remainingSeconds: Int
    var isRunning: Bool
    var isPaused: Bool
}

/// Persisted form for saving/loading timers (UserDefaults).
struct PersistedTimer: Codable {
    var id: String
    var label: String
    var totalSeconds: Int
    var remainingSeconds: Int
    var isRunning: Bool
    var isPaused: Bool
    var savedAtMs: Int64

    static func from(_ item: CookingTimerItem) -> PersistedTimer {
        PersistedTimer(
            id: item.id.uuidString,
            label: item.label,
            totalSeconds: item.totalSeconds,
            remainingSeconds: item.remainingSeconds,
            isRunning: item.isRunning,
            isPaused: item.isPaused,
            savedAtMs: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }

    func toItem(nowMs: Int64) -> CookingTimerItem? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        var remaining = remainingSeconds
        if isRunning, !isPaused {
            let elapsed = Int((nowMs - savedAtMs) / 1000)
            remaining = max(0, remaining - elapsed)
        }
        return CookingTimerItem(
            id: uuid,
            label: label,
            totalSeconds: totalSeconds,
            remainingSeconds: remaining,
            isRunning: isRunning && remaining > 0,
            isPaused: isPaused
        )
    }
}
