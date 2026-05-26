# SmartCart Mailchimp Integration Guide

## Overview
This guide sets up automated email sequences to improve retention and conversion. All sequences are triggered by user actions tracked in Firebase.

**Email Sequences:** 6 campaigns across 30 days
**Platform:** Mailchimp (free tier: up to 500 contacts)
**Delivery:** Via Mailchimp API or Zapier automation

---

## Prerequisites

1. **Mailchimp Account** (free)
   - Sign up: https://mailchimp.com
   - Create audience: "SmartCart Users"

2. **Firebase Setup** (already done)
   - Events are being tracked in Firebase Analytics
   - Need to export data or use Zapier to trigger emails

3. **Email Capture in App**
   - Add email field to onboarding (or optional profile)
   - Store in Firebase under user data

---

## Email Sequence Schedule

### Timeline: Day 0 — Day 30

| Day | Email | Goal | Trigger |
|-----|-------|------|---------|
| 0 | Welcome | Introduce app value | App installed |
| 1 | First Meal Plan | Onboard to core feature | User creates meal plan |
| 3 | Recipe Discovery | Drive engagement | Day 3 (automatic) |
| 7 | Social Proof | Encourage sharing | Day 7 or 5 recipes cooked |
| 14 | Premium Pitch | Convert to paid | Day 14 or achievement unlock |
| 30 | Win-back | Re-engage inactive | 7 days inactive |

---

## Setup Instructions

### Step 1: Create Mailchimp Account & Audience

1. Go to mailchimp.com
2. Click "Sign Up" → complete signup
3. Create new audience:
   - Name: "SmartCart Users"
   - Default from email: noreply@smartcart.app (or your email)
   - Type: Transactional

### Step 2: Get Mailchimp API Key

1. Settings → Account → Extras → API keys
2. Copy your API key (32-character string)
3. Save for later

### Step 3: Create Email List Fields

1. Audience → All Contacts → Manage Audience → Settings
2. Click "Manage contacts" → "Custom fields"
3. Add fields:
   - `recipes_cooked` (Number) - tracks cooked recipes
   - `meal_plans_created` (Number) - tracks meal plans
   - `premium_trial_started` (Date) - when trial started
   - `last_active` (Date) - last app open

### Step 4: Create Email Campaigns

Below are the 6 email templates. Copy-paste into Mailchimp.

---

## Email Templates

### Email 1: Welcome (Day 0)

**Subject:** Welcome to SmartCart 🛒 — Your Offline Meal Planner
**From:** SmartCart Team
**Trigger:** User installs app + provides email (onboarding)

```html
<p>Hi {{FNAME}},</p>

<p>Welcome to SmartCart! 🎉</p>

<p>You now have access to:</p>
<ul>
  <li>415+ recipes (all offline, no wifi needed)</li>
  <li>Smart grocery list generator</li>
  <li>Nutrition tracking</li>
  <li>No account, no sign-in</li>
</ul>

<p><strong>Next Step:</strong> Open the app and create your first meal plan. Just takes 5 minutes.</p>

<p>Questions? Reply to this email — I read every message.</p>

<p>Cook well,<br>
The SmartCart Team</p>
```

---

### Email 2: First Meal Plan (Day 1)

**Subject:** Your First Meal Plan 🍽️ — Here's What's Next
**Trigger:** User creates first meal plan
**Condition:** Only send if not received Welcome email today

```html
<p>Hi {{FNAME}},</p>

<p>Awesome! 🎉 You just created your first meal plan in SmartCart.</p>

<p>Now it's time to save on groceries. Here's what to do:</p>

<ol>
  <li><strong>Export to grocery list</strong> — Tap the list icon to see exactly what you need</li>
  <li><strong>Go shopping</strong> — Check off items as you buy them</li>
  <li><strong>Save money</strong> — No more buying food you don't need</li>
</ol>

<p><strong>Pro Tip:</strong> Share your meal plan with friends or family. They can copy it instantly.</p>

<p>Back in the app? Let's go. 👇<br>
[Open App Button]</p>
```

---

### Email 3: Recipe Discovery (Day 3)

**Subject:** 3 New Recipes Based on Your Pantry 👨‍🍳
**Trigger:** Day 3 after first meal plan OR user hasn't cooked yet
**Personalization:** Show top 3 recipes they can cook with ingredients they've added

