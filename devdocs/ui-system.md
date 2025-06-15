NOTE: by/for LLMs, pretty accurate but not 100% verified yet.

UI system is also a moving target.

# FactorioAccess UI System Documentation

The FactorioAccess UI system is a sophisticated graph-based navigation framework designed to make complex Factorio interfaces accessible through keyboard controls and audio feedback. Unlike vanilla Factorio's visual GUI, this system creates navigable structures that can be efficiently traversed and understood without visual feedback.

## UI System Overview

### Graph-Based Navigation Concept

The UI system represents all user interfaces as directed graphs where:
- **Nodes** represent UI controls (buttons, labels, grid cells, etc.)
- **Edges** represent transitions between controls (up/down/left/right navigation)
- **Properties** on nodes and edges define behavior (labels, sounds, actions)

This approach allows for flexible UI structures beyond simple menus, including:
- Vertical/horizontal menus
- 2D grids
- Tree structures
- Complex layouts with non-uniform navigation patterns

### Router for UI State Management

The Router (`scripts/ui/router.lua`) serves as the central UI manager:
- Tracks which UI is currently open for each player
- Manages transitions between different UIs
- Provides a consistent API for UI lifecycle management
- Maintains UI state in deterministic storage

### Difference from Vanilla Factorio GUI

While vanilla Factorio uses LuaGuiElement for visual interfaces, FactorioAccess:
- Uses keyboard navigation instead of mouse interaction
- Provides audio feedback instead of visual cues
- Organizes UIs as navigable graphs rather than visual layouts
- Maintains focus state for keyboard traversal
- Supports search functionality across UI elements

## Core Components

### KeyGraph - The Foundation

KeyGraph (`scripts/ui/key-graph.lua`) is the low-level "assembly language" of the UI system:

**Key Concepts:**
- Directed graph structure with nodes and transitions
- Each node has up to 4 directional transitions (up/down/left/right)
- Nodes contain vtables with callbacks for labels and actions
- Transitions can have their own labels and sounds

**Graph Constraints:**
- Must follow the "down-right constraint": traversing only down and right must eventually visit all nodes
- This enables consistent ordering for search and dynamic updates

**Example node structure:**
```lua
{
    vtable = {
        label = function(ctx)
            ctx.message:fragment({"entity-name.transport-belt"})
        end,
        left_click = function(ctx)
            -- Handle click action
        end
    },
    transitions = {
        [UiKeyGraph.TRANSITION_DIR.DOWN] = {
            destination = "next-node-key",
            vtable = {
                play_sound = function(ctx)
                    UiSounds.play_menu_move(ctx.pindex)
                end
            }
        }
    }
}
```

### Router - Managing Open UIs

The Router provides high-level UI management:

**Key Methods:**
- `open_ui(name)` - Opens a specific UI
- `close_ui()` - Closes the current UI
- `is_ui_open(name)` - Checks if a UI is open
- `get_open_ui_name()` - Gets the current UI name

**Usage Pattern:**
```lua
local router = UiRouter.get_router(pindex)
router:open_ui(UiRouter.UI_NAMES.INVENTORY)

if router:is_ui_open() then
    -- UI is open, handle accordingly
end
```

### Menu Builder - Creating Navigable Menus

MenuBuilder (`scripts/ui/menu.lua`) simplifies creating vertical menus:

**Features:**
- Automatic up/down navigation
- Sound feedback on movement
- Support for labels and clickable items

**Example:**
```lua
local menu = MenuBuilder.new()
menu:add_label("info", {"fa.some-info-text"})
menu:add_clickable("action", {"fa.perform-action"}, {
    on_click = function(ctx)
        -- Perform action
        game.get_player(ctx.pindex).print("Action performed!")
    end
})
return menu:build()
```

### Grid Builder - 2D Navigation

GridBuilder (`scripts/ui/grid.lua`) creates 2D navigable grids:

**Features:**
- Automatic directional navigation
- Customizable dimension announcements
- Default empty cell handling
- Support for sparse grids

**Example:**
```lua
local grid = Grid.grid_builder()
for x = 1, 3 do
    for y = 1, 3 do
        grid:add_simple_label(x, y, {"fa.cell-content", x, y})
    end
end
grid:set_dimension_labeler(function(ctx, x, y)
    ctx.message:fragment({"fa.grid-position", x, y})
end)
return grid:build()
```

## Creating a New UI

### Step-by-Step Guide

1. **Define the UI structure** - Determine if you need a menu, grid, or custom graph

2. **Create a graph declaration**:
```lua
local function my_ui_renderer(ctx)
    -- Check validity
    local entity = ctx.global_parameters.entity
    if not entity.valid then return nil end

    -- Build and return the graph
    local menu = MenuBuilder.new()
    menu:add_label("title", {"fa.my-ui-title"})
    -- Add more items...
    return menu:build()
end

local my_ui_graph = UiKeyGraph.declare_graph({
    name = "my_ui",
    title = {"fa.my-ui-name"},
    render_callback = my_ui_renderer
})
```

