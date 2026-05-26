//
//  PremiumFeature.swift
//  SmartCart
//

import SwiftUI

struct PremiumFeatureModifier: ViewModifier {
    @EnvironmentObject var storeManager: StoreManager
    @State private var showPremiumSheet = false

    let isPremiumFeature: Bool

    func body(content: Content) -> some View {
        if isPremiumFeature && storeManager.purchasedProductIDs.isEmpty {
            ZStack {
                content
                    .disabled(true)
                    .opacity(0.5)

                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.primary)

                    Text("Premium Feature")
                        .font(.headline)
                        .foregroundStyle(AppTheme.onSurface)

                    Text("Unlock with premium subscription")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                        .multilineTextAlignment(.center)

                    Button(action: { showPremiumSheet = true }) {
                        Text("Unlock Premium")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(AppTheme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(20)
                .frame(maxWidth: 280)
                .background(AppTheme.surface)
                .cornerRadius(12)
                .shadow(radius: 8)
            }
            .sheet(isPresented: $showPremiumSheet) {
                PremiumScreenWrapper()
            }
        } else {
            content
        }
    }
}

// Wrapper to provide environment objects to PremiumScreen
private struct PremiumScreenWrapper: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var referralManager: ReferralManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            PremiumScreen(onBack: { dismiss() })
        }
    }
}

extension View {
    func premiumGate(_ isPremiumFeature: Bool = true) -> some View {
        modifier(PremiumFeatureModifier(isPremiumFeature: isPremiumFeature))
    }
}

// Usage example:
// VStack {
//     Text("Premium content")
// }
// .premiumGate(true)
