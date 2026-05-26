# Apple In-App Purchases Setup Guide for SmartCart

## Overview

This guide walks you through integrating Apple In-App Purchases into the SmartCart iOS app using **StoreKit 2** (Apple's modern framework for in-app purchases).

**Product ID:** `com.nullclub.smartcart.premium.monthly`  
**Subscription Type:** Auto-renewing Monthly Subscription  
**Price:** $4.99/month (with $0.99 introductory offer)

---

## Part 1: App Store Connect Configuration

### Step 1: Create the Subscription Group

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select **My Apps** → **SmartCart** (ID: 6759084715)
3. Navigate to **In-App Purchases**
4. Click **+** to create a new subscription group
5. Enter:
   - **Name:** `SmartCart Premium`
   - **Reference Name:** `Premium`
   - Click **Create**

### Step 2: Create the Monthly Subscription

1. In **In-App Purchases**, click **+** and select **Auto-Renewing Subscription**
2. Fill in:
   - **Product ID:** `com.nullclub.smartcart.premium.monthly`
   - **Reference Name:** `Premium Monthly`
   - **Subscription Group:** Select "SmartCart Premium"
   - **Billing Cycle:** Monthly
   - **Price Tier:** Tier 2 ($4.99 USD)

3. Add **Localization** (English - US):
   - **Display Name:** `SmartCart Premium — Monthly`
   - **Description:** `Unlock advanced features: custom templates, detailed nutrition reports, ad-free experience, and priority support.`

4. **Optional - Add Introductory Offer:**
   - Click **+** under Introductory Offers
   - Offer Type: **Pay as you go**
   - Duration: 1 month
   - Price Tier: Tier 1 ($0.99 USD)
   - Reference: `Intro Offer`

5. Click **Save**

### Step 3: Verify Configuration

- Confirm Product ID appears in App Store Connect
- Test with StoreKit Configuration file locally (see Part 3)
- Never test with real money until ready for launch

---

## Part 2: Xcode Project Integration

### Step 1: Copy Files into Xcode Project

```
SmartCart/
├── Managers/
│   └── StoreManager.swift          ← Copy here
├── Models/
│   └── SubscriptionModels.swift    ← Copy here
├── Screens/
│   ├── PremiumScreen.swift         ← Copy here
│   └── PremiumFeature.swift        ← Copy here
└── SmartCart/
    └── SmartCartApp.swift          ← Update this file
```

### Step 2: Update SmartCartApp.swift

Add `StoreManager` as a state object:

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

### Step 3: Add StoreKit Entitlement

1. In Xcode: Select **SmartCart** project
2. Select **SmartCart** target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Search for and add **In-App Purchase**

### Step 4: Add StoreKit Configuration File

1. In Xcode, go to **File** → **New** → **File**
2. Select **StoreKit Configuration**
3. Name it: `SmartCart`
4. Copy the contents of `SmartCart.storekit` provided

---

## Part 3: Using Premium Features in Your App

### Gate Premium Features

```swift
VStack {
    Text("Advanced Recipe Filters")
    // Advanced filtering UI
}
.premiumGate(true)  // Shows lock screen if not premium
```

### Add Premium Button to Settings

```swift
struct SettingsView: View {
    @State private var showPremium = false
    
    var body: some View {
        List {
            Section {
                Button(action: { showPremium = true }) {
                    Text("Upgrade to Premium")
                        .foregroundColor(.blue)
                }
            }
        }
        .showPremiumSheet($showPremium)
    }
}
```

### Check Subscription Status

```swift
struct ContentView: View {
    @EnvironmentObject var storeManager: StoreManager
    
    var body: some View {
        VStack {
            if storeManager.isPremium {
                Text("✨ You have Premium!")
            } else {
                Text("Free Version")
            }
        }
    }
}
```

---

## Part 4: Local Testing with StoreKit Configuration

### Step 1: Enable StoreKit Configuration in Xcode

1. Go to **Product** → **Scheme** → **Edit Scheme**
2. Select **Run**
3. Go to **Options** tab
4. Set **StoreKit Configuration:** `SmartCart`
5. Click **Close**

### Step 2: Test in Simulator

1. Run the app in the simulator
2. Navigate to the Premium screen
3. Click "Subscribe" button
4. Purchase should complete immediately (simulated)
5. Check that `storeManager.isPremium` is now `true`

### Step 3: Test Purchase Flow

```
✅ Test Scenarios:
- Initial product fetch
- Purchase completion
- Premium features unlock
- Restore purchases button
- Error handling (deny purchase)
- Clear app data & restore
```

---

## Part 5: Testing with Sandbox

### Create Sandbox Account

1. Go to **App Store Connect** → **Users and Access** → **Sandbox**
2. Click **+** under **Sandbox Testers**
3. Create test account (don't use real Apple ID)
4. Note the email address

### Test on Physical Device

1. On iPhone/iPad, sign out of App Store
2. Attempt to purchase in your app
3. Sign in with Sandbox tester account
4. Complete test purchase (charged to sandbox, not real)
5. Monitor **App Store Connect** for transaction reports

### Important Notes

- Sandbox purchases are **free** in terms of real money
- Use only for testing before launch
- Never share sandbox credentials publicly
- Sandbox data doesn't affect production

---

## Part 6: App Store Connect Integration

### Before Submitting to App Store

1. ✅ Remove StoreKit Configuration file (`SmartCart.storekit`)
2. ✅ Verify Product ID matches App Store Connect
3. ✅ Test with Sandbox account on real device
4. ✅ Add Privacy Policy section about in-app purchases
5. ✅ Add screenshot showing premium features
6. ✅ Update App Description mentioning premium tier

### Privacy Compliance

- ✅ Privacy Policy updated (in this repo: `privacy-smartcart.html`)
- ✅ No subscription data sent to Firebase Analytics without user consent
- ✅ Apple handles all payment card data (you never see it)
- ✅ Users can manage subscriptions in Settings → Apple ID

---

## Part 7: Troubleshooting

### Products Not Loading

**Problem:** `storeManager.availableProducts` is empty

**Solutions:**
1. Check Product ID matches exactly in App Store Connect
2. Confirm In-App Purchase capability is enabled
3. Verify App ID allows in-app purchases
4. Try removing and re-adding the product in App Store Connect
5. Wait 15-30 minutes for App Store Connect to sync

### Purchase Fails

**Problem:** Purchase button doesn't work or shows error

**Solutions:**
1. Check internet connection
2. Verify StoreKit Configuration is active (or removed for production)
3. Ensure user is logged into App Store
4. Check `storeManager.errorMessage` for details
5. Review console logs for StoreKit errors

### Premium Status Not Persisting

**Problem:** `isPremium` reverts after app restart

**Solutions:**
1. Transaction observer should be running in `StoreManager.init()`
2. Check `checkSubscriptionStatus()` is being called
3. Verify subscription is active (not expired)
4. Try "Restore Purchases" button
5. Check that app has In-App Purchase entitlement

---

## Part 8: Deployment Checklist

Before submitting to App Store:

- [ ] All files integrated into Xcode project
- [ ] StoreKit Configuration file **removed**
- [ ] Product ID correct in code and App Store Connect
- [ ] In-App Purchase capability enabled
- [ ] Tested on physical iPhone/iPad
- [ ] Tested with Sandbox account
- [ ] Privacy Policy updated
- [ ] Screenshots show premium features
- [ ] App description mentions premium
- [ ] Error messages are user-friendly
- [ ] Restore Purchases works
- [ ] Transaction observer running at startup

---

## Part 9: Monitoring & Analytics

### Track Premium Conversions

```swift
// In StoreManager.swift, add to purchase completion:
Analytics.logEvent("premium_purchased", parameters: [
    "product_id": product.id,
    "price": product.price.stringValue
])
```

### Monitor Subscription Health

1. Go to **App Store Connect** → **Sales and Trends**
2. Review subscription renewal rates
3. Check cancellation reasons
4. Monitor upgrade/downgrade patterns

---

## References

- [Apple StoreKit 2 Documentation](https://developer.apple.com/storekit/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Testing In-App Purchases](https://developer.apple.com/documentation/storekit/setting_up_the_environment_to_test_in-app_purchases)
- [Privacy & Security Guidelines](https://developer.apple.com/app-store/review/guidelines/general/)

---

**Questions?** Review Apple's official StoreKit documentation or post on Apple Developer Forums.
