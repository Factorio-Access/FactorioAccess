#!/usr/bin/env python3
"""
Analyzes localisation string usage in FactorioAccess mod.

Commands:
- lint: Analyze usage of locale keys in Lua code
- extract: Extract all locale keys to a file for comparison

Lint finds:
- Defined locale keys that appear unused in Lua code
- Used locale keys that are not defined in .cfg files
- Prefix patterns (keys ending with -) that have no matching defined keys

Rules:
- Any reference to "fa.key-prefix-" (ending with -) is treated as a prefix
- All defined keys starting with that prefix are considered used
- Prefixes without at least one matching defined key are flagged as errors

Note: This analysis will have false positives/negatives due to:
- Dynamic string construction
- Strings from Factorio base game (entity-name, etc.)
- Comments containing locale keys
"""

import argparse
import re
from pathlib import Path
from collections import defaultdict
from configparser import ConfigParser

# Directories to scan
LOCALE_DIR = Path("locale/en")

# Only check fa section strings for lint
TARGET_SECTION = "fa"


def parse_cfg_files():
    """Parse all .cfg files and extract fa.* keys using configparser."""
    defined_keys = set()

    for cfg_file in LOCALE_DIR.glob("*.cfg"):
        parser = ConfigParser(interpolation=None)
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


def parse_all_cfg_keys():
    """Parse all .cfg files and extract ALL keys from ALL sections.

    Returns:
        tuple: (all_keys, duplicates)
        - all_keys: dict mapping full_key -> (section, cfg_file, key, value)
        - duplicates: dict mapping full_key -> list of (section, cfg_file, key, value)
    """
    all_keys = {}
    duplicates = defaultdict(list)

    for cfg_file in LOCALE_DIR.glob("*.cfg"):
        parser = ConfigParser(interpolation=None)
        try:
            parser.read(cfg_file, encoding='utf-8')

            for section in parser.sections():
                for key in parser[section]:
                    full_key = f"{section}.{key}"
                    value = parser[section][key]

                    # Track location and value
                    location = (section, str(cfg_file), key, value)

                    # Check for duplicates
                    if full_key in all_keys:
                        # First duplicate - add both original and new
                        if full_key not in duplicates:
                            duplicates[full_key].append(all_keys[full_key])
                        duplicates[full_key].append(location)
                    else:
                        all_keys[full_key] = location
        except Exception as e:
            print(f"Warning: Could not parse {cfg_file}: {e}")

    return all_keys, duplicates


def find_lua_files():
    """Find all .lua files recursively from current directory, excluding test directories."""
    all_files = Path(".").rglob("*.lua")
    # Exclude any files in directories containing 'tests' as a path component
    return [f for f in all_files if 'tests' not in f.parts]


def strip_lua_comments(line):
    """Remove Lua comments from a line.

    Handles both single-line comments (--) and doesn't process multi-line comments
    since we process line by line.
    """
    # Find -- that's not inside a string
    in_string = False
    string_char = None
    i = 0
    while i < len(line):
        char = line[i]

        # Toggle string state
        if char in ('"', "'") and (i == 0 or line[i-1] != '\\'):
            if not in_string:
                in_string = True
                string_char = char
            elif char == string_char:
                in_string = False
                string_char = None

        # Check for comment start
        if not in_string and i < len(line) - 1 and line[i:i+2] == '--':
            return line[:i]

        i += 1

    return line


