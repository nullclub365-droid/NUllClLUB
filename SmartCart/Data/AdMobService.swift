//
//  AdMobService.swift
//  SmartCart
//

import Foundation
import UIKit
import GoogleMobileAds
#if DEBUG && !targetEnvironment(simulator)
import AdSupport
#endif

/// AdMob app ID is set in Info.plist as GADApplicationIdentifier.
/// Uses your real ad unit IDs so real ads (and revenue) show in Debug and Release.
enum AdMobService {
    /// Banner (Home screen).
    static let bannerAdUnitID = "ca-app-pub-8715406486268947/8791945269"

    /// Rewarded (e.g. before Generate Grocery List).
    static let rewardedAdUnitID = "ca-app-pub-8715406486268947/1645510038"

    /// Interstitial (e.g. after Log as eaten).
    static let interstitialAdUnitID = "ca-app-pub-8715406486268947/3001989589"

    /// Set to true after start(completionHandler:) runs so banner/interstitial only load when SDK is ready.
    static var isSDKReady = false

    /// Call once at app launch. Run ads-related work (e.g. preload) in completion so it runs after SDK is ready.
    static func initialize(completion: (() -> Void)? = nil) {
        let plistIds = Bundle.main.object(forInfoDictionaryKey: "GADTestDeviceIdentifiers") as? [String]
        let validIds = plistIds?.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? []
        if !validIds.isEmpty {
            MobileAds.shared.requestConfiguration.testDeviceIdentifiers = validIds
        } else {
            #if DEBUG
            print("[SmartCart] To see test ads on your iPhone: Run from Xcode, trigger an ad (e.g. open Home or Generate Grocery List), then check the Xcode console for a line with a device ID. Add that ID to Info.plist → GADTestDeviceIdentifiers. See ADS_ON_IPHONE.md.")
            #endif
        }
        MobileAds.shared.start { _ in
            DispatchQueue.main.async {
                isSDKReady = true
                #if DEBUG && !targetEnvironment(simulator)
                let id = ASIdentifierManager.shared().advertisingIdentifier
                if id.uuidString != "00000000-0000-0000-0000-000000000000" {
                    print("[SmartCart] To see test ads on THIS device, add to Info.plist → GADTestDeviceIdentifiers:")
                    print("[SmartCart]   <string>\(id.uuidString)</string>")
                } else {
                    print("[SmartCart] Allow tracking (ATT) first, then restart the app to get your test device ID for GADTestDeviceIdentifiers.")
                }
                #endif
                completion?()
            }
        }
    }
}
