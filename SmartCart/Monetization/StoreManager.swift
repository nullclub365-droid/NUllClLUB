//
//  StoreManager.swift
//  SmartCart
//

import StoreKit
import Foundation
import Combine

@MainActor
final class StoreManager: NSObject, ObservableObject {
    static let shared = StoreManager()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let productIDs = [
        "com.smartcart.premium.monthly",
        "com.smartcart.premium.annual"
    ]

    override init() {
        super.init()
        Task {
            await loadProducts()
            await updatePurchasedProducts()

            // Listen for transaction updates
            for await result in Transaction.updates {
                await handleTransactionUpdate(result)
            }
        }
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let products = try await Product.products(for: productIDs)
            self.products = products.sorted { $0.price < $1.price }
            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()

                AnalyticsHelper.trackPremiumPurchased(
                    price: NSDecimalNumber(decimal: product.price).doubleValue,
                    period: product.id.contains("annual") ? "annual" : "monthly"
                )

                return true

            case .userCancelled:
                errorMessage = "Purchase cancelled"
                return false

            case .pending:
                errorMessage = "Purchase pending - check your email"
                return false

            @unknown default:
                errorMessage = "Unknown error occurred"
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Transaction Handling

    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        do {
            let transaction = try checkVerified(result)
            await transaction.finish()
            await updatePurchasedProducts()
        } catch {
            print("Transaction verification failed: \(error)")
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.unverifiedTransaction
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Check Premium Status

    func updatePurchasedProducts() async {
        var purchasedIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)
            } catch {
                print("Error checking entitlements: \(error)")
            }
        }

        self.purchasedProductIDs = purchasedIDs
    }

    func isPremium() -> Bool {
        return !purchasedProductIDs.isEmpty
    }

    func getProduct(for id: String) -> Product? {
        return products.first { $0.id == id }
    }

    func getMonthlyProduct() -> Product? {
        return products.first { $0.id.contains("monthly") }
    }

    func getAnnualProduct() -> Product? {
        return products.first { $0.id.contains("annual") }
    }
}

enum StoreError: LocalizedError {
    case unverifiedTransaction

    var errorDescription: String? {
        switch self {
        case .unverifiedTransaction:
            return "Transaction verification failed"
        }
    }
}
