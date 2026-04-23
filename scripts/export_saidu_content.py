#!/usr/bin/env python3
"""
Export Saidu words and prompts from Swift source into content/saidu/ JSON.
Run from NULL CLUB repo root with path to Saidu app, e.g.:
  python3 scripts/export_saidu_content.py /Users/lazaretchaava/Desktop/saidu
"""
import json
import re
import sys
from pathlib import Path

LANG_KEYS = ["english", "georgian", "spanish", "german", "french", "japanese", "chineseSimplified"]
LANG_TO_CODE = {"english": "en", "georgian": "ka", "spanish": "es", "german": "de", "french": "fr", "japanese": "ja", "chineseSimplified": "zh"}
# Who Is Who stays offline (in-app only); not exported.
PROMPT_GAMES = ["iHaveNeverPrompts", "mostLikelyToPrompts", "wouldYouRatherPrompts", "hotSeatPrompts"]
GAME_TO_DIR = {"iHaveNeverPrompts": "iHaveNever", "mostLikelyToPrompts": "mostLikelyTo", "wouldYouRatherPrompts": "wouldYouRather", "hotSeatPrompts": "hotSeat"}


def extract_words(swift_path: Path) -> list[dict]:
    text = swift_path.read_text(encoding="utf-8", errors="replace")
    # One ImpostorWord per line; capture 8 quoted fields (allow \ and " inside with a simple capture)
    pattern = re.compile(
        r'ImpostorWord\s*\(\s*english:\s*"((?:[^"\\]|\\.)*)"\s*,\s*georgian:\s*"((?:[^"\\]|\\.)*)"\s*,\s*spanish:\s*"((?:[^"\\]|\\.)*)"\s*,\s*german:\s*"((?:[^"\\]|\\.)*)"\s*,\s*french:\s*"((?:[^"\\]|\\.)*)"\s*,\s*japanese:\s*"((?:[^"\\]|\\.)*)"\s*,\s*chineseSimplified:\s*"((?:[^"\\]|\\.)*)"\s*,\s*category:\s*"((?:[^"\\]|\\.)*)"\s*\)',
        re.MULTILINE
    )
    items = []
    for m in pattern.finditer(text):
        items.append({
            "en": m.group(1).replace('\\"', '"'),
            "ka": m.group(2).replace('\\"', '"'),
            "es": m.group(3).replace('\\"', '"'),
            "de": m.group(4).replace('\\"', '"'),
            "fr": m.group(5).replace('\\"', '"'),
            "ja": m.group(6).replace('\\"', '"'),
            "zh": m.group(7).replace('\\"', '"'),
            "category": m.group(8).replace('\\"', '"'),
        })
    return items


def extract_prompts_by_game_and_lang(swift_path: Path) -> dict:
    """Returns dict: game_name -> lang_code -> list of {prompt, category}."""
    text = swift_path.read_text(encoding="utf-8", errors="replace")
    # Match PromptItem(prompt: "…", category: "…") - prompt may contain \"
    item_re = re.compile(r'PromptItem\s*\(\s*prompt:\s*"((?:[^"\\]|\\.)*)"\s*,\s*category:\s*"((?:[^"\\]|\\.)*)"\s*\)')
    out = {g: {} for g in PROMPT_GAMES}
    for game in PROMPT_GAMES:
        # Find section: static let iHaveNeverPrompts: [Language: [PromptItem]] = [ ... ]
        start = text.find(f"static let {game}:")
        if start == -1:
            continue
        # Find each .english: [ ... ], .georgian: [ ... ], etc.
        section = text[start:start + 500000]
        for lang_name, lang_code in LANG_TO_CODE.items():
            block_start = section.find(f".{lang_name}: [")
            if block_start == -1:
                continue
            block_start += len(f".{lang_name}: [")
            depth = 1
            i = block_start
            while i < len(section) and depth > 0:
                if section[i:i+2] == "],":
                    depth -= 1
                    if depth == 0:
                        block = section[block_start:i]
                        break
                elif section[i] == "[":
                    depth += 1
                i += 1
            else:
                block = section[block_start:block_start+200000].split("],")[0]
            items = []
            for m in item_re.finditer(block):
                items.append({"prompt": m.group(1).replace('\\"', '"'), "category": m.group(2).replace('\\"', '"')})
            if items:
                out[game][lang_code] = items
    return out


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/export_saidu_content.py <path-to-saidu-app>")
        print("Example: python3 scripts/export_saidu_content.py /Users/lazaretchaava/Desktop/saidu")
        sys.exit(1)
    saidu_root = Path(sys.argv[1]).resolve()
    words_swift = saidu_root / "SAIDU" / "Models" / "ImpostorWordDatabase.swift"
    game_swift = saidu_root / "SAIDU" / "Models" / "GameContent.swift"
    if not words_swift.exists():
        print(f"Not found: {words_swift}")
        sys.exit(1)
    if not game_swift.exists():
        print(f"Not found: {game_swift}")
        sys.exit(1)

    # Output under NULL CLUB repo (script is in scripts/, so parent is repo root)
    repo_root = Path(__file__).resolve().parent.parent
    content_dir = repo_root / "content" / "saidu"
    content_dir.mkdir(parents=True, exist_ok=True)
    prompts_dir = content_dir / "prompts"
    prompts_dir.mkdir(exist_ok=True)

    # Words
    words = extract_words(words_swift)
    words_file = content_dir / "words.json"
    words_file.write_text(json.dumps({"version": 1, "items": words}, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote {len(words)} words -> {words_file}")

    # Prompts per game per language
    by_game = extract_prompts_by_game_and_lang(game_swift)
    for game, lang_map in by_game.items():
        dir_name = GAME_TO_DIR.get(game, game)
        game_dir = prompts_dir / dir_name
        game_dir.mkdir(exist_ok=True)
        for lang_code, items in lang_map.items():
            path = game_dir / f"{lang_code}.json"
            path.write_text(json.dumps({"version": 1, "items": items}, ensure_ascii=False, indent=2), encoding="utf-8")
            print(f"  {dir_name}/{lang_code}.json: {len(items)} prompts")
    print("Done. Commit content/saidu/ and push to deploy.")


if __name__ == "__main__":
    main()
