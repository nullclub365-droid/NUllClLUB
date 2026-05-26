import SwiftUI

struct PremiumFeatureModifier: ViewModifier {
    @StateObject private var storeManager = StoreManager.shared
    @State private var showPremiumSheet = false

    let isPremiumFeature: Bool

    func body(content: Content) -> some View {
        if isPremiumFeature && !storeManager.isPremium {
            ZStack {
                content
                    .disabled(true)
                    .opacity(0.5)

                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)

                    Text("Premium Feature")
                        .font(.headline)

                    Text("Upgrade to access this feature")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: { showPremiumSheet = true }) {
                        Text("Unlock Premium")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color(red: 0.2, green: 0.5, blue: 0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(20)
                .frame(maxWidth: 280)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 8)
            }
            .sheet(isPresented: $showPremiumSheet) {
                PremiumScreen()
            }
        } else {
            content
        }
    }
}

extension View {
    /// Hides content and shows premium upsell if user doesn't have premium subscription
    /// - Parameter isPremiumFeature: Set to `true` if this view should be locked behind premium
    func premiumGate(_ isPremiumFeature: Bool = true) -> some View {
        modifier(PremiumFeatureModifier(isPremiumFeature: isPremiumFeature))
    }

    /// Shows premium sheet
    func showPremiumSheet(_ isPresented: Binding<Bool>) -> some View {
        sheet(isPresented: isPresented) {
            PremiumScreen()
        }
    }
}

// Usage Examples:
/*
 // Simple premium feature gating:
 VStack {
     Text("Advanced Filters")
 }
 .premiumGate(true)

 // Conditional gating:
 VStack {
     Text("Custom Templates")
 }
 .premiumGate(!isPremium)

 // Using a button to show premium screen:
 Button("Upgrade") {
     showPremium = true
 }
 .showPremiumSheet($showPremium)
 */
