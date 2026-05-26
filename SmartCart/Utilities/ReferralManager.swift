//
//  ReferralManager.swift
//  SmartCart
//

import Foundation
import Combine

@MainActor
final class ReferralManager: NSObject, ObservableObject {
    static let shared = ReferralManager()

    @Published var referralCode: String?
    @Published var referrerUserId: String?
    @Published var hasAppliedReferral = false

    private let referralCodeKey = "smartcart_referral_code"
    private let referrerUserIdKey = "smartcart_referrer_user_id"
    private let appliedReferralKey = "smartcart_applied_referral"

    override init() {
        super.init()
        loadStoredReferral()
    }

    func handleDeepLink(url: URL) -> Bool {
        guard url.scheme == "smartcart" else { return false }
        guard url.host == "referral" else { return false }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let code = components?.queryItems?.first(where: { $0.name == "code" })?.value {
            self.referralCode = code
            AnalyticsHelper.trackShareInitiated(type: "referral", content: "deep_link")
            return true
        }

        if let userId = components?.queryItems?.first(where: { $0.name == "referrer" })?.value {
            self.referrerUserId = userId
            return true
        }

        return false
    }

    func generateReferralLink(forUserId userId: String) -> String {
        return "smartcart://referral?code=\(userId)&referrer=\(userId)"
    }

    func applyReferral(store: AppStore) {
        guard !hasAppliedReferral else { return }
        guard referralCode != nil || referrerUserId != nil else { return }

        hasAppliedReferral = true
        UserDefaults.standard.set(true, forKey: appliedReferralKey)

        let referralId = referralCode ?? referrerUserId ?? "unknown"
        AnalyticsHelper.trackFeatureUsed("premium_trial_from_referral", details: [
            "referral_code": referralId
        ])
    }

    private func loadStoredReferral() {
        referralCode = UserDefaults.standard.string(forKey: referralCodeKey)
        referrerUserId = UserDefaults.standard.string(forKey: referrerUserIdKey)
        hasAppliedReferral = UserDefaults.standard.bool(forKey: appliedReferralKey)
    }

    func clearReferral() {
        referralCode = nil
        referrerUserId = nil
        UserDefaults.standard.removeObject(forKey: referralCodeKey)
        UserDefaults.standard.removeObject(forKey: referrerUserIdKey)
    }
}
