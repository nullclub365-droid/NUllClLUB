# Firebase Cloud Functions Setup 🔥

**Time Required:** 1-2 hours  
**Purpose:** Sync Firebase events to Mailchimp automatically

---

## Overview

This Cloud Function listens to Firebase Analytics events and updates Mailchimp subscriber data:

- When user cooks a recipe → increment `recipes_cooked` in Mailchimp
- When user creates meal plan → increment `meal_plans_created` in Mailchimp
- When user buys premium → set `premium_subscriber` = Yes
- When user hasn't cooked in 30 days → mark for win-back email

---

## Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
```

---

## Step 2: Initialize Firebase Functions

In your project directory:

```bash
firebase init functions
```

When prompted:
- **Which project:** Select your SmartCart Firebase project
- **Language:** TypeScript (recommended)
- **ESLint:** Yes (for code quality)

This creates:
```
functions/
├── src/
│   └── index.ts
├── package.json
└── tsconfig.json
```

---

## Step 3: Install Mailchimp SDK

```bash
cd functions
npm install @mailchimp/mailchimp_marketing
npm install firebase-admin
```

---

## Step 4: Create the Cloud Function

Replace `functions/src/index.ts` with:

```typescript
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import mailchimp from "@mailchimp/mailchimp_marketing";

admin.initializeApp();

// Initialize Mailchimp with your API key from earlier
const MAILCHIMP_API_KEY = process.env.MAILCHIMP_API_KEY || "";
const MAILCHIMP_SERVER = process.env.MAILCHIMP_SERVER || "us1";
const MAILCHIMP_AUDIENCE_ID = process.env.MAILCHIMP_AUDIENCE_ID || "";

mailchimp.setConfig({
  apiKey: MAILCHIMP_API_KEY,
  server: MAILCHIMP_SERVER,
});

// Helper to get Mailchimp subscriber hash
function getSubscriberHash(email: string): string {
  const crypto = require("crypto");
  return crypto.createHash("md5").update(email.toLowerCase()).digest("hex");
}

// Cloud Function: Listen to onUserCreate events
export const syncUserToMailchimp = functions.auth.user().onCreate(
  async (user) => {
    try {
      const email = user.email;
      if (!email) return;

      await mailchimp.lists.setListMember(
        MAILCHIMP_AUDIENCE_ID,
        getSubscriberHash(email),
        {
          email_address: email,
          status: "subscribed",
          merge_fields: {
            FNAME: user.displayName || "User",
            RECIPES_COOKED: 0,
            MEAL_PLANS: 0,
            PREMIUM: "No",
            ACHIEVEMENT: 0,
          },
        }
      );

      console.log(`Synced new user: ${email}`);
    } catch (error) {
      console.error("Error syncing user to Mailchimp:", error);
    }
  }
);

