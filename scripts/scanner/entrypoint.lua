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
]]
local FaUtils = require("scripts.fa-utils")
local GlobalManager = require("scripts.global-manager")
local Memosort = require("scripts.memosort")
local ScannerConsts = require("scripts.scanner.scanner-consts")
local SurfaceScanner = require("scripts.scanner.surface-scanner")
local TH = require("scripts.table-helpers")
local WorkQueue = require("scripts.work-queue")

local mod = {}

---@alias fa.scanner.Subcategory string

---@class fa.scanner.ScanEntry
---@field position fa.Point
---@field bounding_box fa.AABB
---@field backend fa.scanner.ScannerBackend
---@field backend_data any
---@field category fa.scanner.Category
---@field subcategory fa.scanner.Subcategory

---@class fa.scanner.ScannerBackend
---@field new fun(LuaSurface): fa.scanner.ScannerBackend
---@field validate_entry function(player: LuaPlayer, entry: fa.scanner.ScanEntry): boolean
---@field update_entry function(player: LuaPlayer, entry: fa.scanner.ScanEntry): boolean
---@field readout_entry function(LuaPlayer, fa.scanner.ScanEntry): LocalisedString
---@field on_new_entity fun(self, LuaEntity)
---@field on_entity_destroyed fun(self, EventData.on_entity_destroyed)
---@field dump_entries_to_callback fun(self, player: LuaPlayer,  callback: fun(fa.scanner.ScanEntry))
---@field on_new_tiles fun(self, tiles: LuaTile[])

---@class fa.scanner.CursorPos
---@field category fa.scanner.Category?
---@field subcategory_index number?
---@field entry_index number?

---@alias fa.scanner.SubcategoryData { entries: fa.scanner.ScanEntry[], subcategory: fa.scanner.Subcategory }

---@class fa.scanner.GlobalPlayerState
---@field scanner_cursor fa.scanner.CursorPos
---@field surface LuaSurface
---@field entries table<fa.scanner.Category, fa.scanner.SubcategoryData[]>
---@field pending_refresh_counter number? used to delay refreshes by a tick.
---@field pending_direction_filter defines.direction?

---@returns fa.scanner.GlobalPlayerState
local function new_player_state(pindex)
   local player = game.get_player(pindex)

   ---@type fa.scanner.GlobalPlayerState
   local ret = {
      scanner_cursor = {
         category = nil,
         subcategory_index = nil,
         entry_index = nil,
      },
      surface = player.surface,
      entries = {},
      pending_refresh_counter = nil,
      pending_direction_filter = nil,
   }

   return ret
end

---@type table<number, fa.scanner.GlobalPlayerState>
local player_state = GlobalManager.declare_global_module("scanner", new_player_state)

---@param player LuaPlayer
---@param pstate fa.scanner.GlobalPlayerState
local function apply_sort(player, pstate)
   local px, py = player.position.x, player.position.y

   for cat, sortable in pairs(pstate.entries) do
      Memosort.memosort(sortable, function(subcat)
         Memosort.memosort(subcat.entries, function(e)
            local ex, ey = e.position.x, e.position.y
            return (px - ex) ^ 2 + (py - ey) ^ 2
         end)

         local example = subcat.entries[1]
         local pos = example.position
         local ex, ey = pos.x, pos.y
         return (px - ex) ^ 2 + (ey - py) ^ 2
      end)
   end
end

