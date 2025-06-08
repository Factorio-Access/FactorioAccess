# Factorio LLM Documentation - Complete Reference

This directory contains comprehensive Factorio documentation optimized for LLM usage, covering both the modding API and the complete game content.

## 📁 Directory Structure

### API Documentation (Technical Reference)
- `runtime-api.md` - Runtime API overview
- `prototype-api.md` - Prototype API overview  
- `events.md` - All Factorio events
- `defines.md` - Constants and enumerations
- `classes/` - 143 runtime API classes
- `concepts/` - 386 type definitions
- `prototypes/` - 268 prototype definitions
- `types/` - 474 prototype types
- `auxiliary/` - Architecture docs (storage, lifecycle, migrations)

### Game Content (Player Experience)
- `game-content/` - Complete extraction of game data:
  - `items.md` - All 216 items with properties
  - `recipes-detailed.md` - 193 recipes with ingredients
  - `technologies-detailed.md` - 193 technologies with prerequisites
  - `entities-complete.md` - 1,395 entities (buildings/machines)
  - `tips-and-tricks-complete.md` - 64 in-game tips
  - `game-progression-guide.md` - Step-by-step game progression
  - `controls-reference.md` - Complete control scheme
  - `game-mechanics.md` - Damage types, equipment, concepts

## 🚀 Quick Start Guide

### For Modding:
1. Start with `auxiliary/data-lifecycle.md` to understand loading stages
2. Use `runtime-api.md` and check specific classes in `classes/`
3. Register events from `events.md`
4. Store data using patterns from `auxiliary/storage.md`

### For Understanding Game Content:
1. Check `game-content/items.md` for available items
2. See `game-content/recipes-detailed.md` for crafting
3. Follow `game-content/game-progression-guide.md` for game flow
4. Use `game-content/technologies-detailed.md` for research tree

## 📋 Common Tasks

### Adding a New Item:
1. Define prototype in data stage (see `prototype-api.md`)
2. Add locale strings for name/description
3. Create recipe if craftable
4. Add to technology if research-locked

### Handling Player Actions:
```lua
script.on_event(defines.events.on_built_entity, function(event)
    local player = game.get_player(event.player_index)
    local entity = event.entity
    -- Your code here
end)
```

### Storing Mod Data:
```lua
storage.my_mod_data = storage.my_mod_data or {}
storage.my_mod_data[player.index] = {
    -- Your data here
}
```

## 📊 Documentation Statistics

- **API Classes**: 143 runtime classes fully documented
- **Events**: 229 events with parameter details
- **Prototypes**: 268 prototype types
- **Game Items**: 216 items extracted
- **Recipes**: 193 recipes with full details
- **Technologies**: 193 technologies mapped
- **Entities**: 1,395 buildings and machines
- **Tips**: 64 gameplay tips

## 🔍 Finding Information

- **By Topic**: Start with index files in each section
- **By Name**: Use file search in your editor
- **By Type**: Check appropriate subdirectory
- **By Example**: See game-content for vanilla implementations

## 💡 Usage Tips

1. **Cross-Reference**: Game content files show vanilla examples of prototype usage
2. **Event Data**: Always check `events.md` for available event data
3. **Type Safety**: Reference `concepts/` for proper type definitions
4. **Localization**: Use game-content locale patterns for consistency
5. **Performance**: Check auxiliary docs for optimization guidelines

This documentation set provides everything needed to understand both how to mod Factorio and what content exists in the vanilla game.