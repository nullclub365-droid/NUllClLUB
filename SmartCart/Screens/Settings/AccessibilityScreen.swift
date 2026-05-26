//
//  AccessibilityScreen.swift
//  SmartCart
//

import SwiftUI

struct AccessibilityScreen: View {
    @AppStorage(AccessibilitySettingsStorage.keyAnnounceActions) private var announceActions = true
    @AppStorage(AccessibilitySettingsStorage.keyDescriptiveLabels) private var descriptiveLabels = true
    @AppStorage(AccessibilitySettingsStorage.keyReduceMotion) private var reduceMotion = false
    @AppStorage(AccessibilitySettingsStorage.keyLargerTouchTargets) private var largerTouchTargets = false

    var body: some View {
        List {
            Section {
                Toggle(isOn: $announceActions) {
                    Label("Announce actions", systemImage: "speaker.wave.2")
                }
                Text("Speak confirmations when you add items to lists, finish a timer, or complete actions.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            } header: {
                Text("VoiceOver")
            }

            Section {
                Toggle(isOn: $descriptiveLabels) {
                    Label("Descriptive labels", systemImage: "textformat")
                }
                Text("Use longer, descriptive labels for buttons and controls when using a screen reader.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            } header: {
                Text("Labels")
            }

            Section {
                Toggle(isOn: $reduceMotion) {
                    Label("Reduce motion", systemImage: "hand.raised")
                }
                Text("Reduce or skip animations (e.g. when moving between cooking steps). When off, the app still follows your device's Reduce Motion setting.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            } header: {
                Text("Motion")
            }

            Section {
                Toggle(isOn: $largerTouchTargets) {
                    Label("Larger touch areas", systemImage: "hand.point.up.left")
                }
                Text("Increase minimum tap size for buttons and controls.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            } header: {
                Text("Touch")
            }
        }
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Keys used by both @AppStorage and AccessibilitySettings (UserDefaults).
enum AccessibilitySettingsStorage {
    static let keyAnnounceActions = "smartcart_accessibility_announce_actions"
    static let keyDescriptiveLabels = "smartcart_accessibility_descriptive_labels"
    static let keyReduceMotion = "smartcart_accessibility_reduce_motion"
    static let keyLargerTouchTargets = "smartcart_accessibility_larger_touch_targets"
}
