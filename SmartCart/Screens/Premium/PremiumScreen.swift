//
//  PremiumScreen.swift
//  SmartCart
//

import SwiftUI
import FirebaseAnalytics
import StoreKit

struct PremiumScreen: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var referralManager: ReferralManager
    @StateObject private var storeManager = StoreManager.shared
    var onBack: () -> Void

    @State private var isAnnual = false
    @State private var showConfirmation = false
    @State private var isPurchasing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                if referralManager.referralCode != nil && !referralManager.hasAppliedReferral {
                    referralBonusSection
                }
                toggleSection
                featuresSection
                pricingSection
                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Go Premium")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Trial Started! 🎉", isPresented: $showConfirmation) {
            Button("Done") { onBack() }
        } message: {
            let period = isAnnual ? "annual" : "monthly"
            Text("Your \(period) premium trial has started. Enjoy ad-free cooking and all premium features!")
        }
        .onAppear {
            AnalyticsHelper.trackPremiumViewed(source: "premium_screen")
        }
    }

    private var referralBonusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gift.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primary)
                Text("Referral Bonus!")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.onSurface)
                Spacer()
            }
            Text("You've been invited! Get 7 extra days free when you start your trial.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .padding(16)
        .background(AppTheme.primaryContainer.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unlock Premium")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.onSurface)
            Text("Enhance your meal planning experience with exclusive features")
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var toggleSection: some View {
        HStack(spacing: 12) {
            Text("Monthly")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(isAnnual ? AppTheme.onSurfaceVariant : AppTheme.onSurface)

            Toggle("", isOn: $isAnnual)
                .labelsHidden()

            HStack(spacing: 4) {
                Text("Annual")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isAnnual ? AppTheme.onSurface : AppTheme.onSurfaceVariant)
                Text("Save 20%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's Included")
                .font(.headline)
                .foregroundStyle(AppTheme.onSurface)

            FeatureRow(icon: "xmark.circle.fill", title: "Ad-free experience", color: AppTheme.primary)
            FeatureRow(icon: "bookmark.fill", title: "Unlimited recipe collections", color: AppTheme.secondary)
            FeatureRow(icon: "chart.bar.fill", title: "Advanced nutrition insights", color: AppTheme.tertiary)
            FeatureRow(icon: "star.fill", title: "Priority recipe recommendations", color: AppTheme.primary)
            FeatureRow(icon: "bell.fill", title: "Custom meal reminders", color: AppTheme.secondary)
            FeatureRow(icon: "export", title: "Export meal plans & grocery lists", color: AppTheme.tertiary)
        }
    }

    private var selectedProduct: Product? {
        isAnnual ? storeManager.getAnnualProduct() : storeManager.getMonthlyProduct()
    }

    private var pricingSection: some View {
        VStack(spacing: 12) {
            if let product = selectedProduct {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.displayPrice)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.onSurface)
                        Text(isAnnual ? "per year" : "per month")
                            .font(.caption)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(isAnnual ? "14-day" : "7-day")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.primary)
                        Text("free trial")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.onSurfaceVariant)
                    }
                }
                .padding(16)
                .background(AppTheme.primaryContainer.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(action: { Task { await startFreeTrial(product) } }) {
                    HStack(spacing: 8) {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "crown.fill")
                        }
                        Text(isPurchasing ? "Processing..." : "Start Free Trial")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppTheme.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(isPurchasing || storeManager.isLoading)
            } else {
                HStack {
                    ProgressView()
                        .tint(AppTheme.primary)
                    Text("Loading pricing...")
                        .foregroundStyle(AppTheme.onSurfaceVariant)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if let errorMessage = storeManager.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .padding(12)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(AppTheme.primary)
                Text("Cancel anytime. No commitment.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.onSurfaceVariant)
            }
            .padding(12)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text("By tapping Start Free Trial, you agree to our Terms of Service and Privacy Policy")
                .font(.caption2)
                .foregroundStyle(AppTheme.onSurfaceVariant)
                .padding(.top, 8)
        }
    }

    private func startFreeTrial(_ product: Product) async {
        isPurchasing = true
        let success = await storeManager.purchase(product)
        isPurchasing = false

        if success {
            referralManager.applyReferral(store: store)
            Haptics.light()
            AccessibilitySettings.announce("Premium trial started")
            showConfirmation = true
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.onSurface)
            Spacer()
        }
        .padding(12)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        PremiumScreen(onBack: {})
            .environmentObject(AppStore())
    }
}