3. **Create a TabList** (for all UIs; single-tab UIs just have one tab):
```lua
local my_tablist = TabList.new({
    ui_name = UiRouter.UI_NAMES.MY_UI,
    tabs = {
        my_ui_graph,
        -- Add more tabs...
    },
    shared_state_setup = function(pindex, parameters)
        return {
            -- Initialize shared state
        }
    end
})
```

4. **Register with the router** - Currently done through control.lua menu handling

5. **Handle opening the UI**:
```lua
function open_my_ui(pindex, entity)
    local router = UiRouter.get_router(pindex)
    -- Tells the router that the UI is open, but doesn't open it until migration is complete.
    router:open_ui(UiRouter.UI_NAMES.MY_UI)

    -- For TabList UIs (the only way, currently):
    -- Parameters vary
    my_tablist:open(pindex, {entity = entity})
end
```

### Required Components

- **Graph renderer** - Function that returns a graph structure
- **UI name** - Registered in `UiRouter.UI_NAMES`
- **Localization strings** - For all labels and messages
- **Integration point** - How the UI gets opened (keybinding, event, etc.)

### Registration with Router

Currently, UI registration involves:
1. Adding a UI name to `UiRouter.UI_NAMES` enum
2. Handling the UI in control.lua's menu system
3. Creating appropriate keybindings in data.lua if needed

## Navigation Patterns

### Key Handling

The UI system handles these standard keys:
- **Arrow keys** - Navigate between nodes
- **Left bracket `[`** - Activate/click current node
- **TAB/Shift+TAB** - Switch between tabs (in TabList)
- **E/ESC** - Close the UI

### Node Connections

Nodes connect via directional transitions:
```lua
node.transitions[UiKeyGraph.TRANSITION_DIR.RIGHT] = {
    destination = "next-node-key",
    vtable = {
        label = function(ctx)
            -- Optional transition announcement
            ctx.message:fragment({"fa.moving-right"})
        end,
        play_sound = function(ctx)
            UiSounds.play_menu_move(ctx.pindex)
        end
    }
}
```

### Dynamic Content

Graphs can be dynamic, regenerated on each render:
```lua
local function dynamic_renderer(ctx)
    local menu = MenuBuilder.new()
    local items = get_current_items() -- Dynamic data

    for i, item in ipairs(items) do
        menu:add_label("item-" .. i, item.name)
    end

    return menu:build()
end
```

## Examples

### Simple Menu UI

```lua
-- Define the menu graph
local simple_menu = UiKeyGraph.declare_graph({
    name = "simple_menu",
    title = {"fa.simple-menu"},
    render_callback = function(ctx)
        local menu = MenuBuilder.new()

        menu:add_label("header", {"fa.menu-header"})
        menu:add_clickable("option1", {"fa.option-1"}, {
            on_click = function(ctx)
                game.get_player(ctx.pindex).print("Option 1 selected")
                ctx.controller:close()
            end
        })
        menu:add_clickable("option2", {"fa.option-2"}, {
            on_click = function(ctx)
                game.get_player(ctx.pindex).print("Option 2 selected")
                ctx.controller:close()
            end
        })

        return menu:build()
    end
})
```

### Grid-Based UI

```lua
-- Belt analyzer grid example
local function belt_grid_renderer(ctx)
    local entity = ctx.global_parameters.entity
    if not entity.valid then return nil end

    local grid = Grid.grid_builder()

    -- Add belt contents to grid
    for lane = 1, 2 do
        for slot = 1, 4 do
            local content = get_belt_content(entity, lane, slot)
            grid:add_lazy_label(lane, slot, function(ctx)
                if content then
                    ctx.message:fragment(content.name)
                    ctx.message:fragment({"fa.count", content.count})
                else
                    ctx.message:fragment({"fa.empty"})
                end
            end)
        end
    end

    -- Custom position announcements
    grid:set_dimension_labeler(function(ctx, lane, slot)
        local lane_name = lane == 1 and {"fa.left-lane"} or {"fa.right-lane"}
        ctx.message:fragment({"fa.belt-position", lane_name, slot})
    end)

    return grid:build()
end
```

### Complex Multi-Tab UI

```lua
-- Define multiple tabs
local info_tab = UiKeyGraph.declare_graph({
    name = "info",
    title = {"fa.info-tab"},
    render_callback = info_renderer
})

local settings_tab = UiKeyGraph.declare_graph({
    name = "settings",
    title = {"fa.settings-tab"},
    render_callback = settings_renderer
})

-- Create the tab list
local complex_ui = TabList.new({
    ui_name = UiRouter.UI_NAMES.COMPLEX_UI,
    tabs = {info_tab, settings_tab},
    shared_state_setup = function(pindex, parameters)
        return {
            entity = parameters.entity,
            -- Other shared data
        }
    end,
    persist_state = true -- Keep state between opens
})
```