```html
<p>Hi {{FNAME}},</p>

<p>Based on the ingredients in your pantry, we found 3 recipes you can cook *today*:</p>

<p><strong>1. Quick Stir Fry</strong> (15 min) — Chicken, vegetables, soy sauce<br>
<strong>2. Pasta Aglio e Olio</strong> (10 min) — Pasta, garlic, olive oil<br>
<strong>3. Simple Salad</strong> (5 min) — Greens, veggies, dressing</strong></p>

<p>All recipes are saved in your app. Pick one and start cooking!</p>

<p>[Open App Button]</p>

<p>Questions? We're here to help.</p>
```

---

### Email 4: Social Proof (Day 7)

**Subject:** See What 10,000+ Meal Planners Are Cooking 🏆
**Trigger:** Day 7 after install OR user achieved 5+ recipes cooked
**Goal:** Encourage sharing + premium trial sign-up

```html
<p>Hi {{FNAME}},</p>

<p>You've been using SmartCart for a week. Great choice! 👏</p>

<p><strong>What others are doing:</strong></p>
<ul>
  <li>👥 10,000+ people planning meals offline</li>
  <li>🍳 50,000+ recipes cooked this month</li>
  <li>📊 Saving $50–150/month on groceries</li>
</ul>

<p><strong>Ready to unlock premium?</strong></p>
<p>SmartCart Premium includes:</p>
<ul>
  <li>Ad-free experience</li>
  <li>Unlimited recipe collections</li>
  <li>Advanced nutrition insights</li>
</ul>

<p>Get <strong>7 days free</strong> — no credit card needed. [Start Free Trial Button]</p>

<p>Not ready for premium? No problem. Keep using SmartCart free forever.</p>
```

---

### Email 5: Premium Pitch (Day 14)

**Subject:** Unlock Premium for Just $2.99/month 💎
**Trigger:** Day 14 after install OR user unlocked achievement
**Goal:** Convert trial users + highlight achievements

```html
<p>Hi {{FNAME}},</p>

<p>You've unlocked {{ACHIEVEMENT_NAME}} in SmartCart! 🏆</p>

<p>This means you're serious about meal planning. Here's what premium users get:</p>

<table>
  <tr>
    <td>Feature</td>
    <td>Free</td>
    <td>Premium</td>
  </tr>
  <tr>
    <td>Recipes</td>
    <td>415</td>
    <td>1000+ (monthly updates)</td>
  </tr>
  <tr>
    <td>Nutrition Tracking</td>
    <td>Basic</td>
    <td>Advanced insights</td>
  </tr>
  <tr>
    <td>No Ads</td>
    <td>Limited</td>
    <td>100% ad-free</td>
  </tr>
  <tr>
    <td>Meal Collections</td>
    <td>5</td>
    <td>Unlimited</td>
  </tr>
</table>

<p><strong>Special Offer:</strong> Try premium free for 7 days.<br>
Then just $2.99/month. Cancel anytime.</p>

<p>[Start Your Free Trial Button]</p>

<p>Or stick with SmartCart free — it's already the best offline meal planner out there. 😊</p>
```

---

### Email 6: Win-Back (Day 30)

**Subject:** We Miss You! Come Back to SmartCart 🥺
**Trigger:** 7 days without app open (after Day 30)
**Goal:** Re-engage inactive users

```html
<p>Hi {{FNAME}},</p>

<p>It's been a while since you've used SmartCart. We miss you! 😢</p>

<p>While you've been away, we've added:</p>
<ul>
  <li>50+ new recipes</li>
  <li>Faster grocery list generation</li>
  <li>Better nutrition insights</li>
</ul>

<p><strong>Come back and:</strong></p>
<ol>
  <li>Plan this week's meals (5 minutes)</li>
  <li>Cook something new</li>
  <li>Save money on groceries</li>
</ol>

<p>[Open App Button]</p>

<p>P.S. — Still deciding on premium? Premium users save $50–150/month. Give it a 7-day free trial.</p>
```

---

## Implementation Methods

### Option A: Firebase → Mailchimp API (Recommended)
Uses Firebase Cloud Functions to send data to Mailchimp.

