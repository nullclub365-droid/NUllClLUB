//
//  InterstitialAdHelper.swift
//  SmartCart
//

import UIKit
import GoogleMobileAds

/// Loads and presents an interstitial ad, then calls `onDismiss` when the user closes it.
/// Call `preload()` after initializing ads and when appropriate so the ad is ready when the user taps.
enum InterstitialAdHelper {
    private static var cachedAd: InterstitialAd?
    /// Retain the delegate so it outlives the present() call; ad SDK holds weak reference.
    private static var currentDelegate: FullScreenContentHandler?
    /// Minimum seconds between any two interstitials (Google recommends ≥ 3 min).
    private static let minInterval: TimeInterval = 180
    private static var lastShownAt: Date?

    /// Preloads an interstitial in the background so it shows quickly when `showInterstitial` is called.
    /// Safe to call repeatedly; does nothing if an ad is already cached or loading.
    static func preload(adUnitID: String = AdMobService.interstitialAdUnitID) {
        guard cachedAd == nil else { return }
        InterstitialAd.load(with: adUnitID, request: Request()) { ad, _ in
            DispatchQueue.main.async {
                if let ad = ad {
                    cachedAd = ad
                }
            }
        }
    }

    /// Presents an interstitial. When the user closes it, `onDismiss()` is called on the main queue.
    /// If a preloaded ad is available it shows immediately; otherwise loads then shows (or calls onDismiss if load fails).
    static func showInterstitial(
        adUnitID: String = AdMobService.interstitialAdUnitID,
        onDismiss: @escaping () -> Void
    ) {
        if let ad = cachedAd {
            present(ad, onDismiss: onDismiss)
            return
        }
        InterstitialAd.load(with: adUnitID, request: Request()) { ad, _ in
            DispatchQueue.main.async {
                if let ad = ad {
                    cachedAd = ad
                    present(ad, onDismiss: onDismiss)
                } else {
                    onDismiss()
                }
            }
        }
    }

    private static func present(_ ad: InterstitialAd, onDismiss: @escaping () -> Void) {
        if let last = lastShownAt, Date().timeIntervalSince(last) < minInterval {
            onDismiss()
            return
        }
        guard let root = rootViewController else {
            onDismiss()
            return
        }
        lastShownAt = Date()
        let handler = FullScreenContentHandler(onDismiss: {
            currentDelegate = nil
            cachedAd = nil
            onDismiss()
            preload()
        })
        currentDelegate = handler
        ad.fullScreenContentDelegate = handler
        ad.present(from: root)
    }

    private static var rootViewController: UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              let root = window.rootViewController else { return nil }
        return root
    }
}

private final class FullScreenContentHandler: NSObject, FullScreenContentDelegate {
    let onDismiss: () -> Void

    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        DispatchQueue.main.async { self.onDismiss() }
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        DispatchQueue.main.async { self.onDismiss() }
    }
}
