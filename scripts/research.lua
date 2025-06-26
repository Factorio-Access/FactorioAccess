--[[
Handle research for a player. This means:

- Computing the research graph, of what technologies come from what.
- Announcing the requirements, either in science packs or trigger conditions.
- Managing the research queue.

Broadly speaking this is all pretty simple.  The complexity comes in with handling successor researches and the like.

This module handles announcements.  Those announcements are in locale/en/research.cfg.

Note that some 2.0 technologies do not have descriptions and names because they are not necessarily to be shown to the
player. To deal with this, you may add support by adding to research.cfg  a key of the form
research-technology-name-prototype-name and research-technology-description-prototype-name, e.g.
research-technology-name-steam-power.

This module's primary public interface are the menu_xxx  s which correspond to inputs.  Until we have a better UI setup,
we do what we can to at least pull that out. They get called from control.lua at appropriate points.

After a bunch of thought the underlying representation of the lists is a flat array tagged with the category each thing
goes in e.g. locked etc.  This lets us represent the position with an index.  That complicates things a bit, but greatly
simplifies menu search.  Hopefully, this can be revisited in future once we have better UI abstractions.
]]
local Consts = require("scripts.consts")
local DataToRuntimeMap = require("scripts.data-to-runtime-map")
local FaUtils = require("scripts.fa-utils")
local Functools = require("scripts.functools")
local Localising = require("scripts.localising")
local Memosort = require("scripts.memosort")
local StorageManager = require("scripts.storage-manager")
local TH = require("scripts.table-helpers")

-- This is the workaround for the lack of counts in craft-item research
-- triggers. See data-updates.lua for the smuggling and a longer description.
---@type fun(): table<string, table<string, number>>
local CRAFT_ITEM_COUNTS = Functools.cached(function()
   local map_outer = DataToRuntimeMap.load(Consts.RESEARCH_CRAFT_ITEMS_MAP_OUTER)

   local res = {}

   for protoname, mapname in pairs(map_outer) do
      local inner_map = DataToRuntimeMap.load(mapname)
      res[protoname] = TH.map(inner_map, tonumber)
   end

   return res
end)

---@enum fa.research.ResearchList
local RESEARCH_LISTS = {
   RESEARCHABLE = "researchable",
   LOCKED = "locked",
   RESEARCHED = "researched",
}
local RESEARCH_LIST_ORDER = { RESEARCH_LISTS.RESEARCHABLE, RESEARCH_LISTS.LOCKED, RESEARCH_LISTS.RESEARCHED }

---@class fa.research.ResearchMenuPosition
---@field index number
---@field focused_list fa.research.ResearchList

---@type table<number, { research_menu_pos: fa.research.ResearchMenuPosition }>
local research_state = StorageManager.declare_storage_module("research", {
   research_menu_pos = {
      index = 1,
      focused_list = RESEARCH_LISTS.RESEARCHABLE,
   },
})
local mod = {}

-- Wrap a research's localised name so that, if vanilla doesn't have a localised
-- description, we have a chance ourselves.
---@param tech LuaTechnology
---@return LocalisedString
local function tech_name_string(tech)
   return { "?", tech.localised_name, { string.format("fa.research-technology-name-%s", tech.name) }, tech.name }
end

---@param tech LuaTechnology
---@return LocalisedString
local function tech_description_string(tech)
   return {
      "?",
      tech.localised_description,
      { string.format("fa.research-technology-description-%s", tech.name) },
      tech.name,
   }
end

-- Place a given technology at the given index in the research queue for a
-- player's force if possible; tell the player if it was; and return what to announce and true if it
-- happened.  If the index is nil, put it at the end, like table.insert does.
---@param player LuaPlayer
---@param name string
---@param index number?
---@return LocalisedString, boolean
function mod.enqueue(player, name, index)
   local tech = prototypes.technology[name]
   if not tech then error(string.format("Got an invalid technology name! %s")) end

   if tech.research_trigger then return { "fa.research-not-in-labs" }, false end

   local force = player.force
   local queue = force.research_queue
   table.insert(queue, index or 1, name)
   -- redundant? no—Factorio needs the copy written back
   force.research_queue = queue
   -- re-fetch in case the engine normalized it
   queue = force.research_queue
   local added = false
   for _, e in pairs(queue) do
      if e.name == name then
         added = true
         break
      end
   end

   if added then
      local tech_param = tech_name_string(player.force.technologies[name])
      if index == 1 then
         return { "fa.research-enqueued-front", tech_param }, true
      elseif index == nil then
         return { "fa.research-enqueued-back", tech_param }, true
      else
         -- Shouldn't be reachable, but whatever, do we care?
         return { "fa.research-enqueued-front", tech_param }, true
      end
   else
      for pred in pairs(tech.prerequisites) do
         if not force.technologies[pred].researched then return { "fa.research-needs-dependencies" }, false end
      end
   end

   return { "fa.research-not-enqueued" }, false