// Cloud Function: Listen to Firestore events
export const onRecipeCookedEvent = functions.firestore
  .document("users/{userId}/analytics/{eventId}")
  .onCreate(async (snap) => {
    try {
      const data = snap.data();
      const eventType = data.event_type;

      // Get user email from Firebase Auth
      const user = await admin.auth().getUser(snap.ref.parent.parent?.id || "");
      const email = user.email;

      if (!email) return;

      const subscriberHash = getSubscriberHash(email);

      // Handle different event types
      if (eventType === "recipe_cooked") {
        // Get current count from Mailchimp
        const member = await mailchimp.lists.getListMember(
          MAILCHIMP_AUDIENCE_ID,
          subscriberHash
        );

        const currentCount = member.merge_fields?.RECIPES_COOKED || 0;

        // Update Mailchimp
        await mailchimp.lists.updateListMember(
          MAILCHIMP_AUDIENCE_ID,
          subscriberHash,
          {
            merge_fields: {
              RECIPES_COOKED: currentCount + 1,
              LAST_COOK_DATE: new Date().toISOString().split("T")[0],
            },
          }
        );

        console.log(
          `Updated recipes_cooked for ${email}: ${currentCount + 1}`
        );
      }

      if (eventType === "meal_plan_created") {
        const member = await mailchimp.lists.getListMember(
          MAILCHIMP_AUDIENCE_ID,
          subscriberHash
        );

        const currentCount = member.merge_fields?.MEAL_PLANS || 0;

        await mailchimp.lists.updateListMember(
          MAILCHIMP_AUDIENCE_ID,
          subscriberHash,
          {
            merge_fields: {
              MEAL_PLANS: currentCount + 1,
            },
          }
        );

        console.log(
          `Updated meal_plans_created for ${email}: ${currentCount + 1}`
        );
      }

      if (eventType === "premium_purchased") {
        await mailchimp.lists.updateListMember(
          MAILCHIMP_AUDIENCE_ID,
          subscriberHash,
          {
            merge_fields: {
              PREMIUM: "Yes",
              PREMIUM_TRIAL_DATE: new Date().toISOString().split("T")[0],
            },
          }
        );

        console.log(`Updated premium status for ${email}`);
      }

      if (eventType === "achievement_unlocked") {
        const member = await mailchimp.lists.getListMember(
          MAILCHIMP_AUDIENCE_ID,
          subscriberHash
        );

        const currentCount = member.merge_fields?.ACHIEVEMENT || 0;

        await mailchimp.lists.updateListMember(
          MAILCHIMP_AUDIENCE_ID,
          subscriberHash,
          {
            merge_fields: {
              ACHIEVEMENT: currentCount + 1,
            },
          }
        );

        console.log(
          `Updated achievement count for ${email}: ${currentCount + 1}`
        );
      }
    } catch (error) {
      console.error("Error processing event:", error);
    }
  });

// Cloud Function: Daily scheduled job to update inactive users
export const markInactiveUsers = functions.pubsub
  .schedule("every day 02:00")
  .timeZone("America/New_York")
  .onRun(async (context) => {
    try {
      // Get all subscribers from Mailchimp
      const response = await mailchimp.lists.getListMembersInfo(
        MAILCHIMP_AUDIENCE_ID,
        { count: 1000 }
      );

      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      for (const member of response.members) {
        const lastCookDate = member.merge_fields?.LAST_COOK_DATE;

        if (lastCookDate) {
          const cookDate = new Date(lastCookDate);

          if (cookDate < thirtyDaysAgo) {
            // Mark as inactive for win-back campaign
            await mailchimp.lists.updateListMember(
              MAILCHIMP_AUDIENCE_ID,
              member.id,
              {
                tags: ["inactive_30days"],
              }
            );

            console.log(
              `Marked ${member.email_address} as inactive (last cooked: ${lastCookDate})`
            );
          }
        }
      }

      console.log("Completed daily inactive user check");
      return null;
    } catch (error) {
      console.error("Error in markInactiveUsers:", error);
      return null;
    }
  });

// REST Endpoint: Allow Mailchimp webhook to trigger automation
export const mailchimpWebhook = functions.https.onRequest(
  async (req, res) => {
    try {
      const { type, data } = req.body;

      // Validate webhook signature (optional, for security)
      if (type === "subscribe") {
        console.log(`Webhook: User subscribed: ${data.email}`);
        // You can add custom logic here
      }

      res.status(200).send("OK");
    } catch (error) {
      console.error("Webhook error:", error);
      res.status(500).send("Error");
    }
  }
);
```

---

## Step 5: Set Environment Variables

Create `functions/.env.local`:

```
MAILCHIMP_API_KEY=your_api_key_here
MAILCHIMP_SERVER=us1
MAILCHIMP_AUDIENCE_ID=your_audience_id_here
```

**How to get these:**

1. **MAILCHIMP_API_KEY:** From earlier setup
   - Mailchimp → Settings → API Keys
   - Copy the key (looks like: `a1b2c3d4...`)

2. **MAILCHIMP_SERVER:** Suffix of your API key
   - If key ends in `-us1` → use `us1`
   - If key ends in `-us2` → use `us2`
   - etc.

3. **MAILCHIMP_AUDIENCE_ID:** From Mailchimp
   - Mailchimp → Audience → Settings → Audience Name & Defaults
   - Scroll to "Audience ID"
   - Copy it (40-character alphanumeric string)

---

## Step 6: Deploy to Firebase

```bash
firebase deploy --only functions
```

**Output** will show:
```
✔ Deploy complete!

