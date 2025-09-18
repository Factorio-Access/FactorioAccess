# CLAUDE-DETAILED.md - In-Depth FactorioAccess Technical Reference

This document provides detailed technical information to supplement CLAUDE.md. It covers complex systems, implementation details, and advanced patterns used throughout the codebase.

## Table of Contents

1. [Scanner System Deep Dive](#scanner-system-deep-dive)
2. [Transport Belt Analysis](#transport-belt-analysis)
3. [Rail Building System](#rail-building-system)
4. [Circuit Networks](#circuit-networks)
5. [Performance Optimizations](#performance-optimizations)
6. [Input System Architecture](#input-system-architecture)
7. [Localization System](#localization-system)
8. [Building Placement Logic](#building-placement-logic)
9. [Multiplayer Considerations](#multiplayer-considerations)
10. [Memory Management](#memory-management)

## Scanner System Deep Dive

The scanner is the most complex system in FactorioAccess, designed to handle millions of entities efficiently.

### Architecture Overview

The scanner system helps players find entities in the game world by organizing them into a hierarchical menu structure. Key components include:

1. **Surface Scanner** (`scripts/scanner/surface-scanner.lua`) - Processes chunks incrementally
2. **Backend System** (`scripts/scanner/backends/`) - Different handlers for different entity types  
3. **Entry Point** (`scripts/scanner/entrypoint.lua`) - Manages player interaction and navigation

For specific implementation details, refer to these files and the documentation in `devdocs/scanner.md`.

### Performance Techniques

The scanner uses several optimization strategies:
- Incremental chunk processing to avoid freezing
- Entity caching to reduce repeated calculations
- Spatial prioritization to scan near players first
- Sparse data structures for memory efficiency

## Transport Belt Analysis

The belt system (`scripts/transport-belts.lua`) solves complex visual analysis problems.

### Belt Node Structure

```lua
-- Each belt segment is a node
local Node = {
    entity = nil,         -- LuaEntity
    pos = {x, y},        -- Position
    shape = nil,         -- "straight", "left_turn", "right_turn"
    parent = nil,        -- Previous belt in flow
    children = {},       -- Next belts in flow
    contents = {
        [1] = {},  -- Left lane items
        [2] = {}   -- Right lane items
    }
}
```

### Flow Analysis Algorithm

1. **Build node graph** from belt entities
2. **Identify shapes** using direction changes
3. **Trace item flow** through parent/child links
4. **Report lane-specific contents**

### Special Cases

- **Underground belts**: Paired entry/exit handling
- **Splitters**: Multi-input/output with priority logic
- **Loaders**: Special transfer rate calculations

## Rail Building System

**IMPORTANT**: Rails are currently broken due to the Factorio 2.0 migration. This section documents the intended functionality, but the feature is not currently operational.

The rail builder (`scripts/rail-builder.lua`) was designed to provide template-based construction with:
- Pre-defined turn patterns
- Automatic signal placement  
- Junction building helpers
- Station spacing calculations

Until rails are fixed for 2.0, avoid working on rail-related features.

## Circuit Networks

**IMPORTANT**: Circuit networks and wire connections are currently broken due to the Factorio 2.0 migration. This functionality is not operational.

Circuit network support (`scripts/circuit-networks.lua`) was designed to make visual wire connections accessible through:
- Wire connection audio feedback
- Signal grouping and navigation
- Circuit condition reading
- Network topology analysis

Until this is fixed for 2.0, avoid working on circuit network features.

## Performance Optimizations

### Lua Micro-optimizations

Key optimization strategies used in the codebase:

1. **Local caching of globals** - Cache frequently used global functions
2. **Avoid table creation in loops** - Reuse tables where possible
3. **String concatenation** - Use table.concat for multiple strings
4. **Appropriate data structures** - Choose the right structure for the use case

For specific examples, refer to the optimization patterns in `scripts/scanner/` and `devdocs/scanner.md`.

### Tick Management

```lua
-- Spread work across ticks
local function on_tick(event)
    local tick = event.tick
    
    -- Different systems at different rates
    if tick % 15 == 0 then
        update_medium_priority()
    end
    
    if tick % 60 == 0 then
        update_low_priority()
    end
    
    -- Player-specific timing
    for pindex, player in pairs(game.connected_players) do
        if (tick + pindex) % 30 == 0 then
            update_player_specific(pindex)
        end
    end
end
```

## Input System Architecture

The input system handles 150+ custom keybindings.

### Input Processing Flow

1. **Data stage** - Define custom inputs in `data.lua`
2. **Runtime handlers** - Process in `control.lua`
3. **Context routing** - Direct to appropriate handler
4. **Feedback** - Audio/text response

### Context Management

```lua
-- UI Router pattern
local ui_router = {
    current_ui = {},  -- Per player
    handlers = {}     -- UI-specific handlers
}

function handle_input(event)
    local pindex = event.player_index
    local current = ui_router.current_ui[pindex]
    
    if current and ui_router.handlers[current] then
        return ui_router.handlers[current](event)
    end
    
    -- Default handling
end
```

## UI System Architecture

The modern UI system (`scripts/ui/`) provides a sophisticated framework for building accessible interfaces.

### Layer Structure

1. **Router** (`ui/router.lua`)
   - Central UI manager
   - Tracks which UI is open per player
   - Provides clean API: `open_ui()`, `close_ui()`, `is_ui_open()`

2. **TabList** (`ui/tab-list.lua`)
   - Manages multi-tab UIs
   - Per-tab and shared state management
   - Lifecycle callbacks for focus changes

3. **KeyGraph** (`ui/key-graph.lua`)
   - Low-level graph representation
   - Nodes = UI elements, Edges = navigation
   - Dynamic rendering support
   - Enforces traversal constraints

4. **High-Level Builders**
   - Menu Builder: Vertical lists with up/down navigation
   - Grid Builder: 2D grids with WASD navigation

### Creating a UI

```lua
local my_ui = TabList.declare_tablist({
    ui_name = UiRouter.UI_NAMES.MY_UI,
    tabs = {
        UiKeyGraph.declare_graph({
            name = "main",
            title = {"my-ui.title"},
            render_callback = function(ctx)
                local menu = Menu.MenuBuilder.new()
                menu:add_label("label1", {"my-ui.label"})
                menu:add_clickable("button1", {"my-ui.button"}, {
                    on_click = function(ctx)
                        -- Handle click
                    end
                })
                return menu:build()
            end
        })
    }
})
```

### Context Object

Every UI callback receives a context with:
- `pindex`: Player index
- `player`: LuaPlayer reference  
- `message`: MessageBuilder for output
- `state`: Per-tab state
- `shared_state`: State shared between tabs
- `parameters`: Data passed when opening

## Localization System

The mod is transitioning from legacy localization to a modern MessageBuilder approach.

### Modern Localization with MessageBuilder

MessageBuilder (`scripts/message-builder.lua`) is the new standard for building complex localized messages:

```lua
-- Building messages with proper spacing and formatting
local message = MessageBuilder.new()
message:fragment({"entity-name.transport-belt"})
message:fragment({"fa.ent-info-facing", "north"})
message:list_item({"fa.item", "iron-plate", 50})
message:list_item({"fa.item", "copper-plate", 25})
local result = message:build()  -- Properly formatted with commas
```

### Localization Patterns in fa-info.lua

The `scripts/fa-info.lua` file demonstrates best practices:

```lua
-- Conditional parameters for clean locale strings
local has_quality = (quality and quality ~= "normal") and 1 or 0
{"fa.item-quantity-quality", item_name, has_quality, quality, has_count, count}

-- Pluralization support in locale files
__plural_for_parameter__1__{0=no items|1=1 item|rest=__1__ items}__
```

### Legacy Translation System

Most code still uses the older approach from `scripts/localising.lua`:
- Async translation requests
- Fallback mechanisms
- Direct string concatenation

The goal is to migrate all user-facing text to use MessageBuilder with proper locale keys.

## Building Placement Logic

Building placement (`scripts/building-tools.lua`) handles complex collision detection.

### Placement Validation

```lua
function can_place_entity(args)
    -- Check terrain
    local tiles = surface.find_tiles_filtered{
        area = entity_box,
        collision_mask = prototype.collision_mask
    }
    
    -- Check entities
    local blocking = surface.find_entities_filtered{
        area = entity_box,
        type = blocking_types
    }
    
    -- Check special conditions
    if prototype.type == "offshore-pump" then
        return check_water_placement(position, direction)
    end
end
```

### Smart Placement Features

- **Rotation handling** - Automatic rotation for fit
- **Power poles** - Wire reach visualization
- **Underground pipes/belts** - Pairing assistance

## Multiplayer Considerations

### State Synchronization

```lua
-- All state must be in storage table
storage.players[pindex] = {
    -- Player-specific state
}

-- Never use local variables for persistent state
local temporary_only = {}  -- OK for same-tick data

-- Events are synchronized automatically
script.on_event(defines.events.on_built_entity, function(event)
    -- This runs on all clients simultaneously
end)
```

### Desync Prevention

1. **Deterministic operations** - Same result on all clients
2. **No os.time()** or random without seed
3. **Storage-only persistence** - Nothing in Lua globals
4. **Event-driven updates** - No assumptions about tick timing

## Memory Management

### Storage Structure

```lua
storage = {
    -- Player data (largest portion)
    players = {
        [1] = { --[[ ~10KB per player ]] },
        [2] = { --[[ player state ]] }
    },
    
    -- Scanner data (can be large)
    scanner = {
        surfaces = {
            [1] = {
                seen_entities = SparseBitset,  -- ~1 bit per entity
                backends = {}  -- Backend instances
            }
        }
    },
    
    -- Temporary data (cleared periodically)
    translation_requests = {},
    scheduled_events = {}
}
```

### Memory Optimization Strategies

1. **Compact representations** - Use appropriate data structures (e.g., bitsets for entity tracking)
2. **Validate and clean invalid references** - Remove references to destroyed entities
3. **Appropriate scope** - Use local variables for temporary data

### Profiling Memory Usage

```lua
-- Debug command to check memory
commands.add_command("fa-memory", nil, function(command)
    local memory_info = {
        player_count = table_size(storage.players),
        scanner_surfaces = table_size(storage.scanner.surfaces),
        total_entities_tracked = count_all_entities_in_scanner()
    }
    print(serpent.line(memory_info))
end)
```

## Advanced Patterns

### Work Queue Pattern
```lua
local work_queue = {
    tasks = {},
    
    add = function(self, task)
        table.insert(self.tasks, task)
    end,
    
    process = function(self, count)
        for i = 1, math.min(count, #self.tasks) do
            local task = table.remove(self.tasks, 1)
            if task then task() end
        end
    end
}
```

### Event Scheduling
```lua
-- Schedule future events
function schedule_event(tick, handler, data)
    storage.scheduled_events[tick] = storage.scheduled_events[tick] or {}
    table.insert(storage.scheduled_events[tick], {
        handler = handler,
        data = data
    })
end

-- Process scheduled events
function on_tick(event)
    local scheduled = storage.scheduled_events[event.tick]
    if scheduled then
        for _, evt in ipairs(scheduled) do
            evt.handler(evt.data)
        end
        storage.scheduled_events[event.tick] = nil
    end
end
```

### Entity Validation Pattern
```lua
-- Safe entity access
function safe_entity_operation(entity, operation)
    if not (entity and entity.valid) then
        return nil, "Entity invalid"
    end
    
    local success, result = pcall(operation, entity)
    if not success then
        return nil, "Operation failed: " .. result
    end
    
    return result
end
```

This detailed reference should be used alongside CLAUDE.md for deep technical work on the FactorioAccess codebase. Remember that accessibility is the primary goal - every technical decision should enhance the audio-first user experience.