# Factorio API Documentation (Markdown Format)

This directory contains the complete Factorio API documentation converted to markdown format for easy consumption by LLMs.

## Contents

### Main Documentation Files

- **[runtime-api.md](runtime-api.md)** - Main index for the Runtime API documentation
- **[prototype-api.md](prototype-api.md)** - Main index for the Prototype API documentation
- **[events.md](events.md)** - Complete list of Factorio events
- **[defines.md](defines.md)** - Constant values used throughout the API

### Directories

- **[classes/](classes/)** - Runtime API classes (LuaEntity, LuaPlayer, etc.)
- **[concepts/](concepts/)** - Runtime API concepts and type definitions
- **[prototypes/](prototypes/)** - Prototype definitions (EntityPrototype, ItemPrototype, etc.)
- **[types/](types/)** - Prototype API type definitions

### Auxiliary Documentation

- **[storage.md](storage.md)** - Information about the global storage table
- **[data-lifecycle.md](data-lifecycle.md)** - Data lifecycle and loading order
- **[migrations.md](migrations.md)** - Migration system documentation
- **[libraries.md](libraries.md)** - Available Lua libraries

## Usage

These markdown files are optimized for LLM consumption with:
- Clear hierarchical structure
- Consistent formatting
- Type annotations in backticks
- Optional parameters marked with _(optional)_
- Read-only attributes marked with _(read-only)_

## Source

This documentation was converted from the official Factorio HTML documentation (version 2.0.55) located at `/factorio/doc-html/`.

## Navigation

Start with either:
- [runtime-api.md](runtime-api.md) for mod scripting
- [prototype-api.md](prototype-api.md) for data stage definitions