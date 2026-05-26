import Foundation
import StoreKit

enum SubscriptionStatus {
    case notSubscribed
    case subscribed
    case expired
    case unknown
}

struct SubscriptionProduct {
    let id: String
    let displayName: String
    let description: String
    let price: Decimal
    let formattedPrice: String
}

enum StoreError: LocalizedError {
    case failedVerification
    case unknown
    case userCancelled
    case networkError
    case invalidProductID

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Failed to verify purchase with Apple."
        case .unknown:
            return "An unknown error occurred."
        case .userCancelled:
            return "Purchase was cancelled."
        case .networkError:
            return "Network connection error. Please try again."
        case .invalidProductID:
            return "Product not found in App Store."
        }
    }
}
