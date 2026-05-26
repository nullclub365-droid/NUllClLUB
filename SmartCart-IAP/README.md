# SmartCart Apple In-App Purchases Setup

Complete implementation files for adding Apple In-App Purchases to SmartCart iOS app.

## 📦 What's Included

### Core Files
- **`StoreManager.swift`** — Main payment manager using StoreKit 2
- **`SubscriptionModels.swift`** — Data structures and error handling
- **`PremiumScreen.swift`** — Beautiful premium subscription UI
- **`PremiumFeature.swift`** — Modifier for gating premium features
- **`SmartCart.storekit`** — StoreKit configuration for local testing

### Documentation
- **`APPLE_IAP_SETUP.md`** — Complete step-by-step integration guide
- **`AppRoute-Integration-Example.swift`** — Examples of how to use in your app
- **`README.md`** — This file

---

## 🚀 Quick Start (5 Minutes)

### 1. Copy Files into Your Xcode Project

```
SmartCart/
├── Managers/
│   └── StoreManager.swift
├── Models/
│   └── SubscriptionModels.swift
└── Screens/
    ├── PremiumScreen.swift
    └── PremiumFeature.swift
```

### 2. Update SmartCartApp.swift

```swift
import SwiftUI

@main
struct SmartCartApp: App {
    @StateObject private var storeManager = StoreManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storeManager)
        }
    }
}
```

### 3. Add In-App Purchase Capability

In Xcode:
- Select project → SmartCart target → Signing & Capabilities
- Click **+ Capability** → **In-App Purchase**

### 4. Add StoreKit Configuration (for testing)

- Copy `SmartCart.storekit` to your Xcode project
- Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration → Select `SmartCart`

### 5. Use Premium Features

```swift
// Gate a premium feature
VStack {
    Text("Advanced Filters")
}
.premiumGate(true)

// Show premium screen
@State var showPremium = false
Button("Upgrade") { showPremium = true }
    .showPremiumSheet($showPremium)
```

---

## 📋 Product Details

| Property | Value |
|----------|-------|
| **Product ID** | `com.nullclub.smartcart.premium.monthly` |
| **Price** | $4.99/month |
| **Intro Offer** | $0.99 for first month |
| **Subscription Type** | Auto-renewing monthly |
| **Group ID** | `com.nullclub.smartcart.premium` |

---

## ✨ Premium Features

Users unlock with premium subscription:
- 🔍 Advanced recipe filtering & saving
- 📋 Custom meal plan templates
- 📊 Detailed nutrition reports
- 🚫 Ad-free experience
- ⭐ Priority support

---

## 🧪 Testing

### Local Testing (Simulator)
- StoreKit Configuration automatically handles purchases
- Purchases complete instantly
- No real money involved

### Sandbox Testing (Real Device)
- Create sandbox tester account in App Store Connect
- Test on physical iPhone/iPad
- Purchases are free in sandbox mode

### Full Guide
See `APPLE_IAP_SETUP.md` for detailed testing instructions.

---

## 📱 Usage Examples

### Check if User Has Premium

```swift
@EnvironmentObject var storeManager: StoreManager

if storeManager.isPremium {
    // Show premium content
}
```

### Gate Features Behind Premium

```swift
VStack {
    Text("This is a premium feature")
}
.premiumGate(true)  // Shows lock screen if not premium
```

### Show Premium Screen

```swift
@State var showPremium = false

Button("Upgrade") { showPremium = true }
    .showPremiumSheet($showPremium)
```

### Handle Purchase Errors

```swift
if let error = storeManager.errorMessage {
    Text("Error: \(error)")
}
```

### Restore Purchases

```swift
Button("Restore Purchases") {
    Task {
        await storeManager.restorePurchases()
    }
}
```

---

## 🔧 API Reference

### StoreManager

```swift
@Published var availableProducts: [Product]  // Available subscriptions
@Published var isPremium: Bool               // Current subscription status
@Published var isLoading: Bool               // Loading state
@Published var errorMessage: String?         // Error details

func fetchProducts() async
func purchase(_ product: Product) async -> Bool
func restorePurchases() async
func checkSubscriptionStatus() async
```

### View Modifiers

```swift
.premiumGate(_ isPremiumFeature: Bool)       // Gate views behind premium
.showPremiumSheet(_ isPresented: Binding<Bool>)  // Show premium screen
```

---

## 🚨 Common Issues

### Products not loading?
- Verify Product ID matches App Store Connect exactly
- Check In-App Purchase capability is enabled
- Wait 15-30 minutes for App Store Connect to sync

### Purchases not working?
- Ensure user is logged into App Store
- Check internet connection
- Verify StoreKit Configuration is active (simulator) or removed (production)
- Review `storeManager.errorMessage` for details

### Premium status not persisting?
- Confirm transaction observer is running
- Try "Restore Purchases" button
- Check that subscription hasn't expired

See `APPLE_IAP_SETUP.md` for detailed troubleshooting.

---

## 📚 Next Steps

1. **Integration** — Follow the Quick Start above
2. **Testing** — Use `SmartCart.storekit` with simulator
3. **Setup App Store** — Follow Part 1 of `APPLE_IAP_SETUP.md`
4. **Sandbox Testing** — Test on real device (see Part 5)
5. **Launch** — Submit to App Store (see Part 6-8)

---

## 📖 Documentation

- **`APPLE_IAP_SETUP.md`** — Complete setup guide (App Store Connect + Code)
- **`AppRoute-Integration-Example.swift`** — Code examples for integration
- **Apple Docs** — [StoreKit 2](https://developer.apple.com/storekit/)

---

## ✅ Checklist for Launch

- [ ] All files copied to Xcode project
- [ ] SmartCartApp.swift updated
- [ ] In-App Purchase capability added
- [ ] Tested in simulator (with StoreKit Configuration)
- [ ] Tested with Sandbox account on real device
- [ ] Product ID created in App Store Connect
- [ ] Privacy Policy updated (already done!)
- [ ] StoreKit Configuration file **removed**
- [ ] Error handling works properly
- [ ] Ready for App Store submission

---

**Questions?** Check `APPLE_IAP_SETUP.md` for detailed explanations.
