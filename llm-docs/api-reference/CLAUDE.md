# Factorio API Reference Documentation

Complete markdown documentation for Factorio 2.0.66 API (both runtime and prototype).

Generated from JSON documentation using `scripts/json_to_markdown.py`.

## Structure

### Runtime API (`runtime/`)
Documentation for the runtime Lua API (used in `control.lua`).

- **`runtime/classes/`** - 147 Lua classes (LuaEntity, LuaPlayer, etc.)
- **`runtime/concepts/`** - 411 concept types (Position, Color, etc.)
- **`runtime/events/`** - 217 events (on_tick, on_built_entity, etc.)
- **`runtime/defines/`** - 60 define enumerations
- **`runtime/builtin_types/`** - Built-in Lua types
- **`runtime/metadata.md`** - API version and metadata

### Prototype API (`prototypes/`)
Documentation for prototype definitions (used in `data.lua`).

- **`prototypes/prototype/`** - 278 prototype types (TransportBeltPrototype, ItemPrototype, etc.)
- **`prototypes/concepts/`** - 687 type concepts (Animation, Trigger, etc.)
- **`prototypes/metadata.md`** - API version and metadata

## Statistics

- **Total files:** 1,803 markdown files
- **Total size:** 5.1 MB
- **API version:** 6
- **Game version:** 2.0.66

## Usage

Use these docs as reference when developing Factorio mods. All cross-references, types, parameters, and examples from the official JSON documentation are preserved.

## Navigation

- **Classes:** Look in `runtime/classes/` for Lua object APIs
- **Prototypes:** Look in `prototypes/prototype/` for entity/item definitions
- **Types:** Look in `runtime/concepts/` or `prototypes/concepts/` for type definitions
- **Events:** Look in `runtime/events/` for event documentation
- **Enums:** Look in `runtime/defines/` for enumeration values
