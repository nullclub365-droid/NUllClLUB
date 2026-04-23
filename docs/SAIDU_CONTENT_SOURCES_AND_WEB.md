# Saidu — Where games get words/prompts (and web hosting plan)

## 1) Where each game gets its data (current app)

| Game | Source file | Symbol / how it’s used |
|------|-------------|------------------------|
| **Impostor** | `SAIDU/Models/ImpostorWordDatabase.swift` | `UnifiedWordDictionary.sharedEntries` (mapped from `ImpostorWordDatabase.words`). `ImpostorViewModel.assignCards()` uses `UnifiedWordDictionary.randomEntry(avoiding:)`. |
| **Alias** | Same as Impostor | Same list. `AliasViewModel` uses `UnifiedWordDictionary.sharedEntries` and `UnifiedWordDictionary.sharedEntries[idx].word(for: currentLanguage)` in `startRound()` / `nextWord()`. |
| **I Have Never** | `SAIDU/Models/GameContent.swift` | `GameContent.iHaveNeverPrompts: [Language: [PromptItem]]`. Used via `GameContent.randomPrompt(for: .iHaveNever, language:)` and `GameContent.prompts(for: .iHaveNever, language:)`. |
| **Who Is Who** | Stays in app (offline) | Uses `GameContent.whoIsWhoCharacters`; not fetched from web. |
| **Most Likely To** | `SAIDU/Models/GameContent.swift` | `GameContent.mostLikelyToPrompts: [Language: [PromptItem]]`. Same API. |
| **Would You Rather** | `SAIDU/Models/GameContent.swift` | `GameContent.wouldYouRatherPrompts: [Language: [PromptItem]]`. Same API. |
| **Hot Seat** | `SAIDU/Models/GameContent.swift` | `GameContent.hotSeatPrompts: [Language: [PromptItem]]`. Same API. |
| **Mafia** | Stays in app | Not moved to web. |
| **Role Call** | Stays in app | Not moved to web. |

**Shared layer (words for Impostor + Alias):**

- **`ImpostorWordDatabase.swift`**  
  - Single source: `static let words: [ImpostorWord]` (~1000 entries).  
  - Each `ImpostorWord`: `english`, `georgian`, `spanish`, `german`, `french`, `japanese`, `chineseSimplified`, `category`.

- **`UnifiedWordDictionary.swift`**  
  - Builds `sharedEntries` from `ImpostorWordDatabase.words` and exposes `words(for: Language)`, `randomEntry(avoiding:)`, and `fallbackEntry`.

**Prompt games (I Have Never, Most Likely To, Would You Rather, Hot Seat; Who Is Who stays offline):**

- **`GameContent.swift`**  
  - Static dictionaries: `iHaveNeverPrompts`, `mostLikelyToPrompts`, `wouldYouRatherPrompts`, `hotSeatPrompts`, `whoIsWhoCharacters`, each `[Language: [PromptItem]]`.
  - `PromptItem`: `prompt: String`, `category: String`.
  - API: `GameContent.randomPrompt(for:language:)`, `GameContent.prompts(for:language:)`, `GameContent.hasContent(for:language:)`.

**Languages in app:**  
`Language` in `GameModels.swift`: `english` (en), `georgian` (ka), `spanish` (es), `german` (de), `french` (fr), `japanese` (ja), `chineseSimplified` (zh-Hans).

---

## 2) Games to move to web (and keep in app as fallback)

- Impostor (words)
- Alias (same words)
- I Have Never (prompts)
- Most Likely To (prompts)
- Would You Rather (prompts)
- Hot Seat (prompts)

**Stay offline (in-app only):** Mafia, Role Call, **Who Is Who**.

---

## 3) Languages (7)

- **en** — English  
- **ka** — Georgian  
- **es** — Spanish  
- **de** — German  
- **fr** — French  
- **ja** — Japanese  
- **zh** — Chinese (Simplified; app uses `zh-Hans`)

---

## 4) Web hosting (GoDaddy custom domain + GitHub)

- Host the static JSON on the same place as your NULL CLUB site (e.g. GitHub Pages).
- Point your GoDaddy custom domain to that host (CNAME or A record as per GitHub/GoDaddy docs).
- App will request content from:  
  `https://<your-domain>/content/saidu/...`  
  (see URL layout below).

---

## 5) URL and JSON shape (for app fetch)

**Base URL (once domain is set):**  
`https://<your-domain>/content/saidu/`

**Manifest (versioning + cache invalidation):**

- **URL:** `https://<your-domain>/content/saidu/manifest.json`
- **Shape (example):**

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

**Words (Impostor + Alias) — one file per language (all 7 langs in one array is an option too):**

- **URL:** `https://<your-domain>/content/saidu/words.json`  
  (or per-locale: `.../words/en.json`, `.../words/ka.json`, …)
- **Shape (single file, all languages):**

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

**Prompt games — one file per game per language (or one file per game with all languages):**

- **URLs (per game, per language):**  
  `https://<your-domain>/content/saidu/prompts/iHaveNever/en.json`  
  `https://<your-domain>/content/saidu/prompts/wouldYouRather/ka.json`  
  … etc.
- **Shape (per file):**

```json
{
  "version": 1,
  "items": [
    { "prompt": "Would you rather eat pizza every day or never eat pizza again?", "category": "food" }
  ]
}
```

**Suggested layout on disk (under your site’s content root):**

```
content/saidu/
  manifest.json
  words.json                    # or words/en.json, words/ka.json, ...
  prompts/
    iHaveNever/
      en.json, ka.json, es.json, de.json, fr.json, ja.json, zh.json
    mostLikelyTo/
      en.json, ...
    wouldYouRather/
      en.json, ...
    hotSeat/
      en.json, ...
    whoIsWho/
      en.json, ...
```

---

## 6) App changes (high level)

1. **Words (Impostor + Alias)**  
   - Add a **content service** that:  
     - Fetches `manifest.json` and, if needed, `words.json` (or `words/<lang>.json`).  
     - Caches JSON on disk; uses cached data when offline.  
   - Replace `UnifiedWordDictionary.sharedEntries` usage with “entries from cache (or bundled fallback)”.  
   - Populate cache on first launch or when manifest version increases; keep using `ImpostorWordDatabase` as bundled fallback when fetch fails or cache empty.

2. **Prompt games**  
   - For each of I Have Never, Most Likely To, Would You Rather, Hot Seat, Who Is Who:  
     - Fetch the corresponding `prompts/<game>/<lang>.json` (or one combined prompts file per game).  
     - Cache by game + language; use cached data when offline.  
   - Replace `GameContent.iHaveNeverPrompts`, `.mostLikelyToPrompts`, etc., with “prompts from cache (or bundled fallback)”.  
   - Keep current `GameContent` as fallback when offline or fetch fails.

3. **Language**  
   - Map app `Language` to URL segment: `en`, `ka`, `es`, `de`, `fr`, `ja`, `zh` (app can send `zh-Hans` as `zh` in the URL).

4. **GoDaddy + GitHub**  
   - Configure your custom domain in GoDaddy to point to GitHub Pages (or your current host).  
   - Ensure `https://<your-domain>/content/saidu/manifest.json` (and the rest) is publicly readable.  
   - App uses `https://<your-domain>/content/saidu/...` as the base for all content requests.

This document answers (1) where games get their words/prompts and (4) what the web structure and URLs look like for your GoDaddy custom domain and GitHub setup.
