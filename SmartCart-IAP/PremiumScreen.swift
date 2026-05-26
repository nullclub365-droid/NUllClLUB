import SwiftUI
import StoreKit

struct PremiumScreen: View {
    @StateObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.1),
                        Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("✨ Premium")
                                .font(.system(size: 32, weight: .bold))
                            Text("Unlock all features and enhance your meal planning experience")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        // Features List
                        VStack(spacing: 16) {
                            FeatureRow(icon: "sparkles", title: "Advanced Filtering", description: "Save and organize recipes by tags and preferences")
                            FeatureRow(icon: "list.bullet.clipboard", title: "Custom Templates", description: "Create and save personalized meal plan templates")
                            FeatureRow(icon: "chart.bar", title: "Detailed Reports", description: "Access comprehensive nutrition analysis and insights")
                            FeatureRow(icon: "xmark.circle", title: "Ad-Free", description: "Enjoy the app without any advertisements")
                            FeatureRow(icon: "star", title: "Priority Support", description: "Get faster responses to your questions")
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)

                        // Pricing
                        if !storeManager.availableProducts.isEmpty {
                            VStack(spacing: 16) {
                                ForEach(storeManager.availableProducts, id: \.id) { product in
                                    PricingButton(product: product, storeManager: storeManager)
                                }
                            }
                        } else if storeManager.isLoading {
                            ProgressView()
                                .frame(height: 60)
                        }

                        // Error Message
                        if let error = storeManager.errorMessage {
                            VStack(spacing: 8) {
                                Text("⚠️ Error")
                                    .font(.headline)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }

                        // Restore Button
                        Button(action: {
                            Task {
                                await storeManager.restorePurchases()
                            }
                        }) {
                            Text("Restore Purchases")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .disabled(storeManager.isLoading)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }

                // Close Button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.3))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct PricingButton: View {
    let product: Product
    let storeManager: StoreManager

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            Task {
                let _ = await storeManager.purchase(product)
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    if let desc = product.description.split(separator: "\n").first {
                        Text(String(desc))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color(red: 0.2, green: 0.5, blue: 0.3))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(storeManager.isLoading)
        .opacity(storeManager.isLoading ? 0.6 : 1.0)
    }
}

#Preview {
    PremiumScreen()
}
