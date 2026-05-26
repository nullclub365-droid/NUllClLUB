//
//  BannerAdView.swift
//  SmartCart
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: View {
    var body: some View {
        Group {
            if AdMobService.isSDKReady {
                BannerAdViewRepresentable()
                    .frame(height: 50)
            } else {
                Color.clear.frame(height: 50)
            }
        }
    }
}

private struct BannerAdViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdMobService.bannerAdUnitID
        banner.rootViewController = Self.rootViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    private static var rootViewController: UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              let root = window.rootViewController else { return nil }
        return root
    }
}
