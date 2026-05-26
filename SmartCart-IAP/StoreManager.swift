import Foundation
import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var availableProducts: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPremium: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let productIDs = ["com.nullclub.smartcart.premium.monthly"]
    private var updateListenerTask: Task<Void, Error>? = nil

    init() {
        updateListenerTask = observeTransactionUpdates()
        Task {
            await fetchProducts()
            await checkSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    @MainActor
    private func observeTransactionUpdates() -> Task<Void, Error> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    self.purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                    await self.checkSubscriptionStatus()
                } catch {
                    self.errorMessage = StoreError.failedVerification.localizedDescription
                }
            }
        }
    }

    func fetchProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let products = try await Product.products(for: productIDs)
            self.availableProducts = products.sorted { $0.price < $1.price }
            isLoading = false
        } catch {
            errorMessage = StoreError.networkError.localizedDescription
            isLoading = false
        }
    }

    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                purchasedProductIDs.insert(transaction.productID)
                await transaction.finish()
                await checkSubscriptionStatus()
                isLoading = false
                return true

            case .userCancelled:
                errorMessage = StoreError.userCancelled.localizedDescription
                isLoading = false
                return false

            case .pending:
                isLoading = false
                return false

            @unknown default:
                errorMessage = StoreError.unknown.localizedDescription
                isLoading = false
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
            isLoading = false
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            isLoading = false
        }
    }

    @MainActor
    func checkSubscriptionStatus() async {
        var hasActivePremium = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                if productIDs.contains(transaction.productID) {
                    let isActive = !transaction.isUpgraded && !transaction.revocationDate.isPresent
                    hasActivePremium = hasActivePremium || isActive

                    if isActive {
                        purchasedProductIDs.insert(transaction.productID)
                    }
                }
            } catch {
                continue
            }
        }

        self.isPremium = hasActivePremium
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Date Extension
extension Optional where Wrapped == Date {
    var isPresent: Bool {
        switch self {
        case .some:
            return true
        case .none:
            return false
        }
    }
}
