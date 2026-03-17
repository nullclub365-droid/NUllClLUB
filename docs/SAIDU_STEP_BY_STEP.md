# Saidu — Step-by-step: Web content + app fetch

Do these in order. Each section is one phase.

---

## Phase 1: Domain and hosting (GoDaddy + GitHub)

### Step 1.1 — Buy or confirm your domain on GoDaddy
- Log in to GoDaddy → Domains.
- Either buy a new domain or note the one you’ll use (e.g. `nullclub.com` or `saidu.com`).

### Step 1.2 — Put your NULL CLUB site on GitHub
- Create a GitHub repo (e.g. `nullclub` or `nullclub-website`).
- Push your current NULL CLUB site (the folder with `index.html`, `saidu.html`, `css/`, etc.) to that repo.
- In the repo: **Settings → Pages**.
- Under “Build and deployment”, set **Source** to **Deploy from a branch**.
- Branch: `main` (or `master`), folder: **/ (root)**.
- Save. Your site will be at `https://<username>.github.io/<repo-name>/` until you add a custom domain.

### Step 1.3 — Connect GoDaddy domain to GitHub Pages
- In GitHub: same repo → **Settings → Pages**.
- Under “Custom domain”, enter your domain (e.g. `www.nullclub.com` or `nullclub.com`).
- Save. GitHub will show a note about DNS (e.g. CNAME or A records).
- In **GoDaddy**: **My Products → DNS** (or Domain settings → Manage DNS).
  - If GitHub says to add a **CNAME** for `www`: add a CNAME record: name `www`, value `\<username>.github.io`.
  - If you use the **apex** (e.g. `nullclub.com` with no www): GitHub’s instructions will list A records (IPs); add those in GoDaddy. Optionally keep a CNAME for `www` pointing to the apex or to GitHub.
- Wait 5–60 minutes (sometimes up to 48 hours). In GitHub Pages settings, click “Enforce HTTPS” when it becomes available.

### Step 1.4 — Confirm the site works
- Open `https://your-domain.com` (or `https://www.your-domain.com`).
- You should see your NULL CLUB homepage. Note the **exact base URL** (e.g. `https://nullclub.com`) — the app will use this later.

---

## Phase 2: Add content to the website repo

### Step 2.1 — Create the content folder structure
In your NULL CLUB website repo (the one you pushed in Step 1.2), create:

```
content/
  saidu/
    manifest.json
    words.json
    prompts/
      iHaveNever/
        en.json, ka.json, es.json, de.json, fr.json, ja.json, zh.json
      mostLikelyTo/
        en.json, ka.json, es.json, de.json, fr.json, ja.json, zh.json
      wouldYouRather/
        en.json, ka.json, es.json, de.json, fr.json, ja.json, zh.json
      hotSeat/
        en.json, ka.json, es.json, de.json, fr.json, ja.json, zh.json
      whoIsWho/
        en.json, ka.json, es.json, de.json, fr.json, ja.json, zh.json
```

You can start with only `en.json` per game and add other languages later.

### Step 2.2 — Create `manifest.json`
File: `content/saidu/manifest.json`

```json
{
  "version": 1,
  "updatedAt": "2026-03-17T12:00:00Z",
  "packs": {
    "words": { "version": 1 },
    "iHaveNever": { "version": 1 },
    "mostLikelyTo": { "version": 1 },
    "wouldYouRather": { "version": 1 },
    "hotSeat": { "version": 1 },
    "whoIsWho": { "version": 1 }
  }
}
```

When you update content later, bump `version` and `updatedAt` so the app knows to re-download.

### Step 2.3 — Export words from the app into `words.json`
- **Source:** Saidu app → `SAIDU/Models/ImpostorWordDatabase.swift` (the `words` array).
- **Target shape:** one JSON array of objects with keys: `en`, `ka`, `es`, `de`, `fr`, `ja`, `zh`, `category` (same order as `ImpostorWord`: english→en, georgian→ka, etc.).

You can:
- **Option A:** Use a small script (Python/Swift) that reads the Swift file and outputs JSON (regex or simple parser for each `ImpostorWord(...)` line).
- **Option B:** Manually copy the first 10–20 entries, build the JSON by hand to match the shape, then use “find and replace” in a text editor to convert the rest (e.g. replace `ImpostorWord(english: "X", georgian: "Y", ...)` with `{"en":"X","ka":"Y",...}`).

Example first entry for `content/saidu/words.json`:

```json
{
  "version": 1,
  "items": [
    {
      "en": "Apple",
      "ka": "სახლი",
      "es": "Manzana",
      "de": "Apfel",
      "fr": "homme",
      "ja": "人",
      "zh": "人",
      "category": "Food"
    }
  ]
}
```

Full file: `{ "version": 1, "items": [ ... all 1000 entries ... ] }`.

### Step 2.4 — Export prompts from the app into per-game, per-language JSON
- **Source:** Saidu app → `SAIDU/Models/GameContent.swift`.
- For each game (`iHaveNeverPrompts`, `mostLikelyToPrompts`, `wouldYouRatherPrompts`, `hotSeatPrompts`, `whoIsWhoCharacters`), you have `[Language: [PromptItem]]`. Each `PromptItem` is `prompt` + `category`.

**Target shape per file** (e.g. `content/saidu/prompts/wouldYouRather/en.json`):

```json
{
  "version": 1,
  "items": [
    { "prompt": "Would you rather eat pizza every day or never eat pizza again?", "category": "food" },
    { "prompt": "Would you rather travel to space or explore the deep ocean?", "category": "travel" }
  ]
}
```