local function do_refresh_after_sfx(pindex, direction_filter)
   -- Step 1: drop the player's data entirely, but keep the category cursor
   -- settings.  We can't patch subcategories back in: they're a result of the
   -- scan refresh.
   local ps = player_state[pindex]

   do
      local cat = ps.scanner_cursor.category
      player_state[pindex] = new_player_state(pindex)
      ps = player_state[pindex]
      ps.scanner_cursor.category = cat
   end

   local player_obj = assert(game.get_player(pindex))
   ---@cast player_obj LuaPlayer

   local px, py = player_obj.position.x, player_obj.position.y

   local known_entries = {}

   do
      local force = player_obj.force
      local dist_limit_squared = ScannerConsts.SCANNER_DISTANCE ^ 2

      local is_chunk_charted = force.is_chunk_charted
      local get_direction_biased = FaUtils.get_direction_biased
      local surface = player_obj.surface

      ---@param e fa.scanner.ScanEntry
      local function adder(e)
         local pos = e.position
         local ex, ey = pos.x, pos.y
         local aabb = e.bounding_box

         -- NOTE: stylua is making the following format weird.
         if
            (ex - px) ^ 2 + (ey - py) ^ 2 < dist_limit_squared
            and (
                              -- We could check all corners too, but that's quite expensive.
               -- Instead we check the center or whatever point the backend
               -- decided was most relevant and assume that's good enough.  This
               -- shaved off 5% or so of scan refreshing time.
is_chunk_charted(surface, { x = ex / 32, y = ey / 32 })
               -- For cases in which the entity is large enough that no corner
               -- or position is charted, let's see if the player themselves is
               -- inside.  This can happen with e.g. seablock where the water
               -- entry surrounds the island, and the bounding box is actually
               -- based off the corners of the generated map.
               or (
                  px >= aabb.left_top.x
                  and px <= aabb.right_bottom.x
                  and py >= aabb.left_top.y
                  and py <= aabb.right_bottom.y
               )
            )
            and (not direction_filter or get_direction_biased(e.position, player_obj.position) == direction_filter)
         then
            known_entries[e] = true
         end
      end

      SurfaceScanner.get_entries_snapshot(player_obj.surface.index, player_obj, adder)
   end

   -- Next: build up the (sub)category setup.
   local cats = TH.defaulting_table()

   --[[
   We iterate over each entry.  The table is [category][subcategory].  Once done
   we flatten and sort.

   All entries automatically go to the all category as well.
   ]]

   local t_insert = table.insert
   local CAT_ALL = ScannerConsts.CATEGORIES.ALL

   local function add(cat, subcat, ent)
      local c = cats[cat][subcat]
      if not c then
         c = {}
         cats[cat][subcat] = c
      end
      t_insert(c, ent)
   end

   ---@type fa.scanner.ScanEntry
   for e in pairs(known_entries) do
      local cat = e.category
      local subcat = e.subcategory

      add(CAT_ALL, subcat, e)
      if cat ~= CAT_ALL then add(cat, subcat, e) end
   end

   -- Now flatten it. This is what goes to the player, but only after sorting.
   local cats_flattened = {}
   for cat, subcats in pairs(cats) do
      local dest = {}
      cats_flattened[cat] = dest
      for subcat, ents in pairs(subcats) do
         t_insert(dest, {
            subcategory = subcat,
            entries = ents,
         })
      end
   end

   ps.entries = cats_flattened
   apply_sort(player_obj, ps)

   if direction_filter then
      printout({ "fa.scanner-refreshed-directional", FaUtils.direction_lookup(direction_filter) }, pindex)
   else
      printout({ "fa.scanner-refreshed" }, pindex)
   end
end

-- Given a pindex, refresh the player's local view over a scan.
---@param pindex number
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
         local s = subcats[1]
         while next(s.entries) do
            local first = s.entries[1]
            if first.backend:validate_entry(pobj, first) then
               -- We can go here, we found a valid entry.
               ps.scanner_cursor = {
                  category = ScannerConsts.CATEGORY_ORDER[cur_ind],
                  subcategory_index = nil,
                  entry_index = nil,
               }

               return true
            else
               table.remove(s.entries, 1)
            end
         end

         table.remove(subcats, 1)
      end

      ::continue::
   end
end

---@param pindex number
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
   if ps.scanner_cursor.subcategory_index then
      ind = ps.scanner_cursor.subcategory_index + dir
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
         if s[1].backend:validate_entry(pobj, s[1]) then
            ps.scanner_cursor.subcategory_index = ind
            ps.scanner_cursor.entry_index = nil
            return true
         end

         table.remove(s, 1)
      end

      -- This subcategory couldn't do it. Move it out from under the index. If
      -- we are moving backward, also move ind one back so that ind isn't moving
      -- forward instead.
      table.remove(subcats, ind)
      if dir == -1 then ind = ind - 1 end
   end
end