def extract_locale_references(lua_files):
    """Extract all fa.* locale key references from Lua code.

    Returns:
        tuple: (exact_keys, prefix_patterns)
        - exact_keys: dict mapping key -> list of (file, line_num)
        - prefix_patterns: dict mapping prefix -> list of (file, line_num)
    """
    # Pattern matches quoted strings containing fa. followed by word characters and hyphens
    pattern = re.compile(r'"(fa\.[\w-]+)"')

    exact_keys = defaultdict(list)  # key -> list of (file, line_num)
    prefix_patterns = defaultdict(list)  # prefix -> list of (file, line_num)

    for lua_file in lua_files:
        try:
            with open(lua_file, 'r', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    # Strip comments before processing
                    line = strip_lua_comments(line)

                    # Skip lines with register_metatable (not locale keys)
                    if 'register_metatable' in line:
                        continue

                    matches = pattern.findall(line)
                    for match in matches:
                        # Check if this is a prefix pattern (ends with -)
                        if match.endswith('-'):
                            prefix_patterns[match].append((str(lua_file), line_num))
                        else:
                            exact_keys[match].append((str(lua_file), line_num))
        except Exception as e:
            print(f"Warning: Could not read {lua_file}: {e}")

    return exact_keys, prefix_patterns


def cmd_lint(args):
    """Lint command: Analyze locale key usage."""
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
    exact_keys, prefix_patterns = extract_locale_references(lua_files)
    print(f"Found {len(exact_keys)} exact key references")
    print(f"Found {len(prefix_patterns)} prefix patterns")
    print()

    # Analyze
    print("=" * 80)
    print("ANALYSIS RESULTS")
    print("=" * 80)
    print()

    # Check for invalid prefixes (prefixes with no matching defined keys)
    invalid_prefixes = []
    for prefix in prefix_patterns:
        matching_keys = [key for key in defined_keys if key.startswith(prefix)]
        if not matching_keys:
            invalid_prefixes.append(prefix)

    print(f"INVALID PREFIXES (no matching keys): {len(invalid_prefixes)}")
    print("-" * 80)
    if invalid_prefixes:
        for prefix in sorted(invalid_prefixes):
            locations = prefix_patterns[prefix][:3]
            print(f"  {prefix}")
            for file, line in locations:
                print(f"    -> {file}:{line}")
            if len(prefix_patterns[prefix]) > 3:
                print(f"    ... and {len(prefix_patterns[prefix]) - 3} more locations")
    else:
        print("  (none)")
    print()

    # Build set of all used keys (exact + prefix matches)
    used_keys = set(exact_keys.keys())
    prefix_matched_keys = set()
    for prefix in prefix_patterns:
        matching = [key for key in defined_keys if key.startswith(prefix)]
        prefix_matched_keys.update(matching)

    all_used = used_keys | prefix_matched_keys

    # Unused keys (defined but not referenced)
    unused = sorted(defined_keys - all_used)

    print(f"POTENTIALLY UNUSED KEYS: {len(unused)}")
    print("-" * 80)
    if unused:
        for key in unused:
            print(f"  {key}")
    else:
        print("  (none)")
    print()

    # Show which prefixes were detected and how many keys they matched
    if prefix_patterns:
        print(f"DETECTED PREFIX PATTERNS: {len(prefix_patterns)}")
        print("-" * 80)
        for prefix in sorted(prefix_patterns.keys()):
            matching_keys = [key for key in defined_keys if key.startswith(prefix)]
            print(f"  {prefix} -> {len(matching_keys)} keys")
        print()

    # Missing keys (exact references that are not defined)
    missing = sorted(set(exact_keys.keys()) - defined_keys)
    print(f"POTENTIALLY MISSING KEYS: {len(missing)}")
    print("-" * 80)
    if missing:
        for key in missing:
            locations = exact_keys[key][:3]  # Show first 3 locations
            print(f"  {key}")
            for file, line in locations:
                print(f"    -> {file}:{line}")
            if len(exact_keys[key]) > 3:
                print(f"    ... and {len(exact_keys[key]) - 3} more locations")
    else:
        print("  (none)")
    print()

    # Summary
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"Total defined keys:          {len(defined_keys)}")
    print(f"Exact key references:        {len(exact_keys)}")
    print(f"Prefix patterns:             {len(prefix_patterns)}")
    print(f"Keys matched by prefixes:    {len(prefix_matched_keys)}")
    print(f"Total used keys:             {len(all_used)}")
    print(f"Potentially unused:          {len(unused)}")
    print(f"Potentially missing:         {len(missing)}")
    print(f"Invalid prefixes:            {len(invalid_prefixes)}")
    print()

    # Exit with error if there are problems
    if invalid_prefixes or missing:
        print("ERRORS FOUND: Script exiting with error code 1")
        print()
        return 1

    print("All checks passed!")
    print()
    return 0


def cmd_extract(args):
    """Extract command: Extract all locale keys to a file."""
    output_file = args.output

    print("=" * 80)
    print("FactorioAccess Localisation Key Extraction")
    print("=" * 80)
    print()

    print("Parsing .cfg files in locale/en/...")
    all_keys, duplicates = parse_all_cfg_keys()
    print(f"Found {len(all_keys)} total locale keys")
    print()

    # Check for duplicates
    if duplicates:
        print("=" * 80)
        print(f"DUPLICATE KEYS FOUND: {len(duplicates)}")
        print("=" * 80)
        print()
        for key in sorted(duplicates.keys()):
            print(f"  {key}")
            for section, cfg_file, _, value in duplicates[key]:
                print(f"    -> {cfg_file} [{section}]")
                print(f"       = {value}")
        print()
        print("ERROR: Duplicate keys found. Fix these before continuing.")
        print()
        return 1

    # Write to output file
    print(f"Writing keys and values to {output_file}...")
    sorted_keys = sorted(all_keys.keys())

    with open(output_file, 'w', encoding='utf-8') as f:
        for key in sorted_keys:
            _, _, _, value = all_keys[key]
            f.write(f"{key}={value}\n")

    print(f"Successfully wrote {len(sorted_keys)} keys to {output_file}")
    print()
    return 0


def main():
    parser = argparse.ArgumentParser(
        description="FactorioAccess localisation tools",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    subparsers = parser.add_subparsers(dest='command', help='Command to run')

    # Lint subcommand
    lint_parser = subparsers.add_parser('lint', help='Analyze locale key usage in Lua code')

    # Extract subcommand
    extract_parser = subparsers.add_parser('extract', help='Extract all locale keys to a file')
    extract_parser.add_argument(
        '-o', '--output',
        default='locale_keys.txt',
        help='Output file for extracted keys (default: locale_keys.txt)'
    )

    args = parser.parse_args()

    if args.command == 'lint':
        return cmd_lint(args)
    elif args.command == 'extract':
        return cmd_extract(args)
    else:
        parser.print_help()
        return 1


if __name__ == "__main__":
    exit(main())
