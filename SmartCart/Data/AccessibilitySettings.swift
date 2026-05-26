//
//  AccessibilitySettings.swift
//  SmartCart
//

import Foundation
import SwiftUI
import UIKit

/// User-controllable accessibility options (Settings → Accessibility).
/// Read these when adding labels, announcements, or animations.
enum AccessibilitySettings {
    /// When true, post VoiceOver announcements for key actions (e.g. "Added to list", "Timer finished").
    static var announceActions: Bool {
        get { UserDefaults.standard.object(forKey: AccessibilitySettingsStorage.keyAnnounceActions) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: AccessibilitySettingsStorage.keyAnnounceActions) }
    }

    /// When true, use longer/more descriptive accessibility labels for screen readers.
    static var descriptiveLabels: Bool {
        get { UserDefaults.standard.object(forKey: AccessibilitySettingsStorage.keyDescriptiveLabels) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: AccessibilitySettingsStorage.keyDescriptiveLabels) }
    }

    /// When true, reduce or skip animations (e.g. cooking step transitions).
    static var reduceMotion: Bool {
        get {
            if let stored = UserDefaults.standard.object(forKey: AccessibilitySettingsStorage.keyReduceMotion) as? Bool { return stored }
            return UIAccessibility.isReduceMotionEnabled
        }
        set { UserDefaults.standard.set(newValue, forKey: AccessibilitySettingsStorage.keyReduceMotion) }
    }

    /// When true, use larger minimum tap areas (e.g. extra padding on buttons).
    static var largerTouchTargets: Bool {
        get { UserDefaults.standard.object(forKey: AccessibilitySettingsStorage.keyLargerTouchTargets) as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: AccessibilitySettingsStorage.keyLargerTouchTargets) }
    }

    /// Whether to actually reduce motion (user setting or system).
    static var shouldReduceMotion: Bool {
        reduceMotion || UIAccessibility.isReduceMotionEnabled
    }

    /// Post an announcement if "Announce actions" is on. Call from main thread.
    static func announce(_ message: String) {
        guard announceActions else { return }
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// MARK: - View helpers for consistent accessibility

extension View {
    /// Applies accessibility label (short or descriptive) and hint for buttons/controls.
    func accessibilityActionLabel(_ label: String, descriptive: String? = nil, hint: String = "Double tap to activate") -> some View {
        self
            .accessibilityLabel(AccessibilitySettings.descriptiveLabels ? (descriptive ?? label) : label)
            .accessibilityHint(hint)
    }

    /// Adds extra padding when "Larger touch areas" is on. Apply to interactive elements.
    func accessibilityTouchTarget() -> some View {
        self.padding(.all, AccessibilitySettings.largerTouchTargets ? 12 : 0)
    }
}
