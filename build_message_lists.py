#!/usr/bin/env python3
"""
Build message lists for the help system.

This script processes ALL .txt files from locale/*/ directories (recursively) and generates:
1. message-lists.cfg files with localised strings for each message
2. scripts/message-list-index.lua with the list of message lists and a hash

Any .txt file anywhere under a locale directory will be treated as a message list.
The message list name is the basename of the file (without .txt extension).
Message list names must be globally unique across all directories.
"""

import base64
import hashlib
import json
import os
import re
import zlib
from pathlib import Path
from typing import Dict, List, Tuple


def parse_message_list_file(file_path: Path) -> List[str]:
    """
    Parse a message list .txt file into individual messages.

    Messages must be separated by blank lines (\\n\\n).
    Lines starting with ; are comments and are ignored.
    Multiline messages are not allowed (Factorio can't display them properly).

    Returns a list of messages (strings).
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove comments (lines starting with ;)
    lines = []
    for line in content.split('\n'):
        if not line.strip().startswith(';'):
            lines.append(line)

    # Join back and split by double newline
    cleaned = '\n'.join(lines)

    # Split by double newline to get messages
    raw_messages = re.split(r'\n\n+', cleaned)

    # Strip whitespace and filter empty messages
    messages = []
    for msg in raw_messages:
        msg = msg.strip()
        if msg:
            # Reject multiline messages - Factorio can't handle them
            if '\n' in msg:
                raise ValueError(
                    f"Multiline message found in {file_path}:\n{msg}\n\n"
                    f"Messages must be single-line. Separate messages with blank lines."
                )
            messages.append(msg)

    return messages


def get_list_name(file_path: Path, locale_root: Path) -> str:
    """Get the message list name from the file path (basename without extension)."""
    return file_path.stem


def hash_all_message_list_files(locale_root: Path) -> str:
    """
    Hash all .txt files across all locale directories in deterministic order.

    Returns SHA256 hash of all file contents.
    """
    all_txt_files = []

    # Collect all .txt files from all locale directories
    for locale_dir in sorted(locale_root.iterdir()):
        if not locale_dir.is_dir():
            continue
        all_txt_files.extend(locale_dir.rglob('*.txt'))

    # Sort by full path for deterministic ordering
    all_txt_files.sort(key=lambda p: str(p))

    # Hash all files
    hasher = hashlib.sha256()
    for txt_file in all_txt_files:
        with open(txt_file, 'rb') as f:
            hasher.update(f.read())

    return hasher.hexdigest()


def process_locale(locale_dir: Path) -> Dict[str, List[str]]:
    """
    Process all .txt files in a locale directory (recursively).

    Any .txt file anywhere under the locale directory will be processed as a message list.

    Returns:
        Dictionary mapping list names to list of messages
    """
    message_lists = {}

    # Find all .txt files recursively under the locale directory
    txt_files = sorted(locale_dir.rglob('*.txt'))

    # Process each file
    for txt_file in txt_files:
        list_name = get_list_name(txt_file, locale_dir)

        # Check for duplicate list names
        if list_name in message_lists:
            raise ValueError(
                f"Duplicate message list name '{list_name}' found in {txt_file} "
                f"(already defined elsewhere). Message list names must be globally unique "
                f"regardless of directory structure."
            )

        messages = parse_message_list_file(txt_file)
        message_lists[list_name] = messages

    return message_lists


def generate_cfg_content(message_lists: Dict[str, List[str]]) -> str:
    """Generate the content for message-lists.cfg."""
    lines = ["[fa]"]

    for list_name in sorted(message_lists.keys()):
        messages = message_lists[list_name]

        # Generate message keys
        for i, message in enumerate(messages, start=1):
            key = f"messagelist--{list_name}--msg{i}"
            # Escape any special characters for .cfg format
            # In Factorio locale files, we mainly need to handle newlines
            value = message.replace('\n', '\\n')
            lines.append(f"{key}={value}")

        # Generate metadata key
        metadata = {
            "count": len(messages),
            "name": list_name,
        }
        metadata_json = json.dumps(metadata, separators=(',', ':'))
        # Compress with zlib (deflate) then base64 encode to match helpers.decode_string
        metadata_compressed = zlib.compress(metadata_json.encode('utf-8'))
        metadata_b64 = base64.b64encode(metadata_compressed).decode('ascii')

        meta_key = f"messagelist--{list_name}--meta"
        lines.append(f"{meta_key}={metadata_b64}")
        lines.append("")  # Blank line between lists

    return '\n'.join(lines) + '\n'


def generate_index_lua(message_lists: Dict[str, List[str]], combined_hash: str) -> str:
    """Generate the content for scripts/message-list-index.lua."""
    list_names = sorted(message_lists.keys())

    lines = [
        "-- Auto-generated by build_message_lists.py",
        "-- DO NOT EDIT MANUALLY",
        "",
        "local mod = {}",
        "",
        "-- Set of valid message list names for O(1) lookup",
        "mod.MESSAGE_LISTS = {",
    ]

    for name in list_names:
        lines.append(f'   ["{name}"] = true,')

    lines.extend([
        "}",
        "",
        f'mod.MESSAGE_LISTS_HASH = "{combined_hash}"',
        "",
        "return mod",
        "",
    ])

    return '\n'.join(lines)


def main():
    """Main entry point."""
    # Get the mod root directory
    mod_root = Path(__file__).parent

    # Process each locale
    locale_root = mod_root / 'locale'

    if not locale_root.exists():
        print(f"Locale directory not found: {locale_root}")
        return

    # Process all locale directories
    locale_dirs = [d for d in locale_root.iterdir() if d.is_dir()]

    if not locale_dirs:
        print("No locale directories found")
        return

    # Hash all .txt files across all locales in deterministic order
    combined_hash = hash_all_message_list_files(locale_root)

    # We'll generate one combined index for all locales
    # but separate .cfg files per locale
    all_message_lists = {}

    for locale_dir in locale_dirs:
        locale_name = locale_dir.name
        print(f"Processing locale: {locale_name}")

        message_lists = process_locale(locale_dir)

        if not message_lists:
            print(f"  No message lists found in {locale_name}")
            continue

        # Use the first locale's message lists for the index
        if not all_message_lists:
            all_message_lists = message_lists

        # Generate .cfg file for this locale
        cfg_content = generate_cfg_content(message_lists)
        cfg_path = locale_dir / 'message-lists.cfg'

        with open(cfg_path, 'w', encoding='utf-8') as f:
            f.write(cfg_content)

        print(f"  Generated {cfg_path}")
        print(f"  Found {len(message_lists)} message list(s)")

    # Generate the Lua index file (only once)
    if combined_hash and all_message_lists:
        index_lua = generate_index_lua(all_message_lists, combined_hash)
        index_path = mod_root / 'scripts' / 'message-list-index.lua'

        with open(index_path, 'w', encoding='utf-8') as f:
            f.write(index_lua)

        print(f"\nGenerated {index_path}")
        print(f"Hash: {combined_hash}")
    else:
        print("\nNo message lists found - skipping index generation")


if __name__ == '__main__':
    main()
