# Factorio LLM Documentation Overview

This directory contains comprehensive Factorio modding documentation formatted for LLM consumption.

## Directory Structure

```
llm-docs/
├── README.md              # API documentation index
├── runtime-api.md         # Runtime API overview
├── prototype-api.md       # Prototype API overview
├── events.md             # All Factorio events reference
├── defines.md            # API constants and enumerations
├── classes/              # Runtime API classes (LuaEntity, LuaPlayer, etc.)
├── concepts/             # Runtime API concepts (types and structures)
├── prototypes/           # Prototype definitions
├── types/                # Prototype type definitions
├── auxiliary/            # Additional documentation
│   ├── storage.md        # Global storage (formerly global, now storage)
│   ├── data-lifecycle.md # Loading stages and data lifecycle
│   ├── migrations.md     # Save game migrations
│   ├── libraries.md      # Available Lua libraries
│   └── ...              # Other auxiliary docs
└── wiki-note.md         # Factorio Wiki reference links
```

## Quick Start for Modding

1. **Mod Structure**: See `auxiliary/data-lifecycle.md` for loading stages
2. **Runtime Scripting**: Start with `runtime-api.md` and `events.md`
3. **Adding Prototypes**: See `prototype-api.md` and prototype definitions
4. **Storage/State**: Read `auxiliary/storage.md` for persistent data

## Key Concepts

### Loading Stages
1. **Settings Stage**: settings.lua and settings-updates.lua
2. **Data Stage**: data.lua, data-updates.lua, data-final-fixes.lua
3. **Runtime Stage**: control.lua (where most mod logic lives)

### Important Globals
- `storage` (formerly `global`) - Persistent storage between saves
- `game` - Access to game state, players, surfaces, forces
- `script` - Event registration and mod interface
- `defines` - Constants and enumerations
- `prototypes` - Access to prototype data (runtime only)

### Common Patterns
- Event handlers: `script.on_event(defines.events.on_built_entity, function(event) ... end)`
- Player iteration: `for _, player in pairs(game.players) do ... end`
- Storage initialization: `storage.my_data = storage.my_data or {}`

## Documentation Sources

1. **Official API**: Extracted from Factorio 2.0.55
2. **Auxiliary Docs**: Bundled HTML documentation converted to markdown
3. **Wiki Reference**: Links to key Factorio Wiki pages (see wiki-note.md)

## Usage Tips for LLMs

- Start with the class you need (e.g., `classes/LuaPlayer.md`)
- Check `events.md` for available events and their data
- Use `defines.md` for constant values
- Reference `concepts/` for type definitions
- Check auxiliary docs for architecture and best practices