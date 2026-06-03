# SmartCart Social Media Post Generator

Use this prompt template with Claude to auto-generate posts. Copy the prompt below and fill in the bracketed sections.

---

## Master Prompt Template

```
Generate a social media post for SmartCart (meal planning & grocery app) based on these parameters:

**POST DETAILS:**
- Platform: [TikTok / Instagram Reels / YouTube Shorts / Facebook]
- Day: [DATE - e.g., June 2, 2026]
- Content Pillar: [Educational Tips / Before-After / Feature Tutorial / Community Proof / Trending Format]
- Topic: [e.g., "Meal Planner Feature", "Budget Meal Prep", "Quick Lunch Ideas"]
- Hook: [Starting line, e.g., "Stop wasting time deciding what to eat"]

**APP CONTEXT:**
- App: SmartCart (meal planning, recipe search, grocery list, nutrition tracking, achievements)
- Target Audience: Busy young adults (20-35), health-conscious, meal prep enthusiasts
- Brand Voice: Playful, educational, lifestyle-focused, relatable, practical
- Current Status: 4.96K downloads, looking to increase downloads & re-engagement
- Do NOT mention premium features (not available yet)

**OUTPUT REQUIREMENTS:**

1. **Hook:** [Attention-grabbing first line - max 12 words]

2. **Body Copy:** 
   - Platform-specific length:
     - TikTok: 150-200 characters
     - Instagram: 200-300 characters
     - YouTube Shorts: 150-200 characters
     - Facebook: 300-400 characters
   - Include: Benefit + practical angle + CTA or question
   - Tone: Conversational, no corporate speak

3. **Hashtags:** 
   - 5-7 hashtags including #SmartCartMeals
   - Mix of: niche (under 100K posts) + broad (1M+ posts)

4. **Optional Call-to-Action:**
   - Download link (if promoting the app)
   - Question to encourage comments
   - Challenge (e.g., "Try this this week")

5. **Video Description:** (1 sentence describing what the video should show)

**TONE RULES:**
- ✅ DO: Be specific with numbers ("save 3 hours", "save $200")
- ✅ DO: Use emojis (1-3 max)
- ✅ DO: End with a question or CTA
- ❌ DON'T: Use corporate jargon
- ❌ DON'T: Be salesy ("Amazing opportunity!")
- ❌ DON'T: Mention premium features

Format output as:

---
**HOOK:** [text]

**COPY:** [text]

**HASHTAGS:** #tag1 #tag2 #tag3

**CTA:** [Question or call-to-action]

**VIDEO SHOWS:** [1-sentence description of what to film]
---
```

---

## Example Uses

### Example 1: Educational Post
```
Platform: TikTok
Day: June 2
Pillar: Educational Tips
Topic: 5-Minute Meals
Hook: "5-minute meals when you're STARVING"
```

**OUTPUT:**
```
**HOOK:** 5-minute meals when you're STARVING 🔥

**COPY:** No time? No excuse. Here are 3 meals you can make in 5 minutes flat: rotisserie chicken + rice + frozen broccoli (3 min), pasta + sauce + veggies (5 min), scrambled eggs + toast + fruit (4 min). All ~400 cal, high protein, no stress.

**HASHTAGS:** #FiveMinuteMeals #EasyRecipes #BusyLifestyle #CookingHacks #FoodTok #SmartCartMeals

**CTA:** Which one are you trying TONIGHT? 👇

**VIDEO SHOWS:** Fast-paced montage of 3 meals being prepared, each under 5 minutes
```

---

### Example 2: Feature Tutorial
```
Platform: Instagram Reels
Day: June 3
Pillar: Feature Tutorial
Topic: Grocery List Smart Features
Hook: "This grocery list feature cut my shopping time in HALF"
```

**OUTPUT:**
```
**HOOK:** This grocery list feature cut my shopping time in HALF ⏱️

**COPY:** SmartCart's smart grocery list: auto-populates from your recipes, groups items by store section, syncs across devices, and tracks quantities. Result: You spend 5 mins planning, 20 mins shopping (vs. 45 mins without it). Stop writing lists on Notes app 📱

**HASHTAGS:** #GroceryListHacks #ShoppingTips #SmartCartMeals #OrganizedLife #ProductivityHacks #LifeHacks

**CTA:** What's YOUR biggest grocery shopping pain point? Drop it below! 👇

**VIDEO SHOWS:** Screen recording of SmartCart's grocery list feature showing auto-population, grouping by section, and checking off items
```

---

### Example 3: Community/Before-After
```
Platform: Facebook
Day: June 4
Pillar: Before-After Transformation
Topic: Kitchen Organization
Hook: "My kitchen before and after meal prep"
```

**OUTPUT:**
```
**HOOK:** My kitchen transformation 🔥

**COPY:** Meal prep changed my entire kitchen (and my life honestly):

BEFORE: Cluttered fridge, random containers, never know what to eat
AFTER: Labeled meal prep containers, organized by meal, grab-and-go ready, less food waste

Bonus: I save 3 hours/week AND $200/month on groceries.

Is your kitchen next? 🙌

**HASHTAGS:** #KitchenOrganization #MealPrepLife #OrganizedHome #SmartCartMeals #HomeGoals #BeforeAndAfter

**CTA:** Show us YOUR before/after in the comments! 👇

**VIDEO SHOWS:** Split-screen before/after of kitchen: cluttered → organized meal prep containers
```

---

## Quick Reference: Content Pillars

| Pillar | Best For | Tone | CTA Type |
|--------|----------|------|----------|
| **Educational** | Tips, hacks, how-to | Practical, helpful | "Try this today" |
| **Before-After** | Transformations, wins | Relatable, celebratory | "Show us yours" |
| **Feature Tutorial** | App features, how-to use | Clear, step-by-step | Question about experience |
| **Community Proof** | Testimonials, user stories | Authentic, inspired | Ask their story |
| **Trending Format** | Trending audio/format | Playful, current | Engagement question |

---

## How to Use This

1. **Pick a day from SOCIAL-CALENDAR.md**
2. **Copy the master prompt above**
3. **Fill in the bracketed sections**
4. **Paste into Claude (claude.ai or Claude Code)**
5. **Claude generates the post**
6. **Copy output → Post to platform**

---

## Pro Tips

- **Batch generate:** Create 5-7 posts at once (fill in multiple examples)
- **Customize:** Adjust tone/length per platform before posting
- **Test:** Start with 3 posts, see what performs, adjust
- **Reuse:** Save top-performing posts, regenerate similar ones

---

## Example: Batch Generation Request

Instead of one post at a time, you can do:

```
Generate 5 SmartCart social posts for these days:

1. Day 1 (June 2): Feature - Meal Planner, Hook: "Stop wasting time deciding what to eat"
2. Day 2 (June 3): Educational - Meal Prep Hack, Hook: "This meal prep hack saves me 10 hours/week"
3. Day 3 (June 4): Feature - Grocery List, Hook: "Never forget an ingredient again"
4. Day 4 (June 5): Before-After - Kitchen, Hook: "My kitchen before and after meal prep"
5. Day 5 (June 6): Feature - Nutrition, Hook: "I tracked my nutrition for 30 days and here's what happened"

Use the SmartCart Post Generation prompt template [paste template].

For each post, output:
- Hook
- Copy (Instagram Reels format, 250 chars max)
- Hashtags (7 tags)
- CTA
- Video description
```

---

**Quick Start:** Copy the Master Prompt Template above, fill in brackets for today's post, paste into Claude, get instant social content. 🚀