end

---@param trig ResearchTrigger
---@return LocalisedString
local function localise_trigger(tech, trig)
   local res = { string.format("fa.research-trigger-%s", trig.type) }

   if trig.type == "craft-item" then
      table.insert(res, Localising.get_localised_name_with_fallback(prototypes.item[trig.item.name]))

      local amount = CRAFT_ITEM_COUNTS()[tech.name][trig.item.name]
      assert(amount)
      table.insert(res, amount)
      table.insert(res, trig.item_quality or "normal")
   elseif trig.type == "mine-entity" then
      table.insert(res, Localising.get_localised_name_with_fallback(prototypes.entity[trig.entity]))
   elseif trig.type == "craft-fluid" then
      table.insert(res, Localising.get_localised_name_with_fallback(prototypes.fluid[trig.fluid]))
      table.insert(res, trig.amount)
   elseif trig.type == "capture-spawner" then
      table.insert(res, Localising.get_localised_name_with_fallback(prototypes.entity[trig.entity]))
   elseif trig.type == "build-entityy" then
      -- TODO: We don't handle quality yet because that is very hard to
      -- localise, and we are just getting 1.0 parity at the moment.
      table.insert(res, Localising.get_localised_name_with_fallback(prototypes.entity[trig.entity.name]))
   elseif trig.type == "send-item-to-orbit" then
      table.insert(res, trig.item.name)
   end

   return res
end

---@param tech LuaTechnology
---@return LocalisedString
local function localise_science_cost(tech)
   -- We have a cost, then we have individual costs beyond that, then what we want
   -- to do is alphabetize the list and very carefully avoid repeating repeated
   -- numbers.

   -- How many "rounds" of the ingredients will be needed.
   local units = tech.research_unit_count

   -- By the types, technically these ingredients can be fluids. Fluids can't happen because the actual prototype only
   -- accepts tools.
   local ingredients = {}

   for _, ingredient in pairs(tech.research_unit_ingredients) do
      ingredients[ingredient.name] = (ingredients[ingredient.name] or 0) + ingredient.amount
   end

   -- Now invert this.  Then we get groups for "free". We will announce greatest to least, so use negatives and
   -- table-helpers helps us table.
   local groups = TH.defaulting_table()
   for name, amount in pairs(ingredients) do
      local real = amount * units
      table.insert(groups[-real], name)
   end

   local sorted = TH.set_to_sorted_array(groups)

   for _, t in pairs(sorted) do
      table.sort(t[2])
   end

   -- Okay, finally we can do this.
   local grouplist = {}
   for _, g in pairs(sorted) do
      local names = g[2]
      local amount = -g[1]
      local namelist = {}
      for _, n in pairs(names) do
         local proto = prototypes.item[n]
         assert(proto, "Should have found item " .. n)
         table.insert(namelist, Localising.get_localised_name_with_fallback(proto))
      end

      table.insert(grouplist, { "fa.research-costs-items-entry", FaUtils.localise_cat_table(namelist, ", "), amount })
   end

   if not next(grouplist) then
      return { "fa.research-technology-costs-nothing" }
   else
      return { "fa.research-costs-items", FaUtils.localise_cat_table(grouplist, " and ") }
   end
end

---@param tech LuaTechnology
local function localise_research_requirements(tech)
   local trig_or_cost
   if tech.prototype.research_trigger then
      trig_or_cost = localise_trigger(tech, tech.prototype.research_trigger)
   elseif tech.prototype.research_unit_ingredients then
      trig_or_cost = localise_science_cost(tech)
   else
      trig_or_cost = { "fa.research-costs-nothing" }
   end

   if not next(tech.prerequisites) then return trig_or_cost end

   ---@type LocalisedString
   local prereqs = {}
   for k, v in pairs(tech.prerequisites) do
      table.insert(prereqs, v)
   end
   table.sort(prereqs, function(a, b)
      return a.name < b.name
   end)

   prereqs = FaUtils.localise_cat_table(TH.map(prereqs, tech_name_string), ", ")
   return FaUtils.spacecat(trig_or_cost, { "fa.research-needs-techs", prereqs })
