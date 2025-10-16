--[[
A simple backend.

This backend handles a vast majority of cases, all of which delegate to fa-info for reading and fa-utils to find the
top-left corner.  This handles almost everything.  Rails is a special case, as for curved-rail we need the center; to
deal with that, this code just hardcodes it in.  By doing so we match what the cursor would say.

The one thing this does not know about is category, so one must call declare_simple_backend with a (sub)category set of
callbacks. Default is other, providing a way to see un-categorized things, and prototype name.  For future proofing, it
is also possible to customize readouts.

Unfortunately, we get a notable performance increase if we cache entries.  So there is that as well.  We also get a
large jump if we inline table constants when dumping to callbacks.  So this is a bit ugly, but it's ugly because
performance--a midgame save goes down from 80ms to under 40ms with respect to scanning everything in the logistics
category (belts, etc), for instance.  Note that it is crutial to update positions and subcategories when dumping, so
even when pulling from the cache we must still do those fields.  The others can be brought forward on updates.

For now, this assumes category cannot change.

fa-utils corner finding relies on map queries and is slow.  As a result, the entry is put into the cache using an
approximated top left corner and then that is made more accurate in update_entry.  The problem we face is that some
entities, primarily rocket ship pieces in the initial crash site, don't quite line up with tiles.  A longer term
solution is to use the bounding boxes. Unfortunately however, we aren't set up to do that safely until we have a better
cursor handling solution because the points such boxes can return are by their nature highly irregular.  Since we can do
this on a slow path and since we know that the old scanner used that successfully, we just do it.
]]
local FaInfo = require("scripts.fa-info")
local FaUtils = require("scripts.fa-utils")
local ScannerConsts = require("scripts.scanner.scanner-consts")
local TH = require("scripts.table-helpers")

local mod = {}

local function default_category_cb(ent)
   return ScannerConsts.CATEGORIES.OTHER
end

local function default_subcategory_cb(ent)
   return ent.name
end

local function default_readout_cb(player, ent)
   return FaInfo.ent_info(player.index, ent, true)
end

---@class fa.scanner.backends.SimpleBackend: fa.scanner.ScannerBackend
---@field known_entities table<number, LuaEntity>
---@field entry_cache table<number, fa.scanner.ScanEntry>
---@field readout_callback fun(LuaPlayer, LuaEntity): LocalisedString
---@field category_callback(LuaEntity): fa.scanner.Category
---@field subcategory_callback fun(LuaEntity): fa.scanner.Subcategory

local SimpleBackend = {}

---@param e fa.scanner.ScanEntry
function SimpleBackend:validate_entry(player, e)
   return e.backend_data.valid and player.surface_index == e.backend_data.surface_index
end

function SimpleBackend:update_entry(_player, entry)
   local entity = entry.backend_data
   if entity.type == "curved-rail" then
      -- curved-rail special case: take the center.
      entry.position = entity.position
   else
      entry.position = FaUtils.get_ent_northwest_corner_position(entity)
   end
   entry.backend = self
   entry.backend_data = entity
   entry.category = self.category_callback(entity)
   entry.subcategory = self.subcategory_callback(entity)
end

function SimpleBackend:readout_entry(player, e)
   return self.readout_callback(player, e.backend_data)
end

function SimpleBackend:on_new_entity(ent)
   if not ent.valid then return end

   self.known_entities[script.register_on_object_destroyed(ent)] = ent
end

---@param event EventData.on_object_destroyed
function SimpleBackend:on_entity_destroyed(event)
   self.known_entities[event.registration_number] = nil
   self.entry_cache[event.registration_number] = nil
end

function SimpleBackend:dump_entries_to_callback(player, callback)
   local cat_cb = self.category_callback
   local subcat_cb = self.subcategory_callback

   for regnum, entity in pairs(self.known_entities) do
      if not entity.valid then
         self.known_entities[regnum] = nil
         self.entry_cache[regnum] = nil
      else
         -- Lua optimizes the case of being able to pre-lookup functions into
         --locals, as well as the case wherein one writes out a table as a
         --constant (it knows how to allocate exactly the right sizes in that
         --case).  This got us 30% gains.  This means that the following cannot
         --be factored out into helper functions easily, if at all.
         local pos = entity.position
         local x, y = pos.x, pos.y
         local tw, th = entity.tile_width, entity.tile_height
         local htw = tw / 2
         local hth = th / 2

         local effective_x, effective_y

         if entity.type == "curved-rail" then
            -- curved-rail special case: take the center.
            effective_x = x
            effective_y = y
         else
            -- This is accurate and better than going through FaUtils in terms of
            -- performance since that does map queries.  We will probably fix FaUtils
            -- but for now we limit the fallout to here.
            effective_x = x - htw
            effective_y = y - hth
         end

         local cached_entry = self.entry_cache[regnum]
         if cached_entry then
            cached_entry.position = { x = effective_x, y = effective_y }
            cached_entry.subcategory = subcat_cb(entity)
            callback(cached_entry)
         else
            local entry = {
               position = { x = effective_x, y = effective_y },
               category = cat_cb(entity),
               subcategory = subcat_cb(entity),
               backend = self,
               backend_data = entity,
            }
            self.entry_cache[regnum] = entry
            callback(entry)
         end
      end
   end
end

function SimpleBackend:on_new_tiles(tiles) end

---@class fa.scanner.SimpleBackendCallbacks
---@field category_callback (fun(e: LuaEntity):fa.scanner.Category)?
---@field subcategory_callback (fun(LuaEntity): fa.scanner.Subcategory)?
---@field readout_callback (fun(LuaPlayer, LuaEntity): LocalisedString)?

---@param callbacks fa.scanner.SimpleBackendCallbacks
---@return fa.scanner.ScannerBackend
function mod.declare_simple_backend(meta_name, callbacks)
   local callbacks_defaulted = {
      category_callback = callbacks.category_callback or default_category_cb,
      subcategory_callback = callbacks.subcategory_callback or default_subcategory_cb,
      readout_callback = callbacks.readout_callback or default_readout_cb,
   }

   local newmeta = TH.nested_indexer(SimpleBackend, callbacks_defaulted)

   if script then script.register_metatable(meta_name, newmeta) end

   local ret = {
      new = function()
         local r = {
            known_entities = {},
            entry_cache = {},
         }
         setmetatable(r, newmeta)
         return r
      end,
   }

   return ret
end

function SimpleBackend:get_aabb(e)
   local aabb = e.backend_data.bounding_box
   local lt = aabb.left_top
   local rb = aabb.right_bottom
   return lt.x, lt.y, rb.x, rb.y
end

function SimpleBackend:is_huge(e)
   return false
end

return mod