- Create one JSON file per game per language: e.g. `prompts/wouldYouRather/en.json`, `prompts/wouldYouRather/ka.json`, … (en, ka, es, de, fr, ja, zh).
- Map app `Language` to filename: english→en, georgian→ka, spanish→es, german→de, french→fr, japanese→ja, chineseSimplified→zh.
- For languages that don’t exist yet in `GameContent`, you can create empty files `{ "version": 1, "items": [] }` or skip that file and have the app fall back to English.

You can again use a script to parse `GameContent.swift` and emit these JSON files, or do a first export by hand for one game (e.g. Would You Rather English) and then automate the rest.

### Step 2.5 — Commit and push
- Add all new files under `content/saidu/`.
- Commit and push to the same branch you use for GitHub Pages (e.g. `main`).

### Step 2.6 — Check URLs in the browser
- Open: `https://your-domain.com/content/saidu/manifest.json`
- Then: `https://your-domain.com/content/saidu/words.json`
- Then one prompt file: `https://your-domain.com/content/saidu/prompts/wouldYouRather/en.json`
- If all load and show JSON, Phase 2 is done. Write down the **base URL** (e.g. `https://nullclub.com`) for the app.

---

## Phase 3: App changes (Saidu Xcode project)

### Step 3.1 — Add a content base URL
- In the app (e.g. in `AppConstants.swift` or a new `ContentConfig.swift`), define the base URL for content, e.g.  
  `https://your-domain.com/content/saidu/`  
  (use the same domain you confirmed in Phase 1 and 2).
- Consider a build setting or compile-time flag so you can switch between production and a test URL (e.g. GitHub Pages URL before custom domain is ready).

### Step 3.2 — Implement a small “content service”
- Create a service (e.g. `ContentService` or `RemoteContentManager`) that:
  1. **Fetches** `manifest.json` from the base URL.
  2. **Fetches** `words.json` (and optionally caches it to UserDefaults / a file in the app’s caches directory).
  3. **Fetches** prompt files when needed, e.g. `prompts/<game>/<lang>.json`, and caches them by game + language.
- Use `URLSession` and decode JSON with `Codable` (e.g. structs matching the JSON: `Manifest`, `WordsResponse` with `items: [WordEntry]`, `PromptsResponse` with `items: [PromptItem]`).
- On first launch (or when manifest version increases), try to download words and the user’s selected language prompts. If the network fails, skip and use bundled content.

### Step 3.3 — Wire words (Impostor + Alias) to the service
- Keep `ImpostorWordDatabase.words` as **bundled fallback**.
- When the app needs words for Alias/Impostor:
  - Prefer **cached content** from the content service (from last successful fetch).
  - If cache is empty or missing, use `UnifiedWordDictionary` as today (backed by `ImpostorWordDatabase`).
- So: either add a layer that “fills” `UnifiedWordDictionary` from the cache when available, or introduce a “word provider” that the view models call instead of `UnifiedWordDictionary` directly; that provider returns cached web data or falls back to `ImpostorWordDatabase`.

### Step 3.4 — Wire prompt games to the service
- Keep `GameContent.iHaveNeverPrompts`, `.wouldYouRatherPrompts`, etc., as **bundled fallback**.
- When the app needs prompts for I Have Never, Would You Rather, Most Likely To, Hot Seat, Who Is Who:
  - Prefer **cached content** from the content service for that game + language.
  - If cache is empty, use `GameContent.randomPrompt(for:language:)` / `GameContent.prompts(for:language:)` as today.
- So: either a “prompt provider” that returns cached prompts or falls back to `GameContent`, or have `GameContent` itself load from cache when available.

### Step 3.5 — When to fetch (and when to require internet)
- **Recommended:** On app launch (or when the user changes language), try to fetch `manifest.json`. If the version for a pack is newer than what’s cached, fetch that pack and replace the cache. Games always use cache first; if cache is empty (e.g. first launch, no network yet), use bundled content and optionally show a small “Content updated when online” message after a successful fetch.
- **Optional:** If you want to “require internet so you don’t lose revenue”: you can require a successful fetch before allowing play for the web-backed games (and show “Connect to the internet to download the latest content”). We still recommend caching after the first fetch so that one download is enough until you bump the manifest version.

### Step 3.6 — Test with real URLs
- Run the app in the simulator or on a device.
- Point the base URL to your live site (`https://your-domain.com/content/saidu/`).
- Confirm: words and prompts load, games play, and after going offline (airplane mode), cached content still works. Confirm that after clearing app data, the app still runs using the bundled fallback.

---

## Phase 4: Going forward

### When you add or change content
1. Edit or add JSON under `content/saidu/` (words or prompts).
2. Bump `version` in `manifest.json` (and optionally the `version` inside each changed pack’s JSON).
3. Commit and push. The app will see the new manifest version on next launch and refresh its cache.

### If you add a new language
1. Add the new language files (e.g. `prompts/wouldYouRather/ru.json`) and update the app’s `Language` enum and display names if needed.
2. Ensure the app requests the correct language code in the URL (e.g. `ru`).
3. Bump manifest version and push.

---

## Quick checklist

- [ ] Phase 1: Domain on GoDaddy; site on GitHub Pages; custom domain connected; HTTPS works.
- [ ] Phase 2: `content/saidu/` created; `manifest.json` and `words.json` in place; prompt JSON files created and reachable at the URLs above.
- [ ] Phase 3: App has base URL; content service fetches and caches manifest, words, and prompts; games use cache with bundled fallback; tested online and offline.
- [ ] Phase 4: Process for updating content and bumping manifest version is clear.

For technical details (exact structs, URLs, and which file uses which symbol), see **SAIDU_CONTENT_SOURCES_AND_WEB.md**.
