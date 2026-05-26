# Recipe Image Generation Guide

This script automatically generates high-quality images for recipes in the SmartCart catalog and pushes them to the `smartcart-assets` GitHub repository.

## Quick Start

### 1. Prerequisites

Make sure you have:
- ✅ `.env` file with `GEMINI_API_KEY` set
- ✅ `GITHUB_TOKEN` with repo access (for pushing to smartcart-assets)
- ✅ Dependencies installed: `npm install`

### 2. Set up .env

```bash
cp .env.example .env
# Edit .env and add:
# GEMINI_API_KEY=your_key_here
# GITHUB_TOKEN=your_token_here
```

### 3. Run Small Test Batch (Recommended First)

```bash
npm run recipes:test
```

This will:
- Generate images for 5 missing recipes
- Show you the results
- NOT push to GitHub (dry-run mode)

### 4. Run Small Batch

Once you confirm the test works:

```bash
npm run recipes
```

This will:
- Generate images for 5 missing recipes
- Save them locally
- Commit and push to GitHub automatically

### 5. Run Larger Batch

```bash
npm run recipes:batch
```

This will generate 10 images. Or specify custom size:

```bash
node recipeImageAgent.js 20
```

## Commands

```bash
# Generate 5 images (default) and push to GitHub
npm run recipes

# Generate 10 images
npm run recipes:batch

# Test with 5 images (dry-run, no GitHub push)
npm run recipes:test

# Generate custom number (e.g., 15 images)
node recipeImageAgent.js 15

# Test custom number without pushing
node recipeImageAgent.js 15 --dry-run
```

## How It Works

1. **Loads catalog** from `SmartCart/smartcart_catalog.json`
2. **Checks existing images** in `~/Desktop/smartcart-assets-renamed/`
3. **Identifies missing recipes** (recipes without images yet)
4. **Generates images** using Gemini API with the premium prompt template
5. **Saves as ID.jpg** (e.g., `100.jpg`, `101.jpg`, `102.jpg`)
6. **Commits to GitHub** with descriptive message

## Output Example

```
🍳 SmartCart Recipe Image Generation Agent

📊 Status:
  Total recipes: 415
  Existing images: 137
  Missing: 278
  Batch size: 5

🚀 Processing 5 recipes...

🎨 [100] Generating: "Chicken Broccoli Rice Bowl"
  ✓ Saved: 100.jpg (245.3 KB)

🎨 [101] Generating: "Protein Oats"
  ✓ Saved: 101.jpg (198.5 KB)

🎨 [102] Generating: "Comfort Fried Egg Rice"
  ✓ Saved: 102.jpg (267.1 KB)

🎨 [103] Generating: "Turkey Chili"
  ✓ Saved: 103.jpg (312.4 KB)

🎨 [104] Generating: "Mediterranean Quinoa Bowl"
  ✓ Saved: 104.jpg (289.7 KB)

✅ Generation Complete
  Generated: 5
  Failed: 0

📤 Pushing to GitHub...
✓ Pushed to nullclub365-droid/smartcart-assets/main
✓ Commit: abc1234
✓ URL: https://github.com/nullclub365-droid/smartcart-assets/commit/abc1234...
```

## Prompt Template

All images are generated using this consistent template (see `PROMPT_TEMPLATE.md`):

```
A high-end editorial food photograph of {DISH_NAME}, styled simply and beautifully...
```

This ensures:
- ✅ Consistent, premium aesthetic
- ✅ Apple iOS marketing style
- ✅ High-quality magazine-ready images
- ✅ Clean, minimal presentation
- ✅ Perfect for recipe cards

## Rate Limiting

With Gemini API Pro ($20/month):
- Generate ~5-10 images at a time
- Wait a few hours between batches
- Can generate all 278 images over 3-4 days comfortably

The script includes 1-second delays between API calls to avoid rate limits.

## Tracking Progress

To see which recipes already have images:

```bash
ls ~/Desktop/smartcart-assets-renamed/ | wc -l  # Count existing
node -e "const fs = require('fs'); const d = JSON.parse(fs.readFileSync('./SmartCart/smartcart_catalog.json')); console.log(d.recipes.length);" # Count total
```

## Troubleshooting

### "Missing environment variables" Error
```bash
# Ensure .env exists and is set up
cat .env | grep GEMINI_API_KEY
cat .env | grep GITHUB_TOKEN
```

### "Cannot read catalog" Error
- Ensure you're in the SmartCart directory: `pwd`
- Verify catalog exists: `ls SmartCart/smartcart_catalog.json`

### Images not uploading to GitHub
- Verify `GITHUB_TOKEN` is valid: `gh auth status`
- Check token has `repo` scope
- Verify repository exists: `https://github.com/nullclub365-droid/smartcart-assets`

### Generation seems slow
- This is normal - Gemini API takes 5-10 seconds per image
- For 5 images, expect 25-60 seconds total
- Progress is logged in real-time

## Next Steps

1. **Start with test**: `npm run recipes:test` ✓
2. **Run first batch**: `npm run recipes` ✓
3. **Check GitHub**: https://github.com/nullclub365-droid/smartcart-assets ✓
4. **Run more batches**: `node recipeImageAgent.js 20` (over multiple days) ✓
5. **Repeat** until all 278 images are generated ✓

## Tips

- **Run overnight**: Start a batch and let it run while you sleep
- **Multiple days**: No problem! Each run only generates missing images
- **Monitor API usage**: Check Google Cloud Console to track quota
- **Git history**: All commits are tracked in the GitHub repo for reference
