--[[
The scanner.

This has 3 main components:

- This file, which mostly passes calls out to other files.  Here we handle the
  keypresses, and the overarching refresh algoreithm.
- surface-scanner.lua, which knows how to iterate over and scan surfaces.
- The backends folder, which has the implementation of the backend classes.

You can link up a new backend in surface-scanner.lua.  Mostly they're
self-explanatory.  I recommend reading simple.lua for a good example that shows
(almost) everything.

IMPORTANT: see devdocs/scanner.md for the whole picture.
]]
local EntitySelection = require("scripts.entity-selection")
local FaUtils = require("scripts.fa-utils")
local Memosort = require("scripts.memosort")
local ScannerConsts = require("scripts.scanner.scanner-consts")
local SurfaceScanner = require("scripts.scanner.surface-scanner")
local GlobalManager = require("scripts.storage-manager")
local TH = require("scripts.table-helpers")
local Viewpoint = require("scripts.viewpoint")
local WorkQueue = require("scripts.work-queue")
local Speech = require("scripts.speech")

local mod = {}

---@alias fa.scanner.Subcategory string

---@class fa.scanner.ScanEntry
---@field position fa.Point
---@field backend fa.scanner.ScannerBackend
---@field backend_data any
---@field category fa.scanner.Category
---@field subcategory fa.scanner.Subcategory

---What surface-scanner.lua is handed for each backend: creates one backend per surface.
---@class fa.scanner.ScannerBackendFactory
---@field new fun(surface: LuaSurface): fa.scanner.ScannerBackend

---A backend class is also its own factory.
---@class fa.scanner.ScannerBackend: fa.scanner.ScannerBackendFactory
---@field validate_entry fun(self, player: LuaPlayer, entry: fa.scanner.ScanEntry): boolean
---@field update_entry fun(self, player: LuaPlayer, entry: fa.scanner.ScanEntry)
---@field readout_entry fun(self, player: LuaPlayer, entry: fa.scanner.ScanEntry): LocalisedString
---@field on_new_entity fun(self, entity: LuaEntity)
---@field on_entity_destroyed fun(self, event: EventData.on_object_destroyed)
---@field dump_entries_to_callback fun(self, player: LuaPlayer, callback: fun(entry: fa.scanner.ScanEntry), wanted: (fun(x: number, y: number): boolean)?) wanted may skip entries by position before any work on them; entries it lets through still get the full filter
---@field is_huge fun(self, entry: fa.scanner.ScanEntry): boolean True if the scanner should check whether the player is in the bounding box.
---@field get_aabb fun(self, entry: fa.scanner.ScanEntry): number, number, number, number left_top.x, left_top.y, right_bottom.x, right_bottom.y

---@class fa.scanner.CursorPos
---@field category fa.scanner.Category?
---@field subcategory_index integer?
---@field entry_index integer?

--[[
The player's scan result is saved with the game, and serialised again on every save, so it is kept compact: a
subcategory's entries are one flat array of x, y, backend, backend_data per entry (ENTRY_STRIDE values), with no key
names or nested tables to write. Backends still see ScanEntry tables: entry_at builds one for the entry being worked
on, and the position update_entry gives it is written back.
]]
---@alias fa.scanner.EntryList any[]

local ENTRY_STRIDE = 4