Function URL: https://us-central1-smartcart-xxxx.cloudfunctions.net/onRecipeCookedEvent
```

---

## Step 7: Verify Deployment

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your SmartCart project
3. Go to **Functions**
4. You should see 3 functions:
   - `syncUserToMailchimp` ✅
   - `onRecipeCookedEvent` ✅
   - `markInactiveUsers` ✅

---

## Step 8: Test the Flow

### Test 1: New User Sync

1. Create a new test user in your app
2. Go to Firebase → Firestore → Collections → Users
3. Verify user was created
4. Go to Mailchimp → Audience → All Contacts
5. Search for the new user's email
6. Should see them in the list with `recipes_cooked: 0`

### Test 2: Recipe Cook Event

1. Open the app (as the test user)
2. Cook a recipe
3. Firebase Analytics should log `recipe_cooked` event
4. Wait 1-2 minutes
5. Go back to Mailchimp
6. Refresh the contact → should show `recipes_cooked: 1`

### Test 3: Premium Purchase

1. Go to Premium screen
2. Tap "Start Free Trial"
3. Wait 1-2 minutes
4. Mailchimp → check contact → should show `PREMIUM: Yes`

---

## Monitoring & Logs

Check if the function is running:

```bash
firebase functions:log --follow
```

This shows real-time logs of all function executions.

**Look for:**
- `Synced new user: email@example.com` ✅
- `Updated recipes_cooked for email@example.com: 1` ✅
- `Completed daily inactive user check` ✅

---

## Pricing

Firebase Cloud Functions pricing (free tier):

- **2 Million invocations/month** — FREE
- Compute time: **400,000 GB-seconds/month** — FREE

For SmartCart:
- ~1,000 active users
- ~500 events/day = 15,000/month
- Cost: **FREE** (well under free tier)

---

## Troubleshooting

### Function deployment fails
```
Error: Could not find a rule matching the deployed service
```
**Solution:**
1. Go to Firebase Console → Functions
2. Set region to `us-central1`
3. Redeploy

### Mailchimp API errors
```
Error: API Key is invalid
```
**Solution:**
1. Copy API key from Mailchimp again
2. Update `functions/.env.local`
3. Redeploy: `firebase deploy --only functions`

### Events not syncing to Mailchimp
1. Check **firebase functions:log --follow**
2. Look for error messages
3. Verify Mailchimp AUDIENCE_ID is correct
4. Verify user email exists in Mailchimp

---

## Alternative: Use Zapier (Easier)

If Cloud Functions are too complex, use Zapier instead:

1. Go to [Zapier.com](https://zapier.com)
2. Create Zap: **Firebase Analytics → Mailchimp**
3. Trigger: When event `recipe_cooked` fires
4. Action: Update Mailchimp contact → `recipes_cooked` +1
5. Cost: ~$29/month (covers all automations)

**Zapier is simpler but less flexible.** Use Cloud Functions if you want custom logic.

---

## Next Steps

1. ✅ Deploy Cloud Functions
2. ✅ Test with a real user action
3. Watch Mailchimp for updates
4. Deploy landing page (see LANDING-PAGE-DEPLOYMENT.md)
5. Submit to App Store

---

## Support

- [Firebase Cloud Functions Docs](https://firebase.google.com/docs/functions)
- [Mailchimp API Docs](https://mailchimp.com/developer/marketing/api/)
- Check your function logs: `firebase functions:log --follow`

You're almost done! 🚀
