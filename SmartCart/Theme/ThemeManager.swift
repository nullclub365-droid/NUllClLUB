//
//  ThemeManager.swift
//  SmartCart
//

import SwiftUI

enum ThemeMode: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

struct ThemeManager {
    private static let key = "smartcart_theme_mode"

    static var current: ThemeMode {
        get {
            guard let raw = UserDefaults.standard.string(forKey: key),
                  let mode = ThemeMode(rawValue: raw) else { return .system }
            return mode
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }

    static func preferredColorScheme() -> ColorScheme? {
        switch current {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
