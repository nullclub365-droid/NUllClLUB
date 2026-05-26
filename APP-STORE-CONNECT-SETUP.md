# App Store Connect Setup Guide 🚀

**Time Required:** 15-20 minutes  
**Status:** Step-by-step walkthrough for SmartCart in-app purchases

---

## Step 1: Log In to App Store Connect

1. Go to [https://appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Sign in with your Apple ID (the one used for SmartCart)
3. Click **Apps** in the sidebar
4. Select **SmartCart**

---

## Step 2: Create Subscription Group

1. In the left sidebar, go to **Monetization → Subscriptions**
2. Click **Create New** (or **+** icon)
3. Enter details:
   - **Subscription Group Name:** `Premium`
   - **Reference Name:** `smartcart_premium` (for your reference)
4. Click **Create**

You should now see a "Premium" group listed.

---

## Step 3: Create Monthly Subscription Product

1. Click **+ Add** under the "Premium" group
2. Fill in:
   - **Product ID:** `com.smartcart.premium.monthly`
   - **Reference Name:** `SmartCart Premium (Monthly)`
   - **Subscription Period:** Monthly (1 month)
   - **Free Trial:** 7 days (recommended)
3. Click the **Pricing and Availability** tab:
   - Select your **Storefronts** (all for global launch)
   - Set **Base Subscription Price:**
     - **US:** $2.99/month
     - (Apple auto-converts to other regions)
   - Set **Free Trial Duration:** 7 days
   - Check "Include free trial" checkbox
4. Click **Save**

---

## Step 4: Create Annual Subscription Product

1. Click **+ Add** under the "Premium" group again
2. Fill in:
   - **Product ID:** `com.smartcart.premium.annual`
   - **Reference Name:** `SmartCart Premium (Annual)`
   - **Subscription Period:** Annual (1 year)
   - **Free Trial:** 7 days
3. Click **Pricing and Availability**:
   - Select **Storefronts** (same as monthly)
   - Set **Base Subscription Price:**
     - **US:** $24.99/year
     - (Apple auto-converts)
   - Set **Free Trial Duration:** 7 days
   - Check "Include free trial" checkbox
4. Click **Save**

---

## Step 5: Configure Billing Retry

1. Go back to **Monetization → Subscriptions → Premium** group
2. Click **Edit** on the Premium group
3. Under **Billing Retry Settings:**
   - Enable **Retry Logic** (toggle ON)
   - Set **Retry Attempts:** 3
   - Apple will retry failed payments 3 times over 8 days
4. Click **Save**

---

## Step 6: Enable Notifications (Optional but Recommended)

1. Go to **Monetization → Subscriptions → Premium**
2. Look for **App Store Server Notifications**
3. Add your notification endpoint (if using Firebase Cloud Functions):
   - Set **Notification Type:** App Store Server Notifications v2
   - Add URL: `https://your-firebase-function-url/webhook` (you'll update this later)
4. Click **Save**

---

## Step 7: Verify in Xcode

1. Open **SmartCart.xcodeproj** in Xcode
2. Go to **Signing & Capabilities**
3. Make sure **In-App Purchase** capability is enabled
4. Check **Project Settings → Product ID:** matches `com.smartcart` in App Store Connect

---

## Step 8: Test with Sandbox Account

1. In Xcode, run the app on a device or simulator
2. Go to **Settings → Apps & iTunes → Sandbox Account**
3. Log in with a **Sandbox Tester account** (create one below)
4. On app, tap **Premium** button
5. Try purchasing monthly or annual subscription
6. You should NOT be charged real money
7. Verify in Firebase Analytics: `premium_purchased` event appears

**To create a Sandbox Tester:**
1. Go to **App Store Connect → Users & Access → Sandbox**
2. Click **+ Add** under Testers
3. Fill in details (fake email like `sandbox-tester-1@example.com`)
4. Email will be sent — click activation link
5. Use this email when testing in-app purchases

---

## Step 9: Wait for Apple Approval

⏳ **Timeline:** 1-2 hours after creation

Apple reviews subscription products. You can check status:
1. Go to **Monetization → Subscriptions → Premium**
2. Look at **Status** column next to each product
3. Status will change from "Pending Review" → "Approved"

Once approved, the product IDs are live and real purchases can happen.

---

## Step 10: Update Your Code (Already Done ✅)

Your `StoreManager.swift` already has the product IDs:
```swift
let monthlyProductId = "com.smartcart.premium.monthly"
let annualProductId = "com.smartcart.premium.annual"
```

No code changes needed!

---

## Verification Checklist

- [ ] Logged into App Store Connect
- [ ] Created "Premium" subscription group
- [ ] Created monthly product (com.smartcart.premium.monthly at $2.99)
- [ ] Created annual product (com.smartcart.premium.annual at $24.99)
- [ ] Both products have 7-day free trial
- [ ] Billing retry enabled (3 attempts)
- [ ] Status shows "Approved" for both products
- [ ] Sandbox tester account created
- [ ] Tested in-app purchase flow
- [ ] Firebase analytics shows `premium_purchased` event

---

## Troubleshooting

### Products show "Pending Review" — how long does it take?
Apple typically reviews within 1-2 hours. If longer:
- Check your internet connection
- Refresh the page
- Contact Apple Support if >24 hours

### Product ID mismatch error
If the app can't find the product IDs:
1. Verify `StoreManager.swift` has exact IDs: `com.smartcart.premium.monthly/annual`
2. Ensure product status is "Approved" in App Store Connect
3. Wait 10 minutes after approval
4. Restart the app

### In-app purchase shows "No subscription products found"
1. Check that In-App Purchase capability is enabled in Xcode
2. Verify Signing & Capabilities has "In-App Purchase" checked
3. Make sure you're using the sandbox tester account (not real Apple ID)

### Free trial isn't working in sandbox
1. Make sure the Free Trial duration is set to 7 days
2. Test with a fresh sandbox account
3. Note: Free trial testing is limited in sandbox (expires after 30 minutes of testing)

---

## Next Steps

After Apple approves (typically in 1-2 hours):

1. **Mailchimp Setup** (see MAILCHIMP-INTEGRATION-GUIDE.md)
   - Create email sequences for retention
   - Send trial expiration reminders
   - Offer win-back discounts

2. **Landing Page Deployment** (see LANDING-PAGE-DEPLOYMENT.md)
   - Deploy landing-page.html to GitHub Pages
   - Add referral tracking
   - Start promoting via social media

3. **Firebase Cloud Functions** (optional but recommended)
   - Automate email sending on purchase
   - Send expiration warnings
   - Sync subscription data to Mailchimp

4. **App Store Submission**
   - Add privacy policy (required for subscriptions)
   - Submit to App Store
   - Wait for review (typically 24-48 hours)

---

## Key Dates to Remember

- ✅ **Today:** Create product IDs
- ⏳ **In 1-2 hours:** Products approved, ready for testing
- 📅 **In 1 week:** First revenue (once live in App Store)
- 📊 **In 2 weeks:** Monitor metrics in Firebase + Mailchimp

---

## Support

**If you get stuck:**
1. Check **Status** column in App Store Connect (should show "Approved")
2. Review [Apple StoreKit2 Docs](https://developer.apple.com/storekit/)
3. Check [SmartCart's StoreManager.swift](../SmartCart/Monetization/StoreManager.swift) — already fully implemented

You're 10 minutes away from in-app purchases! 🚀
