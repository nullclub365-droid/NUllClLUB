# Mailchimp Setup Complete Guide 📧

**Time Required:** 30-45 minutes  
**Status:** Step-by-step walkthrough with email templates

---

## Part 1: Account Setup

### Step 1: Create Mailchimp Account

1. Go to [https://mailchimp.com/en/signup/](https://mailchimp.com/en/signup/)
2. Sign up with your email (lazaretchaava8@gmail.com)
3. Verify email
4. Create account

### Step 2: Create Audience

1. Log into Mailchimp
2. Click **Audiences** (left sidebar)
3. Click **Create Audience**
4. Fill in:
   - **Audience Name:** `SmartCart Users`
   - **Default Email Address:** lazaretchaava8@gmail.com
   - **Default From Name:** `SmartCart`
   - **Campaign Permission:** Check "Yes"
   - **GDPR & Marketing Permissions:** Check all boxes
5. Click **Save**

### Step 3: Add Custom Fields

Custom fields track user behavior for targeted emails:

1. In your `SmartCart Users` audience, click **Settings → Audience Fields & Merges**
2. Click **+ Add a Field**
3. Add these fields one by one:

| Field Name | Type | Notes |
|-----------|------|-------|
| `recipes_cooked` | Number | Trigger first cook email |
| `meal_plans_created` | Number | Trigger planning email |
| `premium_trial_started` | Date | Track trial signup |
| `premium_subscriber` | Radio (Yes/No) | Segment paying users |
| `achievement_count` | Number | Track milestones |
| `last_cook_date` | Date | Identify inactive users |
| `referral_code` | Text | Track referral source |

For each field:
1. Click **+ Add a Field**
2. Enter Field Name
3. Select Type
4. Click **Save**

---

## Part 2: Get API Key

You'll need this for Firebase Cloud Functions later.

1. Go to **Settings → API Keys** (bottom left, your name)
2. Scroll to **Your API keys**
3. Click **Create A Key**
4. Copy the key (looks like: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6-us1`)
5. **SAVE THIS** — you'll need it in 10 minutes

---

## Part 3: Email Automation Setup

### Create Automation Workflows

Mailchimp's **Automations** will send emails automatically based on triggers.

**Workflow 1: Welcome Email (Day 0)**

1. Click **Automations** (left sidebar)
2. Click **Create Automation**
3. Select **Standard** → **Next**
4. Name it: `Welcome Email`
5. Trigger: **Audience Subscribe**
6. Click **Next**
7. Select **Send Email**
8. Click **Create Email**
9. Name: `Welcome - Day 0`
10. Choose **Template** (or create from scratch)
11. Fill in these sections:

**Subject Line:** Welcome to SmartCart! 👨‍🍳

**Email Body (HTML):**
```html
<p>Hi *|FNAME|*,</p>

<p>Welcome to SmartCart! We're excited you joined us.</p>

<p>Here's what you can do:</p>
<ul>
  <li>📚 Browse 500+ healthy recipes</li>
  <li>🛒 Auto-generate smart grocery lists</li>
  <li>⏱️ Cook with built-in timers</li>
  <li>👑 Unlock premium features for meal planning</li>
</ul>

<p><strong>Get Started:</strong><br/>
<a href="smartcart://home">Open SmartCart Now</a></p>

<p>Questions? Reply to this email.</p>

<p>Happy cooking,<br/>
SmartCart Team</p>
```

12. Click **Save & Next**
13. Set timing: **Immediately after subscribe**
14. Click **Start Automation**

---

**Workflow 2: First Meal Plan Email (Day 1)**

1. **Automations → Create Automation**
2. Select **Conditional** (custom trigger)
3. Trigger: **When `meal_plans_created` is > 0**
4. Click **Next**
5. Select **Send Email**
6. Name: `First Meal Plan - Day 1`

**Subject:** Your first meal plan is ready! 🎉

**Email Body:**
```html
<p>Hi *|FNAME|*,</p>

<p>Great! You created your first meal plan in SmartCart.</p>

<p>You're just one step away from cooking:</p>
<ol>
  <li>Go to your meal plan</li>
  <li>Generate your grocery list (auto-filled with prices)</li>
  <li>Start cooking! 👨‍🍳</li>
</ol>

<p><strong>Open SmartCart:</strong><br/>
<a href="smartcart://planner">View Your Meal Plan</a></p>

<p>Pro tip: Premium users can save unlimited meal plans and meal prep in bulk.</p>

<p>SmartCart Team</p>
```

7. Set **Timing:** 1 day after trigger event
8. Click **Start Automation**

---

**Workflow 3: Recipe Discovery Email (Day 3)**

1. **Automations → Create Automation**
2. Select **Conditional**
3. Trigger: **When `recipes_cooked` is > 0**
4. Click **Next**
5. Select **Send Email**
6. Name: `Recipe Discovery - Day 3`

**Subject:** 5 recipes trending in your kitchen ⭐

**Email Body:**
```html
<p>Hi *|FNAME|*,</p>

<p>Since you cooked your first recipe, we thought you'd love these trending picks:</p>

<ul>
  <li>🥗 Mediterranean Buddha Bowl (25 min)</li>
  <li>🍝 Quick Garlic Pasta (15 min)</li>
  <li>🐔 Herb Roasted Chicken (40 min)</li>
  <li>🥑 Avocado Toast 3 Ways (5 min)</li>
  <li>🍲 Creamy Tomato Soup (20 min)</li>
</ul>

<p><strong>Browse Recipes:</strong><br/>
<a href="smartcart://recipes">See All Recipes</a></p>

<p>Happy cooking,<br/>
SmartCart Team</p>
```

7. Set **Timing:** 3 days after trigger event
8. Click **Start Automation**

---

**Workflow 4: Social Proof Email (Day 7)**

1. **Automations → Create Automation**
2. Select **Standard**
3. Trigger: **Audience Subscribe** (same for all users)
4. Click **Next**
5. Name: `Social Proof - Day 7`

**Subject:** See what 10K+ SmartCart users are cooking 👨‍🍳

**Email Body:**
```html
<p>Hi *|FNAME|*,</p>

<p>You've been with SmartCart for a week! Here's what the community is up to:</p>

<blockquote>
  <strong>"SmartCart saved me 2 hours a week on meal planning!"</strong> — Sarah M.
</blockquote>

<blockquote>
  <strong>"Love the smart grocery lists. No more wasted food."</strong> — James T.
</blockquote>

<blockquote>
  <strong>"Cooking with friends using referral codes is so fun!"</strong> — Emma L.
</blockquote>

<p><strong>Join the community:</strong><br/>
<a href="smartcart://home">Open SmartCart</a></p>

<p>SmartCart Team</p>
```

6. Set **Timing:** 7 days after subscribe
7. Click **Start Automation**

---

**Workflow 5: Premium Pitch Email (Day 14)**

1. **Automations → Create Automation**
2. Select **Conditional**
3. Trigger: **When `premium_subscriber` is No**
4. Click **Next**
5. Name: `Premium Pitch - Day 14`

**Subject:** Unlock meal planning superpowers (first week free)

**Email Body:**
```html
<p>Hi *|FNAME|*,</p>

<p>You've cooked *|RECIPES_COOKED|* recipes. Ready to level up?</p>

<p><strong>SmartCart Premium includes:</strong></p>
<ul>
  <li>✅ Unlimited meal plans</li>
  <li>✅ Batch meal prep (save 3+ hours/week)</li>
  <li>✅ Smart grocery aggregation (multi-store)</li>
  <li>✅ Nutrition tracking & goals</li>
  <li>✅ Recipe collections & favorites</li>
  <li>✅ Ad-free experience</li>
</ul>

<p><strong>🎁 First week free. No credit card.</strong></p>

<p><a href="smartcart://premium">Start Free Trial</a></p>

<p>Questions? Reply to this email.</p>

<p>SmartCart Team</p>
```

6. Set **Timing:** 14 days after subscribe
7. Click **Start Automation**

---

**Workflow 6: Win-Back Email (Day 30 Inactive)**

1. **Automations → Create Automation**
2. Select **Conditional**
3. Trigger: **When `last_cook_date` is more than 30 days ago**
4. Click **Next**
5. Name: `Win-Back - Day 30 Inactive`

**Subject:** We miss you! Come back for a special offer

**Email Body:**
```html
<p>Hi *|FNAME|*,</p>

<p>It's been a while since you cooked with SmartCart. We miss you! 😢</p>

<p>Here's what's new:</p>
<ul>
  <li>🆕 200+ new recipes added</li>
  <li>🎯 AI recipe recommendations based on your history</li>
  <li>👥 Friend sharing (challenge friends to cook-offs!)</li>
  <li>📱 Improved meal planning UI</li>
</ul>

<p><strong>Come back and cook:</strong><br/>
<a href="smartcart://recipes">Browse New Recipes</a></p>

<p>Still love us?<br/>
SmartCart Team</p>
```

6. Set **Timing:** Trigger when inactive >30 days
7. Click **Start Automation**

---

## Part 4: Sync Firebase to Mailchimp

### Option A: Firebase Cloud Functions (Recommended)

See **FIREBASE-CLOUD-FUNCTIONS.md** (created below) for how to automatically sync Firebase events to Mailchimp.

### Option B: Manual Zapier Integration (Easiest)

1. Go to [https://zapier.com](https://zapier.com)
2. Sign up for free account
3. Create Zap: **Firebase → Mailchimp**
4. Trigger: **Firebase Analytics Event** (e.g., `premium_purchased`)
5. Action: **Mailchimp → Update Contact**
6. Map fields:
   - Firebase `user_id` → Mailchimp email
   - Firebase `premium_purchased` → set `premium_subscriber` = Yes
7. Test the Zap
8. Turn it on

Cost: Free tier covers ~100 Zaps/month (plenty for SmartCart)

---

## Part 5: Test Email Sending

### Manual Test

1. Go to **Audience → SmartCart Users**
2. Click **Add Subscriber**
3. Add yourself: lazaretchaava8@gmail.com
4. Wait 30 seconds
5. Check your email inbox for welcome email
6. Verify it arrived with correct subject & content

### Firebase Integration Test

Once Firebase Cloud Functions are deployed:

1. Open SmartCart app
2. Create a meal plan
3. Wait 1 minute
4. Check Mailchimp: you should see `meal_plans_created` > 0
5. Day 1 automation should trigger tomorrow

---

## Verification Checklist

- [ ] Created Mailchimp account
- [ ] Created `SmartCart Users` audience
- [ ] Added 7 custom fields
- [ ] Copied API key (saved securely)
- [ ] Created 6 automation workflows
- [ ] Manual test: received welcome email
- [ ] Mailchimp dashboard shows subscriber count

---

## Next Steps

1. **Firebase Cloud Functions** (1-2 hours)
   - Deploy function to sync Firebase events to Mailchimp
   - See FIREBASE-CLOUD-FUNCTIONS.md

2. **Landing Page Deployment** (10 minutes)
   - Deploy landing-page.html to GitHub Pages
   - Add Mailchimp signup form

3. **Monitor Metrics**
   - Watch Mailchimp dashboard for email opens/clicks
   - Check Firebase Analytics for automation triggers
   - Monitor premium conversion rate

---

## Troubleshooting

### Emails not being sent?
1. Check Mailchimp → Campaigns → Automation Status (should be "Running")
2. Verify email addresses are correct in audience
3. Check spam folder (add noreply@smartcart.com to safe senders)

### Custom fields not showing?
1. Go to Audience → Settings → Audience Fields & Merges
2. Verify all 7 fields are listed
3. Wait 5 minutes after adding

### API Key not working?
1. Go to your account settings (bottom left name)
2. Click **Account** → **Extras** → **API Keys**
3. Verify key is correct (looks like: `xxxxx-us1`)
4. Don't share it publicly!

---

## Key Dates

- ✅ **Today:** Mailchimp setup complete
- 📧 **Tomorrow:** Welcome emails send automatically
- 📊 **Week 1:** Monitor open rates (goal: >20%)
- 💰 **Week 2:** Premium pitch goes out

You're 30 minutes away from automated retention! 🚀
