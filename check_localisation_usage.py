#!/usr/bin/env python3
"""
Analyzes localisation string usage in FactorioAccess mod.

Finds:
- Defined locale keys that appear unused in Lua code
- Used locale keys that are not defined in .cfg files

Note: This analysis will have false positives/negatives due to:
- Dynamic string construction
- Strings from Factorio base game (entity-name, etc.)
- Comments containing locale keys
"""

import re
from pathlib import Path
from collections import defaultdict
from configparser import ConfigParser

# Directories to scan
LOCALE_DIR = Path("locale/en")

# Only check fa section strings
TARGET_SECTION = "fa"

# Known dynamic patterns that should be excluded from unused warnings
DYNAMIC_PATTERNS = [
    "fa.inventory-title-",
    "fa.scanner-category-",
    "fa.percentage-suffix-",
    "fa.warning-type-",
    "fa.messagelist--",
    "fa.spidertron-remote-autopilot-",
    "fa.ent-info-heat-conn-",
]


def is_dynamic_key(key):
    """Check if a key matches a known dynamic pattern."""
    return any(key.startswith(pattern) for pattern in DYNAMIC_PATTERNS)


def parse_cfg_files():
    """Parse all .cfg files and extract fa.* keys using configparser."""
    defined_keys = set()

    for cfg_file in LOCALE_DIR.glob("*.cfg"):
        parser = ConfigParser()
        try:
            parser.read(cfg_file, encoding='utf-8')

            # Check if fa section exists
            if TARGET_SECTION in parser:
                for key in parser[TARGET_SECTION]:
                    full_key = f"{TARGET_SECTION}.{key}"
                    defined_keys.add(full_key)
        except Exception as e:
            print(f"Warning: Could not parse {cfg_file}: {e}")

    return defined_keys


def find_lua_files():
    """Find all .lua files recursively from current directory."""
    return list(Path(".").rglob("*.lua"))


def extract_locale_references(lua_files):
    """Extract all fa.* locale key references from Lua code."""
    # Pattern matches quoted strings containing fa. followed by word characters and hyphens
    pattern = re.compile(r'"(fa\.[\w-]+)"')

    used_keys = defaultdict(list)  # key -> list of (file, line_num)

    for lua_file in lua_files:
        try:
            with open(lua_file, 'r', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    matches = pattern.findall(line)
                    for match in matches:
                        used_keys[match].append((str(lua_file), line_num))
        except Exception as e:
            print(f"Warning: Could not read {lua_file}: {e}")

    return used_keys


def main():
    print("=" * 80)
    print("FactorioAccess Localisation Usage Analysis")
    print("=" * 80)
    print()

    # Parse locale files
    print("Parsing .cfg files in locale/en/...")
    defined_keys = parse_cfg_files()
    print(f"Found {len(defined_keys)} defined fa.* keys")
    print()

    # Find Lua files
    print("Finding .lua files recursively...")
    lua_files = find_lua_files()
    print(f"Found {len(lua_files)} Lua files")
    print()

    # Extract references
    print("Extracting locale key references from Lua code...")
    used_keys = extract_locale_references(lua_files)
    print(f"Found {len(used_keys)} unique fa.* key references")
    print()

    # Analyze
    print("=" * 80)
    print("ANALYSIS RESULTS")
    print("=" * 80)
    print()

    # Unused keys (defined but not referenced)
    all_unused = sorted(defined_keys - set(used_keys.keys()))

    # Separate dynamic keys from genuinely unused
    dynamic_unused = [key for key in all_unused if is_dynamic_key(key)]
    genuinely_unused = [key for key in all_unused if not is_dynamic_key(key)]

    print(f"POTENTIALLY UNUSED KEYS: {len(genuinely_unused)}")
    print("-" * 80)
    if genuinely_unused:
        for key in genuinely_unused:
            print(f"  {key}")
    else:
        print("  (none)")
    print()

    if dynamic_unused:
        print(f"DYNAMIC PATTERN KEYS (excluded from above): {len(dynamic_unused)}")
        print("-" * 80)
        # Group by pattern
        by_pattern = defaultdict(list)
        for key in dynamic_unused:
            for pattern in DYNAMIC_PATTERNS:
                if key.startswith(pattern):
                    by_pattern[pattern].append(key)
                    break

        for pattern, keys in sorted(by_pattern.items(), key=lambda x: len(x[1]), reverse=True):
            print(f"  {pattern} ({len(keys)} keys)")
        print()

    # Missing keys (referenced but not defined)
    missing = sorted(set(used_keys.keys()) - defined_keys)
    print(f"POTENTIALLY MISSING KEYS: {len(missing)}")
    print("-" * 80)
    if missing:
        for key in missing:
            locations = used_keys[key][:3]  # Show first 3 locations
            print(f"  {key}")
            for file, line in locations:
                print(f"    -> {file}:{line}")
            if len(used_keys[key]) > 3:
                print(f"    ... and {len(used_keys[key]) - 3} more locations")
    else:
        print("  (none)")
    print()

    # Summary
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"Total defined keys:       {len(defined_keys)}")
    print(f"Total used keys:          {len(used_keys)}")
    print(f"Potentially unused:       {len(genuinely_unused)}")
    print(f"Dynamic pattern keys:     {len(dynamic_unused)}")
    print(f"Potentially missing:      {len(missing)}")
    print()
    print("NOTE: This analysis may have false positives/negatives due to:")
    print("  - Dynamic string construction beyond known patterns")
    print("  - Base game locale keys (entity-name.*, item-name.*, etc.)")
    print("  - Comments containing locale key examples")
    print("  - Test files and tutorial system (being removed)")
    print()
    print("Known dynamic patterns (excluded from unused count):")
    for pattern in DYNAMIC_PATTERNS:
        print(f"  {pattern}")
    print()


if __name__ == "__main__":
    main()