---@param pindex number
---@param ps fa.scanner.GlobalPlayerState
---@param dir -1|1
---@return fa.scanner.MoveResult
local function move_in_subcategory(pindex, ps, dir)
   local pobj = assert(game.get_player(pindex))
   ---@cast pobj LuaPlayer

   local ind = ps.scanner_cursor.entry_index
   -- Start 1 before the beginning.
   if not ind then ind = 0 end

   if
      not ps.scanner_cursor.category
      or not next(ps.entries[ps.scanner_cursor.category])
      or not ps.entries[ps.scanner_cursor.category][ps.scanner_cursor.subcategory_index]
   then
      return dir == -1 and AT_BEGINNING or AT_END
   end

   local ents = ps.entries[ps.scanner_cursor.category][ps.scanner_cursor.subcategory_index].entries

   local total = dir == 1 and #ents or 1

   -- Move in the direction of dir. If we can find a new index to land on, then
   -- return it. Otherwise we have to be at an end, in the sense that either we
   -- actually are or the items are invalid.
   for i = ind + dir, total, dir do
      if ents[i].backend:validate_entry(pobj, ents[i]) then
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
   local announcing = nil -- if set, not empty.
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
            ps.scanner_cursor.entry_index = math.min(ps.scanner_cursor.entry_index, #ents)
            local e = ents[ps.scanner_cursor.entry_index]
            if e.backend:validate_entry(pobj, e) then
               count = #ents
               announcing = e
               goto do_announce
            end
            table.remove(ents, ps.scanner_cursor.entry_index)
         end

         ::continue::
      end
   end

   ::do_announce::
   if announcing then
      -- fa-info has dependencies on having the cursor in the right place that
      -- we can't remove, so just set it first.
      global.players[pindex].cursor_pos = announcing.position
      -- And for the same reason--we shouldn't be caching tile contents, but we do.
      refresh_player_tile(pindex)
      announcing.backend:update_entry(pobj, announcing)
      printout({
         "fa.scanner-full-presentation",
         announcing.backend:readout_entry(pobj, announcing),
         FaUtils.dir_dist_locale(pobj.position, announcing.position),
         tostring(ps.scanner_cursor.entry_index),
         tostring(count),
      }, pindex)
      global.players[pindex].cursor_pos = announcing.position
   else
      printout({
         "fa.scanner-nothing-in-category",
         { "fa.scanner-category-" .. ps.scanner_cursor.category },
      }, pindex)
   end
end

-- Play the sound if at the beginning or end. Does nothing if the value passed
-- isn't the beginning or end.
---@param val fa.scanner.MoveResult
function sound_for_end(val)
   local pstate = player_state[pindex]

   if val == AT_BEGINNING or val == AT_END then game.get_player(pindex).play_sound({ path = "inventory-edge" }) end
end

---@param pindex number
---@param direction 1 | -1
function mod.move_category(pindex, direction)
   if global.players[pindex].in_menu then return end
   local pstate = player_state[pindex]
   sound_for_end(move_category(pindex, pstate, direction))
   printout({ "fa.scanner-category-" .. pstate.scanner_cursor.category }, pindex)
end

---@param pindex number
---@param direction 1 | -1
function mod.move_subcategory(pindex, direction)
   if global.players[pindex].in_menu then return end
   local pstate = player_state[pindex]
   sound_for_end(move_subcategory(pindex, pstate, direction))
   announce_cursor_pos(pindex, pstate)
end

---@param pindex number
---@param direction 1 | -1
function mod.move_within_subcategory(pindex, direction)
   if global.players[pindex].in_menu then return end
   local pstate = player_state[pindex]
   sound_for_end(move_in_subcategory(pindex, pstate, direction))
   announce_cursor_pos(pindex, pstate)
end

---@param pindex number
function mod.announce_current_item(pindex)
   if global.players[pindex].in_menu then return end
   local pstate = player_state[pindex]
   announce_cursor_pos(pindex, pstate)
end

function mod.resort(pindex)
   if global.players[pindex].in_menu then return end
   local pstate = player_state[pindex]
   local player = assert(game.get_player(pindex))
   ---@cast player LuaPlayer
   apply_sort(player, pstate)
   printout({ "fa.scanner-sorted" }, pindex)
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
---@param surface_index number
---@param entity LuaEntity
function mod.on_new_entity(surface_index, entity)
   new_entity_queue:enqueue({ surface_index = surface_index, entity = entity })
end

function mod.on_entity_destroyed(event)
   SurfaceScanner.on_entity_destroyed(event)
end

function mod.on_new_surface(surface)
   SurfaceScanner.on_new_surface(surface.index)
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
