#!/usr/bin/env python3
"""Check a role texture directory against the D/N/M/A naming contract."""
from __future__ import annotations

import argparse
import hashlib
from pathlib import Path

ROLES = {"D": ("d", "diff", "albedo", "base"), "N": ("n", "normal", "bump"),
         "M": ("m", "material", "mask", "other"), "A": ("a", "ao", "attribute", "rough")}

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def classify(path: Path) -> str | None:
    stem = path.stem.lower()
    for role, tokens in ROLES.items():
        if any(token == stem or stem.startswith(token + "_") or f"_{token}_" in stem or stem.endswith("_" + token) for token in tokens):
            return role
    return None

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    args = parser.parse_args()
    files = [p for p in args.root.rglob("*") if p.is_file()]
    by_role: dict[str, list[Path]] = {key: [] for key in ROLES}
    for path in files:
        role = classify(path)
        if role:
            by_role[role].append(path)
    errors = []
    for role, matches in by_role.items():
        if not matches:
            errors.append(f"missing {role} texture")
            continue
        print(f"{role}: {len(matches)} candidate(s)")
        for path in sorted(matches):
            print(f"  {path.relative_to(args.root)} sha256={sha256(path)}")
    if errors:
        for error in errors:
            print("ERROR:", error)
        return 1
    print("Texture contract: PASS")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
