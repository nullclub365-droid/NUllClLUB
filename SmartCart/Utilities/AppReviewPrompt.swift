//
//  AppReviewPrompt.swift
//  SmartCart
//

import StoreKit
import Foundation

enum AppReviewPrompt {
    private static let reviewPromptCountKey = "smartcart_review_prompt_count"
    private static let reviewPromptVersionKey = "smartcart_review_prompt_version"
    private static let reviewPromptThreshold = 3

    static func requestReviewIfEligible(store: AppStore) {
        let appVersion = Bundle.main.appVersion
        let lastPromptVersion = UserDefaults.standard.string(forKey: reviewPromptVersionKey) ?? ""
        let promptCount = UserDefaults.standard.integer(forKey: reviewPromptCountKey)

        guard appVersion != lastPromptVersion else { return }
        guard promptCount < reviewPromptThreshold else { return }

        let cookedCount = store.recipeHistory.count
        guard cookedCount > 0, cookedCount % reviewPromptThreshold == 0 else { return }

        if #available(iOS 16.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }

        let newCount = promptCount + 1
        UserDefaults.standard.set(newCount, forKey: reviewPromptCountKey)
        UserDefaults.standard.set(appVersion, forKey: reviewPromptVersionKey)
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