## Best Practices

### Performance Considerations

1. **Minimize graph rebuilding** - Cache static graphs when possible
2. **Avoid expensive operations in renderers** - Renderers run frequently
3. **Use lazy evaluation** - Compute labels only when needed
4. **Batch related operations** - Group similar calculations

Example of efficient rendering:
```lua
-- Good: Build once, return cached
local static_menu = build_static_menu()
local function efficient_renderer(ctx)
    return static_menu -- Reuse existing graph
end

-- Bad: Rebuild every time
local function inefficient_renderer(ctx)
    local menu = MenuBuilder.new()
    for i = 1, 1000 do
        -- Expensive rebuilding
    end
    return menu:build()
end
```

### Accessibility Patterns

1. **Clear, descriptive labels** - Use localized strings that explain purpose
2. **Consistent navigation** - Follow platform conventions
3. **Audio feedback** - Play sounds for navigation and actions
4. **Context announcements** - Provide positional information

Example:
```lua
menu:add_clickable("save", {"fa.save-button"}, {
    on_click = function(ctx)
        if perform_save() then
            ctx.message:fragment({"fa.save-successful"})
            UiSounds.play_success(ctx.pindex)
        else
            ctx.message:fragment({"fa.save-failed"})
            UiSounds.play_error(ctx.pindex)
        end
    end
})
```

### Common Mistakes

1. **Forgetting the down-right constraint**:
```lua
-- Bad: Node only reachable via up
nodes["orphan"] = {
    transitions = {} -- No way to reach this going down/right!
}

-- Good: Ensure down-right traversal reaches all nodes
```

2. **Not checking entity validity**:
```lua
-- Bad: Assumes entity is always valid
local function renderer(ctx)
    local name = ctx.global_parameters.entity.name -- May crash!
end

-- Good: Check validity first
local function renderer(ctx)
    local entity = ctx.global_parameters.entity
    if not entity.valid then return nil end
    local name = entity.name
end
```

3. **Blocking operations in renderers**:
```lua
-- Bad: Expensive search in renderer
local function renderer(ctx)
    local items = surface.find_entities_filtered{...} -- Slow!
end

-- Good: Pre-compute or cache expensive data
```

4. **Not using MessageBuilder**:
```lua
-- Bad: Direct concatenation
ctx.message:fragment("Count: " .. count)

-- Good: Use proper localization
ctx.message:fragment({"fa.count-label", count})
```

5. **Forgetting to handle state cleanup**:
```lua
-- Good: Allow UI to clean up when entity becomes invalid
if not entity.valid then
    ctx.controller:close()
    return nil
end
```

## Advanced Topics

### Custom Graph Structures

For complex UIs that don't fit menu or grid patterns, build custom graphs:

```lua
local function custom_graph_renderer(ctx)
    local nodes = {}

    -- Create a tree structure
    nodes["root"] = {
        vtable = {label = function(ctx) ctx.message:fragment({"fa.root"}) end},
        transitions = {
            [UiKeyGraph.TRANSITION_DIR.DOWN] = {
                destination = "child1",
                vtable = {}
            }
        }
    }

    -- Add children with up transitions back to parent
    nodes["child1"] = {
        vtable = {label = function(ctx) ctx.message:fragment({"fa.child-1"}) end},
        transitions = {
            [UiKeyGraph.TRANSITION_DIR.UP] = {
                destination = "root",
                vtable = {}
            },
            [UiKeyGraph.TRANSITION_DIR.RIGHT] = {
                destination = "child2",
                vtable = {}
            }
        }
    }

    return {
        nodes = nodes,
        start_key = "root"
    }
end
```

### State Management

Use the context's state fields appropriately:
- `ctx.state` - Per-tab persistent state
- `ctx.shared_state` - Shared between all tabs
- `ctx.parameters` - Passed when opening the UI

### Integration with Game Events

UIs can respond to game changes by checking in the renderer and closing if needed:
```lua
local function renderer(ctx)
    local entity = ctx.global_parameters.entity

    -- Close if entity destroyed
    if not entity.valid then
        ctx.controller:close()
        return nil
    end

    -- Update based on entity state
    local menu = MenuBuilder.new()
    if entity.active then
        menu:add_label("status", {"fa.active"})
    else
        menu:add_label("status", {"fa.inactive"})
    end

    return menu:build()
end
```

This documentation provides a foundation for understanding and working with the FactorioAccess UI system. The system's flexibility allows for creating sophisticated accessible interfaces while maintaining good performance and user experience.