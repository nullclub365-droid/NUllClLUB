#!/usr/bin/env python3
"""
Trim English prompt files for I Have Never, Most Likely To, Would You Rather,
and Hot Seat to exactly 300 prompts each (keeps first 300).
Run from NULL CLUB repo root.
"""
import json
from pathlib import Path

GAMES = ["iHaveNever", "mostLikelyTo", "wouldYouRather", "hotSeat"]
MAX_ITEMS = 300

def main():
    repo_root = Path(__file__).resolve().parent.parent
    prompts_dir = repo_root / "content" / "saidu" / "prompts"
    for game in GAMES:
        path = prompts_dir / game / "en.json"
        if not path.exists():
            print(f"Skip (missing): {path}")
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        items = data.get("items", [])
        original = len(items)
        data["items"] = items[:MAX_ITEMS]
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"{game}/en.json: {original} -> {len(data['items'])} prompts")

if __name__ == "__main__":
    main()