end

local BONUSES_ARE_PERCENTS = TH.array_to_set({}, {
   "laboratory-speed",
   "worker-robot-speed",
   "ammo-damage",
   "gun-speed",
   "character-crafting-speed",
   "character-mining-speed",
   "character-running-speed",
   "worker-robot-battery",
   "laboratory-productivity",
   "artillery-range",
})

---@param player LuaPlayer
---@param tech LuaTechnology
local function localise_research_rewards(player, tech)
   local direct_unlocks = {}
   local indirect_unlock_count = 0
   local recipes = {}

   -- Figure out the technologies this technology unlocks, if it has not yet been researched.  If it has, then just
   -- leave these two parts out.
   if not tech.researched then
      -- Iterate over all successors. Check that 1, 2, or more predecessors are unlocked. If it's exactly one it must be
      -- us, otherwise it must be indirect. Stop after the second for performance.
      for _, candidate in pairs(tech.successors) do
         -- Skip hidden successors
         if not candidate.prototype.hidden then
            local locked = 0
            for name, pred in pairs(candidate.prerequisites) do
               if not pred.researched then
                  locked = locked + 1
                  if locked > 1 then break end
               end
            end

            if locked == 1 then
               -- If only one predecessor of this successor was locked, it's us and will unlock after this research.
               table.insert(direct_unlocks, candidate)
            elseif locked > 1 then
               indirect_unlock_count = indirect_unlock_count + 1
            end
         end
      end
   end

   local other_bonuses = {}

   -- Go over the rewards collecting them one by one. Carve out our special cases, otherwise fallb ack to Vanilla. TODO:
   -- we will need to carve out the space age bonuses. For now I have ignored them.
   for _, reward in pairs(tech.prototype.effects) do
      if reward.type == "gun-speed" then
         table.insert(other_bonuses, {
            "fa.research-reward-gun-speed",
            Localising.get_localised_name_with_fallback(prototypes.ammo_category[reward.ammo_category]),
            string.format("%2.d", reward.modifier * 100),
         })
      elseif reward.type == "gun-speed" then
         table.insert(other_bonuses, {
            "fa.research-reward-gun-damage",
            Localising.get_localised_name_with_fallback(prototypes.ammo_category[reward.ammo_category]),
            string.format("%2.d", reward.modifier * 100),
         })
      elseif reward.type == "turret-attack" then
         table.insert(other_bonuses, {
            "fa.research-reward-turret-attack",
            Localising.get_localised_name_with_fallback(prototypes.entity[reward.turret_id]),
            string.format("%2.d", reward.modifier * 100),
         })
      elseif reward.type == "give-item" then
         table.insert(other_bonuses, {
            "fa.research-reward-give-item",
            Localising.get_localised_name_with_fallback(prototypes.item[reward.item]),
            reward.count,
         })
      elseif reward.type == "nothing" then
         table.insert(
            other_bonuses,
            { "fa.research-reward-nothing", reward.effect_description or "NO DESCRIPTION AVAILABLE" }
         )
      elseif reward.type == "unlock-recipe" then
         table.insert(recipes, prototypes.recipe[reward.recipe])
      else
         -- It's something else, or that we don't know how to handle.
         local key = "fa.research-reward-vanilla-localised-bonus"
         local amount = tostring(reward.modifier)
         if BONUSES_ARE_PERCENTS[reward.type] then
            key = "fa.research-reward-vanilla-localised-bonus-percent"
            amount = string.format("%2.d", reward.modifier * 100)
         end
         -- This complicated string is saying try Vanilla to see if it's
         -- localised, otherwise directly say the raw type.
         table.insert(
            other_bonuses,
            { key, { "?", { string.format("gui-bonus.%s", reward.type) }, reward.type }, amount }
         )
      end
   end

   table.sort(recipes, function(a, b)
      return a.name < b.name
   end)
   table.sort(direct_unlocks, function(a, b)
      return a.name < b.name
   end)

   local result = {}

   -- This magic value is 0xffffffff e.g. UINT32_MAX, and is how Factorio is
   -- converting max levels to the runtime stage API for infinite technologies.
   if tech.prototype.max_level == 4294967295 then table.insert(result, { "fa.research-rewards-tech-infinite" }) end

   if next(recipes) then
      local recipe_string = FaUtils.localise_cat_table(
         TH.map(recipes, function(r)
            return Localising.get_localised_name_with_fallback(r)
         end),
         ", "
      )
      table.insert(result, { "fa.research-rewards-recipes", recipe_string })
   end

   TH.concat_arrays(result, other_bonuses)

   if next(direct_unlocks) then
      local unlocks_string = FaUtils.localise_cat_table(
         TH.map(direct_unlocks, function(t)
            return Localising.get_localised_name_with_fallback(t)
         end),
         ", "
      )
      table.insert(result, { "fa.research-rewards-next-researches", unlocks_string })
   end

   if indirect_unlock_count > 0 then
      table.insert(result, { "fa.research-rewards-other-researches", indirect_unlock_count })
   end

   return FaUtils.localise_cat_table(result)
