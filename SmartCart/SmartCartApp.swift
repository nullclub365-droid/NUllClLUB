//
//  SmartCartApp.swift
//  SmartCart
//
//  Created by lazare tchaava on 02.02.26.
//

import SwiftUI
import FirebaseCore

@main
struct SmartCartApp: App {
    @AppStorage("smartcart_theme_mode") private var themeRaw: String = ThemeMode.system.rawValue
    @StateObject private var referralManager = ReferralManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var storeManager = StoreManager.shared

    init() {
        FirebaseApp.configure()
        // AdMob is initialized after ATT prompt (see ContentView)
        notificationManager.requestAuthorization()
    }

    private var colorScheme: ColorScheme? {
        switch ThemeMode(rawValue: themeRaw) ?? .system {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
                .environmentObject(referralManager)
                .environmentObject(notificationManager)
                .environmentObject(storeManager)
                .onOpenURL { url in
                    referralManager.handleDeepLink(url: url)
                }
        }
    }
}
