//
//  RewardedAdHelper.swift
//  SmartCart
//

import UIKit
import GoogleMobileAds

/// Loads and presents a rewarded ad, then calls `onReward` when the user earns the reward.
/// Call `showRewardedAd(onReward:onNotEarned:)` from the main thread.
enum RewardedAdHelper {
    /// Presents a rewarded ad. When the user earns the reward, `onReward()` is called on the main queue.
    /// If the ad fails to load, `onNotEarned()` is called on the main queue.
    static func showRewardedAd(
        adUnitID: String = AdMobService.rewardedAdUnitID,
        onReward: @escaping () -> Void,
        onNotEarned: (() -> Void)? = nil
    ) {
        RewardedAd.load(with: adUnitID, request: Request()) { ad, _ in
            DispatchQueue.main.async {
                guard let ad = ad, let root = rootViewController else {
                    onNotEarned?()
                    return
                }
                ad.present(from: root) {
                    onReward()
                }
            }
        }
    }

    private static var rootViewController: UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              var vc = window.rootViewController else { return nil }
        while let presented = vc.presentedViewController { vc = presented }
        return vc
    }
}
