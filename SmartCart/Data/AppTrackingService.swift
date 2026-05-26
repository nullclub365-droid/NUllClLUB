//
//  AppTrackingService.swift
//  SmartCart
//

import AppTrackingTransparency
import Foundation

/// Requests App Tracking Transparency permission, then runs the given action (e.g. initialize ads).
/// Call once after app is active (e.g. from ContentView when scenePhase becomes .active).
enum AppTrackingService {
    /// Requests tracking authorization if not yet determined, then calls `onComplete()` on the main queue.
    /// Call AdMobService.initialize() in onComplete so ads are initialized after the user's choice.
    /// - Parameter onDialogShown: Optional. Called with true if the system ATT dialog was shown, false if skipped (e.g. on Simulator).
    static func requestTrackingThenPerform(
        onComplete: @escaping () -> Void,
        onDialogShown: ((Bool) -> Void)? = nil
    ) {
        func performCompletion() {
            DispatchQueue.main.async { onComplete() }
        }
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                requestTrackingThenPerform(onComplete: onComplete, onDialogShown: onDialogShown)
            }
            return
        }
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .notDetermined:
            ATTrackingManager.requestTrackingAuthorization { _ in
                onDialogShown?(true)
                performCompletion()
            }
        default:
            onDialogShown?(false)
            performCompletion()
        }
    }
}