**Trigger:** Firebase event (e.g., `first_meal_plan_created`) → Cloud Function → Mailchimp API

**Steps:**
1. Get user email from Firebase authentication
2. Create Cloud Function (Node.js):
```javascript
const mailchimp = require("@mailchimp/mailchimp_marketing");

exports.sendWelcomeEmail = functions.https.onCall(async (data, context) => {
    mailchimp.setConfig({
        apiKey: "YOUR_MAILCHIMP_API_KEY",
        server: "us1" // Your server (in API key)
    });
    
    await mailchimp.lists.addListMember("AUDIENCE_ID", {
        email_address: data.email,
        status: "subscribed",
        merge_fields: {
            FNAME: data.firstName
        }
    });
    
    return { success: true };
});
```
3. Deploy to Firebase
4. Call from app when events occur

### Option B: Zapier Automation (Easier)
No-code automation platform.

**Setup:**
1. Sign up at zapier.com
2. Create Zap: Firebase → Mailchimp
3. Trigger: "Firebase event logged"
4. Action: "Mailchimp add subscriber"
5. Map fields (email, firstName, etc.)

**Cost:** Free tier allows 100 tasks/month. Paid: $29+/month

### Option C: Manual CSV Export (Simple)
Export users from Firebase, upload to Mailchimp monthly.

**Steps:**
1. Export user data from Firebase Console
2. Format as CSV with columns: email, firstName, recipesCooked
3. Upload to Mailchimp → Import Contacts
4. Create campaign manually

---

## Tracking & Analytics

### In Mailchimp Dashboard, Monitor:
- **Open Rate** — % who opened email (target: 20-30%)
- **Click Rate** — % who clicked (target: 5-10%)
- **Unsubscribe Rate** — % who unsubscribed (target: <1%)
- **Conversion Rate** — % who installed/purchased (measure in Firebase)

### Create Dashboard in Google Sheets:
Track email performance over 30 days:
```
Email | Sent | Opened | Clicked | CTR | Premium Conversions
Welcome | 500 | 125 | 45 | 9% | 8
Day 1 | 480 | 96 | 30 | 6% | 5
Day 3 | 470 | 94 | 28 | 6% | 4
```

---

## Compliance & Best Practices

### GDPR Compliance
- ✅ Only email users who opted in (in-app email field)
- ✅ Include unsubscribe link (Mailchimp does this automatically)
- ✅ Honor opt-out requests within 48 hours
- ✅ Store email securely (use Firebase Authentication)

### Email Best Practices
- ✅ Send from consistent "From" address
- ✅ Include unsubscribe link in footer
- ✅ Mobile-friendly templates
- ✅ Test on iOS Mail, Gmail, Outlook
- ✅ Avoid spam trigger words: "Free!" "Urgent" "Act now"
- ✅ Personalization: Use {{FNAME}}, {{ACHIEVEMENT_NAME}}

### A/B Testing
Test subject lines to improve open rate:
- A: "Welcome to SmartCart 🛒"
- B: "Your Offline Meal Planner Is Ready"

Compare open rates, use winner for larger audience.

---

## Expected Results (30-Day Cohort)

| Metric | Expected | Outcome |
|--------|----------|---------|
| Welcome Email Open Rate | 25% | 125 opens from 500 sends |
| Day 1 Email Click Rate | 6% | 30 clicks = "Open App" taps |
| Day 7 Premium Sign-ups | 5% | 25 premium trials from email series |
| Day 30 Win-back Engagement | 10% | 50 users re-open app |
| 30-Day Email ROI | 3:1 | $3 revenue per $1 email cost |

---

## Next Steps

1. **Week 1:** Set up Mailchimp audience + API key
2. **Week 2:** Create 6 email templates in Mailchimp
3. **Week 3:** Implement Firebase → Mailchimp integration (Option A/B)
4. **Week 4:** Monitor analytics + iterate
5. **Week 5+:** A/B test subject lines, expand sequences

---

## Resources

- Mailchimp docs: https://mailchimp.com/help
- Zapier setup: https://zapier.com/help/apps/mailchimp/
- Firebase Cloud Functions: https://firebase.google.com/docs/functions
- GDPR checklist: https://mailchimp.com/gdpr

---

**You now have a complete email retention strategy. Implement in 1-2 weeks.**