end

---@class fa.research.ResearchEntry
---@field name string
---@field tech LuaTechnology
---@field list fa.research.ResearchList

-- Get an array of all visible technologies for this player, ordered by prototype name
-- and tagged with the category to which they belong.
---@param player LuaPlayer
---@return fa.research.ResearchEntry[]
local function get_visible_researches(player)
   ---@type fa.research.ResearchEntry[]
   local res = {}

   for name, tech in pairs(player.force.technologies) do
      -- Skip hidden technologies - they're not meant to be shown to players
      if tech.prototype.hidden then goto continue end

      local list

      if tech.researched then
         list = RESEARCH_LISTS.RESEARCHED
      else
         local all_unlocked = true

         for _, t in pairs(tech.prerequisites) do
            if not t.researched then
               all_unlocked = false
               break
            end
         end

         list = all_unlocked and RESEARCH_LISTS.RESEARCHABLE or RESEARCH_LISTS.LOCKED
      end

      table.insert(res, {
         name = name,
         tech = tech,
         list = list,
      })

      ::continue::
   end

   table.sort(res, function(a, b)
      return a.name < b.name
   end)

   return res
end

-- Given a position, normalize it to be on a technology in the given list: go down untiln one is found, otherwise go up.
-- This is needed to handle the case when the research lists are open as a technology changes states.  Returns whether
-- this was possible.  Or put another way, if this returns false then the focused list is empty.
---@param researches fa.research.ResearchEntry[]
---@param pos fa.research.ResearchMenuPosition
---@return boolean
local function normalize_pos(researches, pos)
   if pos.index < 1 then
      pos.index = 1
   elseif pos.index > #researches then
      pos.index = #researches
   end

   for direction = -1, 1, 2 do
      local endpoint = (direction == -1 and 1 or #researches)

      for i = pos.index, endpoint, direction do
         if researches[i].list == pos.focused_list then
            pos.index = i
            return true
         end
      end
   end

   return false
end

-- Find the next or previous index in an array of researches which is in the given list, direction, and starting index.
-- Does not return the starting index. Returns nil if there was nothing in the direction specified; throws an error if
-- the index is out of range.
---@param researches fa.research.ResearchEntry[]
---@param start_index number
---@param direction 1|-1
---@param list fa.research.ResearchList
---@return number?
local function find_index_relative(researches, start_index, direction, list)
   local len = #researches
   assert(start_index >= 1 and start_index <= len)
   local endpoint = direction == 1 and len or 1
   local startpoint = start_index + direction
   if startpoint > len then return nil end

   for i = startpoint, endpoint, direction do
      if researches[i].list == list then return i end
   end
end

-- Return a string to announce the research under the given pos, which must
-- already be in range.
---@param researches fa.research.ResearchEntry[]
---@param pos fa.research.ResearchMenuPosition
---@return LocalisedString
local function announce_under_pos(researches, pos)
   -- The point is e.g. "1 of 5" or more context at the top level or etc. This
   -- is basically a hook point whenever we want more complex logic.
   return tech_name_string(researches[pos.index].tech)
end

-- Implements a/d, left/right movement.
---@param player LuaPlayer
---@param direction -1|1
---@return LocalisedString, boolean
local function move_in_list_impl(player, direction)
   local researches = get_visible_researches(player)
   local pos = research_state[player.index].research_menu_pos

   if not normalize_pos(researches, pos) then return { "fa.research-list-no-technologies" }, false end

   local index = find_index_relative(researches, pos.index, direction, pos.focused_list)
   if index then pos.index = index end

   return announce_under_pos(researches, pos), index ~= nil
end

-- Switch pos between the given lists in-place in the given direction; 1 means
-- "down". Return false if hitting an edge, otherwise true.  Does not correct
-- the index.
---@param pos fa.research.ResearchMenuPosition
---@param direction 1|-1
---@return boolean
local function move_between_lists(pos, direction)
   local cur_ind = TH.find_index_of(RESEARCH_LIST_ORDER, pos.focused_list)
   assert(cur_ind)
   local new_ind = cur_ind + direction
   if new_ind < 1 or new_ind > #RESEARCH_LIST_ORDER then return false end
   pos.focused_list = RESEARCH_LIST_ORDER[new_ind]
   return true
end

-- Implements moving between lists.  Returns what to announce.  _impl being the
-- "this implements the keyboard" bit, though the naming isn't great.  The
-- second return value is whether an end was hit; if true, the parent needs to
-- play the edge sound.
---@param researches fa.research.ResearchEntry[]
---@param pos fa.research.ResearchMenuPosition
---@param direction 1|-1
---@return LocalisedString, boolean
local function move_between_lists_impl(researches, pos, direction)
   local moved = move_between_lists(pos, direction)
   if moved then pos.index = 1 end
   local normalized = normalize_pos(researches, pos)
   return {
      "fa.research-list-moved-up-down",
      { string.format("fa.research-list-%s", pos.focused_list) },
      normalized and announce_under_pos(researches, pos) or { "fa.research-list-no-technologies" },
   },
      moved
end

-- Starting at the given index and in the given direction, find the index of the
-- next research which would match the given menu search string. Return this
-- index or nil.
---@param pindex number
---@param researches fa.research.ResearchEntry[]
---@param start_index number
---@param direction -1|1
---@param pattern string
---@return number?
local function search_impl(pindex, researches, start_index, direction, pattern)
   pattern = pattern:lower()

   local len = #researches
   if start_index < 1 or start_index > len then return nil end

   -- The user needs a sensible idea of the list that matches theirs. To do
   -- this, instead of pulling out based off the flatr list, reorder the flat
   -- list sorted by category order, and remember the original index and name
   -- for each.  Then we can line up to get our search index, move in the
   -- specified direction from that, and map back when done.
   ---@type { tech: LuaTechnology, index: number, list: string }

   -- Shallow clone, also remember the original indices.
   local effective_researches = {}
   for k, v in pairs(researches) do
      effective_researches[k] = {
         tech = v.tech,
         list = v.list,
         index = k,
      }
   end

   Memosort.memosort(effective_researches, function(r)
      -- If we ever get more than 16777216 researches, this breaks.
      local ind = TH.find_index_of(RESEARCH_LIST_ORDER, r.list)
      assert(ind)
      return bit32.lshift(ind, 24) + r.index
   end)

   local start
   for i = 1, #effective_researches do
      if effective_researches[i].index == start_index then
         start = i
         break
      end
   end
   assert(start)
   start = start + direction

   local endpoint = direction == -1 and 1 or len
   for i = start, endpoint, direction do
      local name = Localising.get(effective_researches[i].tech, pindex)
      if name:lower():find(pattern, 1, true) then return effective_researches[i].index end
   end

   return nil
end

-- Finally: we may implement our key handlers.

function mod.menu_move_vertical(pindex, direction)
   local player = game.get_player(pindex)
   assert(player)
   local pos = research_state[pindex].research_menu_pos
   local announcing, moved = move_between_lists_impl(get_visible_researches(player), pos, direction)
   if not moved then
      player.play_sound({ path = "inventory-edge" })
   else
      player.play_sound({ path = "Inventory-Move" })
   end
   printout(announcing, pindex)
end

function mod.menu_move_horizontal(pindex, direction)
   local player = assert(game.get_player(pindex))
   local announcing, moved = move_in_list_impl(player, direction)
   if not moved then
      player.play_sound({ path = "inventory-edge" })
   else
      player.play_sound({ path = "Inventory-Move" })
   end
   printout(announcing, pindex)
end

function mod.menu_search(pindex, pattern, direction)
   local player = game.get_player(pindex)
   assert(player)
   local researches = get_visible_researches(player)
   local pos = research_state[player.index].research_menu_pos
   local n_ind = search_impl(pindex, researches, pos.index, direction, pattern)
   if not n_ind then
      player.play_sound({ path = "inventory-edge" })
      printout({ "fa.research-list-no-results", pattern }, pindex)
      return
   else
      pos.index = n_ind
      pos.focused_list = researches[n_ind].list
      player.play_sound({ path = "Inventory-Move" })
   end
   printout({
      "fa.research-list-moved-up-down",
      { string.format("fa.research-list-%s", pos.focused_list) },
      announce_under_pos(researches, pos),
   }, pindex)
end

function mod.menu_describe(pindex)
   local player = game.get_player(pindex)
   assert(player)
   local pos = research_state[pindex].research_menu_pos
   local researches = get_visible_researches(player)
   ---@type LocalisedString
   local announcing = { "fa.research-list-no-technologies" }
   local normed = normalize_pos(researches, pos)
   if normed then
      local tech = researches[pos.index].tech
      announcing =
         FaUtils.spacecat(tech_description_string(researches[pos.index].tech), localise_research_rewards(player, tech))
   end

   printout(announcing, pindex)
end

function mod.menu_describe_costs(pindex)
   local player = game.get_player(pindex)
   assert(player)
   local pos = research_state[pindex].research_menu_pos
   local researches = get_visible_researches(player)
   local normed = normalize_pos(researches, pos)

   ---@type LocalisedString
   local announcing = { "fa.research-list-no-technologies" }
   if normed then announcing = localise_research_requirements(researches[pos.index].tech) end

   printout(announcing, pindex)
end

function mod.menu_start_research(pindex)
   local player = game.get_player(pindex)
   assert(player)

   local pos = research_state[pindex].research_menu_pos
   local researches = get_visible_researches(player)
   local old_ind = pos.index
   if not normalize_pos(researches, pos) or old_ind ~= pos.index then
      printout({ "fa.research-list-changed" }, pindex)
      return
   end

   player.force.research_queue = {}
   local enqueued = mod.enqueue(player, researches[pos.index].name, 1)
   printout(FaUtils.spacecat({ "fa.research-queue-cleared" }, enqueued), pindex)
end

function mod.menu_enqueue(pindex, queue_index)
   local player = game.get_player(pindex)
   assert(player)
   local pos = research_state[pindex].research_menu_pos
   local old_ind = pos.index
   local researches = get_visible_researches(player)
   if not normalize_pos(researches, pos) or pos.index ~= old_ind then
      printout({ "fa.research-list-changed" }, pindex)
      return
   end

   printout(mod.enqueue(player, researches[pos.index].name, queue_index), pindex)
end

function mod.clear_queue(pindex)
   local player = game.get_player(pindex)
   assert(player)
   player.force.research_queue = {}
   printout({ "fa.research-queue-cleared" }, pindex)
end

function mod.queue_announce(pindex)
   local player = game.get_player(pindex)
   assert(player)
   local queue = player.force.research_queue
   if not next(queue) then
      printout({ "fa.research-queue-empty" }, pindex)
      return
   end

   local joining = {}
   for _, t in pairs(queue) do
      table.insert(joining, tech_name_string(t))
   end
   local joined = FaUtils.localise_cat_table(joining, ", ")

   printout({ "fa.research-queue-contains", joined }, pindex)
end

-- For when pressing `t`, the research part of the string. Sadly currently
-- special cased as a non-localised string, because it has to concatenate with
-- other stuff.
---@param pindex number
---@return string
function mod.get_progress_string(pindex)
   local player = game.get_player(pindex)
   assert(player)
   local tech = player.force.current_research
   if tech then
      local progress = player.force.research_progress
      return string.format("Researching %s, %d percent complete", Localising.get(tech, pindex), progress * 100)
   end

   return "No research in progress."
end

-- Called when the menu "gains focus".
function mod.menu_announce_entry(pindex)
   local player = game.get_player(pindex)
   assert(player)
   local pos = research_state[pindex].research_menu_pos
   local researches = get_visible_researches(player)
   local normed = normalize_pos(researches, pos)
   printout(
      FaUtils.spacecat(
         { "", { "fa.research-menu-title" }, "," },
         normed and announce_under_pos(researches, pos) or { "fa.research-list-no-technologiess" }
      ),
      pindex
   )
end

---@param event EventData.on_research_finished
function mod.on_research_finished(event)
   local tech = event.research
   local name_str = tech_name_string(tech)
   local recipes = {}

   for _, v in pairs(tech.prototype.effects) do
      if v.type == "unlock-recipe" then table.insert(recipes, v.recipe) end
   end

   local announcing = { "fa.research-finished-plain", name_str }
   if next(recipes) then
      local namified = TH.map(recipes, function(r)
         return Localising.get_localised_name_with_fallback(prototypes.recipe[r])
      end)

      local joined = FaUtils.localise_cat_table(namified, ", ")
      announcing = { "fa.research-finished-with-recipes", name_str, joined }
   end

   local force = tech.force
   local players = force.players
   for _, p in pairs(players) do
      printout(announcing, p.index)
   end
end

return mod
