# Saidu content (words + prompts)

This folder is used by the **Saidu app** to fetch words (Impostor/Alias) and prompts (I Have Never, Most Likely To, Would You Rather, Hot Seat). **Who Is Who** stays offline (in-app only, like Mafia and Role Call).

## URLs (after deploy)

- **Manifest:** `https://nullclub365-droid.github.io/NUllClLUB/content/saidu/manifest.json`
- **Words:** `https://nullclub365-droid.github.io/NUllClLUB/content/saidu/words.json`
- **Prompts:** `https://nullclub365-droid.github.io/NUllClLUB/content/saidu/prompts/<game>/<lang>.json`  
  e.g. `prompts/wouldYouRather/en.json`, `prompts/iHaveNever/de.json`

Games (prompts): `iHaveNever`, `mostLikelyTo`, `wouldYouRather`, `hotSeat`.  
Languages: `en`, `ka`, `es`, `de`, `fr`, `ja`, `zh`.

## Re-export from Saidu app source

From the **NULL CLUB** repo root (this site), run:

```bash
python3 scripts/export_saidu_content.py /path/to/saidu
```

Example if Saidu app is on your Desktop:

```bash
python3 scripts/export_saidu_content.py ~/Desktop/saidu
```

This reads `SAIDU/Models/ImpostorWordDatabase.swift` and `SAIDU/Models/GameContent.swift`, then overwrites:

- `content/saidu/words.json`
- `content/saidu/prompts/<game>/<lang>.json`

Then commit, push, and GitHub Pages will serve the new content.

## Trim English prompts to 300 each

The English prompt files for `iHaveNever`, `mostLikelyTo`, `wouldYouRather`, and `hotSeat` are trimmed to **300 prompts each** (first 300 from the app export). To re-apply this after a full re-export, run from repo root:

```bash
python3 scripts/trim_prompts_to_300.py
```

Re-running `export_saidu_content.py` without running the trim script again will restore the full English counts from the app.

## Bumping version

When you change content, edit `manifest.json` and increase `version` (and optionally `updatedAt`) so the app knows to re-download.