---@param list fa.scanner.EntryList
---@return integer
local function entry_count(list)
   return math.floor(#list / ENTRY_STRIDE)
end

---@param list fa.scanner.EntryList
---@param i integer
---@return fa.scanner.ScanEntry
local function entry_at(list, i)
   local b = (i - 1) * ENTRY_STRIDE
   return {
      position = { x = list[b + 1], y = list[b + 2] },
      backend = list[b + 3],
      backend_data = list[b + 4],
   } --[[@as fa.scanner.ScanEntry]]
end

---@param list fa.scanner.EntryList
---@param i integer
local function remove_entry(list, i)
   local b = (i - 1) * ENTRY_STRIDE + 1
   for _ = 1, ENTRY_STRIDE do
      table.remove(list, b)
   end
end

---@param list fa.scanner.EntryList
---@param i integer
---@param position fa.Point
local function store_position(list, i, position)
   local b = (i - 1) * ENTRY_STRIDE
   list[b + 1], list[b + 2] = position.x, position.y
end

---@param entries fa.scanner.ScanEntry[]
---@return fa.scanner.EntryList
local function compact(entries)
   local list = {}
   for i, e in ipairs(entries) do
      local b = (i - 1) * ENTRY_STRIDE
      list[b + 1], list[b + 2], list[b + 3], list[b + 4] = e.position.x, e.position.y, e.backend, e.backend_data
   end
   return list
end

---@alias fa.scanner.SubcategoryData { entries: fa.scanner.EntryList, subcategory: fa.scanner.Subcategory }

---@class fa.scanner.GlobalPlayerState
---@field scanner_cursor fa.scanner.CursorPos
---@field entries table<fa.scanner.Category, fa.scanner.SubcategoryData[]?> Categories with no entries are absent
---@field pending_refresh_counter number? used to delay refreshes by a tick.
---@field pending_direction_filter defines.direction?

---@return fa.scanner.GlobalPlayerState
local function new_player_state(pindex)
   local player = game.get_player(pindex)

   ---@type fa.scanner.GlobalPlayerState
   local ret = {
      scanner_cursor = {
         category = nil,
         subcategory_index = nil,
         entry_index = nil,
      },
      entries = {},
      pending_refresh_counter = nil,
      pending_direction_filter = nil,
   }

   return ret
end

---@type table<number, fa.scanner.GlobalPlayerState>
-- The version drops results saved in an older layout: the player refreshes again.
local player_state = GlobalManager.declare_storage_module("scanner", new_player_state, { ephemeral_state_version = 1 })

-- Sort a list's entries by distance from px, py.
---@param list fa.scanner.EntryList
---@param px number
---@param py number
local function sort_entries(list, px, py)
   local n = entry_count(list)
   local order, scores = {}, {}
   for i = 1, n do
      local b = (i - 1) * ENTRY_STRIDE
      order[i] = i
      scores[i] = (px - list[b + 1]) ^ 2 + (py - list[b + 2]) ^ 2
   end
   table.sort(order, function(a, b)
      return scores[a] < scores[b]
   end)
   local old = TH.shallow_copy(list)
   for k = 1, n do
      local from, to = (order[k] - 1) * ENTRY_STRIDE, (k - 1) * ENTRY_STRIDE
      for j = 1, ENTRY_STRIDE do
         list[to + j] = old[from + j]
      end
   end
end

-- Order each category's subcategories by their nearest entry. Their lists must be sorted already.
---@param pstate fa.scanner.GlobalPlayerState
---@param px number
---@param py number
local function sort_subcategories(pstate, px, py)
   for _, sortable in pairs(pstate.entries) do
      Memosort.memosort(sortable, function(subcat)
         local list = subcat.entries
         -- Emptied through the other view of a shared list: last, until navigation removes it.
         if not list[1] then return math.huge end
         return (px - list[1]) ^ 2 + (py - list[2]) ^ 2
      end)
   end
end

-- Sort a stored result again, from where the player is now.
---@param player LuaPlayer
---@param pstate fa.scanner.GlobalPlayerState
local function apply_sort(player, pstate)
   local pos = player.position --[[@as MapPosition.struct]]
   local px, py = pos.x, pos.y

   -- All shares lists with the other categories: each list is sorted once.
   ---@type table<fa.scanner.EntryList, true>
   local sorted = {}
   for _, subcats in pairs(pstate.entries) do
      for _, subcat in ipairs(subcats) do
         local list = subcat.entries
         if not sorted[list] then
            sort_entries(list, px, py)
            sorted[list] = true
         end
      end
   end

   sort_subcategories(pstate, px, py)
end

local function do_refresh_after_sfx(pindex, direction_filter)
   -- Step 1: drop the player's data entirely, but keep the category cursor
   -- settings.  We can't patch subcategories back in: they're a result of the
   -- scan refresh.
   local ps = player_state[pindex]

   do
      local cat = (ps.scanner_cursor and ps.scanner_cursor.category) or ScannerConsts.CATEGORIES.ALL
      player_state[pindex] = new_player_state(pindex)
      ps = player_state[pindex]
      ps.scanner_cursor.category = cat
   end

   local player_obj = assert(game.get_player(pindex))
   ---@cast player_obj LuaPlayer

   local player_pos = player_obj.position --[[@as MapPosition.struct]]
   local px, py = player_pos.x, player_pos.y

   ---@type table<fa.scanner.ScanEntry, true>
   local known_entries = {}

   do
      local force = player_obj.force
      local dist_limit_squared = ScannerConsts.SCANNER_DISTANCE ^ 2

      local is_chunk_charted = force.is_chunk_charted
      local get_direction_biased = FaUtils.get_direction_biased
      local surface = player_obj.surface

      -- Whether the chunk holding a point is charted, asked once per chunk: entries outnumber chunks many times.
      ---@type table<number, boolean>
      local charted = {}
      ---@param x number
      ---@param y number
      ---@return boolean
      local function charted_at(x, y)
         local cx, cy = math.floor(x / 32), math.floor(y / 32)
         local key = (cx + 32768) * 65536 + (cy + 32768)
         local c = charted[key]
         if c == nil then
            c = is_chunk_charted(surface, { x = cx, y = cy })
            charted[key] = c
         end
         return c
      end

      ---@param e fa.scanner.ScanEntry
      local function adder(e)
         local pos = e.position
         local ex, ey = pos.x, pos.y
         local ltx, lty, rbx, rby
         if e.backend:is_huge(e) then
            ltx, lty, rbx, rby = e.backend:get_aabb(e)
         end

         -- NOTE: stylua is making the following format weird.
         if
            (ex - px) ^ 2 + (ey - py) ^ 2 < dist_limit_squared
            and (
                              -- We could check all corners too, but that's quite expensive.
               -- Instead we check the center or whatever point the backend
               -- decided was most relevant and assume that's good enough.  This
               -- shaved off 5% or so of scan refreshing time.
charted_at(ex, ey)
               -- For cases in which the entity is large enough that no corner
               -- or position is charted, let's see if the player themselves is
               -- inside.  This can happen with e.g. seablock where the water
               -- entry surrounds the island, and the bounding box is actually
               -- based off the corners of the generated map.
               --
               -- ltx etc. are nil if we don't need to do the check.
               or (ltx and px >= ltx and px <= rbx and py >= lty and py <= rby)
            )
            and (not direction_filter or get_direction_biased(e.position, player_obj.position) == direction_filter)
         then
            known_entries[e] = true
         end
      end

      -- The cheap part of adder, by position alone: backends use it to skip work on entries it would drop.
      ---@param x number
      ---@param y number
      ---@return boolean
      local function wanted(x, y)
         if (x - px) ^ 2 + (y - py) ^ 2 >= dist_limit_squared then return false end
         return not direction_filter or get_direction_biased({ x = x, y = y }, player_obj.position) == direction_filter
      end

      SurfaceScanner.get_entries_snapshot(player_obj.surface.index, player_obj, adder, wanted)
   end

   -- Next: build up the (sub)category setup.
   local cats = TH.defaulting_table()

   --[[
   We iterate over each entry.  The table is [category][subcategory].  Once done
   we flatten and sort.

   All entries automatically go to the all category as well. A subcategory found in one category only is the same
   list in All: it is sorted once and saved once, and an entry the navigation drops is gone from both views.
   ]]

   local t_insert = table.insert
   local CAT_ALL = ScannerConsts.CATEGORIES.ALL

   for e in pairs(known_entries) do
      local subcats = cats[e.category]
      local c = subcats[e.subcategory]
      if not c then
         c = {}
         subcats[e.subcategory] = c
      end
      t_insert(c, e)
   end

   -- Entries whose own category is All are already there; every other list joins All, shared while it is alone.
   local all = cats[CAT_ALL]
   ---@type table<fa.scanner.Subcategory, true>
   local merged = {}
   for cat, subcats in pairs(cats) do
      if cat ~= CAT_ALL then
         for subcat, ents in pairs(subcats) do
            local existing = all[subcat]
            if not existing then
               all[subcat] = ents
            else
               if not merged[subcat] then
                  existing = TH.shallow_copy(existing)
                  all[subcat] = existing
                  merged[subcat] = true
               end
               for i = 1, #ents do
                  t_insert(existing, ents[i])
               end
            end
         end
      end
   end
   if not next(all) then cats[CAT_ALL] = nil end

   -- Sort the entries while they are still tables: cheaper than sorting the flat lists. A shared list is sorted
   -- once, and each entry scored once.
   do
      local scores = {}
      local function score(e)
         local p = e.position
         return (px - p.x) ^ 2 + (py - p.y) ^ 2
      end
      ---@type table<fa.scanner.ScanEntry[], true>
      local sorted = {}
      for _, subcats in pairs(cats) do
         for _, ents in pairs(subcats) do
            if not sorted[ents] then
               Memosort.memosort(ents, score, scores)
               sorted[ents] = true
            end
         end
      end
   end

   -- Now flatten it. This is what goes to the player. A shared list stays shared.
   ---@type table<fa.scanner.ScanEntry[], fa.scanner.EntryList>
   local compacted = {}
   local cats_flattened = {}
   for cat, subcats in pairs(cats) do
      local dest = {}
      cats_flattened[cat] = dest
      for subcat, ents in pairs(subcats) do
         local list = compacted[ents]
         if not list then
            list = compact(ents)
            compacted[ents] = list
         end
         t_insert(dest, {
            subcategory = subcat,
            entries = list,
         })
      end
   end

   ps.entries = cats_flattened
   sort_subcategories(ps, px, py)

   if direction_filter then
      Speech.speak(pindex, { "fa.scanner-refreshed-directional", FaUtils.direction_lookup(direction_filter) })
   else
      Speech.speak(pindex, { "fa.scanner-refreshed" })
   end
end

-- Given a pindex, refresh the player's local view over a scan.
---@param pindex integer
---@param direction_filter defines.direction?
function mod.do_refresh(pindex, direction_filter)
   game.get_player(pindex).play_sound({ path = "scanner-pulse" })

   player_state[pindex].pending_refresh_counter = 2
   player_state[pindex].pending_direction_filter = direction_filter
end

-- Sentinel tokens to represent not having moved, and to say which end.

---@alias fa.scanner.AT_BEGINNING "at_beginning"
local AT_BEGINNING = "at_beginning"

---@alias fa.scanner.AT_END "at_end"
local AT_END = "at_end"

---@alias fa.scanner.MoveResult fa.scanner.AT_BEGINNING|fa.scanner.AT_END|true

---@param ps fa.scanner.GlobalPlayerState
---@param dir -1|1
---@return fa.scanner.MoveResult
local function move_category(pindex, ps, dir)
   local pobj = assert(game.get_player(pindex))
   ---@cast pobj LuaPlayer

   if not ps.scanner_cursor.category then
      ps.scanner_cursor.category = ScannerConsts.CATEGORIES.ALL
      return true
   end

   -- Move until we cannot anymore.
   local cur_ind = TH.find_index_of(ScannerConsts.CATEGORY_ORDER, ps.scanner_cursor.category)
   assert(cur_ind, "Unrecognized category " .. ps.scanner_cursor.category)

   while true do
      cur_ind = cur_ind + dir

      if cur_ind < 1 then
         return AT_BEGINNING
      elseif cur_ind > #ScannerConsts.CATEGORY_ORDER then
         return AT_END
      end

      -- Clean the category.  Remove entries from the firtst subcategory until
      -- we find a valid one. If not pop that subcategory and try again.
      local subcats = ps.entries[ScannerConsts.CATEGORY_ORDER[cur_ind]]
      -- There may simply be none in this category.
      if not subcats then goto continue end

      while next(subcats) do
         local ents = subcats[1].entries
         while next(ents) do
            local first = entry_at(ents, 1)
            if first.backend:validate_entry(pobj, first) then
               -- We can go here, we found a valid entry.
               ps.scanner_cursor = {
                  category = ScannerConsts.CATEGORY_ORDER[cur_ind],
                  subcategory_index = nil,
                  entry_index = nil,
               }

               return true
            else
               remove_entry(ents, 1)
            end
         end

         table.remove(subcats, 1)
      end

      ::continue::
   end
end

---@param pindex integer
---@param ps fa.scanner.GlobalPlayerState
---@param dir -1|1
---@return fa.scanner.MoveResult
local function move_subcategory(pindex, ps, dir)
   local pobj = assert(game.get_player(pindex))
   ---@cast pobj LuaPlayer

   local subcats = ps.entries[ps.scanner_cursor.category]

   if not subcats or not next(ps.entries[ps.scanner_cursor.category]) then
      return dir == -1 and AT_BEGINNING or AT_END
   end

   local ind
   local cur_index = ps.scanner_cursor.subcategory_index
   if cur_index then
      ind = cur_index + dir
   else
      ind = 1
   end

   while true do
      if ind <= 0 then
         return AT_BEGINNING
      elseif ind > #subcats then
         return AT_END
      end

      -- This is where we want to put the cursor.  We will clean the subcategory
      -- until we find a valid item.  If we can, then the first entry is made
      -- valid and this subcategory is where we want to be. If we can't, remove
      -- it and try again.
      local s = subcats[ind].entries
      while next(s) do
         local first = entry_at(s, 1)
         if first.backend:validate_entry(pobj, first) then
            ps.scanner_cursor.subcategory_index = ind
            ps.scanner_cursor.entry_index = nil
            return true
         end

         remove_entry(s, 1)
      end

      -- This subcategory couldn't do it. Move it out from under the index. If
      -- we are moving backward, also move ind one back so that ind isn't moving
      -- forward instead.
      table.remove(subcats, ind)
      if dir == -1 then ind = ind - 1 end
   end
end

---@param pindex integer
---@param ps fa.scanner.GlobalPlayerState
---@param dir -1|1
---@return fa.scanner.MoveResult
local function move_in_subcategory(pindex, ps, dir)
   local pobj = assert(game.get_player(pindex))
   ---@cast pobj LuaPlayer

   local ind = ps.scanner_cursor.entry_index
   -- Start 1 before the beginning.
   if not ind then ind = 0 end

   ps.scanner_cursor.subcategory_index = ps.scanner_cursor.subcategory_index or 1

   if
      not ps.scanner_cursor.category
      -- Can happen on the first scan of a save after an update which wipes out
      -- state.
      or not ps.entries[ps.scanner_cursor.category]
      or not next(ps.entries[ps.scanner_cursor.category])
      or not ps.entries[ps.scanner_cursor.category][ps.scanner_cursor.subcategory_index]
   then
      return dir == -1 and AT_BEGINNING or AT_END
   end

   local ents = ps.entries[ps.scanner_cursor.category][ps.scanner_cursor.subcategory_index].entries

   local total = dir == 1 and entry_count(ents) or 1

   -- Move in the direction of dir. If we can find a new index to land on, then
   -- return it. Otherwise we have to be at an end, in the sense that either we
   -- actually are or the items are invalid.
   for i = ind + dir, total, dir do
      local e = entry_at(ents, i)
      if e.backend:validate_entry(pobj, e) then
         ps.scanner_cursor.entry_index = i
         return true
      end
   end

   return dir == -1 and AT_BEGINNING or AT_END
end

-- Announce whatever the cursor is now on, doing some necessary cleanups along
-- the way.
---@param ps fa.scanner.GlobalPlayerState
local function announce_cursor_pos(pindex, ps)
   local pobj = assert(game.get_player(pindex))
   local vp = Viewpoint.get_viewpoint(pindex)
   ---@cast pobj LuaPlayer

   -- The cursor is put before the beginning of the list so that it is possible
   -- to move onto the first item. If we are announcing after a scan but before
   -- the player moved, we will see these at nil.
   if not ps.scanner_cursor.entry_index then ps.scanner_cursor.entry_index = 1 end
   if not ps.scanner_cursor.subcategory_index then ps.scanner_cursor.subcategory_index = 1 end
   if not ps.scanner_cursor.category then ps.scanner_cursor.category = ScannerConsts.CATEGORIES.ALL end

   -- Perform the cleanups unconditionally until one of them finds a valid
   -- entity; once it does stop and announce that.  These happen outside in so
   -- that we may only break the loop once.
   ---@type fa.scanner.ScanEntry?
   local announcing = nil -- if set, not empty.
   ---@type fa.scanner.EntryList
   local announcing_list
   local count = 0

   local subcats = ps.entries[ps.scanner_cursor.category]

   -- Moving around can break this because the other functions here must also
   -- try to do cleanup.
   if subcats then
      ps.scanner_cursor.subcategory_index = math.min(ps.scanner_cursor.subcategory_index, #subcats)

      while next(subcats) do
         -- If the current subcategory needs to be removed, do that.
         if not next(subcats[ps.scanner_cursor.subcategory_index].entries) then
            table.remove(subcats, ps.scanner_cursor.subcategory_index)
            ps.scanner_cursor.subcategory_index = math.min(ps.scanner_cursor.subcategory_index, #subcats)
            goto continue
         end

         local ents = subcats[ps.scanner_cursor.subcategory_index].entries

         while next(ents) do
            ps.scanner_cursor.entry_index = math.min(ps.scanner_cursor.entry_index, entry_count(ents))
            local e = entry_at(ents, ps.scanner_cursor.entry_index)
            if e.backend:validate_entry(pobj, e) then
               count = entry_count(ents)
               announcing = e
               announcing_list = ents
               goto do_announce
            end
            remove_entry(ents, ps.scanner_cursor.entry_index)
         end

         ::continue::
      end
   end

   ::do_announce::
   if announcing then
      -- Update the entry first so position is current
      EntitySelection.reset_entity_index(pindex)
      announcing.backend:update_entry(pobj, announcing)
      store_position(announcing_list, ps.scanner_cursor.entry_index, announcing.position)
      -- Now set cursor to the updated position
      vp:set_cursor_pos(announcing.position)
      -- Try to select the entity if there is one
      local new_ent = EntitySelection.get_first_ent_at_tile(pindex)
      if new_ent then pobj.selected = new_ent end
      Speech.speak(pindex, {
         "fa.scanner-full-presentation",
         announcing.backend:readout_entry(pobj, announcing),
         FaUtils.dir_dist_locale(pobj.position, announcing.position),
         tostring(ps.scanner_cursor.entry_index),
         tostring(count),
      })
      -- See entity-selection.lua refresh_player_tile, which goes nuts if we aren't
      -- directly on the center of a tile; this can be removed when that's
      -- fixed.
      vp:set_cursor_pos({
         x = math.floor(announcing.position.x) + 0.5,
         y = math.floor(announcing.position.y) + 0.5,
      })
   else
      Speech.speak(pindex, {
         "fa.scanner-nothing-in-category",
         { "fa.scanner-category-" .. ps.scanner_cursor.category },
      })
   end
end

-- Play the sound if at the beginning or end. Does nothing if the value passed
-- isn't the beginning or end.
---@param val fa.scanner.MoveResult
local function sound_for_end(pindex, val)
   local pstate = player_state[pindex]

   if val == AT_BEGINNING or val == AT_END then game.get_player(pindex).play_sound({ path = "inventory-edge" }) end
end

---@param pindex integer
---@param direction 1 | -1
function mod.move_category(pindex, direction)
   local pstate = player_state[pindex]
   sound_for_end(pindex, move_category(pindex, pstate, direction))
   Speech.speak(pindex, { "fa.scanner-category-" .. pstate.scanner_cursor.category })
end

---@param pindex integer
---@param direction 1 | -1
function mod.move_subcategory(pindex, direction)
   local pstate = player_state[pindex]
   sound_for_end(pindex, move_subcategory(pindex, pstate, direction))
   announce_cursor_pos(pindex, pstate)
end

---@param pindex integer
---@param direction 1 | -1
function mod.move_within_subcategory(pindex, direction)
   local pstate = player_state[pindex]
   sound_for_end(pindex, move_in_subcategory(pindex, pstate, direction))
   announce_cursor_pos(pindex, pstate)
end

---@param pindex integer
function mod.announce_current_item(pindex)
   local pstate = player_state[pindex]
   announce_cursor_pos(pindex, pstate)
end

function mod.resort(pindex)
   local pstate = player_state[pindex]
   local player = assert(game.get_player(pindex))
   ---@cast player LuaPlayer
   apply_sort(player, pstate)
   Speech.speak(pindex, { "fa.scanner-sorted" })
end

--[[
There is a crash in Factorio.  If we query a surface during a created_effect in
the case that entities are being rapidly created or destroyed, sometimes getting
entities crashes out.  See
https://forums.factorio.com/viewtopic.php?f=7&t=115615&p=619147#p619147

To deal with this we just delay the incoming effect triggers so that the code
that runs doesn't run while the trigger is still going.
]]
---@param args { surface_index: number, entity: LuaEntity }
local function on_new_entity_delayed(args)
   SurfaceScanner.on_new_entity(args.surface_index, args.entity)
end

local new_entity_queue = WorkQueue.declare_work_queue({
   name = "scanner_delayed_new_ents",
   worker_function = on_new_entity_delayed,
   per_tick = 100,
})

-- Called from control.lua whenever control.lua finds out about a new entity.
---@param surface_index integer
---@param entity LuaEntity
function mod.on_new_entity(surface_index, entity)
   new_entity_queue:enqueue({ surface_index = surface_index, entity = entity })
end

-- Returns an event handler that extracts an entity from the given field and
-- passes it to the scanner.
---@param field_name string
---@param allow_nil boolean? If true, nil entity is allowed (for optional fields). Default false.
---@return fun(event: table)
function mod.build_new_entity_handler(field_name, allow_nil)
   return function(event)
      local entity = event[field_name]
      if not entity then
         if not allow_nil then error("Expected entity in field '" .. field_name .. "' but got nil") end
         return
      end
      if entity.valid then mod.on_new_entity(entity.surface.index, entity) end
   end
end

-- Handler for the tile events: on_player_built_tile and the others whose tiles carry a position.
---@param event { surface_index: integer, tiles: { position: MapPosition }[] }
function mod.on_tiles_changed(event)
   local positions = {}
   for i, t in ipairs(event.tiles) do
      positions[i] = t.position
   end
   SurfaceScanner.on_tiles_changed(event.surface_index, positions)
end

function mod.on_entity_destroyed(event)
   SurfaceScanner.on_entity_destroyed(event)
end

function mod.on_new_surface(surface)
   SurfaceScanner.on_new_surface(surface.index)
end

---@param surface_index integer
---@param position ChunkPosition
function mod.on_chunk_generated(surface_index, position)
   SurfaceScanner.on_chunk_generated(surface_index, position)
end

function mod.on_surface_delete(index)
   SurfaceScanner.on_surface_delete(index)
end

function mod.on_tick()
   for pindex, state in pairs(player_state) do
      if state.pending_refresh_counter then
         state.pending_refresh_counter = state.pending_refresh_counter - 1
         if state.pending_refresh_counter == 0 then
            do_refresh_after_sfx(pindex, state.pending_direction_filter)
            state.pending_refresh_counter = nil
            state.pending_direction_filter = nil
         end
      end
   end
end

return mod
